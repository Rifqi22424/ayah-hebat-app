class Question {
  int id;
  String question;
  String? answer;
  bool? isAnswer;

  Question(
      {required this.id, required this.question, this.answer, this.isAnswer});

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] ?? 0,
      question: json['question'] ?? "",
      answer: json['answer'] ?? "",
      isAnswer: json['isAnswer'] ?? false,
    );
  }
}
