import 'package:flutter/material.dart';
import 'package:gms_flutter_windows/Modules/AssignmentDetails.dart';
import 'package:gms_flutter_windows/Modules/PrivateCoaches.dart';
import 'package:gms_flutter_windows/Shared/Components.dart';

class Assignments extends StatelessWidget {
  const Assignments({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      {'title': 'Classes', 'icon': Icons.fitness_center, 'type': 'CLASS'},
      {'title': 'Sessions', 'icon': Icons.schedule, 'type': 'SESSION'},
      {'title': 'Programs', 'icon': Icons.newspaper, 'type': 'PROGRAM'},
      {'title': 'Diet Plans', 'icon': Icons.restaurant, 'type': 'DIET_PLAN'},
      {
        'title': 'Private Coaches',
        'icon': Icons.sports_kabaddi_outlined,
        'type': 'PRIVATE_COACHES',
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Components.reusableText(
            content: 'Assignments',
            fontSize: 32,
            fontWeight: FontWeight.bold,
            fontColor: Colors.teal,
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 15,
              childAspectRatio: 2.8,
              children: items.map((item) {
                return InkWell(
                  onTap: () {
                    (item['type'] == 'PRIVATE_COACHES')
                        ? Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => PrivateCoaches()),
                          )
                        : Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AssignmentDetails(
                                type: item['type'].toString(),
                                title: item['title'].toString(),
                              ),
                            ),
                          );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Card(
                    color: Colors.grey[850],
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Icon(
                            item['icon'] as IconData,
                            size: 64,
                            color: Colors.teal,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Flexible(
                          child: Components.reusableText(
                            content: item['title'].toString(),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
