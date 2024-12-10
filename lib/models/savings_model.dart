class SavingModel {
  String title;
  String description;
  String value;

  SavingModel ({
    required this.title,
    required this.description,
    required this.value,
  }
  );

  factory SavingModel.fromJson(Map<String, dynamic> json) {
    return SavingModel(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      value: json['value'] ?? '0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'value': value,
    };
  }

  BigInt fullValue() {
    BigInt amount = BigInt.parse(value.split('.')[0]);
    return amount;
  }

  BigInt changeValue() {
    BigInt amount = BigInt.parse(value.split('.')[1]);
    return amount;
  }
}