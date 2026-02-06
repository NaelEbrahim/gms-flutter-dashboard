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
    Manager manager = Manager.get(context);
    manager.getAllUsers();
    switch (widget.type) {
      case 'CLASS':
        {
          manager.getClasses(0);
          break;
        }
      case 'SESSION':
        {
          manager.getSessions(0);
          break;
        }
      case 'PROGRAM':
        {
          manager.getPrograms(0);
          break;
        }
      case 'DIET_PLAN':
        {
          manager.getDietPlans(0);
          break;
        }
    }
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          selectedTargetId = null;
          selectedUserId = null;
          if (Manager.get(context).subscribersModel != null) {
            Manager.get(context).subscribersModel!.subscribers.clear();
          }
          userAssignments.clear();
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
              style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
            ),
            bottom: TabBar(
              controller: _tabController,
              labelStyle: TextStyle(
                color: Colors.teal,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelColor: Colors.white,
              tabs: const [
                Tab(text: 'By Entity'),
                Tab(text: 'By User'),
              ],
            ),
          ),
          body: ConditionalBuilder(
            condition: state is! LoadingState,
            builder: (context) => TabBarView(
              controller: _tabController,
              children: [_byEntityTab(manager), _byUserTab(manager)],
            ),
            fallback: (context) =>
                Center(child: const CircularProgressIndicator()),
          ),
        );
      },
    );
  }

  Widget _byEntityTab(Manager manager) {
    final items = _getAssignableItems(manager, widget.type);
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          DropdownButtonFormField<int>(
            dropdownColor: Colors.grey[850],
            hint: Text(
              'Select ${widget.type.toLowerCase()}',
              style: const TextStyle(color: Colors.white),
            ),
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
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  dropdownColor: Colors.grey[850],
                  hint: const Text(
                    'User',
                    style: TextStyle(color: Colors.white),
                  ),
                  items: manager.allUsers.items.map((u) {
                    return DropdownMenuItem<int>(
                      value: u.id,
                      child: Text(
                        '${u.firstName} ${u.lastName}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => selectedUserId = v),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.add_circle, color: Colors.teal),
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
          const SizedBox(height: 16),
          Expanded(
            child: selectedTargetId == null
                ? Center(
                    child: Components.reusableText(
                      content:
                          'Please select ${widget.title.substring(0, widget.title.length - 1)}',
                    ),
                  )
                : manager.subscribersModel == null
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    children: manager.subscribersModel!.subscribers.map((u) {
                      final isActive =
                          manager.subscribersModel!.subscribersStatus[u.id
                              .toString()] ??
                          false;
                      return ListTile(
                        title: Components.reusableText(
                          content: '${u.firstName} ${u.lastName}',
                        ),
                        subtitle: Components.reusableText(
                          content: isActive ? 'Active' : 'Inactive',
                          fontSize: 12,
                          fontColor: isActive ? Colors.teal : Colors.red,
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
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _byUserTab(Manager manager) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              DropdownButtonFormField<int>(
                dropdownColor: Colors.grey[850],
                hint: const Text(
                  'Select User',
                  style: TextStyle(color: Colors.white),
                ),
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
                  userAssignments.clear();
                  switch (widget.type) {
                    case 'CLASS':
                      {
                        userAssignments['Classes'] = await manager
                            .getAllClassesForUser(v);
                        break;
                      }
                    case 'SESSION':
                      {
                        userAssignments['Sessions'] = await manager
                            .getAllSessionsForUser(v);
                        break;
                      }
                    case 'PROGRAM':
                      {
                        userAssignments['Programs'] = await manager
                            .getAllProgramsForUser(v);
                        break;
                      }
                    case 'DIET_PLAN':
                      {
                        userAssignments['Diet Plans'] = await manager
                            .getAllDietsForUser(v);
                        break;
                      }
                  }
                  setState(() {});
                },
              ),
              const SizedBox(height: 16),
              Expanded(
                child: userAssignments.isEmpty
                    ? Center(
                        child: Components.reusableText(
                          content: 'Select user to view assignments',
                        ),
                      )
                    : ListView(
                        children: userAssignments.entries
                            .expand((e) => e.value)
                            .toList()
                            .asMap()
                            .entries
                            .map(
                              (entry) => ListTile(
                                title: Components.reusableText(
                                  content: '${entry.key + 1}. ${entry.value}',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                            .toList(),
                      ),
              ),
            ],
          ),
        );
      },
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
