import 'package:gms_flutter_windows/Models/UserModel.dart';

class UserPrivateCoachModel {
  final UserModel coach;
  final bool isActive;
  final String startedAt;

  UserPrivateCoachModel({
    required this.coach,
    required this.isActive,
    required this.startedAt,
  });

  factory UserPrivateCoachModel.fromJson(Map<String, dynamic> json) {
    return UserPrivateCoachModel(
      coach: UserModel.fromJson(json['item']),
      isActive: json['isActive'],
      startedAt: json['startedAt'],
    );
  }

  static List<UserPrivateCoachModel> parseList(List<dynamic> jsonList) {
    return jsonList.map((e) => UserPrivateCoachModel.fromJson(e)).toList();
  }
}
