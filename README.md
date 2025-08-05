\<div align="center"\>
\<img src="assets/logo.png" alt="Struk.in Logo" width="120" height="120"\>

**Aplikasi pintar untuk memindai struk dan membagi tagihan dengan mudah\!**

[](https://play.google.com/store/apps/details?id=com.strukin.pdbl&pcampaignid=web_share)
[](https://flutter.dev)
[](https://github.com/ALFIAN-code/struk.in-pdbl)

\</div\>

## 📱 Tentang Aplikasi

**Struk.in** adalah aplikasi mobile yang memudahkan Anda untuk memindai struk belanja dan membagi tagihan secara otomatis dengan teman-teman. Tidak perlu lagi repot menghitung manual atau merasa bingung saat hendak membagi bill\!

### ✨ Fitur Utama

  - 🔍 **Pemindaian Struk Otomatis**: Gunakan kamera untuk memindai struk dan ekstrak data secara otomatis menggunakan OCR dan AI
  - 🤖 **Powered by Gemini AI**: Menggunakan Google Gemini AI untuk akurasi pemrosesan yang tinggi
  - 👥 **Pembagian Tagihan Pintar**: Bagi tagihan berdasarkan pesanan masing-masing secara transparan
  - 💾 **Riwayat Transaksi**: Simpan dan kelola riwayat pemindaian struk
  - 🏷️ **Kategori Otomatis**: Klasifikasi otomatis untuk makanan, belanja, transportasi, hiburan, dan lainnya
  - 📊 **Detail Lengkap**: Tampilkan informasi lengkap termasuk pajak, diskon, dan biaya layanan
  - 🔄 **Edit Manual**: Fitur edit untuk koreksi data jika diperlukan

### 🛠️ Teknologi yang Digunakan

  - **Flutter** - Framework UI cross-platform
  - **Google ML Kit** - Text Recognition (OCR)
  - **Google Gemini AI** - AI untuk pemrosesan dan ekstraksi data struk
  - **SQLite** - Database lokal untuk penyimpanan data
  - **GetX** - State management dan navigasi
  - **Shorebird** - Code push untuk update aplikasi

## 📲 Download Aplikasi

[![Get it on Google Play](https://play.google.com/intl/en_us/badges/static/images/badges/en_badge_web_generic.png)](https://play.google.com/store/apps/details?id=com.strukin.pdbl&pcampaignid=web_share)

## 🚀 Cara Penggunaan

1.  **Buka Aplikasi** dan ikuti onboarding untuk memahami fitur-fitur utama
2.  **Ambil Foto Struk** menggunakan kamera atau pilih dari galeri
3.  **Tunggu Pemrosesan** - AI akan membaca dan mengekstrak data struk secara otomatis
4.  **Tambah Peserta** untuk membagi tagihan
5.  **Pilih Item** yang akan dibagi untuk setiap peserta
6.  **Lihat Hasil** pembagian tagihan yang sudah dihitung otomatis
7.  **Simpan Transaksi** untuk riwayat masa depan

## 🏗️ Instalasi Development

### Prasyarat

  - Flutter SDK (\>=3.7.0)
  - Android Studio / VS Code
  - Git

### Langkah Instalasi

1.  **Clone repository**

<!-- end list -->

```bash
git clone https://github.com/ALFIAN-code/struk.in-pdbl.git
cd struk.in-pdbl
```

2.  **Install dependencies**

<!-- end list -->

```bash
flutter pub get
```

3.  **Setup API Key**
      - Buat file `lib/gemini_key.dart`
      - Tambahkan Google Gemini API key:

<!-- end list -->

```dart
const String geminiApi = 'YOUR_GEMINI_API_KEY_HERE';
```

4.  **Jalankan aplikasi**

<!-- end list -->

```bash
flutter run
```

### 🔧 Konfigurasi Build

#### Android

  - Minimum SDK: 21
  - Target SDK: 34
  - Compile SDK: 34

#### Dependencies Utama

```yaml
dependencies:
  flutter_gemini: ^3.0.0
  google_generative_ai: ^0.4.6
  google_mlkit_text_recognition: ^0.14.0
  image_picker: ^1.1.2
  sqflite: ^2.4.2
  get: ^4.7.2
  # ... dan lainnya
```

## 📁 Struktur Project

```
lib/
├── controller/          # Business logic & state management
├── database/           # Database helper & remote API
├── model/             # Data models
├── view/              # UI components & screens
└── main.dart          # Entry point aplikasi
```

## 🤝 Kontribusi

Kami terbuka untuk kontribusi\! Silakan:

1.  Fork repository ini
2.  Buat branch fitur baru (`git checkout -b feature/fitur-baru`)
3.  Commit perubahan (`git commit -am 'Tambah fitur baru'`)
4.  Push ke branch (`git push origin feature/fitur-baru`)
5.  Buat Pull Request

## 👨‍💻 Developer

Dikembangkan oleh **ALFIAN** dengan ❤️

  - GitHub: [@ALFIAN-code](https://github.com/ALFIAN-code)
  - Project Link: [struk.in-pdbl](https://github.com/ALFIAN-code/struk.in-pdbl)

## ✨ Contributor

Terima kasih kepada para kontributor yang telah membantu pengembangan proyek ini\!

  - **ALFIAN-code** - [https://github.com/ALFIAN-code](https://github.com/ALFIAN-code)
  - **Dvanosul** - [https://github.com/Dvanosul](https://www.google.com/search?q=https://github.com/Dvanosul)
  - **salsabolu** - [https://github.com/salsabolu](https://www.google.com/search?q=https://github.com/salsabolu)
  - **aldomarsendo** - [https://github.com/aldomarsendo](https://www.google.com/search?q=https://github.com/aldomarsendo)
  - **fikriae** - [https://github.com/fikriae](https://www.google.com/search?q=https://github.com/fikriae)

## 📞 Dukungan

Jika mengalami masalah atau memiliki saran, silakan:

  - Buka [Issues](https://github.com/ALFIAN-code/struk.in-pdbl/issues) di GitHub
  - Download di [Google Play Store](https://play.google.com/store/apps/details?id=com.strukin.pdbl&pcampaignid=web_share)

-----

\<div align="center"\>
\<p\>\<strong\>Struk.in\</strong\> - Memudahkan hidup, satu struk setiap waktu\! 🎉\</p\>
\</div\>