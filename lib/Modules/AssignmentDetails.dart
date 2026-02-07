import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gms_flutter_windows/Bloc/Manager.dart';
import 'package:gms_flutter_windows/Bloc/States.dart';
import 'package:gms_flutter_windows/Shared/Components.dart';
import 'package:gms_flutter_windows/Shared/Constant.dart';

class AssignmentDetails extends StatefulWidget {
  final String type;
  final String title;

  const AssignmentDetails({super.key, required this.type, required this.title});

  @override
  State<AssignmentDetails> createState() => _AssignmentDetailsScreenState();
}

class _AssignmentDetailsScreenState extends State<AssignmentDetails>
    with TickerProviderStateMixin {
  int? selectedUserId;
  int? selectedTargetId;
  late TabController _tabController;
  final Map<String, List<String>> userAssignments = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final manager = Manager.get(context);

    manager.getAllUsers().then((_) {
      switch (widget.type) {
        case 'CLASS':
          manager.getClasses(0);
          break;
        case 'SESSION':
          manager.getSessions(0);
          break;
        case 'PROGRAM':
          manager.getPrograms(0);
          break;
        case 'DIET_PLAN':
          manager.getDietPlans(0);
          break;
      }
    });

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          selectedUserId = null;
          selectedTargetId = null;
          userAssignments.clear();
          if (manager.subscribersModel != null) {
            manager.subscribersModel!.subscribers.clear();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final manager = Manager.get(context);
    return BlocConsumer<Manager, BlocStates>(
      listener: (context, state) {
        if (state is ErrorState) {
          Components.showSnackBar(
            context,
            state.error.toString(),
            color: Colors.red,
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Constant.scaffoldColor,
          appBar: AppBar(
            backgroundColor: Colors.black54,
            foregroundColor: Colors.white,
            title: Text(
              '${widget.title} Assignments',
              style: const TextStyle(
                color: Colors.teal,
                fontWeight: FontWeight.bold,
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.tealAccent,
              labelStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelColor: Colors.white70,
              tabs: const [
                Tab(text: 'By Entity'),
                Tab(text: 'By User'),
              ],
            ),
          ),
          body: ConditionalBuilder(
            condition: state is! LoadingState,
            fallback: (_) => const Center(child: CircularProgressIndicator()),
            builder: (_) => TabBarView(
              controller: _tabController,
              children: [_byEntityTab(manager), _byUserTab(manager)],
            ),
          ),
        );
      },
    );
  }

  Widget _byEntityTab(Manager manager) {
    final items = _getAssignableItems(manager, widget.type);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _card(
            DropdownButtonFormField<int>(
              dropdownColor: Colors.black87,
              initialValue: selectedTargetId,
              decoration: _input('Select ${widget.type.toLowerCase()}'),
              items: items.map((item) {
                return DropdownMenuItem<int>(
                  value: item.id,
                  child: Text(
                    item.title,
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }).toList(),
              onChanged: (v) async {
                if (v == null) return;
                selectedTargetId = v;
                manager.subscribersModel = null;
                setState(() {});
                switch (widget.type) {
                  case 'CLASS':
                    await manager.getClassSubscribers(v);
                    break;
                  case 'SESSION':
                    await manager.getSessionSubscribers(v);
                    break;
                  case 'PROGRAM':
                    await manager.getProgramSubscribers(v);
                    break;
                  case 'DIET_PLAN':
                    await manager.getDietSubscribers(v);
                    break;
                }
                setState(() {});
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _card(
                  DropdownButtonFormField<int>(
                    dropdownColor: Colors.black87,
                    initialValue: selectedUserId,
                    decoration: _input('Select User'),
                    items: manager.allUsers.items.map((u) {
                      return DropdownMenuItem<int>(
                        value: u.id,
                        child: Text(
                          '${u.firstName} ${u.lastName}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
                    onChanged: (v) async {
                      if (v == null) return;
                      setState(() {
                        selectedUserId = v;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.add, color: Colors.white, size: 20),
                label: const Text(
                  'Assign',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: (selectedTargetId == null || selectedUserId == null)
                    ? null
                    : () {
                        switch (widget.type) {
                          case 'CLASS':
                            manager.assignUserToClass({
                              'classId': selectedTargetId!,
                              'userId': selectedUserId!,
                            });
                            break;
                          case 'PROGRAM':
                            manager.assignProgramToUser({
                              'programId': selectedTargetId!,
                              'userId': selectedUserId!,
                            });
                            break;
                          case 'SESSION':
                            manager.assignSessionToUser({
                              'sessionId': selectedTargetId!,
                              'userId': selectedUserId!,
                            });
                            break;
                          case 'DIET_PLAN':
                            manager.assignDietToUser({
                              'dietId': selectedTargetId!,
                              'userId': selectedUserId!,
                            });
                            break;
                        }
                      },
              ),
            ],
          ),
          const SizedBox(height: 24),
          selectedTargetId == null
              ? _hint(
                  'Please select ${widget.title.substring(0, widget.title.length - 1)}',
                )
              : manager.subscribersModel == null
              ? const Center(child: CircularProgressIndicator())
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: manager.subscribersModel!.subscribers.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final u = manager.subscribersModel!.subscribers[i];
                    final isActive =
                        manager.subscribersModel!.subscribersStatus[u.id
                            .toString()] ??
                        false;
                    return _card(
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        title: Text(
                          '${u.firstName} ${u.lastName}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          isActive ? 'Active' : 'Inactive',
                          style: TextStyle(
                            color: isActive ? Colors.teal : Colors.red,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.remove_circle,
                            color: Colors.red,
                          ),
                          onPressed: () async {
                            await Components.deleteDialog<Manager>(
                              context,
                              () async {
                                switch (widget.type) {
                                  case 'CLASS':
                                    manager.inActiveUserInClass({
                                      'userId': u.id,
                                      'classId': selectedTargetId!,
                                    });
                                    break;
                                  case 'PROGRAM':
                                    manager.unAssignProgramFromUser({
                                      'userId': u.id,
                                      'programId': selectedTargetId!,
                                    });
                                    break;
                                  case 'SESSION':
                                    manager.unAssignSessionFromUser({
                                      'userId': u.id,
                                      'sessionId': selectedTargetId!,
                                    });
                                    break;
                                  case 'DIET_PLAN':
                                    manager.unAssignDietFromUser({
                                      'userId': u.id,
                                      'dietId': selectedTargetId!,
                                    });
                                    break;
                                }
                              },
                              body: 'Remove assignment?',
                            );
                            setState(() {});
                          },
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _byUserTab(Manager manager) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _card(
            DropdownButtonFormField<int>(
              dropdownColor: Colors.black87,
              initialValue: selectedUserId,
              decoration: _input('Select User'),
              items: manager.allUsers.items.map((u) {
                return DropdownMenuItem<int>(
                  value: u.id,
                  child: Text(
                    '${u.firstName} ${u.lastName}',
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }).toList(),
              onChanged: (v) async {
                if (v == null) return;
                selectedUserId = v;
                userAssignments.clear();
                switch (widget.type) {
                  case 'CLASS':
                    userAssignments['Classes'] = await manager
                        .getAllClassesForUser(v);
                    break;
                  case 'SESSION':
                    userAssignments['Sessions'] = await manager
                        .getAllSessionsForUser(v);
                    break;
                  case 'PROGRAM':
                    userAssignments['Programs'] = await manager
                        .getAllProgramsForUser(v);
                    break;
                  case 'DIET_PLAN':
                    userAssignments['Diet Plans'] = await manager
                        .getAllDietsForUser(v);
                    break;
                }
                setState(() {});
              },
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: userAssignments.isEmpty
                ? _hint('Select user to view assignments')
                : ListView.separated(
                    itemCount: userAssignments.entries
                        .expand((e) => e.value)
                        .length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final allItems = userAssignments.entries
                          .expand((e) => e.value)
                          .toList();
                      return _card(
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            '${index + 1}. ${allItems[index]}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // Helpers
  Widget _card(Widget child) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(76),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  InputDecoration _input(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white24),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.tealAccent),
      ),
      filled: true,
      fillColor: Colors.black45,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }

  Widget _hint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(color: Colors.white60, fontSize: 14),
        ),
      ),
    );
  }

  List _getAssignableItems(Manager manager, String type) {
    switch (type) {
      case 'CLASS':
        return manager.classes.items;
      case 'SESSION':
        return manager.sessions.items;
      case 'PROGRAM':
        return manager.programs.items;
      case 'DIET_PLAN':
        return manager.dietPlans.items;
      default:
        return [];
    }
  }
}
