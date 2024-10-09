import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/transaction_model.dart';
import '../widgets/app_bar.dart';
import 'transaction_history.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  List<TransactionModel> transactions = [];
  double balance = 0;

  @override
  void initState(){
    super.initState();
    _getTransactions();
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
 
  String pokaSaldo (List<TransactionModel> transakcje){
    
    int cale = 0;
    int reszta = 0;
    String saldo = '0';
    if (transakcje.isNotEmpty) {
      for (var i = 1; i <= transakcje.length; i++) {
        TransactionModel index = transakcje[i];
        if (index.isExpense) {
          cale -= index.fullValue();
          reszta -= index.changeValue();
        }
        else {
          cale += index.fullValue();
          reszta += index.changeValue();
        }
      }
      saldo = '$cale.$reszta';
    }

    return saldo;
  } 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
      body: LayoutBuilder(builder: (context, constraints){
        return SafeArea(
          child: Column(
            children: [
              Text(
                'Saldo: ${pokaSaldo(transactions)} zł',
                style: GoogleFonts.robotoCondensed(
                  fontSize: 30,
                  color: Colors.black
                ),
              ),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const History())  
                    );
                  }, 
                  child: const Text('Historia')
                ),
              ),
            ],
          )
        );
      }),
    );
  }
}