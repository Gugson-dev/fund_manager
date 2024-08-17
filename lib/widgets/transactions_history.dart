
import 'package:flutter/cupertino.dart';
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
                    child: Row(
                      children: [
                        Expanded(
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
                                      color: transactions[index].value! >= 0 ? Colors.green : Colors.red 
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
                        ),
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Informacje'),
                                  content: const Text('Karolina to najpiękniejsza dziewczyna na świecie'),
                                  actions: [
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Zamknij'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.all(10),
                            alignment: Alignment.center,
                            width: 37,
                            child: const Icon(
                              CupertinoIcons.ellipsis_vertical,
                              color: Colors.white,
                              size: 24.0,
                              semanticLabel: 'Info',
                            )          
                          ),
                        )
                      ],
                    ),
                  );
                }
              )
    );
  }