import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gms_flutter_windows/Bloc/Manager.dart';
import 'package:gms_flutter_windows/Bloc/States.dart';
import 'package:gms_flutter_windows/Modules/SidebarScreens/Articles.dart';
import 'package:gms_flutter_windows/Modules/SidebarScreens/Classes.dart';
import 'package:gms_flutter_windows/Modules/SidebarScreens/Events.dart';
import 'package:gms_flutter_windows/Modules/SidebarScreens/Programs.dart';
import 'package:gms_flutter_windows/Modules/SidebarScreens/Sessions.dart';
import 'package:gms_flutter_windows/Modules/SidebarScreens/Users.dart';
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
    Sessions(),
    Events(),
    Articles()
  ];

  @override
  void initState() {
    super.initState();
    Manager.get(context).getCoaches();
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
              /// Sidebar
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
              /// Main Content
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  color: Constant.scaffoldColor,
                  child: _screens[_selectedIndex],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
