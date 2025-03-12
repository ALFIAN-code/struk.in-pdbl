import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:strukin/model/struk_from_api.dart';

Future<StrukFromApi?> processReceipt(
  String receiptText,
  String api,
  List<String> categories,
) async {
  try {
    final model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: api,
    );

    final List<String> formattedList = ['unkown'];

    for (String category in categories) {
      formattedList.add(category.toLowerCase());
    }

    String prompt = """
      Evaluate whether the following text is a valid purchase receipt. 
      If it is a receipt, extract the invoice number, date, payment method, store name, items, their quantity, price, subtotal, total, and tax.
      If the text is NOT a receipt or if there is no text at all, return the following JSON:
      ```json
      {
        "is_valid": false
      }
      ```
      
      If the text is a valid receipt, return the response in this JSON format:
      ```json
      {
        "is_valid": true,
        "invoice_number": "Invoice Number",
        "date": "Date",
        "payment_method":"PAYMENT METHOD",
        "store_name" : "Store Name",
        "items": [
          {
            "name": "Item Name",
            "quantity": Quantity,
            "price": Price,
            "category": "category"
          }
        ],
        "subtotal": Subtotal,
        "tax": Tax,
        "total": Total
      }
      ```
      
      Here is the receipt text:
      $receiptText
    """;

    // String prompt = """
    //   Extract the invoice number, date, payment method, items, their quantity, price, subtotal, total, and tax from the following receipt:
    //   $receiptText And give each item a category strictly from this list of categories $categories. If the invoice number, payment method, date, can't be extracted please put the string "UNKNOWN"

    //   Please return the response in the following JSON format:
    //   ```json
    //   {
    //     "invoice_number": "Invoice Number",
    //     "date": "Date",
    //     "payment_method":"PAYMENT METHOD",
    //     "items": [
    //       {
    //         "name": "Item Name",
    //         "quantity": Quantity,
    //         "price": Price,
    //         "category": "category"
    //       },
    //       ...
    //     ],
    //     "subtotal": Subtotal,
    //     "tax": Tax,
    //     "total": Total
    //   }
    //   ```""";

    final content = [Content.text(prompt)];
    final response = await model.generateContent(content);

    String generatedText = response.text ?? '';

    String jsonString = extractJsonFromText(generatedText);

    Map<String, dynamic> extractedData = jsonDecode(jsonString);

    StrukFromApi order = StrukFromApi.fromJson(extractedData);

    // Return the extracted JSON data

    if (extractedData.containsKey('is_valid') && !extractedData['is_valid']) {
      return null;
    }

    return order;
  } catch (error) {
    throw Exception("Error processing receipt: $error");
  }
}

String extractJsonFromText(String text) {
  final jsonStart = text.indexOf('```json');
  final jsonEnd = text.indexOf('```', jsonStart + 6);

  if (jsonStart != -1 && jsonEnd != -1) {
    String jsonString = text.substring(jsonStart + 6, jsonEnd).trim();

    final validJsonStart = jsonString.indexOf('{');
    final validJsonEnd = jsonString.lastIndexOf('}');

    if (validJsonStart != -1 && validJsonEnd != -1) {
      jsonString = jsonString.substring(validJsonStart, validJsonEnd + 1);
      return jsonString;
    } else {
      throw const FormatException(
        "Valid JSON not found within the extracted text",
      );
    }
  } else {
    throw const FormatException("JSON format not found in the response");
  }
}
