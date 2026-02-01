import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:gms_flutter_windows/Bloc/Manager.dart';
import 'package:gms_flutter_windows/Bloc/States.dart';
import 'package:gms_flutter_windows/Models/WorkoutModel.dart';
import 'package:gms_flutter_windows/Shared/Components.dart';
import 'package:gms_flutter_windows/Shared/Constant.dart';

class Workouts extends StatefulWidget {
  const Workouts({super.key});

  @override
  State<Workouts> createState() => _WorkoutsState();
}

class _WorkoutsState extends State<Workouts> {
  int _pageIndex = 0;
  String _muscleFilter = 'All';
  final TextEditingController _searchController = TextEditingController();

  final muscles = [
    'All',
    'Chest',
    'Back',
    'Shoulders',
    'Biceps',
    'Triceps',
    'Forearms',
    'Abs',
    'Glutes',
    'Quadriceps',
    'Hamstrings',
    'Calves',
  ];

  List<WorkoutModel> _filteredWorkouts(GetWorkoutsModel workouts) {
    final search = _searchController.text.toLowerCase();
    return workouts.items.where((w) {
      final matchesSearch =
          search.isEmpty || w.title.toLowerCase().contains(search);
      final matchesMuscle =
          _muscleFilter == 'All' || w.primaryMuscle == _muscleFilter;
      return matchesSearch && matchesMuscle;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    Manager.get(context).getWorkouts(_pageIndex, _muscleFilter);
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final manager = Manager.get(context);
    final sidebarWidth = Constant.screenWidth / 5;

    return BlocConsumer<Manager, BlocStates>(
      listener: (_, _) {},
      builder: (context, state) {
        final displayedWorkouts = _filteredWorkouts(manager.workouts);
        return Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Components.reusableText(
                content: 'Workouts',
                fontSize: 32,
                fontWeight: FontWeight.bold,
                fontColor: Colors.teal,
              ),
              const SizedBox(height: 16),
              _buildMuscleTabs(manager),
              const SizedBox(height: 16),
              _buildSearchBar(manager, displayedWorkouts),
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
                              label: Center(child: Text('Primary Muscle')),
                              headingRowAlignment: MainAxisAlignment.center,
                            ),
                            DataColumn(
                              label: Center(child: Text('Secondary Muscle')),
                              headingRowAlignment: MainAxisAlignment.center,
                            ),
                            DataColumn(
                              label: Center(child: Text('Avg Calories')),
                              headingRowAlignment: MainAxisAlignment.center,
                            ),
                            DataColumn(
                              label: Center(child: Text('Actions')),
                              headingRowAlignment: MainAxisAlignment.center,
                            ),
                          ],
                          rows: displayedWorkouts.map((w) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  Center(
                                    child: Text(
                                      w.title.length > 30
                                          ? '${w.title.substring(0, 30)}...'
                                          : w.title,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ),
                                DataCell(Center(child: Text(w.primaryMuscle))),
                                DataCell(
                                  Center(
                                    child: Text(w.secondaryMuscles ?? "-"),
                                  ),
                                ),
                                DataCell(
                                  Center(
                                    child: Text(
                                      w.baseAvgCalories.toStringAsFixed(1),
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
                                          onPressed: () => _showWorkoutDialog(
                                            context,
                                            manager,
                                            w,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          onPressed: () {
                                            // TODO delete
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

  Widget _buildMuscleTabs(Manager manager) {
    return SizedBox(
      height: 45,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: muscles.map((m) {
          final active = _muscleFilter == m;
          return InkWell(
            onTap: () {
              setState(() => _muscleFilter = m);
              _pageIndex = 0;
              manager.getWorkouts(_pageIndex, m);
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: active ? Colors.teal : Colors.grey[800],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Components.reusableText(
                content: m,
                fontColor: active ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSearchBar(
    Manager manager,
    List<WorkoutModel> displayedWorkouts,
  ) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: SizedBox(
            width: 300,
            child: Components.reusableTextFormField(
              hint: 'Search by title',
              prefixIcon: Icons.search,
              validator: (_) => null,
              controller: _searchController,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Components.reusablePagination(
          totalPages: manager.workouts.totalPages,
          currentPage: manager.workouts.currentPage,
          onPageChanged: (pageIndex) {
            _pageIndex = pageIndex;
            manager.getWorkouts(pageIndex, _muscleFilter);
          },
        ),
        const Spacer(),
        ElevatedButton.icon(
          onPressed: () => _showWorkoutDialog(context, manager),
          icon: const Icon(Icons.add),
          label: const Text('Create Workout'),
        ),
        const SizedBox(width: 16),
        Components.reusableText(
          content: 'Total Workouts: ${displayedWorkouts.length}',
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ],
    );
  }

  void _showWorkoutDialog(
    BuildContext context,
    Manager manager, [
    WorkoutModel? workout,
  ]) {
    final isEdit = workout != null;

    final titleCtrl = TextEditingController(text: workout?.title ?? '');
    final descCtrl = TextEditingController(text: workout?.description ?? '');
    final avgCaloriesCtrl = TextEditingController(
      text: workout?.baseAvgCalories.toString() ?? '',
    );

    String? primaryMuscle = workout?.primaryMuscle;
    String? secondaryMuscle = workout?.secondaryMuscles;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Components.reusableText(
            content: isEdit ? 'Edit Workout' : 'Create Workout',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontColor: Colors.teal,
          ),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Components.reusableTextFormField(
                    hint: 'Title',
                    prefixIcon: Icons.fitness_center,
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
                  // Primary muscle
                  DropdownButtonFormField<String>(
                    initialValue: primaryMuscle,
                    dropdownColor: Colors.grey[900],
                    decoration: const InputDecoration(
                      label: Text(
                        'Primary Muscle',
                        style: TextStyle(color: Colors.white),
                      ),
                      prefixIcon: Icon(
                        Icons.accessibility,
                        color: Colors.white,
                      ),
                    ),
                    items: muscles
                        .map(
                          (m) => DropdownMenuItem(
                            value: m,
                            child: Text(
                              m,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => primaryMuscle = v),
                  ),
                  const SizedBox(height: 10),
                  // Secondary muscle
                  DropdownButtonFormField<String>(
                    initialValue: secondaryMuscle,
                    dropdownColor: Colors.grey[900],
                    decoration: const InputDecoration(
                      label: Text(
                        'Secondary Muscle (optional)',
                        style: TextStyle(color: Colors.white),
                      ),
                      prefixIcon: Icon(
                        Icons.accessibility_new,
                        color: Colors.white,
                      ),
                    ),
                    items: muscles
                        .where((m) => m != primaryMuscle)
                        .map(
                          (m) => DropdownMenuItem(
                            value: m,
                            child: Text(
                              m,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => secondaryMuscle = v),
                  ),
                  const SizedBox(height: 10),
                  Components.reusableTextFormField(
                    hint: 'Avg Calories',
                    prefixIcon: Icons.local_fire_department,
                    controller: avgCaloriesCtrl,
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
                if (titleCtrl.text.isEmpty ||
                    primaryMuscle == null ||
                    avgCaloriesCtrl.text.isEmpty) {
                  return;
                }
                final data = FormData.fromMap({
                  'title': titleCtrl.text,
                  'description': descCtrl.text,
                  'primaryMuscle': primaryMuscle,
                  'secondaryMuscle': secondaryMuscle,
                  'avgCalories': double.parse(avgCaloriesCtrl.text),
                });
                if (isEdit) {
                  manager.updateWorkout(data, workout.id,_pageIndex,_muscleFilter);
                } else {
                  manager.createWorkout(data);
                }
                Navigator.pop(context);
              },
              child: Text(isEdit ? 'Save' : 'Create'),
            ),
          ],
        ),
      ),
    );
  }
}
