import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import '../one_period_input_formatter.dart';
import '../my_extensions.dart';

enum Menu {edytuj, usun}

Future<void> showEditTransactionDialog(BuildContext context, List<TransactionModel> transactions, List<String> categories, int index, VoidCallback onUpdate, TabController tabController) async {
  TextEditingController titleController = TextEditingController(text: transactions[index].title);
  TextEditingController descriptionController = TextEditingController(text: transactions[index].description);
  TextEditingController valueController = TextEditingController(text: transactions[index].value);
  TextEditingController categoryController = TextEditingController(text: transactions[index].category.capitalize());
  bool isExpense = transactions[index].isExpense;
  
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
                        if (tabController.index == 0) {
                          isExpense = false;
                        } else {
                          isExpense = true;
                        }
                    },
                    tabs: const [
                      Tab(
                        child: Text('Wpłata')
                      ),
                      Tab(
                        child: Text('Wydatek'),
                      )
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
                DropdownMenu<String>(
                  expandedInsets: EdgeInsets.zero,
                  label: const Text('Kategoria'),
                  hintText: 'Wpisz lub wyszukaj kategorie',
                  controller: categoryController,
                  dropdownMenuEntries: categories.map((String value){
                    return DropdownMenuEntry(value: value, label: value.capitalize());
                  }).toList()
                )
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
                if (!categories.contains(categoryController.text.toLowerCase())) {
                  categories.add(categoryController.text.toLowerCase());
                }
                transactions[index] = 
                  TransactionModel(
                    title: titleController.text, 
                    description: descriptionController.text,
                    value: valueController.text, 
                    date: transactions[index].date,
                    isExpense: isExpense,
                    category: categoryController.text.toLowerCase()
                  );
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
  
Container transactionHistory(List<TransactionModel> transactions, List<String> categories, BuildContext context, VoidCallback onUpdate, TabController tabController) {
  return Container(
            margin: const EdgeInsets.only(left: 20, right: 20),
            child: ListView.separated(
              itemCount: transactions.length,
              scrollDirection: Axis.vertical,
              separatorBuilder: (context, index) => const SizedBox(height: 10,),
              itemBuilder: (context, index) {
                String value = transactions[index].value;
                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: ExpansionTile(
                    title: LayoutBuilder(
                      builder: (context, constraints) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: constraints.maxWidth*0.5),
                              child: GestureDetector(
                                onTap: () {
                                  Clipboard.setData(ClipboardData(text: transactions[index].title)).then((_) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        duration: Durations.long2,
                                        showCloseIcon: true,
                                        behavior: SnackBarBehavior.floating,
                                        width: MediaQuery.of(context).size.width*0.3,
                                        content: const Text('Title copied to clipboard')
                                      )
                                    );
                                  });
                                },
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
                            ),
                            Expanded(
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    flex: 1,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: Text(
                                        DateFormat('dd-MM-yyyy').format(transactions[index].date),
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey
                                        ),
                                      ),
                                    ),
                                  ),    
                                  Expanded(
                                    flex: 10,
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
                                  )
                                ],
                              ),
                            )
                          ],
                        );
                      },
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
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Kategoria: ${transactions[index].category.capitalize()}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                          ),
                                        ),
                                        Text(
                                          transactions[index].description.capitalize(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  PopupMenuButton<Menu>(
                                    tooltip: 'Opcje',
                                    itemBuilder: (BuildContext content) => <PopupMenuEntry<Menu>>[
                                      PopupMenuItem<Menu>(
                                        value: Menu.edytuj,
                                        onTap: () {
                                          showEditTransactionDialog(context, transactions, categories, index, onUpdate, tabController);
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