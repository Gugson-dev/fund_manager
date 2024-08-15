
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
  
  Container transactionHistory(List<TransactionModel> transactions, BuildContext context) { 
    return Container(
              margin: const EdgeInsets.only(left: 20, right: 20),
              child: ListView.separated(
                itemCount: transactions.length,
                scrollDirection: Axis.vertical,
                separatorBuilder: (context, index) => const SizedBox(height: 10,),
                itemBuilder: (context, index) {
                  return Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Text(
                                    transactions[index].title, 
                                    style: const TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white
                                    ),
                                  ),
                                  const SizedBox(width: 15,),
                                  Text(
                                    DateFormat('dd-MM-yyyy').format(transactions[index].date),
                                    style: const TextStyle(
                                      color: Colors.grey
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              transactions[index].value.toString(),
                              style: TextStyle(
                                fontSize: 20,
                                color: transactions[index].value >= 0 ? Colors.green : Colors.red 
                              ),
                            )
                          ],
                        ),
                        const Divider(
                          height: 12,
                          thickness: 2,
                        ),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            transactions[index].description,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              )
    );
  }