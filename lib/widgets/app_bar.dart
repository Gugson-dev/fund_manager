  import 'package:flutter/material.dart';
  import 'package:flutter/cupertino.dart';
  
  AppBar appBar() {
    return AppBar(
      title: const Text(
        'Fund Manager',
        style: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold
        ),
      ),
      backgroundColor: Colors.amber,
      elevation: 0.0,
      centerTitle: true,
      leading: 
        GestureDetector(
          onTap: () {

          },
          child: Container(
            margin: const EdgeInsets.all(10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(10)
            ),
            child: const Icon(
              CupertinoIcons.chevron_back,
              color: Colors.black,
              size: 27.0,
              semanticLabel: 'Go back',
            ) 
          ),
        ),
      actions: [
        GestureDetector(
          onTap: () {

          },
          child: Container(
            margin: const EdgeInsets.all(10),
            alignment: Alignment.center,
            width: 37,
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(10)
            ),
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