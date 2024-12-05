import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fund_manager/my_extensions.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/transaction_model.dart';
import '../widgets/app_bar.dart';
import '../widgets/transaction_dialog.dart';
import 'transaction_history.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> 
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
 
  String pokaSaldo (List<TransactionModel> transakcje){ 
    BigInt zero = BigInt.from(0);
    BigInt one = BigInt.from(1);
    BigInt ten = BigInt.from(10);
    BigInt hundred = BigInt.from(100);
    BigInt fulls = zero;
    BigInt change = zero;
    String balance = '0';
    String changeTxt = '';

    if (transakcje.isNotEmpty) {
      balance = '';
      for (int i = 0; i < transakcje.length; i++) {
        TransactionModel index = transakcje[i];
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
      body: LayoutBuilder(builder: (context, constraints){
        return SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 10,),
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
              const SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      clearControllers();
                      showTransactionDialog(context, onUpdate, _tabController, categories, transactions, false);
                    }, 
                    child: const Text('Dodaj transakcje')
                  ),
                  const SizedBox(width: 20,),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const History())  
                      );
                    }, 
                    child: const Text('Historia')
                  ),
                ],
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  children: [
                    const Text(
                      'Ostatnie transakcje',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.w700
                      ),
                    ),
                    const SizedBox(height: 10,),
                    Container(
                      height: MediaQuery.of(context).size.height*0.27,
                      width: MediaQuery.of(context).size.width*0.3,
                      margin: const EdgeInsets.only(left: 8),
                      decoration: const BoxDecoration(
                        //color: Colors.blueGrey,
                        border: Border(top: BorderSide(width: 5), right: BorderSide(width: 7), left:  BorderSide(width: 7), bottom: BorderSide(width: 10)),
                        borderRadius: BorderRadius.only(bottomRight: Radius.circular(30)),
                      ),
                      child: PageView(
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: (){
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => const History())  
                                );
                              },
                              child: LayoutBuilder(builder: (context, constraints) {
                                return ListView(
                                  //physics: const NeverScrollableScrollPhysics(),
                                 // primary: false,
                                  children: [
                                    SizedBox(
                                      height: constraints.maxHeight,
                                      width: constraints.maxWidth,
                                      child: Column(
                                        children: [              
                                          Expanded(
                                            child: Container(
                                              //margin: const EdgeInsets.only(left: 20, right: 20),
                                              child: ListView.separated(
                                                itemCount: 3,
                                                scrollDirection: Axis.vertical,
                                                separatorBuilder: (context, index) => const SizedBox(height: 4,),
                                                itemBuilder: (context, index) {
                                                  String value = transactions[index].value;
                                                  return Card(
                                                    //shadowColor: Colors.black,
                                                    elevation: 6,
                                                    clipBehavior: Clip.antiAlias,
                                                    child: ListTile(
                                                      mouseCursor: SystemMouseCursors.click,
                                                      title: Row(
                                                        mainAxisSize: MainAxisSize.max,
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Expanded(
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
                                                          Expanded(
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
                                                  );
                                                }
                                              )
                                            )
                                          ),
                                        ],
                                      )
                                    )
                                  ],
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              )
            ],
          )
        );
      }),
    );
  }
}