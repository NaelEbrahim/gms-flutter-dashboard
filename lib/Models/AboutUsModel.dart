class AboutUsModel {
  final int id;
  String gymName;
  String gymDescription;
  String ourMission;
  String ourVision;
  String facebookLink;
  String instagramLink;
  String twitterLink;

  AboutUsModel({
    required this.id,
    required this.gymName,
    required this.gymDescription,
    required this.ourMission,
    required this.ourVision,
    required this.facebookLink,
    required this.instagramLink,
    required this.twitterLink,
  });

  factory AboutUsModel.fromJson(Map<String, dynamic> json) {
    return AboutUsModel(
      id: json['id'],
      gymName: json['gymName'] ?? '',
      gymDescription: json['gymDescription'] ?? '',
      ourMission: json['ourMission'] ?? '',
      ourVision: json['ourVision'] ?? '',
      facebookLink: json['facebookLink'] ?? '',
      instagramLink: json['instagramLink'] ?? '',
      twitterLink: json['twitterLink'] ?? '',
    );
  }
}
