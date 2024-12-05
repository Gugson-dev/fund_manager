import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
 
 Container searchField() {
    return Container(
          margin: const EdgeInsets.only(top: 40,left: 20,right: 20),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: const Color(0xff1D1617).withOpacity(0.11),
                blurRadius: 40,
                spreadRadius: 0.0
              )
            ]
          ),
          child: TextField(
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.all(15),
              hintText: 'Transakcja...',
              hintStyle: const TextStyle(
                color: Colors.grey,
                fontSize: 14
              ),
              prefixIcon: const Padding(
                padding: EdgeInsets.all(12),
                child: Icon(
                  CupertinoIcons.search,
                  color: Colors.black,
                  semanticLabel: 'Search',
                ),
              ),
              suffixIcon: const SizedBox(
                width: 100,
                child: IntrinsicHeight(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      VerticalDivider(
                        color: Colors.black,
                        indent: 10,
                        endIndent: 10,
                        thickness: 0.1,
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 12,right: 12,bottom: 12),
                        child: Icon(
                          CupertinoIcons.slider_horizontal_3,
                          color: Colors.black,
                          semanticLabel: 'Filters',
                        ),
                      ),
                    ],
                  ),
                ),
              ), 
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none
              )
            ),
          ),
        );
 }