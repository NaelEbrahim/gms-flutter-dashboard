import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gms_flutter_windows/Bloc/Manager.dart';
import 'package:gms_flutter_windows/Bloc/States.dart';
import 'package:gms_flutter_windows/Models/SessionModel.dart';
import 'package:gms_flutter_windows/Shared/Components.dart';
import 'package:gms_flutter_windows/Shared/Constant.dart';

class Sessions extends StatefulWidget {
  const Sessions({super.key});

  @override
  State<Sessions> createState() => _SessionsState();
}

class _SessionsState extends State<Sessions> {
  int _pageIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  List<SessionModel> _filteredSessions(List<SessionModel> sessions) {
    final search = _searchController.text.toLowerCase();
    return sessions.where((s) {
      return s.title.toLowerCase().contains(search) ||
          (s.className ?? '').toLowerCase().contains(search) ||
          s.coach.firstName.toLowerCase().contains(search);
    }).toList();
  }

  List<SessionModel> displayedSessions = [];

  @override
  void initState() {
    super.initState();
    Manager manager = Manager.get(context);
    manager.getSessions(_pageIndex);
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
      builder: (_, state) {
        displayedSessions = _filteredSessions(manager.sessions.items);
        return Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Components.reusableText(
                content: 'Sessions',
                fontSize: 32,
                fontWeight: FontWeight.bold,
                fontColor: Colors.teal,
              ),
              const SizedBox(height: 16),
              _buildFilters(displayedSessions, manager),
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
                              label: Center(child: Text('Class')),
                              headingRowAlignment: MainAxisAlignment.center,
                            ),
                            DataColumn(
                              label: Center(child: Text('Coach')),
                              headingRowAlignment: MainAxisAlignment.center,
                            ),
                            DataColumn(
                              label: Center(child: Text('Subscribers')),
                              headingRowAlignment: MainAxisAlignment.center,
                            ),
                            DataColumn(
                              label: Center(child: Text('Schedule')),
                              headingRowAlignment: MainAxisAlignment.center,
                            ),
                            DataColumn(
                              label: Center(child: Text('Rate')),
                              headingRowAlignment: MainAxisAlignment.center,
                            ),
                            DataColumn(
                              label: Center(child: Text('Actions')),
                              headingRowAlignment: MainAxisAlignment.center,
                            ),
                          ],
                          rows: displayedSessions.map((s) {
                            return DataRow(
                              cells: [
                                _cell(s.title),
                                _cell(s.className ?? '-'),
                                _cell(
                                  '${s.coach.firstName} ${s.coach.lastName}',
                                ),
                                _cell('${s.subscribersCount}/${s.maxNumber}'),
                                DataCell(
                                  Center(
                                    child: ElevatedButton(
                                      onPressed: () => _showScheduleDialog(
                                        context,
                                        s.schedules,
                                      ),
                                      child: const Text('View'),
                                    ),
                                  ),
                                ),
                                _cell(s.rate.toString()),
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
                                          onPressed: () => _showSessionDialog(
                                            context,
                                            manager,
                                            s,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          onPressed: () {},
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

  Widget _buildFilters(List<SessionModel> displayed, Manager manager) {
    return Row(
      children: [
        SizedBox(
          width: Constant.screenWidth / 4,
          child: Components.reusableTextFormField(
            hint: 'Search by title, class, or coach',
            prefixIcon: Icons.search,
            controller: _searchController,
            validator: (_) => null,
          ),
        ),
        const SizedBox(width: 12),
        Components.reusablePagination(
          totalPages: manager.sessions.totalPages,
          currentPage: manager.sessions.currentPage,
          onPageChanged: (pageIndex) {
            _pageIndex = pageIndex;
            manager.getSessions(_pageIndex);
          },
        ),
        const Spacer(),
        ElevatedButton.icon(
          onPressed: () => _showSessionDialog(context, manager),
          icon: const Icon(Icons.add),
          label: const Text('Create Session'),
        ),
        const SizedBox(width: 15),
        Components.reusableText(
          content: 'Total Sessions: ${displayed.length}',
          fontWeight: FontWeight.bold,
        ),
      ],
    );
  }

  DataCell _cell(String text) {
    return DataCell(
      Center(child: Components.reusableText(content: text, fontSize: 14)),
    );
  }

  void _showSessionDialog(
    BuildContext context,
    Manager manager, [
    SessionModel? session,
  ]) {
    final isEdit = session != null;

    final titleCtrl = TextEditingController(text: session?.title ?? '');
    final descCtrl = TextEditingController(text: session?.description ?? '');
    int maxNumber = session?.maxNumber ?? 1;
    int? selectedCoachId = session?.coach.id;
    int? selectedClassId = session?.classId;

    final schedules = <Map<String, dynamic>>[];

    if (session?.schedules != null) {
      for (var s in session!.schedules) {
        final start = s.startTime.split(':');
        final end = s.endTime.split(':');
        schedules.add({
          'day': s.day,
          'startTime': TimeOfDay(
            hour: int.parse(start[0]),
            minute: int.parse(start[1]),
          ),
          'endTime': TimeOfDay(
            hour: int.parse(end[0]),
            minute: int.parse(end[1]),
          ),
        });
      }
    }
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Components.reusableText(
            content: isEdit ? 'Edit Session' : 'Create Session',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontColor: Colors.teal,
          ),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
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
                    hint: 'Description',
                    prefixIcon: Icons.description,
                    controller: descCtrl,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Text(
                        'Max Number:',
                        style: TextStyle(color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        onPressed: () {
                          if (maxNumber > 1) setState(() => maxNumber--);
                        },
                        icon: const Icon(Icons.remove, color: Colors.white),
                      ),
                      Text(
                        '$maxNumber',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      IconButton(
                        onPressed: () => setState(() => maxNumber++),
                        icon: const Icon(Icons.add, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Class Dropdown
                  DropdownButtonFormField<int>(
                    initialValue: selectedClassId,
                    dropdownColor: Colors.grey[900],
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.fitness_center),
                      labelText: 'Class',
                      fillColor: Colors.black54,
                      filled: true,
                      border: OutlineInputBorder(),
                    ),
                    items: manager.allClasses.items
                        .map(
                          (c) => DropdownMenuItem<int>(
                            value: c.id,
                            child: Text(
                              c.name,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => selectedClassId = value),
                  ),
                  const SizedBox(height: 10),
                  // Coach Dropdown
                  DropdownButtonFormField<int>(
                    initialValue: selectedCoachId,
                    dropdownColor: Colors.grey[900],
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.person),
                      labelText: 'Coach',
                      fillColor: Colors.black54,
                      filled: true,
                      border: OutlineInputBorder(),
                    ),
                    items: manager.coaches.items
                        .map(
                          (u) => DropdownMenuItem<int>(
                            value: u.id,
                            child: Text(
                              '${u.firstName} ${u.lastName}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => selectedCoachId = value),
                  ),
                  const SizedBox(height: 10),
                  // Schedules
                  Column(
                    children: schedules.asMap().entries.map((entry) {
                      int index = entry.key;
                      var schedule = entry.value;
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            // Day
                            DropdownButton<String>(
                              value: schedule['day'],
                              dropdownColor: Colors.grey[900],
                              items:
                                  [
                                        'SUNDAY',
                                        'MONDAY',
                                        'TUESDAY',
                                        'WEDNESDAY',
                                        'THURSDAY',
                                        'FRIDAY',
                                        'SATURDAY',
                                      ]
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
                              onChanged: (v) =>
                                  setState(() => schedule['day'] = v),
                            ),
                            const SizedBox(width: 8),
                            // Start Time
                            ElevatedButton(
                              onPressed: () async {
                                final picked = await showTimePicker(
                                  context: context,
                                  initialTime: schedule['startTime'],
                                );
                                if (picked != null) {
                                  setState(
                                    () => schedule['startTime'] = picked,
                                  );
                                }
                              },
                              child: Text(
                                (schedule['startTime'] as TimeOfDay).format(
                                  context,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // End Time
                            ElevatedButton(
                              onPressed: () async {
                                final picked = await showTimePicker(
                                  context: context,
                                  initialTime: schedule['endTime'],
                                );
                                if (picked != null) {
                                  setState(() => schedule['endTime'] = picked);
                                }
                              },
                              child: Text(
                                (schedule['endTime'] as TimeOfDay).format(
                                  context,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () =>
                                  setState(() => schedules.removeAt(index)),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  // Add Schedule Button
                  ElevatedButton(
                    onPressed: () => setState(() {
                      schedules.add({
                        'day': 'SUNDAY',
                        'startTime': const TimeOfDay(hour: 8, minute: 0),
                        'endTime': const TimeOfDay(hour: 9, minute: 0),
                      });
                    }),
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(Colors.teal),
                    ),
                    child: const Text(
                      'Add Schedule',
                      style: TextStyle(color: Colors.white),
                    ),
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
                    selectedCoachId == null ||
                    selectedClassId == null) {
                  return;
                }
                // Convert schedules to backend (strings)
                final backendSchedules = schedules
                    .map(
                      (s) => {
                        'day': (s['day'] as String).toUpperCase(),
                        'startTime': toLocalTime(s['startTime']),
                        'endTime': toLocalTime(s['endTime']),
                      },
                    )
                    .toList();
                final sessionData = {
                  'title': titleCtrl.text,
                  'description': descCtrl.text,
                  'maxNumber': maxNumber,
                  'coachId': selectedCoachId,
                  'classId': selectedClassId,
                  'schedules': backendSchedules,
                };
                if (isEdit) {
                  manager.updateSession(sessionData, session.id, _pageIndex);
                } else {
                  manager.createSession(sessionData);
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

  String toLocalTime(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  void _showScheduleDialog(BuildContext context, List<dynamic> schedules) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Components.reusableText(
          content: 'Schedule',
          fontColor: Colors.teal,
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: schedules.isEmpty
              ? [Components.reusableText(content: 'No schedules')]
              : schedules
                    .map(
                      (s) => ListTile(
                        leading: const Icon(
                          Icons.access_time,
                          color: Colors.white,
                        ),
                        title: Components.reusableText(
                          content: '${s.day} (${s.startTime} - ${s.endTime})',
                          fontSize: 16.0,
                        ),
                      ),
                    )
                    .toList(),
        ),
      ),
    );
  }
}
