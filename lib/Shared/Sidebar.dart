import 'package:flutter/material.dart';
import 'package:gms_flutter_windows/Shared/Components.dart';
import 'package:gms_flutter_windows/Shared/Constant.dart';
import 'package:gms_flutter_windows/Shared/SecureStorage.dart';

class Sidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      {'icon': Icons.people, 'label': 'Users'},
      {'icon': Icons.fitness_center, 'label': 'Classes'},
      {'icon': Icons.newspaper, 'label': 'Programs'},
      {'icon': Icons.sports_gymnastics, 'label': 'Workouts'},
      {'icon': Icons.restaurant_outlined, 'label': 'DietPlans'},
      {'icon': Icons.schedule, 'label': 'Sessions'},
      {'icon': Icons.fastfood, 'label': 'Meals'},
      {'icon': Icons.assignment_turned_in_outlined, 'label': 'Assignments'},
      {'icon': Icons.event, 'label': 'Events'},
      {'icon': Icons.article, 'label': 'Articles'},
      {'icon': Icons.info, 'label': 'Info'},
    ];

    return Container(
      color: Colors.black,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          Image.asset('images/logo.png', height: 120),
          Components.reusableText(
            content: 'ShapeUp',
            fontWeight: FontWeight.bold,
            textAlign: TextAlign.center,
            fontSize: 25,
            fontColor: Colors.teal,
          ),
          const SizedBox(height: 10),
          FutureBuilder<String?>(
            future: TokenStorage.readFullName(),
            builder: (context, snapshot) {
              String displayName = snapshot.data ?? 'User';
              return Components.reusableText(content: 'Welcome $displayName');
            },
          ),
          const Divider(height: 16, thickness: 1, color: Colors.white),
          // menu items
          Flexible(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: SizedBox(
                width: Constant.screenWidth / 5,
                child: Column(
                  children: items.asMap().entries.map((entry) {
                    int index = entry.key;
                    var item = entry.value;
                    final selected = selectedIndex == index;
                    return InkWell(
                      onTap: () => onDestinationSelected(index),
                      child: Container(
                        width: double.infinity,
                        color: selected ? Colors.teal : Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          children: [
                            Container(
                              width: 4,
                              height: 40,
                              color: selected
                                  ? Colors.white
                                  : Colors.transparent,
                            ),
                            const SizedBox(width: 8),
                            Icon(item['icon'] as IconData, color: Colors.white),
                            const SizedBox(width: 16),
                            Flexible(
                              child: Text(
                                item['label'] as String,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: selected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
