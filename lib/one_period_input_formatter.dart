import 'package:flutter/services.dart';

class OnePeriodInputFormatter implements TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.indexOf('.') != newValue.text.lastIndexOf('.')) {
        return oldValue;
    }
    if (oldValue.text.contains('.')) {
      if (newValue.text.length > oldValue.text.lastIndexOf('.')+3) {
        if (newValue.text.split('.')[0] != oldValue.text.split('.')[0]) {
          return newValue;
        }
        return oldValue;
      }
    }
    return newValue;
  }
}