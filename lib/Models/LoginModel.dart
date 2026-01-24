import 'package:gms_flutter_windows/Models/UserModel.dart';

class LoginModel {
  final UserModel user;
  final String accessToken;
  final String refreshToken;

  LoginModel({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      user: UserModel.fromJson(json),
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
    );
  }
}
