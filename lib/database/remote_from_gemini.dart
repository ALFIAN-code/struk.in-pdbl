import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:strukin/model/struk_from_api.dart';

Future<StrukFromApi> processReceipt(
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
      Extract the invoice number, date, payment method, items, their quantity, price, subtotal, total, and tax from the following receipt:
      $receiptText And give each item a category strictly from this list of categories $categories. If the invoice number, payment method, date, can't be extracted please put the string "UNKNOWN"

      Please return the response in the following JSON format:
      ```json
      {
        "invoice_number": "Invoice Number",
        "date": "Date",
        "payment_method":"PAYMENT METHOD",
        "items": [
          {
            "name": "Item Name",
            "quantity": Quantity,
            "price": Price,
            "category": "category"
          },
          ...
        ],
        "subtotal": Subtotal,
        "tax": Tax,
        "total": Total
      }
      ```""";

    final content = [Content.text(prompt)];
    final response = await model.generateContent(content);

    String generatedText = response.text ?? '';

    String jsonString = extractJsonFromText(generatedText);

    Map<String, dynamic> extractedData = jsonDecode(jsonString);

    StrukFromApi order = StrukFromApi.fromJson(extractedData);

    // Return the extracted JSON data
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
