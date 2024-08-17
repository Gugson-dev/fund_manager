
class TransactionModel {
  String title;
  String description;
  double? value;
  DateTime date;

  TransactionModel({
    required this.title,
    required this.description,
    required this.value,
    required this.date
  });

  get length => null;

  static List<TransactionModel> getTransactions() {
    List<TransactionModel> transactions = [];
    return transactions;
  }
}