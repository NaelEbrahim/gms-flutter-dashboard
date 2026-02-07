import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gms_flutter_windows/Bloc/Manager.dart';
import 'package:gms_flutter_windows/Bloc/States.dart';
import 'package:gms_flutter_windows/Shared/Constant.dart';

class PrivateCoaches extends StatefulWidget {
  const PrivateCoaches({super.key});

  @override
  State<PrivateCoaches> createState() => _PrivateCoachesState();
}

class _PrivateCoachesState extends State<PrivateCoaches>
    with SingleTickerProviderStateMixin {
  int? _selectedUserId;
  int? _selectedCoachId;
  int? _assignCoachId;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final manager = Manager.get(context);
    manager.getAllUsers().then((_) => manager.getCoaches());

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _selectedUserId = null;
          _selectedCoachId = null;
          _assignCoachId = null;
          manager.userPrivateCoaches.clear();
          manager.coachUsers.clear();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final manager = Manager.get(context);
    return Scaffold(
      backgroundColor: Constant.scaffoldColor,
      appBar: AppBar(
        backgroundColor: Colors.black54,
        foregroundColor: Colors.white,
        title: const Text(
          'Private Coaches',
          style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.teal,
          unselectedLabelColor: Colors.white70,
          labelColor: Colors.tealAccent,
          labelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          tabs: const [
            Tab(text: 'User Coaches'),
            Tab(text: 'Coach Users'),
          ],
        ),
      ),
      body: BlocConsumer<Manager, BlocStates>(
        listener: (_, _) {},
        builder: (context, state) {
          return ConditionalBuilder(
            condition: state is! LoadingState,
            fallback: (_) => const Center(child: CircularProgressIndicator()),
            builder: (_) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _userDropdown(manager),
                          const SizedBox(height: 16),
                          if (_selectedUserId == null)
                            _hint('Select a user to see coaches')
                          else ...[
                            _assignCoachSection(manager),
                            const SizedBox(height: 24),
                            _userPrivateCoachesList(manager),
                          ],
                        ],
                      ),
                    ),
                    SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _coachDropdown(manager),
                          const SizedBox(height: 16),
                          if (_selectedCoachId == null)
                            _hint('Select a coach to see assigned users')
                          else
                            _coachUsersList(manager),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Tab_1
  Widget _userDropdown(Manager manager) {
    return _card(
      DropdownButtonFormField<int>(
        initialValue: _selectedUserId,
        dropdownColor: Colors.black87,
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
        onChanged: (v) {
          setState(() {
            _selectedUserId = v;
            _assignCoachId = null;
          });
          if (v != null) manager.getUserCoaches(v);
        },
      ),
    );
  }

  Widget _assignCoachSection(Manager manager) {
    return _card(
      Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<int>(
              initialValue: _assignCoachId,
              dropdownColor: Colors.black87,
              decoration: _input('Assign New Coach'),
              items: manager.coaches.items.map((c) {
                return DropdownMenuItem<int>(
                  value: c.id,
                  child: Text(
                    '${c.firstName} ${c.lastName}',
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }).toList(),
              onChanged: (v) => setState(() => _assignCoachId = v),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            icon: const Icon(Icons.add, size: 20),
            label: const Text('Assign'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            ),
            onPressed: _assignCoachId == null
                ? null
                : () {
                    manager.assignCoachToUser({
                      'userId': _selectedUserId!,
                      'coachId': _assignCoachId!,
                    });
                    setState(() => _assignCoachId = null);
                  },
          ),
        ],
      ),
    );
  }

  Widget _userPrivateCoachesList(Manager manager) {
    if (manager.userPrivateCoaches.isEmpty) {
      return _hint('No private coaches assigned');
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: manager.userPrivateCoaches.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final item = manager.userPrivateCoaches[i];
        final coach = item.coach;
        return _card(
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(
                  coach.profileImagePath.toString(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${coach.firstName} ${coach.lastName}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Started: ${item.startedAt}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.isActive ? 'Active' : 'Inactive',
                      style: TextStyle(
                        fontSize: 12,
                        color: item.isActive ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
                onPressed: () {
                  manager.unAssignCoachFromUser({
                    'userId': _selectedUserId!,
                    'coachId': coach.id,
                  });
                },
                child: const Text(
                  'Unassign',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Tab_2
  Widget _coachDropdown(Manager manager) {
    return _card(
      DropdownButtonFormField<int>(
        initialValue: _selectedCoachId,
        dropdownColor: Colors.black87,
        decoration: _input('Select Coach'),
        items: manager.coaches.items.map((c) {
          return DropdownMenuItem<int>(
            value: c.id,
            child: Text(
              '${c.firstName} ${c.lastName}',
              style: const TextStyle(color: Colors.white),
            ),
          );
        }).toList(),
        onChanged: (v) {
          setState(() => _selectedCoachId = v);
          if (v != null) manager.getCoachUsers(v);
        },
      ),
    );
  }

  Widget _coachUsersList(Manager manager) {
    if (manager.coachUsers.isEmpty) return _hint('No users assigned');

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: manager.coachUsers.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final user = manager.coachUsers[i].coach;
        return _card(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              '${user.firstName} ${user.lastName}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }

  // Helpers
  Widget _card(Widget child) {
    return Container(
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      filled: true,
      fillColor: Colors.black45,
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
}
