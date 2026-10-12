# PANDUAN TEKNIS & RUBRIK TUGAS 1: DOCKERISASI BACKEND DENGAN DOCKER COMPOSE

**Penyelenggara**: Study Club Backend Intermediate — Kabinet Genesis, KSM Veterantech UPNVJ 2026  
**Jenis Tugas**: Praktik Individu (Bobot 25% Nilai Akhir)  
**Batas Waktu**: Kamis, 15 Oktober 2026 pukul 23:25 WIB  
**Format Pengumpulan**: 1 Berkas PDF (`Tugas1_BackendIntermediate_Nama_NIM.pdf`) berisi Link GitHub Publik & Link Video YouTube.

---

## 1. Sasaran & Hasil Akhir Tugas

Tugas ini bertujuan mempraktikkan kontainerisasi backend dan database menggunakan Dockerfile dan Docker Compose. Hasil akhir yang harus dicapai:
1. **Container Image**: Berhasil di-build dari source code tanpa error.
2. **Koneksi Antar-Service**: Backend terhubung secara internal dengan service database PostgreSQL melalui Compose network.
3. **Aksesibilitas API**: Endpoint API dapat diakses melalui port lokal yang dipetakan (`5000:5000`).
4. **Persistensi Data**: Data yang ditulis ke database tetap tersimpan dan dapat dibaca kembali setelah container dimatikan dan dibuat ulang (`recreated`) menggunakan named volume.
5. **Kemandirian Lokal**: Seluruh pengerjaan dan demo dilakukan di komputer lokal (tidak perlu VPS).

---

## 2. Rincian Rubrik Penilaian (Total 100%)

| Komponen | Bobot | Kriteria Penilaian |
| :--- | :---: | :--- |
| **Penjelasan & Demo Video** | **50%** | • Penjelasan konfigurasi Dockerfile & Docker Compose (20 poin)<br>• Bukti build, menjalankan service, integrasi API–database, dan uji persistensi data (25 poin)<br>• Kejelasan penyampaian suara dan visual terminal (5 poin) |
| **Compose & Integrasi Database**| **20%** | • Backend dan database berjalan sebagai service di Docker Compose<br>• Environment variable dan port terpetakan dengan benar<br>• Koneksi antar-service (DNS Compose) berhasil |
| **Dockerfile & Build** | **15%** | • Image berhasil dibangun dari source code<br>• Konfigurasi dependency (Node.js, Prisma, OpenSSL) sesuai kebutuhan aplikasi |
| **Persistensi Data** | **10%** | • Named volume dikonfigurasi dengan benar pada service database<br>• Data tetap tersedia saat container dihapus/dibuat ulang |
| **README & Reproduksi** | **5%** | • Petunjuk lengkap dan jelas untuk menjalankan proyek dari awal serta mengulangi pengujian |

---

## 3. Spesifikasi Berkas yang Harus Dibuat di Repository

### A. `Dockerfile`
* Base image: `node:20-alpine`.
* Paket Alpine: `openssl` (wajib untuk binary engine Prisma).
* Direktori kerja: `/app`.
* Instalasi dependensi: `package.json` & `package-lock.json`.
* Prisma: `npx prisma generate` dieksekusi saat build.
* Port: `5000`.
* Entrypoint/CMD: Menjalankan sinkronisasi database (`npx prisma db push`) dan memulai server (`node api/app.js`).

### B. `docker-compose.yml`
* **Service `db`**:
  * Image: `postgres:16-alpine`.
  * Environment: `POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_DB`.
  * Named volume: `postgres_data:/var/lib/postgresql/data`.
  * Healthcheck: `pg_isready -U postgres -d upnext_db`.
* **Service `backend`**:
  * Build: `.` (menggunakan Dockerfile).
  * Port: `5000:5000`.
  * Environment: `DATABASE_URL=postgresql://postgres:postgres_password@db:5432/upnext_db?schema=public`.
  * Dependency: `depends_on` dengan condition `service_healthy` ke service `db`.
* **Named Volumes**: Definisi volume `postgres_data` di root level.
* **Network**: Bridge network terdedikasi.

### C. `.dockerignore`
* Mengabaikan: `node_modules`, `.env`, `.git`, `.dist`, `npm-debug.log`, dsb.

### D. `.env.example`
* Menyediakan template variabel lingkungan tanpa mengekspos kredensial asli.

### E. `README.md`
* Dokumentasi instruksi setup, build, pengujian endpoint, dan pengujian persistensi data, serta atribusi tools/AI.

---

## 4. Panduan & Skenario Rekaman Video Demo (Maks. 10 Menit)

Gunakan skenario berikut saat merekam video demo untuk memastikan seluruh 50 poin video terpenuhi:

* **Menit 00:00 – 01:30 (Perkenalan Proyek & Konfigurasi):**
  * Sebutkan Nama, NIM, dan judul tugas.
  * Tunjukkan dan jelaskan baris demi baris file `Dockerfile` (base image, install dependencies, prisma generate, expose port).
  * Tunjukkan dan jelaskan file `docker-compose.yml` (service `backend`, service `db`, network inter-service, environment variable, port mapping, dan named volume `postgres_data`).
* **Menit 01:30 – 03:30 (Proses Build & Menjalankan Service):**
  * Tunjukkan terminal dalam kondisi bersih: jalankan `docker compose up --build -d`.
  * Tunjukkan status container dengan `docker compose ps` (keduanya running/healthy).
  * Tunjukkan log backend dengan `docker compose logs backend` untuk memperlihatkan `prisma db push` berhasil dan API siap menerima request.
* **Menit 03:30 – 06:00 (Pengujian Integrasi API – Database / Write & Read):**
  * Lakukan pengujian request **Tulis Data (Write)** menggunakan `curl` atau Postman (misalnya request registrasi organisasi atau create data).
  * Lakukan pengujian request **Baca Data (Read)** untuk membuktikan data berhasil masuk ke database PostgreSQL di dalam container.
* **Menit 06:00 – 08:30 (Uji Pembuktian Persistensi Data - Poin Kunci):**
  * Jelaskan bahwa container akan dimatikan tanpa menghapus volume.
  * Jalankan perintah: `docker compose down` (tekankan: *tanpa flag `-v`*).
  * Nyalakan kembali container dengan: `docker compose up -d`.
  * Kirimkan kembali request **Baca Data (Read)** ke endpoint yang sama.
  * Tunjukkan bahwa data yang dibuat sebelumnya **masih ada** secara utuh, membuktikan volume bekerja dengan benar.
* **Menit 08:30 – 09:30 (Penutup):**
  * Ringkas hasil pengujian dan tutup video.
