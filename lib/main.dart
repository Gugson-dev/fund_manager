import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(const FundManagerApp());
}

class FundManagerApp extends StatelessWidget {
  const FundManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fund Manager',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blueGrey,
        ).copyWith(
          secondary: Colors.amber,
          onPrimary: Colors.white,
        ),
        textTheme: TextTheme(
          headlineLarge: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey[800]),
          titleLarge: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey[800]),
          bodyLarge: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey[800]),
          bodyMedium: TextStyle(fontSize: 14, color: Colors.blueGrey[700]),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: const OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blueGrey[800]!),
          ),
          labelStyle: TextStyle(color: Colors.blueGrey[800]),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
            foregroundColor: Colors.white,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.amber,
          ),
        ),
      ),
      home: const FundManagerHomePage(),
    );
  }
}

class FundManagerHomePage extends StatefulWidget {
  const FundManagerHomePage({super.key});

  @override
  State createState() => _FundManagerHomePageState();
}

class _FundManagerHomePageState extends State<FundManagerHomePage> {
  double _currentFunds = 0;
  final List<Map<String, dynamic>> _transactions = [];
  final TextEditingController _fundController = TextEditingController();
  final TextEditingController _expenseController = TextEditingController();
  final TextEditingController _incomeController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  double _monthlyBudget = 0;
  final List<Map<String, dynamic>> _filteredTransactions = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentFunds = prefs.getDouble('currentFunds') ?? 0;
      _monthlyBudget = prefs.getDouble('monthlyBudget') ?? 0;
      final transactionsData = prefs.getString('transactions');
      if (transactionsData != null) {
        _transactions.addAll(
          List<Map<String, dynamic>>.from(json.decode(transactionsData)),
        );
        _transactions.sort(
            (a, b) => DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));
      }
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble('currentFunds', _currentFunds);
    prefs.setDouble('monthlyBudget', _monthlyBudget);
    prefs.setString('transactions', json.encode(_transactions));
  }

  void _addFunds() {
    if (_fundController.text.isEmpty) return;
    setState(() {
      double? funds = double.tryParse(_fundController.text);
      if (funds != null) {
        _currentFunds = funds;
      }
      _fundController.clear();
    });
    _saveData();
  }

  void _showAddTransactionDialog({required bool isExpense}) {
    final title = isExpense ? 'Add Expense' : 'Add Income';
    final amountController = isExpense ? _expenseController : _incomeController;
    _dateController.text = DateTime.now().toLocal().toString().split('.')[0]; // Automatically fill with today's date and time

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Enter Title',
                  ),
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Enter Description',
                  ),
                ),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(
                    labelText: 'Enter Amount',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: AbsorbPointer(
                    child: TextField(
                      controller: _dateController,
                      decoration: const InputDecoration(
                        labelText: 'Select Date',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _addTransaction(isExpense);
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = picked.toLocal().toString().split(' ')[0];
      });
    }
  }

  String categorizeTransaction(String title, String description) {
    final text = ('$title $description').toLowerCase();

    for (var category in categories.keys) {
      for (var keyword in categories[category]!) {
        if (text.contains(keyword)) {
          return category;
        }
      }
    }

    return "Miscellaneous";
  }

  void _addTransaction(bool isExpense) {
    final amountController = isExpense ? _expenseController : _incomeController;
    if (amountController.text.isEmpty || _titleController.text.isEmpty || _dateController.text.isEmpty) return;

    double? amount = double.tryParse(amountController.text);
    if (amount != null) {
      DateTime date = DateTime.parse(_dateController.text);
      String category = categorizeTransaction(_titleController.text, _descriptionController.text);

      setState(() {
        if (isExpense && amount <= _currentFunds) {
          _currentFunds -= amount;
          _transactions.add({
            "type": "expense",
            "title": _titleController.text,
            "description": _descriptionController.text,
            "amount": amount,
            "date": date.toIso8601String(),
            "category": category,
          });
        } else if (!isExpense) {
          _currentFunds += amount;
          _transactions.add({
            "type": "income",
            "title": _titleController.text,
            "description": _descriptionController.text,
            "amount": amount,
            "date": date.toIso8601String(),
            "category": category,
          });
        }
        amountController.clear();
        _titleController.clear();
        _descriptionController.clear();
        _dateController.clear();
        // Sorting the transactions by date and time in descending order
        _transactions.sort(
            (a, b) => DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));
      });
      _saveData();
    }
  }

  void _updateBudget() {
    if (_budgetController.text.isEmpty) return;
    setState(() {
      double? budget = double.tryParse(_budgetController.text);
      if (budget != null) {
        _monthlyBudget = budget;
      }
      _budgetController.clear();
    });
    _saveData();
  }

  void _searchTransactions() {
    setState(() {
      _isSearching = true;
      _filteredTransactions.clear();
      _filteredTransactions.addAll(
        _transactions.where((transaction) {
          return transaction['title']
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()) ||
              transaction['description']
                  .toLowerCase()
                  .contains(_searchController.text.toLowerCase());
        }).toList(),
      );
    });
  }

  void _clearSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
    });
  }

  @override
  void dispose() {
    _fundController.dispose();
    _expenseController.dispose();
    _incomeController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    _budgetController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transactionsToShow = _isSearching ? _filteredTransactions : _transactions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fund Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              _showSearchDialog();
            },
          ),
          IconButton(
            icon: const Icon(Icons.pie_chart),
            onPressed: () {
              _showReportDialog();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Current Funds: \$${_currentFunds.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            Text(
              'Monthly Budget: \$${_monthlyBudget.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            if (_currentFunds == 0) ...[
              TextField(
                controller: _fundController,
                decoration: const InputDecoration(
                  labelText: 'Enter Initial Funds',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addFunds,
                child: const Text('Set Initial Funds'),
              ),
            ] else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => _showAddTransactionDialog(isExpense: true),
                    child: const Text('Add Expense'),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () => _showAddTransactionDialog(isExpense: false),
                    child: const Text('Add Income'),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () => _showUpdateBudgetDialog(),
                    child: const Text('Set Budget'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: transactionsToShow.length,
                  itemBuilder: (context, index) {
                    final transaction = transactionsToShow[index];
                    final isExpense = transaction['type'] == 'expense';
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                      child: ExpansionTile(
                        title: Text(
                          transaction["title"],
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              transaction["date"].toString().split('T')[0],
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              'Category: ${transaction["category"]}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Description: ${transaction["description"]}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Amount: ${isExpense ? '-' : '+'}\$${transaction["amount"].toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: isExpense ? Colors.red : Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Search Transactions'),
          content: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: 'Enter search term',
            ),
            onChanged: (value) {
              _searchTransactions();
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                _clearSearch();
                Navigator.of(context).pop();
              },
              child: const Text('Clear'),
            ),
            ElevatedButton(
              onPressed: () {
                _searchTransactions();
                Navigator.of(context).pop();
              },
              child: const Text('Search'),
            ),
          ],
        );
      },
    );
  }

  void _showUpdateBudgetDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update Monthly Budget'),
          content: TextField(
            controller: _budgetController,
            decoration: const InputDecoration(
              labelText: 'Enter new budget',
            ),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _updateBudget();
                Navigator.of(context).pop();
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Monthly Report'),
          content: _buildMonthlyReport(),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMonthlyReport() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    double totalIncome = 0;
    double totalExpenses = 0;

    for (var transaction in _transactions) {
      final date = DateTime.parse(transaction['date']);
      if (date.isAfter(startOfMonth) && date.isBefore(endOfMonth)) {
        if (transaction['type'] == 'income') {
          totalIncome += transaction['amount'];
        } else if (transaction['type'] == 'expense') {
          totalExpenses += transaction['amount'];
        }
      }
    }

    final balance = totalIncome - totalExpenses;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Total Income: \$${totalIncome.toStringAsFixed(2)}',
          style: const TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          'Total Expenses: \$${totalExpenses.toStringAsFixed(2)}',
          style: const TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          'Balance: \$${balance.toStringAsFixed(2)}',
          style: TextStyle(
            color: balance >= 0 ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

const Map<String, List<String>> categories = {
  "Food": ["restaurant", "groceries", "meal", "lunch", "breakfast", "shopping"],
  "Transport": ["taxi", "bus", "train", "flight", "uber"],
  "Entertainment": ["movie", "concert", "game", "party"],
  "Health": ["doctor", "medicine", "pharmacy", "hospital"],
  "Shopping": ["clothes", "electronics", "gifts", "mall"],
  "Utilities": ["electricity", "water", "internet", "gas", "rent"],
  "Miscellaneous": []
};
