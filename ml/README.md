# ml/ — model deep learning (opsional)

Aplikasi sudah jalan tanpa ini. Folder ini untuk meningkatkan deteksi dengan model terlatih.

- `sample_dataset.csv` — contoh data berlabel (1 = penipuan, 0 = aman). Perbanyak untuk akurasi lebih baik.
- `train_smishing.ipynb` — melatih model teks ringan lalu mengekspor `smishing.tflite`.

Jalankan notebook di Google Colab (gratis). Hasil `smishing.tflite` lalu diintegrasikan
ke aplikasi seperti dijelaskan di sel terakhir notebook.
