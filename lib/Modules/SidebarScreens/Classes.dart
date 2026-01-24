import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gms_flutter_windows/Bloc/Manager.dart';
import 'package:gms_flutter_windows/Bloc/States.dart';
import 'package:gms_flutter_windows/Models/ClassModel.dart';
import 'package:gms_flutter_windows/Shared/Components.dart';
import 'package:gms_flutter_windows/Shared/Constant.dart';

class Classes extends StatefulWidget {
  const Classes({super.key});

  @override
  State<Classes> createState() => _ClassesState();
}

class _ClassesState extends State<Classes> {
  final TextEditingController _searchController = TextEditingController();
  int _pageIndex = 0;

  List<ClassModel> _filteredClasses(List<ClassModel> allClasses) {
    final search = _searchController.text.toLowerCase();
    return allClasses.where((cls) {
      return cls.name.toLowerCase().contains(search) ||
          cls.coach.firstName.toLowerCase().contains(search);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    final manager = Manager.get(context);
    manager.getClasses(_pageIndex);
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
        final displayedClasses = _filteredClasses(manager.classes.items);
        return Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Components.reusableText(
                content: 'Classes',
                fontSize: 32,
                fontWeight: FontWeight.bold,
                fontColor: Colors.teal,
              ),
              const SizedBox(height: 16),
              _buildFilters(manager, displayedClasses),
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
                              label: Center(child: Text('Price / Month')),
                              headingRowAlignment: MainAxisAlignment.center,
                            ),
                            DataColumn(
                              label: Center(child: Text('Coach')),
                              headingRowAlignment: MainAxisAlignment.center,
                            ),
                            DataColumn(
                              label: Center(child: Text('Programs')),
                              headingRowAlignment: MainAxisAlignment.center,
                            ),
                            DataColumn(
                              label: Center(child: Text('Actions')),
                              headingRowAlignment: MainAxisAlignment.center,
                            ),
                          ],
                          rows: displayedClasses.map((cls) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  Center(
                                    child: Components.reusableText(
                                      content: cls.name,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Center(
                                    child: Components.reusableText(
                                      content: '\$${cls.price}',
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Center(
                                    child: Components.reusableText(
                                      content:
                                          '${cls.coach.firstName} ${cls.coach.lastName}',
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Center(
                                    child: ElevatedButton(
                                      onPressed: () => _showProgramsDialog(
                                        context,
                                        manager,
                                        cls,
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
                                        onPressed: () => _showClassDialog(
                                          context,
                                          manager,
                                          cls,
                                        ),
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.teal,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        onPressed: () {
                                          // TODO: delete class confirmation
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

  Widget _buildFilters(Manager manager, List<ClassModel> displayedClasses) {
    return Row(
      children: [
        SizedBox(
          width: Constant.screenWidth / 4,
          child: Components.reusableTextFormField(
            hint: 'Search by title or coach',
            prefixIcon: Icons.search,
            controller: _searchController,
            validator: (_) => null,
          ),
        ),
        const SizedBox(width: 12),
        Components.reusablePagination(
          totalPages: manager.classes.totalPages,
          currentPage: manager.classes.currentPage,
          onPageChanged: (pageIndex) {
            _pageIndex = pageIndex;
            manager.getClasses(_pageIndex);
          },
        ),
        const SizedBox(width: 12),
        const Spacer(),
        ElevatedButton.icon(
          onPressed: () => _showClassDialog(context, manager),
          icon: const Icon(Icons.add),
          label: const Text('Create Class'),
        ),
        const SizedBox(width: 15.0),
        Components.reusableText(
          content: 'Total Classes: ${displayedClasses.length}',
          fontWeight: FontWeight.bold,
        ),
      ],
    );
  }

  void _showClassDialog(
    BuildContext context,
    Manager manager, [
    ClassModel? cls,
  ]) {
    final isEdit = cls != null;
    final titleCtrl = TextEditingController(text: cls?.name ?? '');
    final descriptionCtrl = TextEditingController(text: cls?.description ?? '');
    final priceCtrl = TextEditingController(text: cls?.price.toString() ?? '');
    int? selectedCoachId = cls?.coach.id;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Components.reusableText(
            content: isEdit ? 'Edit Class' : 'Create Class',
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
                Components.reusableTextFormField(
                  hint: 'Price / Month',
                  prefixIcon: Icons.attach_money,
                  controller: priceCtrl,
                ),
                const SizedBox(height: 10),
                Components.reusableTextFormField(
                  hint: 'Description',
                  prefixIcon: Icons.description_outlined,
                  controller: descriptionCtrl,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<int>(
                  initialValue: selectedCoachId,
                  dropdownColor: Colors.grey[900],
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.person),
                    labelText: 'Audit Coach',
                    fillColor: Colors.black54,
                    filled: true,
                    border: OutlineInputBorder(),
                  ),
                  items: manager.coaches.items.map((coach) {
                    return DropdownMenuItem<int>(
                      value: coach.id,
                      child: Text(
                        '${coach.firstName} ${coach.lastName}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => selectedCoachId = value);
                  },
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
                if (titleCtrl.text.isEmpty ||
                    priceCtrl.text.isEmpty ||
                    selectedCoachId == null) {
                  return;
                }
                if (isEdit) {
                  manager.updateClass(
                    {
                      'name': titleCtrl.text,
                      'description': descriptionCtrl.text,
                      'price': priceCtrl.text,
                      'coachId': selectedCoachId,
                    },
                    cls.id,
                    _pageIndex,
                  );
                } else {
                  manager.createClass(
                    FormData.fromMap({
                      'coachId': selectedCoachId,
                      'name': titleCtrl.text,
                      'description': descriptionCtrl.text,
                      'price': priceCtrl.text,
                    }),
                  );
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

  void _showProgramsDialog(
      BuildContext mainContext,
      Manager manager,
      ClassModel cls,
      ) {
    int? selectedProgramId;
    showDialog(
      context: mainContext,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Components.reusableText(
            content: 'Programs - ${cls.name}',
            fontColor: Colors.teal,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          content: SizedBox(
            width: Constant.screenWidth / 4,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: selectedProgramId,
                        dropdownColor: Colors.grey[850],
                        hint: const Text(
                          'Select Program',
                          style: TextStyle(color: Colors.white),
                        ),
                        items: manager.allPrograms.items
                            .where(
                              (p) => !cls.programs.any((cp) => cp.id == p.id),
                        )
                            .map(
                              (program) => DropdownMenuItem(
                            value: program.id,
                            child: Text(
                              program.name,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                            .toList(),
                        onChanged: (v) {
                          setState(() => selectedProgramId = v);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.add, color: Colors.teal),
                      onPressed: selectedProgramId == null
                          ? null
                          : () async {
                         manager.assignProgram({
                          'classId': cls.id,
                          'programId': selectedProgramId,
                        }, _pageIndex);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: cls.programs.isEmpty
                      ? Components.reusableText(
                    content: 'No programs assigned',
                    fontColor: Colors.white,
                  )
                      : ListView.separated(
                    itemCount: cls.programs.length,
                    separatorBuilder: (_, _) =>
                    const Divider(color: Colors.grey),
                    itemBuilder: (_, index) {
                      final program = cls.programs[index];
                      return Row(
                        children: [
                          Expanded(
                            child: Components.reusableText(
                              content: program.name,
                              fontSize: 15,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.remove_circle,
                              color: Colors.red,
                            ),
                            onPressed: () {
                                    Components.deleteDialog<Manager>(
                                context,
                                    () async {
                                        manager.unAssignProgram({
                                    'classId': cls.id,
                                    'programId': program.id,
                                  }, _pageIndex);
                                },
                                body: 'Un-assign this program?',
                              ).then((_){Navigator.pop(mainContext);});

                            },
                          ),
                        ],
                      );
                    },
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

}
