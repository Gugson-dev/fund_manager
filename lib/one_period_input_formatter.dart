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
        return oldValue;
      }
    }
    return newValue;
  }
}