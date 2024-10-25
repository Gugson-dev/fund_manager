import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/transaction_model.dart';
import '../one_period_input_formatter.dart';
import '../widgets/app_bar.dart';
import 'transaction_history.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin{

  List<TransactionModel> transactions = [];
  late AnimationController controller;
  String title = '';
  String description = '';
  String value = ''; 
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController valueController = TextEditingController();

  @override
  void initState(){
    super.initState();
    _getTransactions();
    controller = AnimationController(
      vsync: this, 
    )..addListener((){
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _getTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      final transactionsData = prefs.getString('transactions');
      final savingData = prefs.getStringList('savings');

      if (savingData != null) {
        title = savingData[0];
        description = savingData[1];
        value = savingData[2];
      }

      if (transactionsData != null) {
        final decodedData = json.decode(transactionsData) as List;
        transactions.addAll(
          decodedData.map((transactionMap) => TransactionModel.fromJson(transactionMap)).toList()
        );
      }
    });
  }

  void _saveSaving() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('savings', [titleController.text,descriptionController.text,valueController.text]);

  }
 
  String pokaSaldo (List<TransactionModel> transactions){ 
    BigInt zero = BigInt.from(0);
    BigInt one = BigInt.from(1);
    BigInt ten = BigInt.from(10);
    BigInt hundred = BigInt.from(100);
    BigInt fulls = zero;
    BigInt change = zero;
    String balance = '0';
    String changeTxt = '';

    if (transactions.isNotEmpty) {
      balance = '';
      for (int i = 0; i < transactions.length; i++) {
        TransactionModel index = transactions[i];
        if (index.isExpense) {
          fulls -= index.fullValue();

          if (change < zero && (change - index.changeValue()) < -hundred){
            fulls -= one;
            change += hundred;
          }
          change -= index.changeValue();
        }
        else {
          fulls += index.fullValue();

          if (change > zero && (change + index.changeValue()) > hundred){
            fulls += one;
            change -= hundred;
          }
          change += index.changeValue();
        }
      }

      if (change < zero){
        changeTxt = change.toString().split('-')[1];
      } else {
        changeTxt = '$change';
      }
      if (change == zero) {
        balance += '$fulls';        
      } else {
        if (change > -ten && change < ten) {
          balance += '$fulls.0$changeTxt';
        } else{
          balance += '$fulls.$changeTxt';
        }
      }
    }

    return balance;
  } 

  void clearControllers() {
    titleController.clear();
    descriptionController.clear();
    valueController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
      body: LayoutBuilder(builder: (context, constraints){
        return SafeArea(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Saldo: ',
                    style: GoogleFonts.robotoCondensed(
                      fontSize: 30,
                      color: Colors.black
                    ),
                  ),
                  Flexible(
                    child: Text(
                      pokaSaldo(transactions),
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.robotoCondensed(
                        fontSize: 30,
                        color: pokaSaldo(transactions) == '0' ? Colors.black : pokaSaldo(transactions).contains('-') ? Colors.red : Colors.green
                    
                      ),
                    ),
                  ),
                  Text(
                    ' zł',
                    style: GoogleFonts.robotoCondensed(
                      fontSize: 30,
                      color: Colors.black
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const History())  
                      );
                    }, 
                    child: const Text('Historia')
                  ),
                  ElevatedButton(
                    onPressed: () {
                      clearControllers();
                      addGoal(context);
                    },
                    child: const Text('Dodaj cel oszczczędnościowy')
                  )
                ],
              ),
              const SizedBox(height: 10,),

              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Twój cel: $title',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20
                    ),
                  ),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned.fill(
                        left: MediaQuery.of(context).size.width*0.25,
                        right: MediaQuery.of(context).size.width*0.25,
                        child: LinearProgressIndicator(
                          color: Colors.green,
                          backgroundColor: Colors.grey,
                          value: value.isEmpty ? 0.00 : double.parse(pokaSaldo(transactions)) / double.parse(value), // zmienić do BigInta
                          semanticsLabel: 'Twój cel $value',
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          '${!pokaSaldo(transactions).contains('.') || pokaSaldo(transactions).length == pokaSaldo(transactions).indexOf('.')+1 || pokaSaldo(transactions).contains('.00') ? pokaSaldo(transactions).split('.')[0] : pokaSaldo(transactions)} zł/${!value.contains('.') || value.length == value.indexOf('.')+1 || value.contains('.00') ? value.split('.')[0] : value} zł',
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.black
                          ),
                        )
                      )
                    ]
                  ),
                ],
              )
            ],
          )
        );
      }),
    );
  }

  Future<dynamic> addGoal(BuildContext context) {
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
                                  title: const Text('Wpisz dane celu'),
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
                                            _saveSaving();
                                            value = valueController.text;
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
}