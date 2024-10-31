import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fund_manager/my_extensions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction_model.dart';
import '../one_period_input_formatter.dart';
import '../widgets/app_bar.dart';
import '../widgets/transactions_history.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<History> 
    with SingleTickerProviderStateMixin {
  List<TransactionModel> transactions = [];
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController valueController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  late TabController _tabController;
  List<String> categories = [];
  

  @override
  void initState(){
    super.initState();
    _getData();
    _tabController = TabController(initialIndex: 0, length: 2, vsync: this);
  }

  void _getData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      final transactionsData = prefs.getString('transactions');
      final categoriesData = prefs.getStringList('categories');

      if (categoriesData != null) {
        categories = categoriesData;
      }

      if (transactionsData != null) {
        final decodedData = json.decode(transactionsData) as List;
        transactions.addAll(
          decodedData.map((transactionMap) => TransactionModel.fromJson(transactionMap)).toList()
        );
      }
    });
  }

  void _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('transactions', json.encode(transactions));
    prefs.setStringList('categories', categories);
  }

  void clearControllers() {
    titleController.clear();
    descriptionController.clear();
    valueController.clear();
    _tabController.index = 0;
    categoryController.clear();
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
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')), // Allow only numbers and periods
                              OnePeriodInputFormatter(), // Custom formatter for one period
                            ],
                          ),
                          const SizedBox(height: 20,),
                          DropdownMenu<String>(
                            expandedInsets: EdgeInsets.zero,
                            label: const Text('Kategoria'),
                            hintText: 'Wpisz lub wyszukaj kategorie',
                            controller: categoryController,
                            dropdownMenuEntries: categories.map((String value){
                              return DropdownMenuEntry(value: value, label: value.capitalize());
                            }).toList()
                          )
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
                            if (!valueController.text.contains('.')) {
                              valueController.text += '.00';
                            } else if (valueController.text.length == valueController.text.indexOf('.')+2) {
                              valueController.text += '0';
                            }
                            if (!categories.contains(categoryController.text.toLowerCase())) {
                              categories.add(categoryController.text.toLowerCase());
                            }
                            transactions.add(
                              TransactionModel(
                                title: titleController.text, 
                                description: descriptionController.text, 
                                value: valueController.text, 
                                date: DateTime.now(),
                                isExpense: isExpense,
                                category: categoryController.text.toLowerCase()
                              )
                            );
                            _saveData();
                            Navigator.pop(context);
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
                      child: transactionHistory(transactions, categories, context, () {setState(() {_getData();});}, _tabController)
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