import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gms_flutter_windows/Bloc/Manager.dart';
import 'package:gms_flutter_windows/Bloc/States.dart';
import 'package:gms_flutter_windows/Modules/SidebarScreens/Articles.dart';
import 'package:gms_flutter_windows/Modules/SidebarScreens/Assignments.dart';
import 'package:gms_flutter_windows/Modules/SidebarScreens/Classes.dart';
import 'package:gms_flutter_windows/Modules/SidebarScreens/DietPlans.dart';
import 'package:gms_flutter_windows/Modules/SidebarScreens/Events.dart';
import 'package:gms_flutter_windows/Modules/SidebarScreens/Info.dart';
import 'package:gms_flutter_windows/Modules/SidebarScreens/Meals.dart';
import 'package:gms_flutter_windows/Modules/SidebarScreens/Programs.dart';
import 'package:gms_flutter_windows/Modules/SidebarScreens/Sessions.dart';
import 'package:gms_flutter_windows/Modules/SidebarScreens/Subscriptions.dart';
import 'package:gms_flutter_windows/Modules/SidebarScreens/Users.dart';
import 'package:gms_flutter_windows/Modules/SidebarScreens/Workouts.dart';
import 'package:gms_flutter_windows/Shared/Components.dart';
import 'package:gms_flutter_windows/Shared/Constant.dart';
import 'package:gms_flutter_windows/Shared/Sidebar.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const Users(),
    const Classes(),
    const Programs(),
    const Workouts(),
    const DietPlans(),
    const Sessions(),
    const Meals(),
    const Assignments(),
    const Subscriptions(),
    const Events(),
    const Articles(),
    const Info(),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constant.scaffoldColor,
      body: BlocConsumer<Manager, BlocStates>(
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
          return Row(
            children: [
              // Sidebar
              Container(
                width: Constant.screenWidth / 5,
                color: Colors.teal,
                child: Sidebar(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (index) {
                    setState(() => _selectedIndex = index);
                  },
                ),
              ),
              // Main Content
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  color: Constant.scaffoldColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () {
                          Manager.get(context).logout();
                        },
                        icon: Icon(Icons.logout, color: Colors.white),
                        label: Text(
                          'Logout',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      Expanded(child: _screens[_selectedIndex]),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
