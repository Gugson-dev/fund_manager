
class TransactionModel {
  String title;
  String description;
  double? value;
  DateTime date;
  bool isExpense;

  TransactionModel({
    required this.title,
    required this.description,
    required this.value,
    required this.date,
    required this.isExpense
  });

  get length => null;

  static List<TransactionModel> getTransactions() {
    List<TransactionModel> transactions = [];
    return transactions;
  }
}