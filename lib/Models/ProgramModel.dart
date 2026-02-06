import 'package:gms_flutter_windows/Models/WorkoutModel.dart';

class ProgramModel {
  final int id;
  final String title;
  final String level;
  final bool isPublic;
  final double rate;
  final ScheduleModel schedule;

  ProgramModel({
    required this.id,
    required this.title,
    required this.level,
    required this.isPublic,
    required this.rate,
    required this.schedule,
  });

  factory ProgramModel.fromJson(Map<String, dynamic> json) {
    return ProgramModel(
      id: json['id'],
      title: json['name'],
      level: json['level'],
      isPublic: json['isPublic'],
      rate: (json['rate'] as num).toDouble(),
      schedule: ScheduleModel.fromJson(json['schedule']),
    );
  }

  static List<ProgramModel> parseList(List<dynamic> jsonList) {
    return jsonList.map((e) => ProgramModel.fromJson(e)).toList();
  }
}

class GetProgramsModel {
  final int count;

  final int totalPages;

  final int currentPage;

  final List<ProgramModel> items;

  GetProgramsModel({
    required this.count,
    required this.totalPages,
    required this.currentPage,
    required this.items,
  });

  factory GetProgramsModel.fromJson(Map<String, dynamic> json) {
    return GetProgramsModel(
      count: json['count'],
      totalPages: json['totalPages'],
      currentPage: json['currentPage'],
      items: ProgramModel.parseList(json['programs']),
    );
  }
}

class ScheduleModel {
  final Map<String, Map<String, List<WorkoutModel>>> days;

  ScheduleModel({required this.days});

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    final rawDays = json['days'] as Map<String, dynamic>;
    return ScheduleModel(
      days: rawDays.map((dayKey, muscles) {
        final muscleMap = muscles as Map<String, dynamic>;
        return MapEntry(
          dayKey,
          muscleMap.map((muscle, workouts) {
            return MapEntry(
              muscle,
              (workouts as List).map((e) => WorkoutModel.fromJson(e)).toList(),
            );
          }),
        );
      }),
    );
  }
}
