import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../widgets/app_bar.dart';
import '../widgets/search_field.dart';
import '../widgets/transactions_history.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<TransactionModel> transactions = [];

  void _getTransactions() {
    transactions = TransactionModel.getTransactions();
  }

  @override
  Widget build(BuildContext context) {
    _getTransactions();

    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: appBar(),
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
                      child: transactionHistory(transactions, context)
                    )
                  ],
                )
              )
            ],
          ),
        );
      }
      ),
    );
  }
}