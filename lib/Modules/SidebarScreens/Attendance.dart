import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gms_flutter_windows/Bloc/Manager.dart';
import 'package:gms_flutter_windows/Bloc/States.dart';
import 'package:gms_flutter_windows/Shared/Constant.dart';

class Attendance extends StatefulWidget {
  const Attendance({super.key});

  @override
  State<Attendance> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<Attendance>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  DateTimeRange? overviewRange;

  String? selectedUser;
  int? selectedUserId;
  DateTimeRange? userRange;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Manager.get(context).getAllUsers();
  }

  String fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Widget card({required Widget child, EdgeInsets? padding}) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black38, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: child,
    );
  }

  Widget hoverButton({required Widget child, VoidCallback? onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      hoverColor: Colors.teal.withAlpha(25),
      onTap: onTap,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final manager = Manager.get(context);

    return BlocConsumer<Manager, BlocStates>(
      listener: (_, _) {},
      builder: (_, state) => Scaffold(
        backgroundColor: Constant.scaffoldColor,
        appBar: AppBar(
          backgroundColor: Colors.black54,
          foregroundColor: Colors.white,
          title: const Text(
            'Attendance',
            style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
          ),
          bottom: TabBar(
            controller: _tabController,
            labelColor: Colors.teal,
            unselectedLabelColor: Colors.white70,
            tabs: const [
              Tab(text: 'Overview'),
              Tab(text: 'By User'),
            ],
          ),
        ),
        body: ConditionalBuilder(
          condition: state is! LoadingState,
          builder: (_) => Padding(
            padding: EdgeInsetsGeometry.all(10),
            child: TabBarView(
              controller: _tabController,
              children: [_overviewTab(manager), _byUserTab(manager)],
            ),
          ),
          fallback: (_) => const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }

  Widget _overviewTab(Manager manager) {
    if (overviewRange == null) {
      return Center(
        child: card(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _rangePicker(
                label: 'Select date range',
                onPicked: (r) async {
                  overviewRange = r;
                  await manager.getAllAttendance(fmt(r.start), fmt(r.end));
                  setState(() {});
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Select a date range to view attendance',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      );
    }

    final dates = manager.attendanceList.expand((m) => m.dates).toList();

    final perDay = <DateTime, int>{};
    for (final d in dates) {
      final day = DateTime(d.year, d.month, d.day);
      perDay[day] = (perDay[day] ?? 0) + 1;
    }

    final mostActive = perDay.entries.isEmpty
        ? null
        : perDay.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _rangePicker(
            label: '${fmt(overviewRange!.start)} → ${fmt(overviewRange!.end)}',
            onPicked: (r) async {
              overviewRange = r;
              await manager.getAllAttendance(fmt(r.start), fmt(r.end));
              setState(() {});
            },
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _kpi('Total Attendance', dates.length.toString()),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _kpi(
                  'Most Active Day',
                  mostActive == null ? '-' : fmt(mostActive),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Row(
              children: [
                Expanded(flex: 2, child: card(child: _chart(dates))),
                const SizedBox(width: 16),
                Expanded(
                  child: card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'By User',
                          style: TextStyle(
                            color: Colors.teal,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(color: Colors.white24),
                        Expanded(
                          child: ListView(
                            children: manager.attendanceList.map((m) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      m.user ?? '',
                                      style: const TextStyle(
                                        color: Colors.teal,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '${m.dates.length} days',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _byUserTab(Manager manager) {
    final dates = manager.userAttendanceDates;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'User Attendance',
              style: TextStyle(
                color: Colors.teal,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButton<String>(
              value: selectedUser,
              hint: const Text(
                'Select user',
                style: TextStyle(color: Colors.white70),
              ),
              isExpanded: true,
              dropdownColor: Colors.black54,
              items: manager.allUsers.items.map((u) {
                final name = '${u.firstName} ${u.lastName}';
                return DropdownMenuItem(
                  value: name,
                  child: Text(
                    name,
                    style: const TextStyle(color: Colors.white70),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                final u = manager.allUsers.items.firstWhere(
                  (e) => '${e.firstName} ${e.lastName}' == value,
                );
                setState(() {
                  selectedUser = value;
                  selectedUserId = u.id;
                  userRange = null;
                  manager.userAttendanceDates.clear();
                });
              },
            ),
            const SizedBox(height: 16),
            _rangePicker(
              label: userRange == null
                  ? 'Select date range'
                  : '${fmt(userRange!.start)} → ${fmt(userRange!.end)}',
              onPicked: selectedUserId == null
                  ? null
                  : (r) async {
                      userRange = r;
                      await manager.getUserAttendance(
                        selectedUserId!,
                        fmt(r.start),
                        fmt(r.end),
                      );
                      setState(() {});
                    },
            ),

            const SizedBox(height: 20),

            if (dates.isEmpty && userRange != null)
              const Center(
                child: Text(
                  'No attendance for selected range',
                  style: TextStyle(color: Colors.white70),
                ),
              ),

            if (dates.isNotEmpty)
              Expanded(
                child: ListView.separated(
                  itemCount: dates.length,
                  separatorBuilder: (_, _) =>
                      const Divider(color: Colors.white24),
                  itemBuilder: (_, i) => Text(
                    fmt(dates[i]),
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _kpi(String title, String value) {
    return card(
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.teal,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _rangePicker({
    required String label,
    required Future<void> Function(DateTimeRange r)? onPicked,
  }) {
    return hoverButton(
      onTap: onPicked == null
          ? null
          : () async {
              final r = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (r != null) await onPicked(r);
            },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.teal),
        ),
        child: Row(
          children: [
            const Icon(Icons.date_range, color: Colors.teal),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _chart(List<DateTime> dates) {
    final perDay = <DateTime, int>{};
    for (final d in dates) {
      final day = DateTime(d.year, d.month, d.day);
      perDay[day] = (perDay[day] ?? 0) + 1;
    }

    final days = perDay.keys.toList()..sort();
    final spots = List.generate(
      days.length,
      (i) => FlSpot(i.toDouble(), perDay[days[i]]!.toDouble()),
    );

    return LineChart(
      LineChartData(
        borderData: FlBorderData(show: false),
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.teal,
            barWidth: 3,
            dotData: FlDotData(show: true),
          ),
        ],
      ),
    );
  }
}
