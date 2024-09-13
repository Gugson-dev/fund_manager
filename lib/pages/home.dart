import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction_model.dart';
import '../widgets/app_bar.dart';
import '../widgets/transactions_history.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> 
    with SingleTickerProviderStateMixin {
  List<TransactionModel> transactions = [];
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController valueController = TextEditingController();
  late TabController _tabController;
  

  @override
  void initState(){
    super.initState();
    _getTransactions();
    _tabController = TabController(initialIndex: 0, length: 2, vsync: this);
  }

  void _getTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      final transactionsData = prefs.getString('transactions');
      
      if (transactionsData != null) {
        final decodedData = json.decode(transactionsData) as List;
        transactions.addAll(
          decodedData.map((transactionMap) => TransactionModel.fromJson(transactionMap)).toList()
        );
      }
    });
  }

  void _saveTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('transactions', json.encode(transactions));
  }

  void clearControllers() {
    titleController.clear();
    descriptionController.clear();
    valueController.clear();
    _tabController.index = 0;
  }

  Future<void> showAddTransactionDialog(BuildContext context) async {
    bool isExpense = false;
    return showDialog(
      useSafeArea: true,
      barrierDismissible: false,
      context: context, 
      builder: (context) {
        return ScaffoldMessenger(
          child: Builder(
            builder: (context) {
              return Scaffold(
                backgroundColor: Colors.transparent,
                body: AlertDialog(
                  title: TabBar(
                    controller: _tabController,
                    onTap: (value) {
                        if (_tabController.index == 0) {
                          isExpense = false;
                        } else {
                          isExpense = true;
                        }
                    },
                    tabs: const [
                      Tab(
                        child: Text('Wpłata')
                      ),
                      Tab(
                        child: Text('Wydatek'),
                      )
                    ],
                  ),
                  content: SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width*0.3
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 10,),
                          TextField(
                            controller: titleController,
                            decoration: const InputDecoration(
                              labelText: 'Tytuł transakcji',
                            ),
                          ),
                          const SizedBox(height: 20,),
                          TextField(
                            controller: descriptionController,
                            minLines: 1,
                            maxLines: 4,
                            decoration: const InputDecoration(
                              labelText: 'Opis',
                            ),
                          ),
                          const SizedBox(height: 20,),
                          TextField(
                            controller: valueController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Kwota',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    ElevatedButton(
                      onPressed: (){
                        Navigator.pop(context);
                      }, 
                      child: const Text('Zamknij')
                      ),
                    ElevatedButton(
                      onPressed: (){
                        setState(() {
                          double? value = double.tryParse(valueController.text);
                          if (value != null) {
                            if (isExpense) {
                              value *= -1;
                            }
                            transactions.add(
                              TransactionModel(
                                title: titleController.text, 
                                description: descriptionController.text, 
                                value: value, 
                                date: DateTime.now(),
                                isExpense: isExpense
                              )
                            );
                            _saveTransactions();
                            Navigator.pop(context);
                          } else {
                            const snackBar = SnackBar(
                              content: SelectableText('Źle wypełniona kwota'),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          }
                        });
                      },
                      child: const Text('Dodaj')
                    )
                  ],
                )
              );   
            }
          )
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
      body:  LayoutBuilder(builder: (context, constraints) {
        return SafeArea(
          child: ListView(
            children: [
              SizedBox(
                height: constraints.maxHeight,
                width: constraints.maxWidth,
                child: Column(
                  children: [              
                    //searchField(),
                    const SizedBox(height: 20,),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          clearControllers();
                          showAddTransactionDialog(context);
                        }, 
                        child: const Text('Dodaj transakcje')
                      ),
                    ),
                    const SizedBox(height: 20,),
                    const Text(
                      'Twoje transakcje',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w600
                      ),
                    ),
                    const SizedBox(height: 15,),
                    Expanded(
                      child: transactionHistory(transactions, context, () {setState(() {_saveTransactions();});}, _tabController)
                    ),
                  ],
                )
              )
            ],
          ),
        );
      }),
    );
  }
}