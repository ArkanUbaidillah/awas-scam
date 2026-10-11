# Awas Scam — detektor pesan penipuan (on-device, hibrida AI + aturan)

Aplikasi Flutter yang menandai pesan berpotensi penipuan (smishing): undian palsu,
"mama/papa minta pulsa", phishing OTP/PIN, pinjol ilegal, link mencurigakan, dan modus
"paket tertahan di bea cukai". **Semua analisis berjalan di perangkat, tanpa internet** —
isi pesanmu tidak pernah dikirim ke mana pun.

## Fitur
- **Periksa pesan** — tempel SMS/WhatsApp, dapatkan nilai risiko (Aman/Waspada/Bahaya) dengan
  rincian **Skor pola + Skor AI + Gabungan**, alasan yang jelas, dan saran tindakan.
- **Deteksi hibrida** — menggabungkan **mesin berbasis pola** (kata/fraze modus penipuan khas
  Indonesia, analisis tautan) dengan **model AI ringan** (logistic regression bag-of-words yang
  dilatih dari dataset, ditanam sebagai kode Dart murni di `lib/services/ml_model.dart`).
  Model menangkap kasus yang luput dari aturan.
- **Pindai SMS** (Android) — membaca kotak masuk dan menandai yang mencurigakan.
- **Statistik** — dashboard: jumlah diperiksa/ditandai, sebaran tingkat risiko, modus
  tersering, dan grafik 7 hari terakhir (menyambung ke visualisasi data).
- **Cek Tautan** — bongkar sebuah URL tanpa membukanya: pemendek tautan, domain peniru merek,
  karakter non-Latin (punycode), IP mentah, trik "@", TLD berisiko, subdomain bertingkat.
- **Pengaturan** — mode gelap dan tingkat sensitivitas deteksi (Rendah/Normal/Tinggi).
- **Edukasi** — pustaka modus penipuan umum beserta ciri dan cara menanggapinya.
- **Umpan balik** — tandai hasil "benar penipuan / salah tandai"; ikut masuk ke statistik.
- **Transparan** — setiap keputusan disertai alasan, bukan kotak hitam.

## Cara kerja
Inti deteksi: `lib/services/detector.dart`.
- Skor **pola**: bobot kata kunci modus + analisis tautan, dengan deteksi konteks **pelindung**
  (mis. "jangan beri kode ke siapa pun") agar pesan OTP resmi tidak salah ditandai.
- Skor **AI**: `lib/services/ml_model.dart` (dihasilkan notebook `ml/train_smishing.ipynb`).
- **Gabungan** = 0.65 × pola + 0.35 × AI, lalu dipetakan ke tingkat risiko.

## Menjalankan
Butuh Flutter SDK (`flutter doctor` hijau).

```bash
flutter create .     # melengkapi berkas platform tanpa menimpa kode ini (sekali saja)
flutter pub get
flutter test         # menguji mesin deteksi (pola + AI + tautan)
flutter run          # pilih HP/emulator Android; fitur "Pindai SMS" hanya aktif di Android
```

Pratinjau cepat tanpa HP: aktifkan Developer Mode Windows (`start ms-settings:developers`),
lalu `flutter run -d windows`. Inti aplikasi jalan; "Pindai SMS" menampilkan pesan khusus Android.

## Melatih ulang model AI (opsional)
Model sekarang dilatih dari dataset contoh kecil. Untuk akurasi lebih baik, perbanyak
`ml/sample_dataset.csv`, jalankan `ml/train_smishing.ipynb` (Google Colab, gratis), lalu
salin hasil `MlModel` (bobot) ke `lib/services/ml_model.dart`. Notebook juga bisa mengekspor
TensorFlow Lite bila ingin model lebih besar.

## Dua versi: web + aplikasi (untuk portofolio)

Satu kodebase, dua hasil. Semua logika deteksi sama; di web fitur "Pindai SMS" otomatis
disembunyikan (browser tidak bisa membaca SMS).

### Aplikasi Android (APK)
```bash
flutter build apk --release
# hasil: build/app/outputs/flutter-apk/app-release.apk  -> bagikan/di-install di HP
```

### Versi web (bisa dicoba lewat browser)
```bash
# untuk GitHub Pages (situs proyek di /namarepo/):
flutter build web --base-href "/awas-scam/"
# untuk Netlify/Vercel (di root domain): gunakan --base-href "/"
```
Hasilnya ada di `build/web` (situs statis).

### Hosting web gratis, tanpa kartu
**Pilihan A — GitHub Pages** (repo harus publik):
```powershell
flutter build web --base-href "/awas-scam/"
Remove-Item -Recurse -Force docs -ErrorAction SilentlyContinue
Copy-Item -Recurse build\web docs
git add docs; git commit -m "deploy web demo"; git push
```
Lalu GitHub → repo → **Settings → Pages** → Source: **Deploy from a branch** → `main` / `/docs`.
Alamatnya: `https://USERNAME.github.io/awas-scam/`

**Pilihan B — Netlify (cocok untuk repo privat, tanpa kartu):** build dengan `--base-href "/"`,
lalu buka app.netlify.com/drop dan seret folder `build/web` ke sana. Dapat alamat publik instan.

Taruh kedua tautan (situs web + unduhan APK) di portofoliomu agar orang bisa langsung mencoba.

## Struktur
```
lib/
  main.dart · theme.dart
  models/        detection.dart · url_check.dart
  services/      detector.dart (inti) · ml_model.dart (bobot AI) · stats.dart
                 history_store.dart · sms_service.dart
  screens/       main_shell.dart · home_screen.dart · detail_screen.dart
                 stats_screen.dart · url_check_screen.dart · education_screen.dart
  widgets/       risk_badge.dart · reason_tile.dart
test/            detector_test.dart · widget_test.dart
ml/              sample_dataset.csv · train_smishing.ipynb
```

## Batasan & etika
- Alat **bantu**, bukan kepastian. Keputusan akhir tetap di tangan pengguna.
- Model AI dilatih dari dataset kecil; perbanyak data untuk hasil lebih baik.
- Membaca SMS memakai izin sensitif; hanya diproses **di perangkat**, tidak dikirim ke mana pun.
  Aplikasi berizin SMS dibatasi di Google Play; versi ini untuk pemakaian pribadi / sideload /
  portofolio.
