# LAPORAN PENGERJAAN TUGAS 1
## DOCKERISASI BACKEND DENGAN DOCKER COMPOSE

**Mata Kuliah / Program**: Study Club Backend Intermediate — Kabinet Genesis  
**Penyelenggara**: KSM Veterantech UPN "Veteran" Jakarta 2026  
**Format Berkas Akhir**: PDF (`Tugas1_BackendIntermediate_Nama_NIM.pdf`)

---

## 1. IDENTITAS MAHASISWA & TAUTAN PENGUMPULAN

* **Nama Lengkap**: Muhammad Zakki
* **NIM**: [MASUKKAN_NIM_ANDA_DI_SINI]
* **Program Studi**: [MASUKKAN_PRODI_ANDA_DI_SINI]
* **Link Repositori GitHub**: https://github.com/mhdztr/t1-upnext
* **Link Video Demo YouTube**: [MASUKKAN_LINK_YOUTUBE_ANDA_DI_SINI]

---

## 2. DESKRIPSI SINGKAT PROYEK

Proyek **UpNext Backend** adalah layanan RESTful API berbasis Node.js dan PostgreSQL yang berfungsi sebagai sistem manajemen dan publikasi kegiatan organisasi kemahasiswaan (BEM, HIMA, SENAT, UKM). Sistem ini menangani autentikasi akun organisasi, manajemen event kampus, unggah berkas dan banner, serta pencarian kegiatan.

Pada tugas ini, aplikasi telah dikontainerisasi secara penuh menggunakan **Dockerfile** dan diorkestrasikan dengan **Docker Compose**. Seluruh komponen backend dan database PostgreSQL berjalan secara terisolasi di dalam kontainer lokal, terhubung melalui jaringan bridge internal, dan memiliki jaminan **persistensi data** menggunakan Docker Named Volume.

---

## 3. ARSITEKTUR & IMPLEMENTASI KONTAINERISASI

### A. Konfigurasi `Dockerfile`
Berkas `Dockerfile` dirancang dengan arsitektur multi-layer berbasis image minimalis:
* **Base Image**: `node:20-alpine` untuk meminimalkan ukuran image dan permukaan celah keamanan.
* **Dependensi Sistem**: Memasang paket `openssl` via Alpine Package Keeper (`apk add --no-cache openssl`). Paket ini wajib tersedia agar Prisma Query Engine binary dapat berjalan di Linux Alpine berbasis musl libc.
* **Layering Cache Dependensi**: Menyalin `package*.json` dan direktori `prisma/` sebelum instalasi dependensi, diikuti eksekusi `npx prisma generate` untuk mengompilasi Prisma Client khusus platform container.
* **Port Mapping**: Mengekspos port `5000` sebagai port utama aplikasi Express.js.
* **Entrypoint Lifecycle**: Menggunakan script eksekusi `docker-entrypoint.sh` untuk menjamin otomatisasi sinkronisasi tabel database sebelum server utama menyala.

### B. Konfigurasi `docker-compose.yml`
Orkestrasi multi-kontainer didefinisikan ke dalam dua service terpadu:
1. **Service `db` (Database)**:
   * Menggunakan image resmi `postgres:16-alpine`.
   * Menetapkan environment `POSTGRES_USER`, `POSTGRES_PASSWORD`, dan `POSTGRES_DB`.
   * Memetakan port `5432:5432` ke host untuk keperluan inspeksi.
   * Menghubungkan named volume `postgres_data:/var/lib/postgresql/data`.
   * Dilengkapi healthcheck menggunakan `pg_isready -U postgres -d upnext_db` dengan interval 5 detik dan toleransi 5 kali percobaan.
2. **Service `backend` (Aplikasi API)**:
   * Dibangun dari `Dockerfile` lokal.
   * Memetakan port `5000:5000` ke host machine.
   * Menetapkan `DATABASE_URL` dengan DNS internal Compose: `postgresql://postgres:postgres_password@db:5432/upnext_db?schema=public`.
   * Memiliki dependensi `depends_on` ke service `db` dengan kondisi `service_healthy` untuk menjamin backend hanya menyala saat database siap menerima koneksi.
