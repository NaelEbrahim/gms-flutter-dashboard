import 'UserModel.dart';

class ArticleModel {
  final int id;
  final UserModel admin;
  final String title;
  final String content;
  final String wikiType;
  final DateTime createdAt;
  final DateTime? lastModifiedAt;
  final int minReadTime;

  ArticleModel({
    required this.id,
    required this.admin,
    required this.title,
    required this.content,
    required this.wikiType,
    required this.createdAt,
    this.lastModifiedAt,
    required this.minReadTime,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      id: json['id'],
      admin: UserModel.fromJson(json['admin']),
      title: json['title'],
      content: json['content'],
      wikiType: json['wikiType'],
      createdAt: DateTime.parse(json['createdAt']),
      lastModifiedAt: json['lastModifiedAt'] != null
          ? DateTime.parse(json['lastModifiedAt'])
          : null,
      minReadTime: json['minReadTime'],
    );
  }

  static List<ArticleModel> parseList(List<dynamic> jsonList) {
    return jsonList.map((e) => ArticleModel.fromJson(e)).toList();
  }
}

class GetArticlesModel {
  final int count;
  final int totalPages;
  final int currentPage;
  final List<ArticleModel> items;

  GetArticlesModel({
    required this.count,
    required this.totalPages,
    required this.currentPage,
    required this.items,
  });

  factory GetArticlesModel.fromJson(Map<String, dynamic> json) {
    return GetArticlesModel(
      count: json['count'],
      totalPages: json['totalPages'],
      currentPage: json['currentPage'],
      items: ArticleModel.parseList(json['articles']),
    );
  }
}
