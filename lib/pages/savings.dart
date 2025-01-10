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

import '../widgets/app_bar.dart';

class Savings extends StatefulWidget {
  const Savings({super.key});

  @override
  State<Savings> createState() => _SavingsState();
}

class _SavingsState extends State<Savings> {

  List<SavingModel> savings = [];
  List<File> _images = [];
  TextEditingController valueController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

    @override
  void initState(){
    super.initState();
    _getData();
    _loadImages();
  }

  void _getData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      final savingData = prefs.getString('savings');

      if (savingData != null) {
        final decodedData = json.decode(savingData) as List;
        savings.addAll(
          decodedData.map((transactionMap) => SavingModel.fromJson(transactionMap)).toList()
        );
      }
    });
  }
  
  void _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('savings', json.encode(savings));
  }

  Future<void> _loadImages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? imagePaths = prefs.getStringList('saved_images');
    if (imagePaths != null) {
      setState(() {
        _images = imagePaths
            .where((path) => File(path).existsSync()) // Usuwanie niedostępnych plików
            .map((path) => File(path))
            .toList();
      });
    }
  }

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null) {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String filePath =
          '${appDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg'; // Unikalna nazwa pliku
      final File savedImage = await File(result.files.single.path!).copy(filePath);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> imagePaths = prefs.getStringList('saved_images') ?? [];
      imagePaths.add(savedImage.path);
      await prefs.setStringList('saved_images', imagePaths);

      setState(() {
        _images.add(savedImage);
      });
    }
  }

  Future<void> changeImage(int index) async {
  try {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null && index >= 0 && index < _images.length) {
      // Ścieżka do nowego zdjęcia
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String filePath =
          '${appDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final File newImage = await File(result.files.single.path!).copy(filePath);

      // Aktualizacja w `SharedPreferences`
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> imagePaths = prefs.getStringList('saved_images') ?? [];

      if (imagePaths.length > index) {
        // Usuń stare zdjęcie
        File oldImage = _images[index];
        if (await oldImage.exists()) {
          await oldImage.delete();
        }

        // Zastąp stare zdjęcie nową ścieżką
        imagePaths[index] = newImage.path;
        await prefs.setStringList('saved_images', imagePaths);

        // Zaktualizuj listę w stanie
        setState(() {
          _images[index] = newImage;
        });
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print('Wystąpił błąd podczas zmiany zdjęcia: $e');
    }
  }
}


  Future<void> deleteImage(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> imagePaths = prefs.getStringList('saved_images') ?? [];
    File imageFile = _images[index];

    if (await imageFile.exists()) {
      await imageFile.delete(); // Usuń plik z systemu plików
    }

    imagePaths.removeAt(index); // Usuń ścieżkę z listy
    await prefs.setStringList('saved_images', imagePaths);

    setState(() {
      _images.removeAt(index);
    });
  }

  void clearControllers() {
    titleController.clear();
    descriptionController.clear();
    valueController.clear();
  }

  void onUpdate() {
    setState(() {});
    _saveData();
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
                        clearControllers();
                        addGoal(context,onUpdate,savings);
                      },
                      child: const Icon(
                        CupertinoIcons.add_circled,
                        size: 30,
                      )
                    ),
                    const Text(
                      'Dodaj cel oszczędnościowy',
                      style: TextStyle(
                        color: Colors.black
                      ),
                    )
                  ],
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(left: 20, right: 20),
                    child: ListView.separated(                          
                      itemCount: savings.length,
                      scrollDirection: Axis.vertical,
                      separatorBuilder: (context, index) => const SizedBox(height: 10,),
                      itemBuilder: (context, index) {
                        return SizedBox(
                          width: MediaQuery.of(context).size.width*0.9,
                          child: Row(
                            children: [
                              Column(
                                children: [
                                  MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: GestureDetector(
                                      onTap: (){
                                        if (_images.isNotEmpty && index < _images.length && File(_images[index].path).existsSync()) {
                                          changeImage(index);
                                        } else {
                                          _pickImage();
                                        }
                                      },
                                      child: Container(
                                        width: MediaQuery.of(context).size.width*0.1,
                                        height: MediaQuery.of(context).size.height*0.05,           
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image:_images.isNotEmpty && index < _images.length && File(_images[index].path).existsSync()
                                              ? FileImage(_images[index]) as ImageProvider
                                              : const AssetImage('assets/images/placeholder-image-removebg-preview.png'),
                                            fit:_images.isNotEmpty && index < _images.length && File(_images[index].path).existsSync()
                                              ? BoxFit.fill
                                              : BoxFit.cover
                                          )
                                        )
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10,),
                                  ElevatedButton(
                                    onPressed:()
                                      {
                                      
                                      }, 
                                    child: const Text('Wpłać')
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
                                      fontSize: 20
                                    ),
                                  ),
                                  const SizedBox(height: 10,),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width*0.75,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Stack(
                                          children: [
                                            Positioned.fill(
                                              child: LinearProgressIndicator(
                                                color: Colors.green,
                                                backgroundColor: Colors.grey,
                                                borderRadius: BorderRadius.circular(10),
                                                value: savings[index].value.isEmpty ? 0.00 : 10 / double.parse(savings[index].value), // zmienić do BigInta
                                              ),
                                            ),
                                            Align(
                                              alignment: Alignment.center,
                                              child: Text(
                                                '10 zł/${!savings[index].value.contains('.') || savings[index].value.length == savings[index].value.indexOf('.')+1 || savings[index].value.contains('.00') ? savings[index].value.split('.')[0] : savings[index].value} zł',
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

/* import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ImagePickerDesktopScreen extends StatefulWidget {
  const ImagePickerDesktopScreen({super.key});

  @override
  _ImagePickerDesktopScreenState createState() => _ImagePickerDesktopScreenState();
}

class _ImagePickerDesktopScreenState extends State<ImagePickerDesktopScreen> {
  File? _image;



Future<void> _loadImage() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? imagePath = prefs.getString('saved_image');
  if (imagePath != null && File(imagePath).existsSync()) {
    setState(() {
      _image = File(imagePath);
    });
  }
}


Future<void> _pickImage() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.image,
  );

  if (result != null) {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final String filePath = '${appDir.path}/saved_image.jpg';
    final File savedImage = await File(result.files.single.path!).copy(filePath);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_image', savedImage.path);

    setState(() {
      _image = savedImage;
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Picker for Desktop'),
      ),
      body: Center(
        child: _image != null
            ? Image.file(_image!)
            : const Text('No image selected'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImage,
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }
} */
