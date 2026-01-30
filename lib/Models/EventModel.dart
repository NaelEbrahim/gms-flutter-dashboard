import 'UserModel.dart';

class EventModel {
  final int id;
  final UserModel admin;
  final String title;
  final String description;
  final String? imagePath;
  final DateTime startedAt;
  final DateTime endedAt;
  final List<EventPrizeModel> prizes;
  final List<EventParticipantModel> participants;

  EventModel({
    required this.id,
    required this.admin,
    required this.title,
    required this.description,
    this.imagePath,
    required this.startedAt,
    required this.endedAt,
    required this.prizes,
    required this.participants,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'],
      admin: UserModel.fromJson(json['admin']),
      title: json['title'],
      description: json['description'],
      imagePath: json['imagePath'],
      startedAt: DateTime.parse(json['startedAt']),
      endedAt: DateTime.parse(json['endedAt']),
      prizes:
          (json['prizes'] as List<dynamic>?)
              ?.map((e) => EventPrizeModel.fromJson(e))
              .toList() ??
          [],
      participants:
          (json['participants'] as List<dynamic>?)
              ?.map((e) => EventParticipantModel.fromJson(e))
              .toList() ??
          [],
    );
  }

  static List<EventModel> parseList(List<dynamic> jsonList) {
    return jsonList.map((e) => EventModel.fromJson(e)).toList();
  }
}

class EventPrizeModel {
  final int id;
  final String condition;
  final String prize;

  EventPrizeModel({
    required this.condition,
    required this.prize,
    required this.id,
  });

  factory EventPrizeModel.fromJson(Map<String, dynamic> json) {
    return EventPrizeModel(
      id: json['id'],
      condition: json['precondition'],
      prize: json['description'],
    );
  }
}

class EventParticipantModel {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final double score;

  EventParticipantModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.score,
  });

  factory EventParticipantModel.fromJson(Map<String, dynamic> json) {
    return EventParticipantModel(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      score: (json['score'] as num).toDouble(),
    );
  }
}

class GetEventsModel {
  final int count;
  final int totalPages;
  final int currentPage;
  final List<EventModel> items;

  GetEventsModel({
    required this.count,
    required this.totalPages,
    required this.currentPage,
    required this.items,
  });

  factory GetEventsModel.fromJson(Map<String, dynamic> json) {
    return GetEventsModel(
      count: json['count'],
      totalPages: json['totalPages'],
      currentPage: json['currentPage'],
      items: EventModel.parseList(json['events']),
    );
  }
}
