import 'package:gms_flutter_windows/Models/ProgramModel.dart';
import 'package:gms_flutter_windows/Models/UserModel.dart';

class ClassModel {
  final int id;
  final String title;
  final String description;
  final double price;
  final UserModel coach;
  final List<ProgramModel> programs;

  ClassModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.coach,
    required this.programs,
  });

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      id: json['id'],
      title: json['name'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      coach: UserModel.fromJson(json['coach']),
      programs: ProgramModel.parseList(json['programs'])
    );
  }

  static List<ClassModel> parseList(List<dynamic> jsonList) {
    return jsonList.map((e) => ClassModel.fromJson(e)).toList();
  }
}

class GetClassesModel {
  final int count;

  final int totalPages;

  final int currentPage;

  final List<ClassModel> items;

  GetClassesModel({
    required this.count,
    required this.totalPages,
    required this.currentPage,
    required this.items,
  });

  factory GetClassesModel.fromJson(Map<String, dynamic> json) {
    return GetClassesModel(
      count: json['count'],
      totalPages: json['totalPages'],
      currentPage: json['currentPage'],
      items: ClassModel.parseList(json['classes']),
    );
  }
}
