class SavingModel {
  String title;
  String description;
  String donated;
  String goal;
  String photo;

  SavingModel ({
    required this.title,
    required this.description,
    required this.donated,
    required this.goal,
    this.photo = ''
  }
  );

  factory SavingModel.fromJson(Map<String, dynamic> json) {
    return SavingModel(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      donated: json['donated'] ?? '0',
      goal: json['goal'] ?? '0',
      photo: json['photo'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'donated': donated,
      'goal': goal,
      'photo': photo,
    };
  }

  BigInt fullValue(String value) {
    BigInt amount = BigInt.parse(value.split('.')[0]);
    return amount;
  }

  BigInt changeValue(String value) {
    BigInt amount = BigInt.parse(value.split('.')[1]);
    return amount;
  }
}