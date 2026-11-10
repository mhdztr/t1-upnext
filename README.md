# UpNext Backend — Nginx Gateway, Load Balancing & Traffic Security

**Tugas 2 — Study Club Backend Intermediate**  
Kabinet Genesis | KSM Veterantech UPNVJ 2026  
Repository: [mhdztr/t1-upnext](https://github.com/mhdztr/t1-upnext)

---

## 1. Overview

Proyek ini merupakan kelanjutan dari repositori Tugas 1 UpNext Backend. Pada tahap ini, arsitektur sistem ditingkatkan dengan menerapkan Nginx sebagai satu-satunya pintu gerbang masuk (*Single Ingress Gateway* / *Reverse Proxy*), penyeimbang beban (*Load Balancer*) untuk 3 replika backend Express.js, pembatasan laju permintaan (*Rate Limiting*), serta penerapan header keamanan dan kompresi Gzip.

### Arsitektur Multi-Container

* **Satu Pintu Masuk (Single Ingress)**: Service Nginx adalah satu-satunya service yang memublikasikan port ke host (`80:80`). Service backend dan database PostgreSQL tidak mengekspos port ke host (`no ports`), melainkan berkomunikasi di dalam bridge network internal terisolasi (`upnext_network`).
* **Reverse Proxy**: Nginx memetakan prefix `/api/` ke cluster backend, meneruskan header `Host` dan `X-Forwarded-For`.
* **Load Balancing**: Backend berjalan dengan 3 replika kontainer (`deploy.replicas: 3`), dikonfigurasikan dengan upstream shared memory `zone`, dan menyematkan header respons `X-Upstream: $upstream_addr`.
* **Rate Limiting**: Dibatasi menggunakan modul Nginx `limit_req` dengan status penolakan `429 Too Many Requests`.
* **Security & Compression**: Header proteksi `X-Content-Type-Options: nosniff` dan kompresi `gzip on` aktif untuk payload `application/json`.

---

## 2. Cara Menjalankan

### Prasyarat
* Docker Engine (minimal versi 24.0.0)
* Docker Compose (minimal versi 2.20.0 / Compose v2)
* Git & cURL

### Langkah Menjalankan

1. Salin template variabel lingkungan:
   ```bash
   cp .env.example .env
   ```

2. Jalankan seluruh stack kontainer di latar belakang (*detached mode*):
   ```bash
   docker compose up --build -d
   ```

3. Periksa status kontainer:
   ```bash
   docker compose ps
   ```

   Seluruh kontainer (1 Nginx, 3 Backend Replicas, dan 1 PostgreSQL) harus berstatus aktif (*Up*). Hanya Nginx yang memiliki port mapping `0.0.0.0:80->80/tcp`.

---

## 3. Bukti Pengujian cURL

Berikut adalah bukti pengujian fungsionalitas yang diambil langsung dari terminal (output teks asli):

### A. Port Backend Lama Tidak Bisa Diakses (Host Isolation)

Service backend (port 5000) dan PostgreSQL (port 5432) tidak lagi diekspos ke host network. Akses langsung dari host machine ditolak:

```text
$ curl -i http://localhost:5000
curl: (7) Failed to connect to localhost:5000 after 0 ms: Could not connect to server

$ curl -i http://localhost:5432
curl: (7) Failed to connect to localhost:5432 after 0 ms: Could not connect to server
```

### B. Load Balancing (X-Upstream Berganti Antar-Replika)

Permintaan berulang ke endpoint `/api/organizations` diteruskan bergantian secara *round-robin* ke ketiga replika backend, dibuktikan oleh perubahan IP internal pada header respons `X-Upstream`:

```text
$ for i in {1..6}; do curl -s -D - http://localhost/api/organizations -o /dev/null | grep -E "HTTP/|X-Upstream"; sleep 0.2; done
HTTP/1.1 200 OK
X-Upstream: 172.20.0.5:5000
HTTP/1.1 200 OK
X-Upstream: 172.20.0.4:5000
HTTP/1.1 200 OK
X-Upstream: 172.20.0.3:5000
HTTP/1.1 200 OK
X-Upstream: 172.20.0.5:5000
HTTP/1.1 200 OK
X-Upstream: 172.20.0.4:5000
HTTP/1.1 200 OK
X-Upstream: 172.20.0.3:5000
```

### C. Rate Limiting (Penolakan dengan Kode Status HTTP 429)

Ketika frekuensi request melebihi batas yang ditentukan pada Nginx (`rate=5r/s burst=2 nodelay`), Nginx secara otomatis menolak request berikutnya dengan status `429 Too Many Requests`:

```text
$ for i in {1..8}; do curl -s -D - http://localhost/api/organizations -o /dev/null | grep "HTTP/"; done
HTTP/1.1 200 OK
HTTP/1.1 200 OK
HTTP/1.1 200 OK
HTTP/1.1 429 Too Many Requests
HTTP/1.1 429 Too Many Requests
HTTP/1.1 429 Too Many Requests
HTTP/1.1 429 Too Many Requests
HTTP/1.1 429 Too Many Requests
```

### D. Header Keamanan dan Kompresi Gzip

Pengujian request dengan header `Accept-Encoding: gzip` membuktikan Nginx menyematkan header keamanan `X-Content-Type-Options: nosniff` dan mengompresi response JSON menjadi `Content-Encoding: gzip`:

```text
$ curl -I -H "Accept-Encoding: gzip" http://localhost/api/organizations
HTTP/1.1 200 OK
Server: nginx/1.31.8
Date: Tue, 10 Nov 2026 00:50:34 GMT
Content-Type: application/json; charset=utf-8
Connection: keep-alive
Vary: Accept-Encoding
X-Powered-By: Express
Access-Control-Allow-Origin: https://upnext-eta.vercel.app
Vary: Origin
Access-Control-Allow-Credentials: true
ETag: W/"c19-N1Qv+DcLKYQL1TSuaJ5GzGRtR1o"
X-Upstream: 172.20.0.5:5000
X-Content-Type-Options: nosniff
Content-Encoding: gzip
```

---

## 4. Jawaban Pertanyaan Konseptual

### (a) Kenapa upstream perlu zone? Apa yang terjadi kalau dihapus?
Direktif `zone` berfungsi mengalokasikan area memori bersama (*shared memory zone*) yang dapat diakses oleh seluruh *worker process* Nginx untuk menyinkronkan status upstream, konfigurasi peer, dan status penyeimbangan beban (*load balancing state*). Jika direktif `zone` dihapus, setiap *worker process* akan menyimpan salinan daftar server upstream di memori lokalnya masing-masing secara terisolasi. Akibatnya, penghitung rotasi request tidak tersinkronisasi antar-worker, sehingga distribusi beban trafik tidak berjalan secara merata dan konsisten.

### (b) Kenapa limit_req_status diganti ke 429? Apa bedanya dengan bawaan nginx?
Secara bawaan (*default*), Nginx mengembalikan kode status HTTP 503 (*Service Temporarily Unavailable*) ketika batas frekuensi request terlampaui. Kode 503 mengindikasikan adanya gangguan atau kelebihan beban di sisi server, sedangkan rate limiting merupakan pembatasan akibat kuota permintaan klien yang telah habis. Mengganti `limit_req_status` ke 429 (*Too Many Requests*) mematuhi standar RFC 6585, secara semantik menyatakan kepada klien bahwa laju request melebihi batas yang diizinkan, dan memudahkan penanganan error pada sisi frontend/klien.

### (c) Kenapa backend dan database tidak punya ports, dan nginx menjangkau backend lewat apa?
Blok `ports` ditiadakan pada service backend dan database untuk menerapkan prinsip keamanan *defense in depth* dan *least privilege*, mencegah kontainer terekspos langsung ke host network, serta menjadikan Nginx sebagai satu-satunya gerbang masuk (*single point of entry / ingress*). Nginx tetap dapat menjangkau service backend karena keduanya berada di dalam Docker bridge network internal yang sama (`upnext_network`), di mana Nginx berkomunikasi langsung ke backend melalui DNS resolver internal Docker menggunakan nama service (`http://backend:5000`).

---

## 5. Pemetaan Service dan Konfigurasi

| Service Name | Port Internal | Port Host | Skala Replika | Keterangan |
| :--- | :--- | :--- | :---: | :--- |
| `nginx` | `80` | `80:80` | 1 | Reverse Proxy, Rate Limiter, Load Balancer |
| `backend` | `5000` | *None* | 3 | API Express.js (Round-Robin via Nginx) |
| `db` | `5432` | *None* | 1 | PostgreSQL 16 (Persistensi via Named Volume) |

---

## 6. Perintah Operasional

```bash
# Menjalankan seluruh stack (Nginx, 3 Backend Replicas, DB)
docker compose up --build -d

# Memeriksa status kontainer
docker compose ps

# Memeriksa log Nginx
docker compose logs -f nginx

# Memeriksa log replika backend
docker compose logs -f backend

# Menghentikan stack
docker compose down

# Menghentikan stack sekaligus menghapus volume data database
docker compose down -v
```

---

## 7. Atribusi Alat Bantu & Referensi

* **AI Assistance**: Claude & Google DeepMind Antigravity AI digunakan untuk perancangan arsitektur ingress Nginx, konfigurasi Compose multi-replica, implementasi rate limiting HTTP 429, dan penyusunan dokumentasi teknis.
* **Referensi Resmi**:
  * [Nginx Reverse Proxy Documentation](https://nginx.org/en/docs/http/ngx_http_proxy_module.html)
  * [Nginx Upstream Shared Memory Zone](https://nginx.org/en/docs/http/ngx_http_upstream_module.html#zone)
  * [Nginx Rate Limiting Module](https://nginx.org/en/docs/http/ngx_http_limit_req_module.html)
  * [RFC 6585: Additional HTTP Status Codes (429 Too Many Requests)](https://datatracker.ietf.org/doc/html/rfc6585#section-4)
