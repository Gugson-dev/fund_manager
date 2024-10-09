class TransactionModel {
  String title;
  String description;
  String value;
  DateTime date;
  bool isExpense;

  TransactionModel({
    required this.title,
    required this.description,
    required this.value,
    required this.date,
    required this.isExpense,
  }
  );

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      value: json['value'] ?? '0',
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      isExpense: json['isExpense'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'value': value,
      'date': date.toIso8601String(),
      'isExpense': isExpense,
    };
  }

  int fullValue() {
    int amount = int.parse(value.split('.')[0]);
    return amount;
  }

  int changeValue() {
    int amount = int.parse(value.split('.')[1]);
    return amount;
  }
}