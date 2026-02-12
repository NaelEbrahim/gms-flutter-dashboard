import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:gms_flutter_windows/Bloc/Manager.dart';
import 'package:gms_flutter_windows/Bloc/States.dart';
import 'package:gms_flutter_windows/Models/DietPlanModel.dart';
import 'package:gms_flutter_windows/Shared/Components.dart';
import 'package:gms_flutter_windows/Shared/Constant.dart';

class DietPlans extends StatefulWidget {
  const DietPlans({super.key});

  @override
  State<DietPlans> createState() => _DietPlansState();
}

class _DietPlansState extends State<DietPlans> {
  int _pageIndex = 0;
  late Manager manager;
  final TextEditingController _searchController = TextEditingController();

  List<DietPlanModel> _filteredPlans(GetDietPlansModel plans) {
    final search = _searchController.text.toLowerCase();
    return plans.items.where((p) {
      return search.isEmpty || p.title.toLowerCase().contains(search);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    manager = Manager.get(context);
    manager
        .getDietPlans(_pageIndex)
        .then((_) => manager.getCoaches())
        .then((_) => manager.getAllMeals());
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    manager.dietPlans.items.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final manager = Manager.get(context);
    final sidebarWidth = Constant.screenWidth / 5;

    return BlocConsumer<Manager, BlocStates>(
      listener: (_, _) {},
      builder: (context, state) {
        final displayedPlans = _filteredPlans(manager.dietPlans);

        return Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Components.reusableText(
                content: 'Diet Plans',
                fontSize: 32,
                fontWeight: FontWeight.bold,
                fontColor: Colors.teal,
              ),
              const SizedBox(height: 16),
              _buildSearchBar(manager, displayedPlans),
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
                              label: Center(child: Text('Coach')),
                              headingRowAlignment: MainAxisAlignment.center,
                            ),
                            DataColumn(
                              label: Center(child: Text('Rate')),
                              headingRowAlignment: MainAxisAlignment.center,
                            ),
                            DataColumn(
                              label: Center(child: Text('Meals')),
                              headingRowAlignment: MainAxisAlignment.center,
                            ),
                            DataColumn(
                              label: Center(child: Text('Created At')),
                              headingRowAlignment: MainAxisAlignment.center,
                            ),
                            DataColumn(
                              label: Center(child: Text('Actions')),
                              headingRowAlignment: MainAxisAlignment.center,
                            ),
                          ],
                          rows: displayedPlans.map((p) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  Center(
                                    child: Text(
                                      p.title.length > 30
                                          ? '${p.title.substring(0, 30)}...'
                                          : p.title,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Center(
                                    child: Text(
                                      '${p.coach.firstName} ${p.coach.lastName}',
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Center(
                                    child: Text(
                                      p.rate?.toStringAsFixed(1) ?? '-',
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Center(
                                    child: ElevatedButton(
                                      onPressed: () =>
                                          _openMealsDialog(context, manager, p),
                                      child: const Text('View'),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Center(
                                    child: Text(p.createdAt.split('T').first),
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
                                          onPressed: () => _showDietPlanDialog(
                                            context,
                                            manager,
                                            p,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          onPressed: () {
                                            // TODO delete diet plan
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

  Widget _buildSearchBar(Manager manager, List<DietPlanModel> displayedPlans) {
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
          totalPages: manager.dietPlans.totalPages,
          currentPage: manager.dietPlans.currentPage,
          onPageChanged: (pageIndex) {
            _pageIndex = pageIndex;
            manager.getDietPlans(pageIndex);
          },
        ),
        const Spacer(),
        ElevatedButton.icon(
          onPressed: () => _showDietPlanDialog(context, manager),
          icon: const Icon(Icons.add),
          label: const Text('Create Diet Plan'),
        ),
        const SizedBox(width: 16),
        Components.reusableText(
          content: 'Total Plans: ${displayedPlans.length}',
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ],
    );
  }

  void _showDietPlanDialog(
    BuildContext context,
    Manager manager, [
    DietPlanModel? plan,
  ]) {
    final isEdit = plan != null;
    final titleCtrl = TextEditingController(text: plan?.title ?? '');
    int? selectedCoachId = plan?.coach.id;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Components.reusableText(
          content: isEdit ? 'Edit Diet Plan' : 'Create Diet Plan',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontColor: Colors.teal,
        ),
        content: SizedBox(
          width: 420,
          child: Column(
            children: [
              Components.reusableTextFormField(
                hint: 'Title',
                prefixIcon: Icons.restaurant_menu,
                controller: titleCtrl,
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
              if (titleCtrl.text.isEmpty) return;

              final data = {
                'title': titleCtrl.text,
                'coachId': selectedCoachId,
              };

              if (isEdit) {
                manager.updateDietPlan(data, plan.id, _pageIndex);
              } else {
                manager.createDietPlan(data);
              }
              Navigator.pop(context);
            },
            child: Text(isEdit ? 'Save' : 'Create'),
          ),
        ],
      ),
    );
  }

  void _openMealsDialog(
    BuildContext mainContext,
    Manager manager,
    DietPlanModel plan,
  ) {
    int? selectedMealId;
    String? selectedDay;
    String? selectedMealTime;
    double quantity = 100;

    final availableDays = List.generate(7, (i) => 'Day_${i + 1}');
    final mealTimes = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];

    showDialog(
      context: mainContext,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Components.reusableText(
            content: 'Meals - ${plan.title}',
            fontColor: Colors.teal,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 480,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ADD MEAL SECTION
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              isExpanded: true,
                              dropdownColor: Colors.grey[850],
                              hint: const Text(
                                'Meal',
                                style: TextStyle(color: Colors.white),
                              ),
                              items: manager.allMeals.meals
                                  .map(
                                    (m) => DropdownMenuItem(
                                      value: m.id,
                                      child: Text(
                                        m.title,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => selectedMealId = v),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              isExpanded: true,
                              dropdownColor: Colors.grey[850],
                              hint: const Text(
                                'Day',
                                style: TextStyle(color: Colors.white),
                              ),
                              items: availableDays
                                  .map(
                                    (d) => DropdownMenuItem(
                                      value: d,
                                      child: Text(
                                        d,
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) => setState(() => selectedDay = v),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              isExpanded: true,
                              dropdownColor: Colors.grey[850],
                              hint: const Text(
                                'Meal Time',
                                style: TextStyle(color: Colors.white),
                              ),
                              items: mealTimes
                                  .map(
                                    (t) => DropdownMenuItem(
                                      value: t,
                                      child: Text(
                                        t,
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => selectedMealTime = v),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Components.reusableText(
                                  content: 'Quantity (g)',
                                  fontColor: Colors.white,
                                  fontSize: 12,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.remove,
                                        color: Colors.white,
                                      ),
                                      onPressed: () => setState(() {
                                        if (quantity > 10) quantity -= 5;
                                      }),
                                    ),
                                    Components.reusableText(
                                      content: quantity.toStringAsFixed(0),
                                      fontSize: 14,
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.add,
                                        color: Colors.white,
                                      ),
                                      onPressed: () =>
                                          setState(() => quantity += 5),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          IconButton(
                            icon: const Icon(Icons.upload, color: Colors.teal),
                            onPressed: () {
                              if (selectedMealId == null ||
                                  selectedDay == null ||
                                  selectedMealTime == null ||
                                  quantity <= 0) {
                                return;
                              }
                              manager.assignMeal({
                                'dietId': plan.id,
                                'mealId': selectedMealId,
                                'day': selectedDay,
                                'mealTime': selectedMealTime,
                                'quantity': quantity,
                              }, _pageIndex);
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: Colors.grey),
                  // ASSIGNED MEALS
                  plan.schedule?.days == null || plan.schedule!.days.isEmpty
                      ? Components.reusableText(
                          content: 'No meals assigned',
                          fontColor: Colors.white,
                        )
                      : Column(
                          children: plan.schedule!.days.entries.map((dayEntry) {
                            final dayName = dayEntry.key;
                            final mealTimesMap = dayEntry.value;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Components.reusableText(
                                  content: dayName,
                                  fontColor: Colors.teal,
                                  fontWeight: FontWeight.bold,
                                ),
                                ...mealTimesMap.entries.map((mealTimeEntry) {
                                  final mealTime = mealTimeEntry.key;
                                  final meals = mealTimeEntry.value;
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 12,
                                        ),
                                        child: Components.reusableText(
                                          content: mealTime,
                                          fontColor: Colors.orange,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      ...meals.map((meal) {
                                        return ListTile(
                                          contentPadding: const EdgeInsets.only(
                                            left: 24,
                                          ),
                                          title: Components.reusableText(
                                            content: meal.title,
                                          ),
                                          subtitle: Components.reusableText(
                                            content:
                                                'Qty: ${meal.quantity} | Cal: ${meal.totalCalories}',
                                          ),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.edit,
                                                  color: Colors.teal,
                                                ),
                                                onPressed: () {
                                                  int editQuantity =
                                                      (meal.quantity ?? 1)
                                                          .toInt();
                                                  showDialog(
                                                    context: context,
                                                    builder: (_) => StatefulBuilder(
                                                      builder: (context, setState) => AlertDialog(
                                                        backgroundColor:
                                                            Colors.grey[900],
                                                        title: Components.reusableText(
                                                          content:
                                                              'Update Quantity',
                                                          fontColor:
                                                              Colors.teal,
                                                        ),
                                                        content: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            IconButton(
                                                              icon: const Icon(
                                                                Icons.remove,
                                                                color:
                                                                    Colors.red,
                                                              ),
                                                              onPressed: () =>
                                                                  setState(() {
                                                                    if (editQuantity >
                                                                        1) {
                                                                      editQuantity -=
                                                                          5;
                                                                    }
                                                                  }),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        16,
                                                                  ),
                                                              child: Components.reusableText(
                                                                content:
                                                                    editQuantity
                                                                        .toString(),
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                            IconButton(
                                                              icon: const Icon(
                                                                Icons.add,
                                                                color:
                                                                    Colors.teal,
                                                              ),
                                                              onPressed: () =>
                                                                  setState(
                                                                    () =>
                                                                        editQuantity +=
                                                                            5,
                                                                  ),
                                                            ),
                                                          ],
                                                        ),
                                                        actions: [
                                                          ElevatedButton(
                                                            onPressed: () {
                                                              manager.updateAssignedMeal({
                                                                'dietId':
                                                                    plan.id,
                                                                'mealId':
                                                                    meal.id,
                                                                'day': dayName,
                                                                'mealTime':
                                                                    mealTime,
                                                                'quantity':
                                                                    editQuantity,
                                                              }, _pageIndex);
                                                              Navigator.pop(
                                                                context,
                                                              );
                                                            },
                                                            child: const Text(
                                                              'Save',
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.remove_circle,
                                                  color: Colors.red,
                                                ),
                                                onPressed: () {
                                                  Components.deleteDialog<
                                                        Manager
                                                      >(
                                                        context,
                                                        () async {
                                                          manager.unAssignMeal({
                                                            'dietId': plan.id,
                                                            'mealId': meal.id,
                                                            'day': dayName,
                                                            'mealTime':
                                                                mealTime,
                                                          }, _pageIndex);
                                                        },
                                                        body:
                                                            'Remove this meal?',
                                                      )
                                                      .then(
                                                        (_) => Navigator.pop(
                                                          mainContext,
                                                        ),
                                                      );
                                                },
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                    ],
                                  );
                                }),
                                const Divider(color: Colors.grey),
                              ],
                            );
                          }).toList(),
                        ),
                ],
              ),
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
