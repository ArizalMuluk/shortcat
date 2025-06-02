## Versi

Versi saat ini: **v1.0.1 (Bahasa Indonesia)**

Catatan: Versi ini mencakup skrip `cdisk` dan `simapt` sebagai fitur utama.

# Perintah Bash Sederhana untuk Linux

Ini adalah koleksi skrip Bash kustom yang saya buat untuk menyederhanakan beberapa tugas umum dan menambahkan perintah praktis di terminal Linux. Tujuannya adalah membuat interaksi dengan command line menjadi lebih cepat dan efisien untuk penggunaan sehari-hari.

## Deskripsi Proyek

Proyek ini berisi skrip-skrip Bash independen yang dirancang untuk dijalankan langsung di terminal Linux. Skrip-skrip ini adalah perintah kustom yang bisa Anda tambahkan ke sistem Anda agar tersedia dari mana saja.

Contoh utama skrip yang disertakan adalah `cdisk`, sebuah perintah sederhana untuk mengecek penggunaan ruang disk pada partisi penting dan ukuran direktori home Anda, membantu Anda memantau ruang penyimpanan dengan cepat. Juga disertakan skrip `simapt`, sebuah utilitas sederhana untuk mengelola paket menggunakan APT (Advanced Package Tool) dengan cepat, mencakup update, upgrade, clean, dan autoremove.

Kami menggunakan `install.sh` sebagai skrip pembantu untuk memudahkan proses pemasangan skrip-skrip ini ke dalam `$HOME/.local/bin/`, lokasi standar yang direkomendasikan untuk executable yang diinstal oleh pengguna.

## Isi Repositori

Repositori ini berisi struktur dasar untuk mendistribusikan skrip Bash kustom:

- `README.md`: File ini (yang sedang Anda baca!) menjelaskan tentang proyek.
- `install.sh`: Skrip Bash yang akan mengotomatiskan proses penyalinan skrip kustom ke direktori `$HOME/.local/bin/` Anda dan memberikan izin eksekusi.
- `uninstall.sh`: Skrip Bash untuk menghapus skrip kustom yang telah diinstal.
- `scripts/`: Direktori yang berisi file-file skrip kustom itu sendiri. Saat ini, berisi:
  - `scripts/cdisk`: Skrip untuk mengecek ruang disk.
  - `scripts/simapt`: Skrip untuk menjalankan perintah apt update, clean, dan autoremove.

## Persyaratan

Untuk menggunakan skrip ini, Anda memerlukan:

- Sistem operasi berbasis Linux dengan Bash sebagai shell default atau tersedia.
- Perintah `git` (karena metode instalasi utama menggunakan kloning repositori).
- Koneksi internet untuk mengunduh file (jika tidak diambil secara lokal).

## Instalasi

Cara termudah untuk memasang skrip ini adalah dengan menggunakan skrip `install.sh` yang sudah disediakan. Skrip ini akan menyalin perintah kustom ke direktori `$HOME/.local/bin/` Anda. Instalasi ke `$HOME/.local/bin/` tidak memerlukan hak akses root (sudo) karena direktori tersebut berada dalam area home pengguna.

### Opsi Menggunakan Git Clone (Direkomendasikan)

1. Buka terminal.
2. Kloning repositori ini ke komputer Anda:
   ```bash
   git clone https://github.com/ArizalMuluk/simple-linux-commands.git
   ```

3. Masuk ke direktori hasil kloning:
   ```bash
   cd shortcat
   ```

4. Berikan izin eksekusi pada skrip instalasi:
   ```bash
   chmod +x ./install.sh
   ```

5. Jalankan skrip instalasi:
   ```bash
   ./install.sh
   ```

### Langkah Pasca-Instalasi (Penting):

Setelah skrip `install.sh` selesai berjalan, ia akan menyalin skrip kustom Anda ke `$HOME/.local/bin/`. Agar sistem mengenali perintah baru ini dari direktori manapun, Anda perlu memastikan `$HOME/.local/bin/` ada dalam variabel lingkungan `$PATH` Anda.

