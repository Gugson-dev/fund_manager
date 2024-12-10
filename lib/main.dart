import 'package:flutter/material.dart';
import 'package:fund_manager/pages/home.dart';

void main() {
  runApp(const FundManager());
}

class FundManager extends StatelessWidget {
  const FundManager({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold            
          ),
          backgroundColor: Colors.amber
        ),
        primarySwatch: Colors.blueGrey,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blueGrey,
        ).copyWith(
          secondary: Colors.amber,
          onPrimary: Colors.white,
        ),
        textTheme: TextTheme(
          headlineLarge: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey[800]),
          titleLarge: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey[800]),
          bodyLarge: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey[800]),
          bodyMedium: TextStyle(fontSize: 14, color: Colors.blueGrey[700]),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: const OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blueGrey[800]!),
          ),
          labelStyle: TextStyle(
            fontSize: 15,
            color: Colors.blueGrey[800]
            ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
            foregroundColor: Colors.black,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.black,
          ),
        ),
        dialogTheme: const DialogTheme(
          titleTextStyle: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.black
          ),
          contentTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black
          )
        ),
        dividerColor: Colors.transparent,
        splashColor: Colors.transparent,
        listTileTheme: const ListTileThemeData(
          tileColor: Colors.black,
          iconColor: Colors.white
        ),
        expansionTileTheme: ExpansionTileThemeData(
          backgroundColor: Colors.black,
          collapsedBackgroundColor: Colors.black,
          collapsedIconColor: Colors.white,
          iconColor: Colors.white,
          expansionAnimationStyle: AnimationStyle(
            duration: Durations.long1
          )
        ),
        popupMenuTheme: const PopupMenuThemeData(
          iconSize: 20,
          iconColor: Colors.white,
          position: PopupMenuPosition.under
        )
      ),
      home: const Home()
    );
  }
  }