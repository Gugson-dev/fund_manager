import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fund_manager/my_extensions.dart';
import 'package:fund_manager/widgets/dialogs.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction_model.dart';
import '../widgets/app_bar.dart';

enum Menu {edytuj, usun}

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<History> 
    with SingleTickerProviderStateMixin {
      
  List<TransactionModel> transactions = [];
  List<String> categories = [];
  late TabController _tabController;
  

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
    _tabController.index = 0;
  }

  void onUpdate() {
    setState(() {});
    _saveData();
  }

  @override
  Widget build(BuildContext context) {
    final tile = ModalRoute.of(context)!.settings.arguments;
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
                    /*const SizedBox(height: 20,),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          clearControllers();
                          showTransactionDialog(context, onUpdate, _tabController, categories, transactions, false);
                        }, 
                        child: const Text('Dodaj transakcje')
                      ),
                    ),*/
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
                      child: Container(
                        margin: const EdgeInsets.only(left: 20, right: 20),
                        child: ListView.separated(
                          itemCount: transactions.length,
                          scrollDirection: Axis.vertical,
                          separatorBuilder: (context, index) => const SizedBox(height: 10,),
                          itemBuilder: (context, index) {
                            String value = transactions[index].value;
                            return Card(
                              clipBehavior: Clip.antiAlias,
                              child: ExpansionTile(
                                initiallyExpanded: tile == index,
                                title: LayoutBuilder(
                                  builder: (context, constraints) {
                                    return Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        ConstrainedBox(
                                          constraints: BoxConstraints(maxWidth: constraints.maxWidth*0.5),
                                          child: GestureDetector(
                                            onTap: () {
                                              Clipboard.setData(ClipboardData(text: transactions[index].title)).then((_) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    duration: Durations.long2,
                                                    showCloseIcon: true,
                                                    behavior: SnackBarBehavior.floating,
                                                    width: MediaQuery.of(context).size.width*0.3,
                                                    content: const Text('Title copied to clipboard')
                                                  )
                                                );
                                              });
                                            },
                                            child: Text(
                                              transactions[index].title.capitalize(),
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 25,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Flexible(
                                                flex: 1,
                                                child: Padding(
                                                  padding: const EdgeInsets.only(left: 8),
                                                  child: Text(
                                                    DateFormat('dd-MM-yyyy').format(transactions[index].date),
                                                    overflow: TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.grey
                                                    ),
                                                  ),
                                                ),
                                              ),    
                                              Expanded(
                                                flex: 10,
                                                child: Align(
                                                  alignment: Alignment.centerRight,
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(left: 8.0),
                                                    child: Text(
                                                      '${transactions[index].isExpense ? '-' : ''}${!value.contains('.') || value.length == value.indexOf('.')+1 || value.contains('.00') ? value.split('.')[0] : value} zł',
                                                      overflow: TextOverflow.ellipsis,
                                                      style: GoogleFonts.robotoCondensed(
                                                          fontSize: 20,
                                                          color: value == '0.00' ? Colors.grey : transactions[index].isExpense ? Colors.red : Colors.green
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    );
                                  },
                                ),
                                children: [
                                  const Divider(
                                    height: 2,
                                    thickness: 100,
                                    color: Colors.white,
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.only(
                                          left: 10,
                                          right: 10
                                        ),
                                        decoration: const BoxDecoration(
                                          color: Color.fromARGB(255, 63, 63, 63)
                                        ),
                                        child:Row(
                                          children: [
                                            Expanded(
                                              child: transactions[index].category.isEmpty ? 
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    transactions[index].description.capitalize(),
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 20,
                                                    ),
                                                  ),
                                                ],
                                              ) 
                                              :
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  const SizedBox(height: 2,),
                                                  Text(
                                                    'Kategoria: ${transactions[index].category.capitalize()}',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                  Text(
                                                    transactions[index].description.capitalize(),
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 20,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            PopupMenuButton<Menu>(
                                              tooltip: 'Opcje',
                                              itemBuilder: (BuildContext content) => <PopupMenuEntry<Menu>>[
                                                PopupMenuItem<Menu>(
                                                  value: Menu.edytuj,
                                                  onTap: () {
                                                    showTransactionDialog(context, onUpdate, _tabController, categories, transactions, true, transactions[index].isExpense, index);
                                                  },
                                                  child: const ListTile(
                                                    leading: Icon(
                                                      CupertinoIcons.square_pencil,
                                                      size: 20,
                                                    ),
                                                    title: Text('Edytuj'),
                                                    )
                                                ),
                                                PopupMenuItem<Menu>(
                                                  value: Menu.usun,
                                                  onTap: () {
                                                    setState(() {
                                                      transactions.removeAt(index);
                                                      _saveData();
                                                    });
                                                  },
                                                  child: const ListTile(
                                                    leading: Icon(
                                                      CupertinoIcons.trash,
                                                      size: 20,
                                                    ),
                                                    title: Text('Usun'),
                                                  )
                                                )
                                              ]
                                            )
                                          ],
                                        ),
                                      ),
                                    ]
                                  )
                                ]
                              )
                            );
                          }
                        )
                      )
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