3. **Isolasi Jaringan & Volume**:
   * Jaringan menggunakan driver bridge terisolasi: `upnext_network`.
   * Persistensi data dijamin oleh named volume level root: `postgres_data`.

---

## 4. METODE & HASIL PENGUJIAN

Pengujian dilakukan secara lokal pada host machine untuk membuktikan pemenuhan seluruh kriteria rubrik tugas:

### A. Pengujian Build & Status Kontainer
* **Perintah**: `docker compose up --build -d` dilanjutkan `docker compose ps`
* **Hasil**:
  * Image `upnext-backend-backend` berhasil dibangun tanpa error.
  * Kontainer `upnext_db` berstatus `Up (healthy)` pada port 5432.
  * Kontainer `upnext_backend` berstatus `Up` pada port 5000.
  * Log backend mengonfirmasi `npx prisma db push` berhasil menyinkronkan seluruh model skema database dan server Express aktif di port 5000.

### B. Pengujian Integrasi API – Database (Read & Write)
1. **Uji Baca Data (Read)**:
   * Request: `GET http://localhost:5000/organizations`
   * Hasil: Berhasil mengembalikan status HTTP 200 OK beserta payload data organisasi dari database PostgreSQL.
2. **Uji Tulis Data (Write)**:
   * Request: `POST http://localhost:5000/auth/signup` (multipart/form-data dengan field name, email, password, dan membershipProof).
   * Hasil: Berhasil mengembalikan status HTTP 201 Created dengan pesan *"Organization registered successfully"* dan token JWT.
   * Verifikasi DB: Pemanggilan ulang `GET /organizations` membuktikan bahwa record organisasi baru tersebut telah berhasil tersimpan di PostgreSQL.

### C. Pembuktian Uji Persistensi Data (Named Volume)
Pengujian ini membuktikan bahwa data database tidak hilang saat siklus hidup kontainer dihentikan dan dibuat ulang:
1. Seluruh kontainer dimatikan dan dihapus dari memori menggunakan perintah:
   `docker compose down` *(tanpa flag `-v`)*.
2. Keberadaan volume lokal diverifikasi dengan:
   `docker volume ls | grep postgres_data` -> volume `upnext-backend_postgres_data` tetap tersimpan di disk lokal.
3. Kontainer dinyalakan kembali dari awal menggunakan:
   `docker compose up -d`.
4. Endpoint `GET http://localhost:5000/organizations` dipanggil kembali.
5. **Hasil**: Seluruh data yang dibuat sebelum kontainer dimatikan **tetap ada, lengkap, dan utuh**. Hal ini membuktikan bahwa konfigurasi volume persistensi bekerja 100% sesuai standar tugas.

---

## 5. KESIMPULAN

Seluruh capaian dan sasaran tugas telah berhasil dipenuhi:
1. Aplikasi Express.js dan database PostgreSQL berhasil dikontainerisasi secara independen di komputer lokal.
2. Komunikasi antar-kontainer terhubung melalui internal network DNS Docker Compose.
3. Port lokal 5000 dan 5432 berhasil dipetakan dengan tepat.
4. Persistensi data terbukti berfungsi melalui named volume `postgres_data`.

---

## 6. ATRIBUSI ALAT BANTU & KEJUJURAN AKADEMIK

Sesuai ketentuan transparansi tugas:
* **Alat Bantu AI**: Claude & Google DeepMind Antigravity AI digunakan untuk perancangan struktur `Dockerfile`, konfigurasi `docker-compose.yml`, optimasi script entrypoint, dan penyusunan draf dokumentasi teknis.
* **Referensi Resmi**:
  * Docker Documentation (https://docs.docker.com/)
  * Prisma Deployment to Docker Guide (https://www.prisma.io/docs/guides/deployment/deployment-guides/deploying-to-docker)
  * PostgreSQL Docker Official Image (https://hub.docker.com/_/postgres)
