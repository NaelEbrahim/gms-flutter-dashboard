import 'package:gms_flutter_windows/Models/UserModel.dart';

import 'MealModel.dart';

class DietPlanModel {
  final int id;
  final String title;
  final UserModel coach;
  final double? rate;
  final bool? isActive;
  final String createdAt;
  final String? lastModifiedAt;
  final DietScheduleModel? schedule;

  DietPlanModel({
    required this.id,
    required this.title,
    required this.coach,
    this.rate,
    this.isActive,
    required this.createdAt,
    this.lastModifiedAt,
    this.schedule,
  });

  factory DietPlanModel.fromJson(Map<String, dynamic> json) {
    return DietPlanModel(
      id: json['id'],
      title: json['title'],
      coach: UserModel.fromJson(json['coach']),
      rate: (json['rate'] as num?)?.toDouble(),
      isActive: json['isActive'],
      createdAt: json['createdAt'],
      lastModifiedAt: json['lastModifiedAt'],
      schedule: json['schedule'] != null
          ? DietScheduleModel.fromJson(json['schedule'])
          : null,
    );
  }

  static List<DietPlanModel> parseList(List<dynamic> jsonList) {
    return jsonList.map((e) => DietPlanModel.fromJson(e)).toList();
  }
}

class DietScheduleModel {
  final Map<String, Map<String, List<MealModel>>> days;

  DietScheduleModel({required this.days});

  factory DietScheduleModel.fromJson(Map<String, dynamic> json) {
    final rawDays = json['days'] as Map<String, dynamic>;

    return DietScheduleModel(
      days: rawDays.map((dayKey, mealsByType) {
        final mealsMap = mealsByType as Map<String, dynamic>;

        return MapEntry(
          dayKey,
          mealsMap.map((mealType, meals) {
            return MapEntry(
              mealType,
              (meals as List).map((e) => MealModel.fromJson(e)).toList(),
            );
          }),
        );
      }),
    );
  }
}

class DietDayModel {
  final List<MealModel> breakfast;
  final List<MealModel> lunch;
  final List<MealModel> dinner;
  final List<MealModel> snack;

  DietDayModel({
    required this.breakfast,
    required this.lunch,
    required this.dinner,
    required this.snack,
  });

  factory DietDayModel.fromJson(Map<String, dynamic> json) {
    return DietDayModel(
      breakfast: json['breakfast'] != null
          ? MealModel.parseList(json['breakfast'])
          : [],
      lunch: json['lunch'] != null ? MealModel.parseList(json['lunch']) : [],
      dinner: json['dinner'] != null ? MealModel.parseList(json['dinner']) : [],
      snack: json['snack'] != null ? MealModel.parseList(json['snack']) : [],
    );
  }
}

class GetDietPlansModel {
  final int count;
  final int totalPages;
  final int currentPage;
  final List<DietPlanModel> items;

  GetDietPlansModel({
    required this.count,
    required this.totalPages,
    required this.currentPage,
    required this.items,
  });

  factory GetDietPlansModel.fromJson(Map<String, dynamic> json) {
    return GetDietPlansModel(
      count: json['count'],
      totalPages: json['totalPages'],
      currentPage: json['currentPage'],
      items: DietPlanModel.parseList(json['dietPlans']),
    );
  }
}
