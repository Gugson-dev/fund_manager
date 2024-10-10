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
    
    BigInt zero = BigInt.from(0);
    BigInt one = BigInt.from(1);
    BigInt ten = BigInt.from(10);
    BigInt hundred = BigInt.from(100);
    BigInt cale = BigInt.from(0);
    BigInt reszta = BigInt.from(0);
    String saldo = '0';
    String resztaTxt = '';
    if (transakcje.isNotEmpty) {
      saldo = '';
      for (int i = 0; i < transakcje.length; i++) {
        TransactionModel index = transakcje[i];
        if (index.isExpense) {
          cale -= index.fullValue();

          if (reszta > zero && (reszta - index.changeValue()) < zero){
            cale -= one;
            reszta += hundred;
          } else if (reszta < zero && (reszta - index.changeValue()) < -hundred){
            cale -= one;
            reszta += hundred;
          }
          reszta -= index.changeValue();
        }
        else {
          cale += index.fullValue();

          if (reszta < zero && (reszta + index.changeValue()) > zero ){
            cale += one;
            reszta -= hundred;
          } else if (reszta > zero && (reszta + index.changeValue()) > hundred){
            cale += one;
            reszta -= zero;
          }
          reszta += index.changeValue();
        }
      }

      if (reszta < zero){
        resztaTxt = reszta.toString().split('-')[1];
      } else {
        resztaTxt = '$reszta';
      }
      if (reszta == zero) {
        saldo += '$cale';        
      } else {
        if (reszta > -ten && reszta < ten) {
          saldo += '$cale.0$resztaTxt';
        } else{
          saldo += '$cale.$resztaTxt';
        }
      }
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