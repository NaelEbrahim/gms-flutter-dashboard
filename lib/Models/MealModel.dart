class MealModel {
  final int id;
  final String title;
  final String? imagePath;
  final double baseCalories;
  final double? quantity;
  final double? totalCalories;
  final String description;

  MealModel({
    required this.id,
    required this.title,
    this.imagePath,
    required this.baseCalories,
    this.quantity,
    this.totalCalories,
    required this.description,
  });

  factory MealModel.fromJson(Map<String, dynamic> json) {
    return MealModel(
      id: json['id'],
      title: json['title'],
      imagePath: json['imagePath'],
      baseCalories: (json['baseCalories'] as num).toDouble(),
      quantity: (json['quantity'] as num?)?.toDouble(),
      totalCalories: (json['totalCalories'] as num?)?.toDouble(),
      description: json['description'] ?? '',
    );
  }

  static List<MealModel> parseList(List<dynamic> jsonList) {
    return jsonList.map((e) => MealModel.fromJson(e)).toList();
  }
}

class GetMealsModel {
  final int count;
  final int totalPages;
  final int currentPage;
  final List<MealModel> meals;

  GetMealsModel({
    required this.count,
    required this.totalPages,
    required this.currentPage,
    required this.meals,
  });

  factory GetMealsModel.fromJson(Map<String, dynamic> json) {
    return GetMealsModel(
      count: json['count'],
      totalPages: json['totalPages'],
      currentPage: json['currentPage'],
      meals: MealModel.parseList(json['meals']),
    );
  }
}
