import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fund_manager/my_extensions.dart';
import 'package:fund_manager/pages/savings.dart';
import 'package:fund_manager/widgets/linechart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction_model.dart';
import '../widgets/app_bar.dart';
import '../widgets/dialogs.dart';
import 'transaction_history.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}


class _HomeState extends State<Home> with SingleTickerProviderStateMixin{

  List<TransactionModel> transactions = [];
  List<String> categories = [];

  late TabController _tabController;
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController valueController = TextEditingController();

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
    titleController.clear();
    descriptionController.clear();
    valueController.clear();
  }

  void onUpdate() {
    setState(() {});
    _saveData();
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
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          clearControllers();
                          showTransactionDialog(context, onUpdate, _tabController, categories, transactions, false);
                        }, 
                        child:  const Icon(CupertinoIcons.plus_app, //zrobić grubszy plus
                        size: 30,)
                      ),
                      const Text(
                        'Dodaj transakcje',
                        style: TextStyle(
                          color: Colors.black
                        ),
                      )
                    ],
                  ),
                  const SizedBox(width: 20,),
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const History())  
                          );
                        }, 
                        child: const Icon(
                          CupertinoIcons.list_dash,
                          size: 30,
                        )
                      ),
                      const Text(
                        'Historia',
                        style: TextStyle(
                          color: Colors.black
                        ),
                      )

                    ],
                  ),
                  const SizedBox(width: 20,),
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const Savings())  
                          );
                        },
                        child: const Icon(
                          CupertinoIcons.money_dollar_circle,
                          size: 30,
                        )
                      ),
                      const Text(
                        'Cele oszczędnościowe',
                        style: TextStyle(
                          color: Colors.black
                        ),
                      )
                    ],
                  )
                ],
              ),
              const SizedBox(height: 10,),
              Container(
                margin: const EdgeInsets.only(left: 50,right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                  SizedBox(
                    height: 400,
                    width: MediaQuery.of(context).size.width*0.6,
                    child:
                      const LineChartSample1()
                   /* Padding(
                    padding: const EdgeInsets.all(30),
                      child: PieChart(PieChartData(
                        centerSpaceRadius: 5,
                        borderData: FlBorderData(show: false),
                        sectionsSpace: 2,
                        sections: [
                          PieChartSectionData(value: 35, color: Colors.purple, radius: 100),
                          PieChartSectionData(value: 40, color: Colors.amber, radius: 100),
                          PieChartSectionData(value: 55, color: Colors.green, radius: 100),
                          PieChartSectionData(value: 70, color: Colors.orange, radius: 100),
                        ]
                      ))
                  ) */,
                ),
                    Container(
                      margin: const EdgeInsets.only(top: 30),
                      decoration: const BoxDecoration(
                        //color: Colors.blueGrey,
                        border: Border(top: BorderSide(width: 8),left: BorderSide(width: 5),right: BorderSide(width: 5),bottom: BorderSide(width: 3)),
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(5),topRight: Radius.circular(5)),
                      ),
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
                          const SizedBox(height: 5,),
                          Container(
                            height: MediaQuery.of(context).size.height*0.50,
                            width: MediaQuery.of(context).size.width*0.3,
                            decoration: const BoxDecoration(
                              //color: Colors.blueGrey,
                              border: Border(top: BorderSide(width: 5)),
                              //borderRadius: BorderRadius.only(bottomRight: Radius.circular(30)),
                            ),
                            child: PageView(
                              physics: const NeverScrollableScrollPhysics(),
                              children: [
                                LayoutBuilder(builder: (context, constraints) {
                                  return SizedBox(
                                    height: constraints.maxHeight,
                                    width: constraints.maxWidth,
                                    child: Column(
                                      children: [              
                                        Expanded(
                                          child: ListView.separated(
                                            itemCount: transactions.length < 5 ? transactions.length : 5,
                                            scrollDirection: Axis.vertical,
                                            separatorBuilder: (context, index) => const SizedBox(height: 4,),
                                            itemBuilder: (context, index) {
                                              String value = transactions[index].value;
                                              return MouseRegion(
                                                cursor: SystemMouseCursors.click,
                                                child: GestureDetector(
                                                  onTap: (){
                                                    Navigator.pushReplacement(
                                                      context,
                                                      MaterialPageRoute(builder: (context) => const History(),
                                                      settings: RouteSettings(
                                                        arguments: index)
                                                      )  
                                                    );
                                                  },
                                                  child: Card(
                                                    //shadowColor: Colors.black,
                                                    elevation: 6,
                                                    clipBehavior: Clip.antiAlias,
                                                    child: ListTile(
                                                      tileColor: Colors.black,
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
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  ),
                                                ),
                                              );
                                            }
                                          ),
                                        ),
                                      ],
                                    )
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
/*               const SizedBox(
                height: 500,
                width: 500,
                child:
                LineChartSample1()
                 /* Padding(
                  padding: const EdgeInsets.all(30),
                    child: PieChart(PieChartData(
                      centerSpaceRadius: 5,
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 2,
                      sections: [
                        PieChartSectionData(value: 35, color: Colors.purple, radius: 100),
                        PieChartSectionData(value: 40, color: Colors.amber, radius: 100),
                        PieChartSectionData(value: 55, color: Colors.green, radius: 100),
                        PieChartSectionData(value: 70, color: Colors.orange, radius: 100),
                      ]
                    ))
                ) */,
              ), */
            ],
          )
        );
      }),
    );
  }
}