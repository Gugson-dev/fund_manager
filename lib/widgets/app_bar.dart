import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fund_manager/pages/home.dart';

AppBar appBar(BuildContext context) {
  return AppBar(
    title: GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Home())  
        );
      },
      child: const Text('Fund Manager')
    ),
    elevation: 0.0,
    centerTitle: true,
    leading: 
      GestureDetector(
        onTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Home())  
          );
        },
        child: Container(
          margin: const EdgeInsets.all(10),
          alignment: Alignment.center,
          child: const Icon(
            CupertinoIcons.chevron_back,
            color: Colors.black,
            size: 27.0,
            semanticLabel: 'Powrót',
          ) 
        ),
      ),
    actions: [
      GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Informacje'),
                content: const Text('Karolina to najpiękniejsza dziewczyna na świecie'),
                actions: [
                  TextButton(
                    onPressed: () {
                      showLicensePage(context: context);
                    },
                    child: const Text('Pokaż licencje'),
                  ),
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
            CupertinoIcons.info_circle,
            color: Colors.black,
            size: 24.0,
            semanticLabel: 'Info',
          )          
        ),
      )
    ],
  );
}