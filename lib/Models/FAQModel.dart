class FAQModel {
  final int id;
  final String question;
  final String answer;

  FAQModel({required this.id, required this.question, required this.answer});

  factory FAQModel.fromJson(Map<String, dynamic> json) {
    return FAQModel(
      id: json['id'],
      question: json['question'] ?? '',
      answer: json['answer'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'question': question, 'answer': answer};
  }

  static List<FAQModel> parseList(List<dynamic> jsonList) {
    return jsonList.map((e) => FAQModel.fromJson(e)).toList();
  }
}
