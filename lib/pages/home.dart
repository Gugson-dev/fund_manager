import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../widgets/app_bar.dart';
import '../widgets/transactions_history.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<TransactionModel> transactions = [];
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController valueController = TextEditingController();
  

  @override
  void initState(){
    super.initState();
    _getTransactions();
  }
  

  void _getTransactions() {
    setState(() {
      transactions = TransactionModel.getTransactions();
    });
  }

  void clearControllers() {
    titleController.clear();
    descriptionController.clear();
    valueController.clear();
  }

  Future<void> showAddTransactionDialog(BuildContext context, bool isExpense) async {
    final title = isExpense ? 'Dodaj wpłatę' : 'Dodaj wydatek';
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
                clearControllers();
              }, 
              child: const Text('Zamknij')
              ),
            ElevatedButton(
              onPressed: (){
                setState(() {
                  double? value = double.tryParse(valueController.text);
                  if (value != null) {
                    if (!isExpense) {
                      value *= -1;
                    }
                  }
                  transactions.add(
                    TransactionModel(
                      title: titleController.text, 
                      description: descriptionController.text, 
                      value: value, 
                      date: DateTime.now()
                    )
                  );  
                });
                Navigator.pop(context);
                clearControllers();
              },
               child: const Text('Dodaj'))
          ],
        );
      }
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: appBar(context),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            foregroundColor: Colors.black
                          ),
                          onPressed: () {
                            showAddTransactionDialog(context,true);
                          }, 
                          child: const Text('Dodaj wpłatę')
                        ),
                        const SizedBox(width: 20,),
                        ElevatedButton(
                          onPressed: () {
                            showAddTransactionDialog(context,false);
                          }, 
                          child: const Text('Dodaj wydatek')
                        ),
                      ],
                    ),
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
                    ),
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