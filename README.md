# UpNext Backend — Containerized Event & Organization Management API

**Tugas 1 — Study Club Backend Intermediate**  
Kabinet Genesis | KSM Veterantech UPNVJ 2026  
Repository: [mhdztr/t1-upnext](https://github.com/mhdztr/t1-upnext)

---

## 1. Overview

**UpNext Backend** is a RESTful API service built with Node.js and PostgreSQL designed for managing and publishing campus student organization events (BEM, HIMA, SENAT, UKM). The platform handles organization authentication, profile management, event publishing, media and document uploads, and campus event exploration.

This repository implements full multi-container orchestration using **Docker** and **Docker Compose**, isolating the Express API and PostgreSQL database inside a dedicated bridge network while guaranteeing **data persistence** across container lifecycles via Docker Named Volumes.

---

## 2. Architecture & Technology Stack

| Component | Technology | Description |
| :--- | :--- | :--- |
| **Runtime** | Node.js 20 LTS (Alpine) | Minimalist and lightweight containerized runtime |
| **Framework** | Express.js 5.1.0 | Core HTTP routing and controller logic |
| **Database** | PostgreSQL 16 (Alpine) | Relational database engine |
| **ORM** | Prisma 6.7.0 | Schema modeling, query building, and runtime migrations |
| **Authentication** | JWT & Bcrypt.js | Stateless token-based auth and secure password hashing |
| **Media Storage** | Multer & Cloudinary SDK | Memory storage buffer and streaming media upload |
| **Timezone** | Day.js | Standardized to Western Indonesia Time (`Asia/Jakarta` / WIB) |
| **Orchestration** | Docker & Docker Compose | Multi-service networking, healthchecks, and named volumes |

### Service & Port Mapping

| Service Name | Container Name | Internal Port | Host Port | Network |
| :--- | :--- | :--- | :--- | :--- |
| `backend` | `upnext_backend` | `5000` | `5000:5000` | `upnext_network` (bridge) |
| `db` | `upnext_db` | `5432` | `5432:5432` | `upnext_network` (bridge) |

---

## 3. Prerequisites

Ensure your host machine has the following tools installed:

* **Docker Engine** (v24.0.0 or higher)
* **Docker Compose** (v2.20.0 or higher / Compose v2)
* **Git**
* **cURL** (or any HTTP client like Postman / Bruno)

Verify your local installation:

```bash
docker --version
docker compose version
```

---

## 4. Environment Configuration

The application loads environment variables during startup. A `.env.example` template is provided with pre-configured defaults for local Docker environments.

1. Create a `.env` file from the example template:
   ```bash
   cp .env.example .env
   ```

2. Default Docker Compose configuration:
   ```env
   PORT=5000
   POSTGRES_USER=postgres
   POSTGRES_PASSWORD=postgres_password
   POSTGRES_DB=upnext_db
   DATABASE_URL="postgresql://postgres:postgres_password@db:5432/upnext_db?schema=public"
   JWT_SECRET="upnext_jwt_secret_key_demo"
   SUPERUSER_SECRET="upnext_superuser_key_demo"
   FRONTEND_ORIGIN="http://localhost:5173"
   ```

> [!NOTE]
> The `docker-compose.yml` file includes fallback defaults for all required database parameters, allowing the stack to run immediately out-of-the-box even without a `.env` file.

---

## 5. Build & Deployment

### Step 1: Build Image and Start Services

Build the backend container image from the `Dockerfile` and start all services in detached mode:

```bash
docker compose up --build -d
```

### Step 2: Verify Container Health

Confirm both services are running and healthy:

```bash
docker compose ps
```

Expected output:
* `upnext_db`: Status `Up (healthy)` on port `0.0.0.0:5432->5432/tcp`
* `upnext_backend`: Status `Up` on port `0.0.0.0:5000->5000/tcp`

### Step 3: Inspect Application Logs

Verify database synchronization (`npx prisma db push`) and server initialization:

```bash
docker compose logs -f backend
```

---

## 6. API Verification & Testing

### Endpoint Reference Matrix

| Test Case | Method | Endpoint | Payload Type | Description |
| :--- | :---: | :--- | :--- | :--- |
| **Read Data** | `GET` | `/organizations` | None | Fetch all registered student organizations |
| **Read Data** | `GET` | `/events` | None | Fetch all published campus events |
| **Write Data** | `POST` | `/auth/signup` | `multipart/form-data` | Register a new organization with membership proof |
| **Authentication** | `POST` | `/auth/signin` | `application/json` | Authenticate organization and receive JWT token |

### 1. Read Test (Querying Existing Records)

Retrieve all registered organizations:
```bash
curl -s http://localhost:5000/organizations
```

Retrieve all campus events:
```bash
curl -s http://localhost:5000/events
```

### 2. Write Test (Registering a New Record)

Register a new organization with a valid image attachment:

```bash
# Generate a 1-pixel sample proof image
echo "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==" | base64 -d > /tmp/sample-proof.png

# Send registration request
curl -s -X POST http://localhost:5000/auth/signup \
  -F "name=HIMA Informatika UPNVJ" \
  -F "email=hima.informatika@upnvj.ac.id" \
  -F "password=password123" \
  -F "membershipProof=@/tmp/sample-proof.png"
```

Verify that the new record is committed to PostgreSQL:
```bash
curl -s http://localhost:5000/organizations | grep "HIMA Informatika UPNVJ"
```

---

## 7. Data Persistence Verification (Named Volume)

This test proves that database state is persisted inside the Docker Named Volume (`postgres_data`) and survives container destruction and recreation.

1. **Verify data has been written** using the Write Test above.
2. **Stop and remove all containers** without removing volumes:
   ```bash
   docker compose down
   ```
   > [!IMPORTANT]
   > Do **NOT** pass the `-v` or `--volumes` flag during this step to ensure the named volume is preserved on the host.

3. **Verify the named volume exists on host**:
   ```bash
   docker volume ls | grep postgres_data
   ```

4. **Recreate and start the containers**:
   ```bash
   docker compose up -d
   ```

5. **Query the API again**:
   ```bash
   curl -s http://localhost:5000/organizations | grep "HIMA Informatika UPNVJ"
   ```

**Result**: The record created in Step 1 remains intact, confirming that the named volume is correctly configured and database persistence is operational.

---

## 8. Container Management Reference

| Action | Command | Purpose |
| :--- | :--- | :--- |
| **Start Stack** | `docker compose up -d` | Start services in background |
| **Build & Start** | `docker compose up --build -d` | Rebuild image from Dockerfile and start |
| **Stop Services** | `docker compose stop` | Pause containers without removing them |
| **Tear Down** | `docker compose down` | Remove containers and network, **preserves data** |
| **Reset Stack** | `docker compose down -v` | Remove containers, network, and **wipe all data** |
| **Tail Logs** | `docker compose logs -f` | Stream live combined service logs |
| **Database CLI** | `docker compose exec db psql -U postgres -d upnext_db` | Open interactive PostgreSQL shell |

---

## 9. Project Directory Structure

```text
upnext-backend/
├── api/
│   └── app.js                  # Express.js entry point, middleware, and route mounting
├── controllers/                # Business logic handlers (auth, event, organization)
├── middlewares/                # Auth verification, Joi schema validation, Multer storage
├── prisma/
│   ├── schema.prisma           # Prisma schema definition and PostgreSQL mapping
│   └── seed.js                 # Demo data seeder script
├── routes/                     # Express RESTful route definitions
├── utils/                      # Utilities (Cloudinary upload, response formatter, timezone)
├── .dockerignore               # Build context exclusions
├── .env.example                # Environment variables template
├── Dockerfile                  # Production container definition (Node.js 20 Alpine)
├── docker-compose.yml          # Multi-container orchestration (Backend + PostgreSQL 16)
├── docker-entrypoint.sh        # Startup script for automated Prisma push and app boot
└── README.md                   # Technical project documentation
```

---

## 10. Attribution & References

In compliance with academic integrity and assignment guidelines:

* **AI Assistance**:
  * Claude & Google DeepMind Antigravity AI were utilized for containerization architecture design (`Dockerfile`, `docker-compose.yml`), entrypoint lifecycle scripting, testing procedure design, and documentation authoring.
* **Official Documentation**:
  * [Docker Documentation](https://docs.docker.com/) — Containerization and Compose specifications.
  * [Prisma Deployment Guide](https://www.prisma.io/docs/guides/deployment/deployment-guides/deploying-to-docker) — Alpine Linux binary engine dependencies.
  * [PostgreSQL Docker Image](https://hub.docker.com/_/postgres) — Environment variables and healthcheck patterns.