Biasanya, distribusi Linux modern akan otomatis menambahkan `$HOME/.local/bin/` ke `$PATH` jika direktori tersebut ada. Namun, jika ini pertama kalinya Anda menggunakan direktori ini, Anda mungkin perlu:

- Membuka terminal baru, ATAU
- Memuat ulang konfigurasi Bash Anda di terminal saat ini dengan:
  ```bash
  source ~/.bashrc
  ```

Skrip `install.sh` akan memberikan pesan konfirmasi dan mengingatkan Anda tentang langkah ini.

## Uninstalasi

Untuk menghapus skrip kustom yang telah diinstal, gunakan skrip `uninstall.sh` yang disertakan dalam repositori ini.

1. Buka terminal.
2. Masuk ke direktori tempat Anda mengkloning repositori ini sebelumnya:
   ```bash
   cd simple-linux-commands # Atau nama folder tempat Anda mengkloning repo
   ```

3. Berikan izin eksekusi pada skrip uninstalasi:
   ```bash
   chmod +x ./uninstall.sh
   ```

4. Jalankan skrip uninstalasi:
   ```bash
   ./uninstall.sh
   ```

Skrip uninstalasi akan menghapus file `cdisk` dan `simapt` dari direktori `$HOME/.local/bin/` Anda.

### Langkah Pasca-Uninstalasi (Penting):

Setelah skrip `uninstall.sh` selesai berjalan, perintah yang dihapus mungkin masih aktif di terminal saat ini sampai shell dimuat ulang. Untuk memastikan perintah tidak bisa lagi dijalankan:

- Buka terminal baru, ATAU
- Muat ulang konfigurasi Bash Anda di terminal saat ini dengan:
  ```bash
  source ~/.bashrc
  ```

## Penggunaan

Setelah proses instalasi selesai dan terminal Anda dimuat ulang (atau setelah menjalankan `source ~/.bashrc`), Anda bisa langsung menjalankan perintah kustom dari direktori manapun di terminal Anda.

### Contoh:

- Untuk mengecek penggunaan ruang disk:
  ```bash
  cdisk
  ```

Perintah ini akan menjalankan skrip `cdisk` yang telah diinstal dan menampilkan penggunaan ruang disk Anda.

- Contoh lainnya:
  ```bash
  simapt
  ```

Eksekusi perintah `simapt` akan menginisiasi serangkaian operasi manajemen paket melalui Advanced Package Tool (APT), yang mana memerlukan otorisasi tingkat superuser. Oleh karena itu, pada saat pemanggilan `simapt`, sistem akan memohon penyediaan kredensial otentikasi `sudo` dari pengguna eksekutif. Secara spesifik, skrip ini dikonfigurasi untuk menjalankan perintah-perintah `sudo apt update`, `sudo apt upgrade -y`, `sudo apt clean`, dan `sudo apt autoremove -y` secara berurutan.

## Skrip yang Tersedia

- **cdisk**: Utilitas ini berfungsi untuk menginspeksi dan melaporkan alokasi ruang pada partisi-partisi disk krusial, mencakup direktori root (/), direktori home pengguna (/home), dan direktori variabel (/var), serta menghitung total volume yang ditempati oleh direktori home pengguna (~). Hasil keluaran disajikan dalam format yang dioptimalkan untuk keterbacaan.

- **simapt**: Skrip ini merupakan instrumentasi yang disederhanakan untuk mengeksekusi prosedur pembaharuan dan pembersihan paket melalui APT, meliputi operasi `sudo apt update`, `sudo apt upgrade -y`, `sudo apt clean`, dan `sudo apt autoremove -y`. Eksekusinya mengharuskan penyediaan kredensial `sudo`.

## Kontribusi

Partisipasi dalam pengembangan proyek ini sangat dihargai. Kontribusi dapat berbentuk usulan skrip Bash baru, penyempurnaan terhadap skrip yang telah ada, atau saran-saran konstruktif terkait dokumentasi ini. Prosedur kontribusi dapat dilakukan melalui pembukaan isu atau pengajuan Pull Request pada repositori yang bersangkutan.

## Lisensi

Proyek ini dilisensikan di bawah [MIT License](./LICENSE).

## Kreator

ArizalMuluk
