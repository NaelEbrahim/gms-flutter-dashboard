import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gms_flutter_windows/Bloc/Manager.dart';
import 'package:gms_flutter_windows/Bloc/States.dart';
import 'package:gms_flutter_windows/Models/EventModel.dart';
import 'package:gms_flutter_windows/Shared/Components.dart';
import 'package:gms_flutter_windows/Shared/Constant.dart';

class Events extends StatefulWidget {
  const Events({super.key});

  @override
  State<Events> createState() => _EventsState();
}

class _EventsState extends State<Events> {
  int _pageIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  List<EventModel> displayedEvents = [];

  @override
  void initState() {
    super.initState();
    Manager.get(context).getEvents(_pageIndex);
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<EventModel> _filterEvents(List<EventModel> events) {
    final query = _searchController.text.toLowerCase();
    return events.where((s) {
      return s.title.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final manager = Manager.get(context);
    final sidebarWidth = Constant.screenWidth / 5;
    return BlocConsumer<Manager, BlocStates>(
      listener: (_, _) {},
      builder: (context, state) {
        displayedEvents = _filterEvents(manager.events.items);
        return Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Components.reusableText(
                content: 'Events',
                fontSize: 32,
                fontWeight: FontWeight.bold,
                fontColor: Colors.teal,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      width: Constant.screenWidth / 4,
                      child: Components.reusableTextFormField(
                        hint: 'Search by title',
                        prefixIcon: Icons.search,
                        validator: (_) => null,
                        controller: _searchController,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Components.reusablePagination(
                    totalPages: manager.events.totalPages,
                    currentPage: manager.events.currentPage,
                    onPageChanged: (pageIndex) {
                      _pageIndex = pageIndex;
                      manager.getEvents(_pageIndex);
                    },
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: () => _showEventDialog(context, manager),
                    icon: const Icon(Icons.add),
                    label: const Text('Create Event'),
                  ),
                  const SizedBox(width: 16),
                  Components.reusableText(
                    content: 'Total Events: ${displayedEvents.length}',
                    fontWeight: FontWeight.bold,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ConditionalBuilder(
                condition: state is! LoadingState,
                builder: (context) => Flexible(
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
                              label: Center(child: Text('Start')),
                              headingRowAlignment: MainAxisAlignment.center,
                            ),
                            DataColumn(
                              label: Center(child: Text('End')),
                              headingRowAlignment: MainAxisAlignment.center,
                            ),
                            DataColumn(
                              label: Center(child: Text('Prizes')),
                              headingRowAlignment: MainAxisAlignment.center,
                            ),
                            DataColumn(
                              label: Center(child: Text('Participants')),
                              headingRowAlignment: MainAxisAlignment.center,
                            ),
                            DataColumn(
                              label: Center(child: Text('Actions')),
                              headingRowAlignment: MainAxisAlignment.center,
                            ),
                          ],
                          rows: displayedEvents.map((e) {
                            return DataRow(
                              cells: [
                                DataCell(Center(child: Text(e.title))),
                                DataCell(
                                  Center(
                                    child: Text(
                                      e.startedAt
                                          .toIso8601String()
                                          .split('T')
                                          .first,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Center(
                                    child: Text(
                                      e.endedAt
                                          .toIso8601String()
                                          .split('T')
                                          .first,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Center(
                                    child: ElevatedButton(
                                      onPressed: () => _showPrizesDialog(
                                        context,
                                        manager,
                                        e,
                                      ),
                                      child: const Text('View'),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Center(
                                    child: ElevatedButton(
                                      onPressed: () => _showParticipantsDialog(
                                        context,
                                        manager,
                                        e,
                                        e.participants,
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
                                          onPressed: () => _showEventDialog(
                                            context,
                                            manager,
                                            e,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          onPressed: () {
                                            // TODO : implement Delete
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
                fallback: (context) =>
                    Center(child: const CircularProgressIndicator()),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEventDialog(
    BuildContext context,
    Manager manager, [
    EventModel? event,
  ]) {
    final isEdit = event != null;

    final titleCtrl = TextEditingController(text: event?.title ?? '');
    final descCtrl = TextEditingController(text: event?.description ?? '');
    DateTime? startDate = event?.startedAt;
    DateTime? endDate = event?.endedAt;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Components.reusableText(
            content: isEdit ? 'Edit Event' : 'Create Event',
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
                      Expanded(
                        child: Components.reusableTextFormField(
                          hint: startDate == null
                              ? 'Start Date'
                              : startDate!.toIso8601String().split('T').first,
                          prefixIcon: Icons.calendar_today,
                          controller: TextEditingController(),
                          readOnly: true,
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: startDate ?? DateTime.now(),
                              firstDate: DateTime(2025),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() => startDate = picked);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Components.reusableTextFormField(
                          hint: endDate == null
                              ? 'End Date'
                              : endDate!.toIso8601String().split('T').first,
                          prefixIcon: Icons.calendar_today,
                          controller: TextEditingController(),
                          readOnly: true,
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: endDate ?? DateTime.now(),
                              firstDate: DateTime(2025),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() => endDate = picked);
                            }
                          },
                        ),
                      ),
                    ],
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
                    startDate == null ||
                    endDate == null) {
                  return;
                }
                final eventData = FormData.fromMap({
                  'title': titleCtrl.text,
                  'description': descCtrl.text,
                  'startedAt': startDate!.toIso8601String().split('T').first,
                  'endedAt': endDate!.toIso8601String().split('T').first,
                });
                if (isEdit) {
                  manager.updateEvent(eventData, event.id, _pageIndex);
                } else {
                  manager.createEvent(eventData);
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

  // View Prizes Dialog
  void _showPrizesDialog(
    BuildContext context,
    Manager manager,
    EventModel event,
  ) {
    final conditionCtrl = TextEditingController();
    final prizeCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Components.reusableText(
            content: 'Prizes',
            fontColor: Colors.teal,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          content: SizedBox(
            width: 350,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (event.prizes.isEmpty)
                  Components.reusableText(content: 'No prizes')
                else
                  ...event.prizes.asMap().entries.map((entry) {
                    final p = entry.value;
                    return ListTile(
                      title: Components.reusableText(
                        content: '${p.condition}: ${p.prize}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          Components.deleteDialog<Manager>(context, () async {
                            manager.deletePrize(p.id);
                          }).then((_) {
                            Navigator.pop(context);
                          });
                        },
                      ),
                    );
                  }),
                const Divider(color: Colors.grey),
                // Add prize
                Components.reusableTextFormField(
                  hint: 'Condition',
                  prefixIcon: Icons.rule,
                  controller: conditionCtrl,
                ),
                const SizedBox(height: 8),
                Components.reusableTextFormField(
                  hint: 'Prize',
                  prefixIcon: Icons.card_giftcard,
                  controller: prizeCtrl,
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    if (conditionCtrl.text.isNotEmpty &&
                        prizeCtrl.text.isNotEmpty) {
                      manager.createPrize({
                        'event_id': event.id,
                        'description': prizeCtrl.text,
                        'precondition': conditionCtrl.text,
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Add Prize'),
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

  // View Participants Dialog
  void _showParticipantsDialog(
    BuildContext context,
    Manager manager,
    EventModel event,
    List<EventParticipantModel> participants,
  ) {
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Components.reusableText(
            content: 'Participants',
            fontColor: Colors.teal,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          content: SizedBox(
            width: 340,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (participants.isEmpty)
                  Components.reusableText(content: 'No participants')
                else
                  ...participants.map((p) {
                    final scoreCtrl = TextEditingController(
                      text: p.score.toString(),
                    );

                    return Card(
                      color: Colors.grey[850],
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Components.reusableText(
                              content: '${p.firstName} ${p.lastName}',
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Expanded(
                                  child: Components.reusableTextFormField(
                                    hint: 'Score',
                                    controller: scoreCtrl,
                                    prefixIcon: Icons.score,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(
                                    Icons.save,
                                    color: Colors.teal,
                                  ),
                                  onPressed: () {
                                    final newScore = int.tryParse(
                                      scoreCtrl.text,
                                    );
                                    if (newScore == null) return;
                                    // Api call
                                    manager.editUserScore({
                                      'userId': p.id,
                                      'eventId': event.id,
                                      'score': newScore,
                                    });
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
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
