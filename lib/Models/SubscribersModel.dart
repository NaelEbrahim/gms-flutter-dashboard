import 'package:gms_flutter_windows/Models/UserModel.dart';

class SubscribersModel {
  final Map<String, bool> subscribersStatus;
  final List<UserModel> subscribers;

  SubscribersModel({
    required this.subscribersStatus,
    required this.subscribers,
  });

  factory SubscribersModel.fromJson(Map<String, dynamic> json) {
    return SubscribersModel(
      subscribersStatus: Map<String, bool>.from(
        json['subscribersStatus'] ?? {},
      ),
      subscribers: (json['subscribers'] as List? ?? [])
          .map((e) => UserModel.fromJson(e))
          .toList(),
    );
  }
}
