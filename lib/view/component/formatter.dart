import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Melemparkan kembali nilai lama jika hasil edit jadi kosong
class NoEmptyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Jika hasil baru kosong, ubah jadi "0"
    if (newValue.text.isEmpty) {
      return TextEditingValue(
        text: '0',
        selection: TextSelection.collapsed(offset: 1),
      );
    }
    return newValue;
  }
}
