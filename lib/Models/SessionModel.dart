import 'package:gms_flutter_windows/Models/UserModel.dart';

class SessionModel {
  final int id;
  final String title;
  final String description;
  final int classId;
  final UserModel coach;
  final double rate;
  final List<SessionScheduleModel> schedules;
  final DateTime createdAt;
  final int maxNumber;
  final int subscribersCount;
  final List<dynamic>? feedbacks;
  final String? myFeedBack;
  final DateTime? joinedAt;
  final String? className;
  final String? classImage;

  SessionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.classId,
    required this.coach,
    required this.rate,
    required this.schedules,
    required this.createdAt,
    required this.maxNumber,
    required this.subscribersCount,
    this.feedbacks,
    this.myFeedBack,
    this.joinedAt,
    this.className,
    this.classImage,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      classId: json['classId'],
      coach: UserModel.fromJson(json['coach']),
      rate: (json['rate'] as num).toDouble(),
      schedules: (json['schedules'] as List)
          .map((e) => SessionScheduleModel.fromJson(e))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      maxNumber: json['maxNumber'],
      subscribersCount: json['subscribersCount'],
      feedbacks: json['feedbacks'],
      myFeedBack: json['myFeedBack'],
      joinedAt:
      json['joinedAt'] != null ? DateTime.parse(json['joinedAt']) : null,
      className: json['className'],
      classImage: json['classImage'],
    );
  }

  static List<SessionModel> parseList(List<dynamic> jsonList) {
    return jsonList.map((e) => SessionModel.fromJson(e)).toList();
  }
}

class SessionScheduleModel {
  final String day;
  final String startTime;
  final String endTime;

  SessionScheduleModel({
    required this.day,
    required this.startTime,
    required this.endTime,
  });

  factory SessionScheduleModel.fromJson(Map<String, dynamic> json) {
    return SessionScheduleModel(
      day: json['day'],
      startTime: json['startTime'],
      endTime: json['endTime'],
    );
  }
}


class GetSessionsModel {
  final int count;
  final int totalPages;
  final int currentPage;
  final List<SessionModel> items;

  GetSessionsModel({
    required this.count,
    required this.totalPages,
    required this.currentPage,
    required this.items,
  });

  factory GetSessionsModel.fromJson(Map<String, dynamic> json) {
    return GetSessionsModel(
      count: json['count'],
      totalPages: json['totalPages'],
      currentPage: json['currentPage'],
      items: SessionModel.parseList(json['sessions']),
    );
  }
}
