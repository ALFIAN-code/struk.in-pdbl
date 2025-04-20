import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:strukin/model/struk_from_api.dart';

/// Memproses gambar struk dan mengembalikan data struk dalam format JSON
///
/// [api] - API key untuk mengakses layanan Gemini
/// [image] - File gambar struk yang akan diproses
///
/// Mengembalikan:
/// - StrukFromApi yang berisi data struk yang telah diproses
/// - Null jika gambar bukan struk atau terjadi error
Future<StrukFromApi?> processReceipt(String api, XFile image) async {
  try {
    if (api.isEmpty) throw Exception("API key is required");
    if (image.path.isEmpty) throw Exception("Image path is invalid");

    final model = GenerativeModel(model: 'gemini-2.0-flash-lite', apiKey: api);

    String prompt = """ 
    Dari gambar, keluarkan hanya JSON dengan format:
    ```json
{
  "is_struk": Boolean,
  "business_name": String,
  "currency_code": String (ISO 4217),
  "invoice_number": String,
  "date": String,
  "payment_method": String,
  "items": [
    {id : int,"name": String, "quantity": Int, "unit_price": Int, "price_total": Int}
  ],
  "subtotal": Int,
  "tax": Int,
  "total": Int
  ```
}

Aturan:
- Jika gambar bukan struk, hasilkan: {"is_struk": false} dan sisakan lainnya kosong.
- Jika unit_price hilang, set unit_price = price_total / quantity.
- Jika price_total hilang, set price_total = unit_price * quantity.
- Jika tax hilang, set tax = total − subtotal.
- Data yang tidak ada harus di-derive dari nilai lain.
- Jika string null, ganti dengan "-".
- Harga (price_total) selalu sama atau lebih dari unit_price.
- beri ID di setiap item dengan int 1 .. n
""";

    // Diberi gambar struk, kembalikan **ONLY JSON**:
    // ```json
    // {
    //   "is_struk": true,
    //   "business_name": "String",
    //   "currency_code" :"String",
    //   "invoice_number":"String",
    //   "date":"String",
    //   "payment_method":"String",
    //   "items":[
    //     {"name":"String","quantity":Int,"unit_price":Int,"price_total": Int}
    //   ],
    //   "subtotal":Int,
    //   "tax":Int,
    //   "total":Int
    // }
    // ```

    // Aturan:
    // - jika gambar bukan merupakan struk, kembalikan {"is_struk": false}, dan sisakan data yang lain kosong
    // - Jika unit_price hilang: unit_price=price_total/quantity
    // - Jika price_total hilang: price_total=unit_price*quantity
    // - Jika tax hilang: tax=total−subtotal
    // - Jika data tak ada, derivasi dari nilai lain
    // - currency code menggunakan format iso 4217
    // - jika ada data string yang null, berikan "-"
    // - unit_price adalah harga satuan per item/menu
    // - price_total adalah harga total per item berdasarkan quantity dan unit_price
    // - price price selalu sama atau lebih dari unit_price

    // Read image bytes directly
    final imageBytes = await image.readAsBytes();
    if (imageBytes.isEmpty) {
      throw Exception("Failed to read image bytes");
    }

    final content = [
      Content.multi([TextPart(prompt), DataPart('image/jpeg', imageBytes)]),
    ];
    final response = await model.generateContent(content);

    print(response.text);
    String generatedText = response.text ?? '';

    if (generatedText.isEmpty) {
      throw Exception("Empty response from Gemini API");
    }

    String jsonString;
    try {
      jsonString = extractJsonFromText(generatedText);
    } catch (e) {
      throw Exception("Failed to extract JSON from response: ${e.toString()}");
    }

    Map<String, dynamic> extractedData;
    try {
      extractedData = jsonDecode(jsonString);
    } catch (e) {
      throw Exception("Invalid JSON format: ${e.toString()}");
    }

    // if (extractedData.containsKey('is_struk') && !extractedData['is_struk']) {
    //   return null;
    // }

    try {
      StrukFromApi order = StrukFromApi.fromJson(extractedData);
      return order;
    } catch (e) {
      throw Exception("Failed to create StrukFromApi: ${e.toString()}");
    }
  } catch (error) {
    // return
    throw Exception("Error processing receipt: $error");
  }
}

/// Mengekstrak string JSON dari teks respons Gemini
///
/// [text] - Teks respons dari Gemini yang mengandung data JSON
///
/// Mengembalikan:
/// - String JSON yang telah dibersihkan
/// - Melempar FormatException jika format JSON tidak valid
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
