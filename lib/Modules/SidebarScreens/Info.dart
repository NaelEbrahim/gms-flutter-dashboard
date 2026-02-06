import 'package:flutter/material.dart';
import 'package:gms_flutter_windows/Modules/AboutUs.dart';
import 'package:gms_flutter_windows/Modules/FAQ.dart';

class Info extends StatefulWidget {
  const Info({super.key});

  @override
  State<Info> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<Info> with SingleTickerProviderStateMixin {
  late TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Colors.grey[900],
          child: TabBar(
            controller: _controller,
            labelColor: Colors.teal,
            unselectedLabelColor: Colors.white,
            indicatorColor: Colors.teal,
            tabs: const [
              Tab(text: 'About Us'),
              Tab(text: 'FAQ'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _controller,
            children: const [
              AboutTab(),
              FaqTab(),
            ],
          ),
        ),
      ],
    );
  }
}
