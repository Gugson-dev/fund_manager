import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../models/transaction_model.dart';
import '../widgets/app_bar.dart';
import '../widgets/search_field.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

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
      body:  Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          searchField(),
          const SizedBox(height: 40,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 20.0),
                child: Text(
                  'Twoje transakcje',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w600
                  ),
                ),
              ),
              const SizedBox(height: 15,),
              Container(
                height: 200,
                color: Colors.black,
                child: ListView.separated(
                  itemCount: transactions.length,
                  scrollDirection: Axis.vertical,
                  padding: const EdgeInsets.only(
                    top: 10,
                    left: 20,
                    right: 20
                  ),
                  separatorBuilder: (context, index) => const SizedBox(height: 25,),
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(6)
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            transactions[index].title,
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.white
                            ),
                          ),
                          Text(
                            transactions[index].description,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 20,
                            ),
                          ),
                          Text(
                            transactions[index].value.toString(),
                            style: TextStyle(
                              color: transactions[index].value >= 0 ? Colors.green : Colors.red 
                            ),
                          ),
                          Text(
                            transactions[index].date.toString(),
                            style: const TextStyle(
                              color: Colors.white
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),  
              )
            ],
          )
        ],
      ),
    );
  }
}