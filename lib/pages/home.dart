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
  
  

  void _getTransactions() {
    transactions = TransactionModel.getTransactions();
  }

  void clearControllers() {
    titleController.clear();
    descriptionController.clear();
    valueController.clear();
  }

  Future<void> addTransaction(BuildContext context) async {
    return showDialog(
      useSafeArea: true,
      barrierDismissible: false,
      context: context, 
      builder: (context) {
        return AlertDialog(
          title: const Text('Dodaj transakcje'),
          titleTextStyle: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.black
          ),
          backgroundColor: Colors.amberAccent,
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
                      border: OutlineInputBorder()
                    ),
                  ),
                  const SizedBox(height: 20,),
                  TextField(
                    controller: descriptionController,
                    minLines: 1,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Opis',
                      border: OutlineInputBorder()
                    ),
                  ),
                  const SizedBox(height: 20,),
                  TextField(
                    controller: valueController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Kwota',
                      border: OutlineInputBorder()
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
                transactions.add(
                  TransactionModel(
                    title: titleController.text, 
                    description: descriptionController.text, 
                    value: double.parse(valueController.text), 
                    date: DateTime.now()
                  )
                );
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
                    ElevatedButton(
                      onPressed: () {
                        addTransaction(context);
                      }, 
                      child: const Text('Dodaj Transakcje')
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