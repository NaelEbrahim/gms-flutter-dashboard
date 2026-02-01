import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gms_flutter_windows/Bloc/Manager.dart';
import 'package:gms_flutter_windows/Bloc/States.dart';
import 'package:gms_flutter_windows/Models/ProgramModel.dart';
import 'package:gms_flutter_windows/Models/WorkoutModel.dart';
import 'package:gms_flutter_windows/Shared/Components.dart';
import 'package:gms_flutter_windows/Shared/Constant.dart';

class Programs extends StatefulWidget {
  const Programs({super.key});

  @override
  State<Programs> createState() => _ProgramsState();
}

class _ProgramsState extends State<Programs> {
  int _pageIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  final availableDays = [
    'Day_1',
    'Day_2',
    'Day_3',
    'Day_4',
    'Day_5',
    'Day_6',
    'Day_7',
  ];
  List<String> programLevels = ['Beginner', 'Intermediate', 'Advanced'];

  List<ProgramModel> _filteredPrograms(List<ProgramModel> programs) {
    final search = _searchController.text.toLowerCase();
    return programs.where((program) {
      return program.name.toLowerCase().contains(search) ||
          program.level.toLowerCase().contains(search);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    Manager.get(context).getPrograms(_pageIndex);
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
    const horizontalPadding = 20.0;

    return BlocConsumer<Manager, BlocStates>(
      listener: (_, _) {},
      builder: (context, state) {
        final displayedPrograms = _filteredPrograms(manager.programs.items);
        return Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Components.reusableText(
                content: 'Programs',
                fontSize: 32,
                fontWeight: FontWeight.bold,
                fontColor: Colors.teal,
              ),
              const SizedBox(height: 16),
              _buildFilters(manager, displayedPrograms),
              const SizedBox(height: 24),
              ConditionalBuilder(
                condition: state is! LoadingState,
                builder: (_) => Flexible(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth:
                            Constant.screenWidth -
                            sidebarWidth -
                            horizontalPadding,
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
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
                              label: Center(child: Text('Level')),
                              headingRowAlignment: MainAxisAlignment.center,
                            ),
                            DataColumn(
                              label: Center(child: Text('Public')),
                              headingRowAlignment: MainAxisAlignment.center,
                            ),
                            DataColumn(
                              label: Center(child: Text('Workouts')),
                              headingRowAlignment: MainAxisAlignment.center,
                            ),
                            DataColumn(
                              label: Center(child: Text('Actions')),
                              headingRowAlignment: MainAxisAlignment.center,
                            ),
                          ],
                          rows: displayedPrograms.map((program) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  Center(
                                    child: Components.reusableText(
                                      content: program.name,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Center(
                                    child: Components.reusableText(
                                      content: program.level,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Center(
                                    child: Components.reusableText(
                                      content: program.isPublic ? 'Yes' : 'No',
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Center(
                                    child: ElevatedButton(
                                      onPressed: () => _showWorkoutsDialog(
                                        context,
                                        manager,
                                        program,
                                      ),
                                      child: const Text('View'),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        onPressed: () => _showProgramDialog(
                                          context,
                                          manager,
                                          program,
                                        ),
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.teal,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        onPressed: () {
                                          // TODO: delete program confirmation
                                        },
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
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

  Widget _buildFilters(Manager manager, List<ProgramModel> displayedPrograms) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: SizedBox(
            width: Constant.screenWidth / 4,
            child: Components.reusableTextFormField(
              hint: 'Search by title or level',
              prefixIcon: Icons.search,
              controller: _searchController,
              validator: (_) => null,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Components.reusablePagination(
          totalPages: manager.programs.totalPages,
          currentPage: manager.programs.currentPage,
          onPageChanged: (pageIndex) {
            _pageIndex = pageIndex;
            manager.getPrograms(_pageIndex);
          },
        ),
        const Spacer(),
        ElevatedButton.icon(
          onPressed: () => _showProgramDialog(context, manager),
          icon: const Icon(Icons.add),
          label: const Text('Create Program'),
        ),
        const SizedBox(width: 15.0),
        Components.reusableText(
          content: 'Total Programs: ${displayedPrograms.length}',
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ],
    );
  }

  void _showProgramDialog(
    BuildContext context,
    Manager manager, [
    ProgramModel? program,
  ]) {
    final isEdit = program != null;
    final titleCtrl = TextEditingController(text: program?.name ?? '');
    String? selectedLevel = program?.level;
    bool isPublic = program?.isPublic ?? true;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Components.reusableText(
            content: isEdit ? 'Edit Program' : 'Create Program',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontColor: Colors.teal,
          ),
          content: SizedBox(
            width: 350,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Components.reusableTextFormField(
                  hint: 'Title',
                  prefixIcon: Icons.title,
                  controller: titleCtrl,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: selectedLevel,
                  dropdownColor: Colors.grey[900],
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.trending_up),
                    labelText: 'Level',
                    fillColor: Colors.black54,
                    filled: true,
                    border: OutlineInputBorder(),
                  ),
                  items: programLevels
                      .map(
                        (level) => DropdownMenuItem<String>(
                          value: level,
                          child: Text(
                            level,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() => selectedLevel = value);
                  },
                ),
                const SizedBox(height: 10),
                SwitchListTile(
                  value: isPublic,
                  title: const Text(
                    'Public',
                    style: TextStyle(color: Colors.white),
                  ),
                  onChanged: (val) => setState(() => isPublic = val),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleCtrl.text.isEmpty || selectedLevel == null) return;
                if (isEdit) {
                  manager.updateProgram(
                    {
                      'title': titleCtrl.text,
                      'level': selectedLevel,
                      'isPublic': isPublic,
                    },
                    program.id,
                    _pageIndex,
                  );
                } else {
                  manager.createProgram({
                    'title': titleCtrl.text,
                    'level': selectedLevel,
                    'isPublic': isPublic,
                  });
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

  void _showWorkoutsDialog(
    BuildContext mainContext,
    Manager manager,
    ProgramModel program,
  ) {
    int? selectedWorkoutId;
    String? selectedDay;
    int sets = 1;
    int reps = 1;
    showDialog(
      context: mainContext,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Components.reusableText(
            content: 'Workouts - ${program.name}',
            fontColor: Colors.teal,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          content: SizedBox(
            width: 450,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Assign new workout
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        isExpanded: true,
                        dropdownColor: Colors.grey[850],
                        hint: const Text(
                          'Workout',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.white),
                        ),
                        items: manager.allWorkouts.items
                            .map(
                              (w) => DropdownMenuItem(
                                value: w.id,
                                child: Text(
                                  w.title,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => selectedWorkoutId = v),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        dropdownColor: Colors.grey[850],
                        hint: const Text(
                          'Day',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.white),
                        ),
                        items: availableDays
                            .map(
                              (d) => DropdownMenuItem(
                                value: d,
                                child: Text(
                                  d,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => selectedDay = v),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Sets - Reps - Add button
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _counter(
                      label: 'Sets',
                      value: sets,
                      onAdd: () => setState(() => sets++),
                      onRemove: () => setState(() => sets > 1 ? sets-- : sets),
                    ),
                    const SizedBox(width: 16),
                    _counter(
                      label: 'Reps',
                      value: reps,
                      onAdd: () => setState(() => reps++),
                      onRemove: () => setState(() => reps > 1 ? reps-- : reps),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(Icons.upload, color: Colors.teal),
                      onPressed: () {
                        if (selectedWorkoutId == null || selectedDay == null) {
                          return;
                        }
                        manager.assignWorkout({
                          'programId': program.id,
                          'workoutId': selectedWorkoutId,
                          'day': selectedDay,
                          'sets': sets,
                          'reps': reps,
                        });
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(color: Colors.grey, thickness: 1, height: 20),
                // Assigned workouts
                Expanded(
                  child: program.schedule.days.isEmpty
                      ? Components.reusableText(
                          content: 'No workouts assigned',
                          fontColor: Colors.white,
                        )
                      : ListView(
                          children: program.schedule.days.entries.map((
                            dayEntry,
                          ) {
                            final dayName = dayEntry.key;
                            final musclesMap = dayEntry.value;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Day header
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4.0,
                                  ),
                                  child: Components.reusableText(
                                    content: dayName,
                                    fontColor: Colors.teal,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                // Workouts for this day
                                ...musclesMap.entries.expand((muscleEntry) {
                                  return muscleEntry.value.map((workout) {
                                    return ListTile(
                                      title: Components.reusableText(
                                        content: workout.title,
                                      ),
                                      subtitle: Components.reusableText(
                                        content:
                                            'Sets: ${workout.sets}, Reps: ${workout.reps}',
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // Update
                                          IconButton(
                                            icon: const Icon(
                                              Icons.edit,
                                              color: Colors.teal,
                                            ),
                                            onPressed: () {
                                              _showUpdateWorkoutDialog(
                                                mainContext,
                                                manager,
                                                program.id,
                                                workout,
                                                dayName,
                                              );
                                            },
                                          ),
                                          // UN-ASSIGN
                                          IconButton(
                                            icon: const Icon(
                                              Icons.remove_circle,
                                              color: Colors.red,
                                            ),
                                            onPressed: () {
                                              Components.deleteDialog<Manager>(
                                                context,
                                                () async {
                                                  manager.unAssignWorkout({
                                                    'programId': program.id,
                                                    'workoutId': workout.id,
                                                    'day': dayName,
                                                  }, _pageIndex);
                                                },
                                                body: 'Un-assign this workout?',
                                              ).then((_) {
                                                Navigator.pop(mainContext);
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  });
                                }),
                              ],
                            );
                          }).toList(),
                        ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdateWorkoutDialog(
    BuildContext mainContext,
    Manager manager,
    int programId,
    WorkoutModel workout,
    String currentDay,
  ) {
    int sets = workout.sets ?? 1;
    int reps = workout.reps ?? 1;
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Components.reusableText(
            content: 'Update Workout',
            fontColor: Colors.teal,
            fontWeight: FontWeight.bold,
          ),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: currentDay,
                    dropdownColor: Colors.grey[850],
                    items: availableDays
                        .map(
                          (d) => DropdownMenuItem(
                            value: d,
                            child: Text(
                              d,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => currentDay = v!),
                  ),
                ),
                const SizedBox(height: 12),
                _counter(
                  label: 'Sets',
                  value: sets,
                  onAdd: () => setState(() => sets++),
                  onRemove: () => setState(() => sets > 1 ? sets-- : sets),
                ),
                const SizedBox(height: 12),
                _counter(
                  label: 'Reps',
                  value: reps,
                  onAdd: () => setState(() => reps++),
                  onRemove: () => setState(() => reps > 1 ? reps-- : reps),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                manager.updateAssignedWorkout({
                  'programId': programId,
                  'workoutId': workout.id,
                  'day': currentDay,
                  'sets': sets,
                  'reps': reps,
                }, _pageIndex);
                Navigator.pop(context);
                Navigator.pop(mainContext);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _counter({
    required String label,
    required int value,
    required VoidCallback onAdd,
    required VoidCallback onRemove,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white)),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove, color: Colors.red),
              onPressed: onRemove,
            ),
            Text(
              value.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add, color: Colors.teal),
              onPressed: onAdd,
            ),
          ],
        ),
      ],
    );
  }
}
