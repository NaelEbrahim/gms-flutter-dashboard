class WorkoutModel {
  final int id;
  final String title;
  final double baseAvgCalories;
  final String primaryMuscle;
  final String? secondaryMuscles;
  final double totalBurnedCalories;
  final String description;
  final String? imagePath;
  final int? reps;
  final int sets;
  final int duration;

  WorkoutModel({
    required this.id,
    required this.title,
    required this.baseAvgCalories,
    required this.primaryMuscle,
    required this.secondaryMuscles,
    required this.totalBurnedCalories,
    required this.description,
    this.imagePath,
    this.reps,
    required this.sets,
    required this.duration,
  });

  factory WorkoutModel.fromJson(Map<String, dynamic> json) {
    return WorkoutModel(
      id: json['id'],
      title: json['title'],
      baseAvgCalories: (json['baseAvgCalories'] as num).toDouble(),
      primaryMuscle: json['primaryMuscle'],
      secondaryMuscles: json['secondaryMuscles'] ?? '',
      totalBurnedCalories: (json['totalBurnedCalories'] as num).toDouble(),
      description: json['description'],
      imagePath: json['imagePath'],
      reps: json['reps'] as int?,
      sets: json['sets'],
      duration: json['duration'],
    );
  }

  static List<WorkoutModel> parseList(List<dynamic> jsonList) {
    return jsonList.map((e) => WorkoutModel.fromJson(e)).toList();
  }
}

class GetWorkoutsModel {
  final int count;

  final int totalPages;

  final int currentPage;

  final List<WorkoutModel> items;

  GetWorkoutsModel({
    required this.count,
    required this.totalPages,
    required this.currentPage,
    required this.items,
  });

  factory GetWorkoutsModel.fromJson(Map<String, dynamic> json) {
    return GetWorkoutsModel(
      count: json['count'],
      totalPages: json['totalPages'],
      currentPage: json['currentPage'],
      items: WorkoutModel.parseList(json['workouts']),
    );
  }
}
