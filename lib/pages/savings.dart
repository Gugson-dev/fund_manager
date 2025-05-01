import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fund_manager/models/savings_model.dart';
import 'package:fund_manager/widgets/dialogs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';


import '../models/transaction_model.dart';
import '../widgets/app_bar.dart';

class Savings extends StatefulWidget {
  const Savings({super.key});

  @override
  State<Savings> createState() => _SavingsState();
}

class _SavingsState extends State<Savings> {

  List<SavingModel> savings = [];
  List<TransactionModel> transactions = [];


    @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savingData = prefs.getString('savings');
      final transactionsData = prefs.getString('transactions');


      if (savingData != null) {
        final decodedData = json.decode(savingData) as List;
        savings.addAll(
          decodedData.map((transactionMap) => SavingModel.fromJson(transactionMap)).toList()
        );
      }

      if (transactionsData != null) {
        final decodedData = json.decode(transactionsData) as List;
        transactions.addAll(
          decodedData.map((transactionMap) => TransactionModel.fromJson(transactionMap)).toList()
        );
      }
      setState(() {});
    } catch (e) {
      if (kDebugMode) {
        print('Wystąpił błąd podczas ładowania danych: $e');
      }
    }
  }
  
  void saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('savings', json.encode(savings));
      prefs.setString('transactions', json.encode(transactions));
      setState(() {});
    } catch (e) {
      if (kDebugMode) {
        print('Wystąpił błąd podczas zapisywania danych: $e');
      }
    }
  }

  Future<void> chooseImage(int index) async {
  try {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result != null) {
      // Ścieżka do nowego zdjęcia
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String filePath =
          '${appDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final File choosedImage = await File(result.files.single.path!).copy(filePath);

        // Zaktualizuj listę w stanie
        setState(() {
          savings[index].photo = choosedImage.path;
          saveData();
        });
    }
  } catch (e) {
    if (kDebugMode) {
      print('Wystąpił błąd podczas zmiany zdjęcia: $e');
    }
  }
}


  Future<void> deleteImage(int index) async {
    try {
      setState(() {
        savings[index].photo = '';
        saveData();
      });
    } catch (e) {
      if (kDebugMode) {
        print('Wystąpił błąd podczas usuwania zdjęcia: $e');
      }
    }
  }

  String showMoney(String value) {
    return !value.contains('.') || value.length == value.indexOf('.')+1 || value.contains('.00') ? value.split('.')[0] : value;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
      body: LayoutBuilder(builder: (context,constraints){
        return SafeArea(
          child: SizedBox(
            height: constraints.maxHeight,
            width: constraints.maxWidth,
            child: Column(
              children: [
                const SizedBox(height: 20,),
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        addGoal(context,saveData,savings);
                      },
                      child: const Icon(
                        CupertinoIcons.add_circled,
                        size: 30,
                      )
                    ),
                     const Text(
                      'Dodaj cel oszczędnościowy',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black
                      ),
                    )
                  ],
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    child: ListView.separated(                          
                      itemCount: savings.length,
                      scrollDirection: Axis.vertical,
                      separatorBuilder: (context, index) => const SizedBox(height: 40,),
                      itemBuilder: (context, index) {
                        return Container(
                          padding: const EdgeInsets.all(20), 
                          decoration: BoxDecoration(
                            color: Colors.grey[600],
                            border: Border.all(
                              color: Colors.black,
                              width: 2
                            ),
                            borderRadius: BorderRadius.circular(10)
                          ),
                          width: MediaQuery.of(context).size.width*0.9,
                          child: Row(
                            children: [
                              Column(
                                children: [
                                  savings[index].photo.isNotEmpty && File(savings[index].photo).existsSync() ?
                                  Stack(
                                    children: [
                                      Container(
                                      width: MediaQuery.of(context).size.width*0.1,
                                      height: MediaQuery.of(context).size.height*0.1,           
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.black,
                                          width: 2
                                        ),
                                        image: DecorationImage(
                                          image: FileImage(File(savings[index].photo)) as ImageProvider, 
                                          fit: BoxFit.fill
                                        )
                                      )
                                    ),
                                    Positioned(
                                      right: 2,
                                      top: 3,
                                      child: MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: GestureDetector(
                                          onTap: (){
                                            deleteImage(index);
                                          },
                                          child: const Icon(
                                            CupertinoIcons.trash_fill, 
                                            size: 16,
                                            color: Colors.red,
                                          ),
                                        ),
                                      )
                                    )
                                  ]
                                  )
                                  :
                                  Stack(
                                    children: [
                                      Container(
                                        width: MediaQuery.of(context).size.width*0.1,
                                        height: MediaQuery.of(context).size.height*0.1,           
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.black,
                                            width: 2
                                          ),
                                          image: const DecorationImage(
                                            image: AssetImage('assets/images/placeholder-image-removebg-preview.png'),
                                            fit: BoxFit.cover
                                          )
                                        )
                                      ),
                                      Positioned(
                                        left: 3,
                                        bottom: 2,
                                        child: MouseRegion(
                                          cursor: SystemMouseCursors.click,
                                          child: GestureDetector(
                                            onTap: (){
                                              chooseImage(index);
                                            },
                                            child: const Icon(
                                              CupertinoIcons.photo_camera_solid, 
                                              size: 16
                                            ),
                                          ),
                                        )
                                      )
                                    ]
                                  ),
                                  const SizedBox(height: 10,),
                                  Row(
                                    children: [
                                      ElevatedButton(
                                        onPressed:()
                                          {
                                            clearControllers();
                                            manageGoalTransaction(context, saveData, savings, transactions, index, true);
                                          }, 
                                        child: const Text('Wpłać')
                                      ),
                                      const SizedBox(width: 10,),
                                      ElevatedButton(
                                        onPressed:()
                                          {
                                            clearControllers();
                                            manageGoalTransaction(context, saveData, savings, transactions, index, false);
                                          }, 
                                        child: const Text('Wypłać')
                                      )
                                    ],
                                  )
                                ],
                              ),
                              const SizedBox(width: 20,),
                              Column(
                                children: [
                                  Text(
                                    savings[index].title,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30
                                    ),
                                  ),
                                  const SizedBox(height: 20,),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width*0.65,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Stack(
                                          children: [
                                            Positioned.fill(
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: Colors.black,
                                                    width: 2
                                                  ),
                                                  borderRadius: BorderRadius.circular(10)
                                                ),
                                                child: LinearProgressIndicator(
                                                  color: Colors.green,
                                                  backgroundColor: Colors.grey,
                                                  borderRadius: BorderRadius.circular(10),
                                                  value: savings[index].goal.isEmpty ? 0.00 : double.parse(savings[index].donated) / double.parse(savings[index].goal), // zmienić do BigInta
                                                ),
                                              ),
                                            ),
                                            Align(
                                              alignment: Alignment.center,
                                              child: Text(
                                                '${showMoney(savings[index].donated)} zł/${showMoney(savings[index].goal)} zł',
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.black
                                                ),
                                              )
                                            )
                                          ]
                                        )
                                      ]
                                    )
                                  ),
                                ],
                              ),
                              Align(
                                alignment: Alignment.topRight,
                                child:
                              ElevatedButton(
                                onPressed: (){
                                  try {
                                    setState(() {
                                      savings.removeAt(index);
                                      saveData();
                                    });
                                  } catch (e) {
                                    if (kDebugMode) {
                                      print('Wystąpił błąd podczas usuwania celu oszczędnościowego: $e');
                                    }
                                  }
                                },
                                child: const Icon(
                                  CupertinoIcons.delete,
                                  size: 30,
                                )
                              )
                              )
                            ]
                          )
                        );
                      }
                    )
                  )
                )
              ]
            ),
          )
        );
      }),
    );
  }
}
