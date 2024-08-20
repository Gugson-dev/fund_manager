
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';

enum Menu {edytuj, usun}

Future<void> showEditTransactionDialog(BuildContext context, List<TransactionModel> transactions, int index, VoidCallback onUpdate) async {
  TextEditingController titleController = TextEditingController(text: transactions[index].title);
  TextEditingController descriptionController = TextEditingController(text: transactions[index].description);
  TextEditingController valueController = TextEditingController(text: transactions[index].value?.abs().toString());
  final title = transactions[index].isExpense ? 'Edytuj wpłatę' : 'Edytuj wydatek';
  
  return showDialog(
    useSafeArea: true,
    barrierDismissible: false,
    context: context, 
    builder: (context) {
      return AlertDialog(
        title: Text(title),
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
              double? value = double.tryParse(valueController.text);
              if (value != null) {
                if (!transactions[index].isExpense) {
                  value *= -1;
                }
              }
              transactions[index].title = titleController.text;
              transactions[index].description = descriptionController.text;
              transactions[index].value = value;
              //implement custom date
              onUpdate();
              Navigator.pop(context);
            },
              child: const Text('Zmień'))
        ],
      );
    }
    );
}
  
Container transactionHistory(List<TransactionModel> transactions, BuildContext context, VoidCallback onUpdate) { 
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
                                  PopupMenuButton<Menu>(
                                    tooltip: 'Opcje',
                                    itemBuilder: (BuildContext content) => <PopupMenuEntry<Menu>>[
                                      PopupMenuItem<Menu>(
                                        value: Menu.edytuj,
                                        onTap: () {
                                          showEditTransactionDialog(context, transactions, index, onUpdate);
                                        },
                                        child: const ListTile(
                                          leading: Icon(
                                            CupertinoIcons.square_pencil,
                                            size: 20,
                                          ),
                                          title: Text('Edytuj'),
                                          )
                                      ),
                                      PopupMenuItem<Menu>(
                                        value: Menu.usun,
                                        onTap: () {
                                          transactions.removeAt(index);
                                          onUpdate();
                                        },
                                        child: const ListTile(
                                          leading: Icon(
                                            CupertinoIcons.trash,
                                            size: 20,
                                          ),
                                          title: Text('Usun'),
                                        )
                                      )
                                    ]
                                  )
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