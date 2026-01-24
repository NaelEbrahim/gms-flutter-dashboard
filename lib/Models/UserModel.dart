class UserModel {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String? profileImagePath;
  final String phoneNumber;
  final String gender;
  final String dob;
  final String? createdAt;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.profileImagePath,
    required this.phoneNumber,
    required this.gender,
    required this.dob,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      profileImagePath: json['profileImagePath'] as String?,
      phoneNumber: json['phoneNumber'],
      gender: json['gender'],
      dob: json['dob'],
      createdAt: json['createdAt'] as String?,
    );
  }

  static List<UserModel> parseList(List<dynamic> jsonList) {
    return jsonList.map((e) => UserModel.fromJson(e)).toList();
  }
}

class GetUsersModel {
  final int count;

  final int totalPages;

  final int currentPage;

  final List<UserModel> items;

  GetUsersModel({
    required this.count,
    required this.totalPages,
    required this.currentPage,
    required this.items,
  });

  factory GetUsersModel.fromJson(Map<String, dynamic> json) {
    return GetUsersModel(
      count: json['count'],
      totalPages: json['totalPages'],
      currentPage: json['currentPage'],
      items: UserModel.parseList(json['users']),
    );
  }
}
