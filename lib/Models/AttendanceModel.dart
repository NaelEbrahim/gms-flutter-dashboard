class AttendanceModel {
  String? user;
  List<DateTime> dates;

  AttendanceModel({this.user, required this.dates});

  static List<AttendanceModel> listFromJson(dynamic json) {
    final List<AttendanceModel> list = [];
    if (json is Map<String, dynamic> && json.isNotEmpty) {
      json.forEach((key, value) {
        list.add(
          AttendanceModel(
            user: key,
            dates: (value as List)
                .map((e) => DateTime.parse(e.toString()))
                .toList(),
          ),
        );
      });
    } else if (json is List && json.isNotEmpty) {
      list.add(
        AttendanceModel(
          dates: json.map((e) => DateTime.parse(e.toString())).toList(),
        ),
      );
    }
    return list;
  }
}
