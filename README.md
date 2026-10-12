# UpNext Backend — Dockerized Event & Organization Management API

> **Tugas 1 - Study Club Backend Intermediate**  
> **Kabinet Genesis | KSM Veterantech UPNVJ 2026**

---

## 📌 Deskripsi Proyek

**UpNext Backend** adalah layanan RESTful API berbasis Node.js dan PostgreSQL untuk platform manajemen dan publikasi kegiatan organisasi kemahasiswaan (BEM, HIMA, UKM). Sistem ini menangani autentikasi organisasi, manajemen data profil, publikasi event, pengunggahan banner/dokumen, serta pencarian event kampus.

Pada repositori ini, aplikasi telah dikontainerisasi menggunakan **Dockerfile** dan **Docker Compose** agar backend dan database PostgreSQL dapat dijalankan secara terisolasi, terintegrasi melalui jaringan container, serta memiliki **persistensi data** melalui Docker Named Volume.

---

## 🏗️ Arsitektur & Teknologi

* **Runtime & Framework**: Node.js (v20 LTS), Express.js (v5)
* **Database & ORM**: PostgreSQL 16, Prisma ORM
* **Authentication**: JSON Web Token (JWT) & Bcrypt
* **Containerization**: Docker & Docker Compose
* **Data Persistence**: Docker Named Volume (`postgres_data`)

---

## 📋 Prasyarat Sistem (Prerequisites)

Sebelum menjalankan aplikasi, pastikan sistem Anda telah terpasang:
* **Docker Engine** (versi 24.0.0 atau lebih baru)
* **Docker Compose** (versi 2.20.0 atau lebih baru)
* **Git**
* *(Opsional)* **cURL** atau **Postman** untuk pengujian endpoint API

Verifikasi instalasi dengan perintah:
```bash
docker --version
docker compose version
```

---

## ⚙️ Setup Lingkungan (Environment Setup)

1. Clone repositori ini:
   ```bash
   git clone <URL_REPOSITORY_ANDA>
   cd upnext-backend
   ```

2. Buat berkas environment dari template `.env.example`:
   ```bash
   cp .env.example .env
   ```

3. Sesuaikan isi `.env` jika diperlukan. Secara default untuk lingkungan Docker Compose:
   ```env
   PORT=5000
   DATABASE_URL="postgresql://postgres:postgres_password@db:5432/upnext_db?schema=public"
   JWT_SECRET="upnext_jwt_secret_key_demo"
   SUPERUSER_SECRET="upnext_superuser_key_demo"
   ```

---

## 🚀 Perintah Build & Menjalankan Aplikasi

Jalankan seluruh service (Backend API + Database PostgreSQL) di latar belakang menggunakan perintah:

```bash
docker compose up --build -d
```

### Memeriksa Status Container
Pastikan kedua container (`backend` dan `db`) berjalan dengan baik:
```bash
docker compose ps
```

### Melihat Log Aplikasi
Untuk memverifikasi sinkronisasi skema Prisma dan server yang telah menyala:
```bash
docker compose logs -f backend
```

---

## 🧪 Contoh Pengujian Endpoint API

### 1. Pengujian Tulis Data (Write - Sign In / Public Endpoints)
Kalian dapat menguji endpoint publik atau membuat data organisasi baru:

**Mendaftarkan Organisasi Baru (Form-Data):**
```bash
curl -X POST http://localhost:5000/auth/signup \
  -F "name=HIMA Informatika" \
  -F "email=hima@upnvj.ac.id" \
  -F "password=secretpassword" \
  -F "membershipProof=@./dummy-proof.png"
```

*(Catatan: Anda juga bisa menggunakan endpoint sign-in atau seeder untuk membuat data awal).*

### 2. Pengujian Baca Data (Read - Mengambil Daftar Organisasi / Event)
Mengambil daftar seluruh organisasi yang terdaftar di database:
```bash
curl -X GET http://localhost:5000/organizations
```

Mengambil daftar seluruh event kampus:
```bash
curl -X GET http://localhost:5000/events
```

---

## 💾 Pengujian Persistensi Data (Data Persistence Test)

Pengujian ini membuktikan bahwa data di dalam database PostgreSQL **tidak hilang** saat container dimatikan dan dibuat ulang, berkat volume `postgres_data`.

1. **Simpan data baru** ke dalam API menggunakan salah satu endpoint tulis di atas.
2. **Ambil data** untuk memastikan data tersebut sudah tersimpan di database:
   ```bash
   curl -X GET http://localhost:5000/organizations
   ```
3. **Matikan dan hapus container** *(PENTING: Jangan gunakan flag `-v` agar volume tetap aman)*:
   ```bash
   docker compose down
   ```
4. **Nyalakan kembali container**:
   ```bash
   docker compose up -d
   ```
5. **Ambil kembali data melalui API**:
   ```bash
   curl -X GET http://localhost:5000/organizations
   ```
   **Hasil**: Data yang dibuat pada langkah 1 tetap tampil dan utuh. Ini membuktikan konfigurasi Docker Volume bekerja sesuai ketentuan.

---

## 🛑 Menghentikan Aplikasi

Untuk menghentikan service:
```bash
docker compose down
```

Untuk menghentikan service sekaligus **menghapus volume database** (reset data):
```bash
docker compose down -v
```

---

## 🤖 Atribusi Alat Bantu & Referensi

Sesuai dengan ketentuan tugas (Poin 5.C):
* **AI Assistance**: Anthropic Claude & Google DeepMind Antigravity AI digunakan untuk membantu perancangan struktur `Dockerfile`, konfigurasi `docker-compose.yml`, penyusunan skenario pengujian, serta pembuatan dokumentasi ini.
* **Referensi Resmi**:
  * [Docker Official Documentation](https://docs.docker.com/)
  * [Prisma Database in Docker Guide](https://www.prisma.io/docs/guides/deployment/deployment-guides/deploying-to-docker)
  * [PostgreSQL Docker Official Image](https://hub.docker.com/_/postgres)
