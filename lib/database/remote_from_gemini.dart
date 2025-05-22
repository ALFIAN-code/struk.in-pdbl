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
  var category = ["Makanan", "Belanja", "Transportasi", "Hiburan", "Lainnya"];

  try {
    if (api.isEmpty) throw Exception("API key is required");
    if (image.path.isEmpty) throw Exception("Image path is invalid");

    final model = GenerativeModel(model: 'gemma-3-27b-it', apiKey: api);
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
      "diskon" : Int,
      "biaya_layanan" : Int,
      "biaya_lainnya" : Int,
      "category" : String,
      "items": [
        {id : int,"name": String, "quantity": Int, "unit_price": Int, "price_total": Int}
      ],
      "subtotal": Int,
      "tax": Int,
      "total": Int
      ```
    }

    Aturan:
    - Jika bukan struk pembelian barang/jasa (misal: ATM, transfer, QRIS, e-wallet, mutasi, tiket, boarding pass), hasilkan:
    { "is_struk": false }
    Jika struk valid:
        - is_struk = true
        - Gunakan "00:00" jika jam tidak ada (date dalam format "yyyy-MM-dd HH:mm")
        - Semua harga dan jumlah: integer
        - Hitung unit_price = price_total / quantity jika tidak ada
        - Hitung price_total = unit_price * quantity jika tidak ada
        - Hitung tax = total - subtotal jika tidak ada
        - Biaya_lainnya: isi jika ada biaya lain di luar pajak, diskon, dan layanan, jika tidak: 0,
        - apapun yang berhubungan dengan potongan harga, masukan ke diskon
        - Data tak tersedia dan tak bisa diturunkan: "-"
        - id dimulai dari 1

    Category:
      - Makanan: restoran, kafe, minuman, makan
      - Belanja: supermarket, kebutuhan harian, toko
      - Transportasi: bensin, parkir, tol, ojek
      - Hiburan: bioskop, game, tiket hiburan
      - Selain itu: Lainnya
""";

    //     String prompt = """
    //     Dari gambar, keluarkan hanya JSON dengan format:
    //     ```json
    // {
    //   "is_struk": Boolean,
    //   "business_name": String,
    //   "currency_code": String (ISO 4217),
    //   "invoice_number": String,
    //   "date": String,
    //   "payment_method": String,
    //   "diskon" : Int,
    //   "Biaya_layanan" : Int,
    //   "Biaya_lainnya" : Int,
    //   "items": [
    //     {id : int,"name": String, "quantity": Int, "unit_price": Int, "price_total": Int}
    //   ],
    //   "subtotal": Int,
    //   "tax": Int,
    //   "total": Int
    //   ```
    // }

    // Aturan:
    // - Jika gambar bukan struk pembelian barang atau jasa (misalnya: struk ATM, bukti transfer, tampilan aplikasi, transaksi e-wallet, QRIS tanpa item, mutasi rekening, tiket, boarding pass, dll.), maka hasilkan:
    // { "is_struk": false } dan kosongkan semua field lainnya
    // - Jika gambar adalah struk pembelian valid, set "is_struk": true.
    // - Jika terdapat lebih dari satu struk dalam satu gambar, pilih hanya satu struk yang paling lengkap, dominan, atau terbaca jelas. Abaikan struk lainnya.
    // - Jika field unit_price hilang, hitung dari: price_total / quantity.
    // - Jika price_total hilang, hitung dari: unit_price * quantity.
    // - Jika tax hilang, hitung dari: tax = total − subtotal.
    // - Data yang tidak tersedia harus diisi dengan nilai hasil turunan dari data lain jika memungkinkan. Jika tetap tidak tersedia, isikan string "-" (bukan null).
    // - Semua angka (termasuk harga dan quantity) dalam bentuk integer.
    // - Harga price_total harus selalu sama atau lebih besar dari unit_price.
    // - Nomor ID pada tiap item mulai dari 1 dan naik satu per item.
    // - isi biaya_lainnya jika ada biaya atau potongan yang tidak termasuk dalam diskon, pajak atapupun biaya_layanan, jika tidak ada isi dengan 0.
    // - isi category berdasarkan tipe struk yang ditemukan ("Makanan", "Belanja", "Transportasi", "Hiburan", "Lainnya")
    // - Format tanggal date harus dalam format ISO-8601 lengkap: "yyyy-MM-dd HH:mm" (jika waktu tidak tersedia, gunakan "00:00" sebagai waktu default).,
    // """;

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


// Aturan:
//     Jika bukan struk pembelian barang/jasa (misal: ATM, transfer, QRIS, e-wallet, mutasi, tiket, boarding pass), hasilkan:
//     { "is_struk": false }
//     Jika struk valid:
//         is_struk = true
//         Gunakan "00:00" jika jam tidak ada (date dalam format "yyyy-MM-dd HH:mm")
//         Semua harga dan jumlah: integer
//         Hitung unit_price = price_total / quantity jika tidak ada
//         Hitung price_total = unit_price * quantity jika tidak ada
//         Hitung tax = total - subtotal jika tidak ada
//         Biaya_lainnya: isi jika ada biaya lain di luar pajak, diskon, dan layanan, jika tidak: 0
//         Data tak tersedia dan tak bisa diturunkan: "-"
//         id dimulai dari 1

// Category:
//     Makanan: restoran, kafe, minuman, makan
//     Belanja: supermarket, kebutuhan harian, toko
//     Transportasi: bensin, parkir, tol, ojek
//     Hiburan: bioskop, game, tiket hiburan
//     Selain itu: Lainnya