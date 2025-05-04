import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Melemparkan kembali nilai lama jika hasil edit jadi kosong
class NoEmptyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String cleaned = newValue.text.replaceFirst(RegExp(r'^0+(?=\d)'), '');

    // Kalau hasilnya kosong, set jadi 0
    if (cleaned.isEmpty) cleaned = '0';

    return TextEditingValue(
      text: cleaned,
      selection: TextSelection.collapsed(offset: cleaned.length),
    );
  }
}
