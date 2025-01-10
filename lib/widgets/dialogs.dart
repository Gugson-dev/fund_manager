import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fund_manager/models/savings_model.dart';
import 'package:fund_manager/my_extensions.dart';

import '../models/transaction_model.dart';
import '../one_period_input_formatter.dart';

TextEditingController titleController = TextEditingController();
TextEditingController descriptionController = TextEditingController();
TextEditingController valueController = TextEditingController();
TextEditingController categoryController = TextEditingController();

void clearControllers() async {
  await Future.delayed(const Duration(seconds: 1));
  titleController.clear();
  descriptionController.clear();
  valueController.clear();
  categoryController.clear();
}

void showTransactionDialog(BuildContext context, VoidCallback onUpdate, TabController tabController, List<String> categories, List<TransactionModel> transactions, [bool mode = false, bool isExpense = false, int index = 0]) async {
  
  bool addCategory = false;
  
  if (mode) {
    titleController = TextEditingController(text: transactions[index].title);
    descriptionController = TextEditingController(text: transactions[index].description);
    valueController = TextEditingController(text: transactions[index].value);
    categoryController = TextEditingController(text: transactions[index].category.capitalize());
  }
  
  return showDialog(
    useSafeArea: true,
    barrierDismissible: false,
    context: context, 
    builder: (context) {
      isExpense ? tabController.index = 1 : tabController.index = 0;
      return AlertDialog(
        title: TabBar(
          controller: tabController,
          onTap: (value) {
            tabController.index == 0 ? isExpense = false : isExpense = true;
          },
          tabs: const [
            Tab(child: Text('Wpłata')),
            Tab(child: Text('Wydatek'))
          ]
        ),
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
                   inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')), // Allow only numbers and periods
                    OnePeriodInputFormatter(), // Custom formatter for one period
                  ],
                ),
                const SizedBox(height: 20,),
                StatefulBuilder(
                  builder: (context, setState) {
                    return DropdownMenu<String>(
                      expandedInsets: EdgeInsets.zero,
                      label: const Text('Kategoria'),
                      hintText: 'Wpisz lub wyszukaj kategorie',
                      controller: categoryController,
                      dropdownMenuEntries: categories.map((String value){
                        return DropdownMenuEntry(
                          value: value, 
                          label: value.capitalize(), 
                          trailingIcon: GestureDetector(
                            onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      content: const Text('Czy na pewno chcesz usunąć kategorie?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('Zamknij'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            setState((){
                                              categories.removeWhere((item) => item == value);
                                            });
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('Tak, usuń'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                            },
                            child: const Icon(
                              CupertinoIcons.delete,
                              size: 18,
                              applyTextScaling: true,
                              color: Colors.red,
                            ),
                          )
                        );
                      }).toList()
                    );
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text(
                      'Czy dodać kategorię do listy?',
                      style: TextStyle(
                        fontSize: 15
                      ),
                    ),
                    StatefulBuilder(
                      builder: (context, setState) {
                        return Transform.scale(
                          scale: 0.7,
                          child: Checkbox(
                            checkColor: Colors.white,
                            activeColor: Colors.black,
                            value: addCategory,
                            onChanged: (newValue) {
                              setState(() {
                                addCategory = newValue!;
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              clearControllers();
            }, 
            child: const Text('Zamknij')
            ),
          ElevatedButton(
            onPressed: () {
                if (valueController.text.isEmpty) {
                  valueController.text = '0';
                }
                if (!valueController.text.contains('.')) {
                  valueController.text += '.00';
                } else if (valueController.text.length == valueController.text.indexOf('.')+2) {
                  valueController.text += '0';
                }
                if (!categories.contains(categoryController.text.toLowerCase()) && categoryController.text != '' && addCategory) {
                  categories.add(categoryController.text.toLowerCase());
                }

                if (mode) {
                  transactions[index] = 
                    TransactionModel(
                      title: titleController.text, 
                      description: descriptionController.text,
                      value: valueController.text, 
                      date: transactions[index].date,
                      isExpense: isExpense,
                      category: categoryController.text.toLowerCase()
                    );
                } else {
                  transactions.add(
                    TransactionModel(
                      title: titleController.text, 
                      description: descriptionController.text, 
                      value: valueController.text, 
                      date: DateTime.now(),
                      isExpense: isExpense,
                      category: categoryController.text.toLowerCase()
                    )
                  );
                }
                //implement custom date
                onUpdate();
                Navigator.pop(context);
                clearControllers();
            },
              child: Text(mode ? 'Zmień' : 'Dodaj'))
        ],
      );
    }
  );
}


Future<dynamic> addGoal(BuildContext context, VoidCallback onUpdate, List<SavingModel> savings) {
    return showDialog(
                      useSafeArea: true,
                      barrierDismissible: false,
                      context: context,
                      builder: (context) {
                        return ScaffoldMessenger(
                          child: Builder(
                            builder: (context) {
                              return Scaffold(
                                backgroundColor: Colors.transparent,
                                body: AlertDialog(
                                  title: const Text('Wpisz dane celu'),
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
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')), // Allow only numbers and periods
                                              OnePeriodInputFormatter(), // Custom formatter for one period
                                            ],
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
                                            if (!valueController.text.contains('.')) {
                                              valueController.text += '.00';
                                            } else if (valueController.text.length == valueController.text.indexOf('.')+2) {
                                              valueController.text += '0';
                                            }
                                            savings.add(
                                              SavingModel(
                                                title: titleController.text,
                                                description: descriptionController.text,
                                                value: valueController.text
                                              )
                                            );
                                            onUpdate();
                                            Navigator.pop(context);
                                            clearControllers();
                                      },
                                      child: const Text('Dodaj')
                                    )
                                  ],
                                )
                              );   
                            }
                          )
                        );
                      }
                    );
  }