import 'package:gms_flutter_windows/Models/ClassModel.dart';
import 'package:gms_flutter_windows/Models/UserModel.dart';

class SubscriptionModel {
  final int id;
  final DateTime paymentDate;
  final double paymentAmount;
  final double discountPercentage;
  final UserModel user;
  final ClassModel aClass;

  SubscriptionModel({
    required this.id,
    required this.paymentDate,
    required this.paymentAmount,
    required this.discountPercentage,
    required this.user,
    required this.aClass,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['id'],
      paymentDate: DateTime.parse(json['paymentDate']),
      paymentAmount: (json['paymentAmount'] as num).toDouble(),
      discountPercentage: (json['discountPercentage'] as num).toDouble(),
      user: UserModel.fromJson(json['user']),
      aClass: ClassModel.fromJson(json['aclass']),
    );
  }

  static List<SubscriptionModel> parseList(List<dynamic> jsonList) {
    return jsonList.map((e) => SubscriptionModel.fromJson(e)).toList();
  }
}
