
class TransactionModel {
  String title;
  String description;
  double value;
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

    transactions.add(
      TransactionModel(
        title: 'Jedzenie',
        description: 'Kupiłem se nicnacsy',
        value: 10.49,
        date: DateTime(2024,8,5)
      )
    );
    transactions.add(
      TransactionModel(
        title: 'Jedzenie',
        description: 'Kupiłem se nicnacsy',
        value: 10.49,
        date: DateTime(2024,8,5)
      )
    );
    transactions.add(
      TransactionModel(
        title: 'Jedzenie',
        description: 'Kupiłem se nicnacsy',
        value: 10.49,
        date: DateTime(2024,8,5)
      )
    );
    transactions.add(
      TransactionModel(
        title: 'Jedzenie',
        description: 'Kupiłem se nicnacsy',
        value: 10.49,
        date: DateTime(2024,8,5)
      )
    );
    transactions.add(
      TransactionModel(
        title: 'Jedzenie',
        description: 'Kupiłem se nicnacsy',
        value: 10.49,
        date: DateTime(2024,8,5)
      )
    );
    transactions.add(
      TransactionModel(
        title: 'Jedzenie',
        description: 'Kupiłem se nicnacsy',
        value: 10.49,
        date: DateTime(2024,8,5)
      )
    );
    transactions.add(
      TransactionModel(
        title: 'Jedzenie',
        description: 'Kupiłem se nicnacsy',
        value: 10.49,
        date: DateTime(2024,8,5)
      )
    );
    transactions.add(
      TransactionModel(
        title: 'Jedzenie',
        description: 'Kupiłem se nicnacsy',
        value: 10.49,
        date: DateTime(2024,8,5)
      )
    );
    transactions.add(
      TransactionModel(
        title: 'Jedzenie',
        description: 'Kupiłem se nicnacsy',
        value: 10.49,
        date: DateTime(2024,8,5)
      )
    );
    transactions.add(
      TransactionModel(
        title: 'Jedzenie',
        description: 'Kupiłem se nicnacsy',
        value: 10.49,
        date: DateTime(2024,8,5)
      )
    );

    return transactions;
  }
}