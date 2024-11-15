import 'package:flutter/foundation.dart';

extension StringExtensions on String { 
  String capitalize() {
    try {
      return "${this[0].toUpperCase()}${substring(1)}"; 
    } on RangeError {
      return '';
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return 'Wystąpił błąd';
    }
  } 
}