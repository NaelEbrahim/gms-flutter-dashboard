import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:gms_flutter_windows/Bloc/Manager.dart';
import 'package:gms_flutter_windows/Bloc/States.dart';
import 'package:gms_flutter_windows/Models/MealModel.dart';
import 'package:gms_flutter_windows/Shared/Components.dart';
import 'package:gms_flutter_windows/Shared/Constant.dart';

class Meals extends StatefulWidget {
  const Meals({super.key});

  @override
  State<Meals> createState() => _MealsState();
}

class _MealsState extends State<Meals> {
  int _pageIndex = 0;
  late Manager manager;
  final TextEditingController _searchController = TextEditingController();

  List<MealModel> _filteredMeals(GetMealsModel meals) {
    final search = _searchController.text.toLowerCase();
    return meals.meals.where((m) {
      return search.isEmpty || m.title.toLowerCase().contains(search);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    manager = Manager.get(context);
    manager.getMeals(_pageIndex);
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    manager.meals.meals.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final manager = Manager.get(context);
    final sidebarWidth = Constant.screenWidth / 5;

    return BlocConsumer<Manager, BlocStates>(
      listener: (_, _) {},
      builder: (context, state) {
        final displayedMeals = _filteredMeals(manager.meals);

        return Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Components.reusableText(
                content: 'Meals',
                fontSize: 32,
                fontWeight: FontWeight.bold,
                fontColor: Colors.teal,
              ),
              const SizedBox(height: 16),
              _buildSearchBar(manager, displayedMeals),
              const SizedBox(height: 24),
              ConditionalBuilder(
                condition: state is! LoadingState,
                builder: (_) => Flexible(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: Constant.screenWidth - sidebarWidth - 20,
                      ),
                      child: SingleChildScrollView(
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.all(
                            Colors.grey[800],
                          ),
                          dataRowColor: WidgetStateProperty.all(
                            Colors.grey[850],
                          ),
                          headingTextStyle: const TextStyle(
                            color: Colors.teal,
                            fontWeight: FontWeight.bold,
                          ),
                          dataTextStyle: const TextStyle(color: Colors.white),
                          columns: const [
                            DataColumn(
                              label: Center(child: Text('Title')),
                              headingRowAlignment: MainAxisAlignment.center,
                            ),
                            DataColumn(
                              label: Center(child: Text('Description')),
                              headingRowAlignment: MainAxisAlignment.center,
                            ),
                            DataColumn(
                              label: Center(child: Text('Avg Calories')),
                              headingRowAlignment: MainAxisAlignment.center,
                            ),
                            DataColumn(
                              label: Center(child: Text('Image')),
                              headingRowAlignment: MainAxisAlignment.center,
                            ),
                            DataColumn(
                              label: Center(child: Text('Actions')),
                              headingRowAlignment: MainAxisAlignment.center,
                            ),
                          ],
                          rows: displayedMeals.map((m) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  Center(
                                    child: Text(
                                      m.title.length > 30
                                          ? '${m.title.substring(0, 30)}...'
                                          : m.title,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Center(
                                    child: Text(
                                      m.description.length > 30
                                          ? '${m.description.substring(0, 30)}...'
                                          : m.description,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Center(
                                    child: Text(
                                      m.baseCalories.toStringAsFixed(1),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Center(
                                    child: ElevatedButton(
                                      onPressed: () =>
                                          Components.reusableImageViewerDialog(
                                            context: context,
                                            title: 'Meal Image',
                                            imageUrl: m.imagePath,
                                            onUpdate: (data) async {
                                              await manager.updateMealImage(
                                                FormData.fromMap({
                                                  'id': m.id,
                                                  'image': data,
                                                }),
                                                _pageIndex,
                                              );
                                            },
                                          ),
                                      child: const Text('View'),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.edit,
                                            color: Colors.teal,
                                          ),
                                          onPressed: () => _showMealDialog(
                                            context,
                                            manager,
                                            m,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          onPressed: () {
                                            // TODO delete meal
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
                fallback: (_) =>
                    const Center(child: CircularProgressIndicator()),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(Manager manager, List<MealModel> displayedMeals) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Components.reusableTextFormField(
            hint: 'Search by title',
            prefixIcon: Icons.search,
            validator: (_) => null,
            controller: _searchController,
          ),
        ),
        const SizedBox(width: 16),
        Components.reusablePagination(
          totalPages: manager.meals.totalPages,
          currentPage: manager.meals.currentPage,
          onPageChanged: (pageIndex) {
            _pageIndex = pageIndex;
            manager.getMeals(pageIndex);
          },
        ),
        const Spacer(),
        ElevatedButton.icon(
          onPressed: () => _showMealDialog(context, manager),
          icon: const Icon(Icons.add),
          label: const Text('Create Meal'),
        ),
        const SizedBox(width: 16),
        Components.reusableText(
          content: 'Total Meals: ${displayedMeals.length}',
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ],
    );
  }

  void _showMealDialog(
    BuildContext context,
    Manager manager, [
    MealModel? meal,
  ]) {
    final isEdit = meal != null;

    final titleCtrl = TextEditingController(text: meal?.title ?? '');
    final descCtrl = TextEditingController(text: meal?.description ?? '');
    final caloriesCtrl = TextEditingController(
      text: meal?.baseCalories.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Components.reusableText(
          content: isEdit ? 'Edit Meal' : 'Create Meal',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontColor: Colors.teal,
        ),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Components.reusableTextFormField(
                  hint: 'Title',
                  prefixIcon: Icons.restaurant,
                  controller: titleCtrl,
                ),
                const SizedBox(height: 10),
                Components.reusableTextFormField(
                  hint: 'Description',
                  prefixIcon: Icons.description,
                  controller: descCtrl,
                  maxLines: 4,
                ),
                const SizedBox(height: 10),
                Components.reusableTextFormField(
                  hint: 'Base Calories',
                  prefixIcon: Icons.local_fire_department,
                  controller: caloriesCtrl,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleCtrl.text.isEmpty || caloriesCtrl.text.isEmpty) {
                return;
              }
              final data = FormData.fromMap({
                'title': titleCtrl.text,
                'description': descCtrl.text,
                'calories': double.parse(caloriesCtrl.text),
              });

              if (isEdit) {
                manager.updateMeal(data, meal.id, _pageIndex);
              } else {
                manager.createMeal(data);
              }

              Navigator.pop(context);
            },
            child: Text(isEdit ? 'Save' : 'Create'),
          ),
        ],
      ),
    );
  }
}
