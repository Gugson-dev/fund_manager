
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
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    child: ExpansionTile(
                      title: Row(
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
                                        )
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
                                      child: Text(
                                        transactions[index].description,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 20,
                                        ),
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
                                        alignment: Alignment.centerRight,
                                        child: const Icon(
                                          CupertinoIcons.ellipsis_vertical,
                                          color: Colors.white,
                                          size: 24.0,
                                          semanticLabel: 'Info',
                                        )          
                                      ),
                                    ),
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
    );
  }