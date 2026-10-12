# AGENT DIRECTIVE & ARCHITECTURE MANUAL: UPNEXT BACKEND

> **Audience**: AI Agents, Autonomous Coding Agents, and Human Engineers.
> **Project**: UpNext Backend (Event & Organization Management API)
> **Context**: Tugas 1 - Study Club Backend Intermediate, KSM Veterantech UPNVJ 2026

---

## 1. System Overview & Context

UpNext Backend is a RESTful API service built for the **UpNext** platform. It provides backend services for university campus student organizations (BEM, HIMA, SENAT, UKM) to register, authenticate, and publish campus events, manage event banners, upload documentation/guidelines, and maintain organization profiles.

### Technical Stack
* **Language/Runtime**: Node.js (v20+ LTS) with ES Modules (`"type": "module"`).
* **API Framework**: Express.js (v5.1.0).
* **Database**: PostgreSQL (v16).
* **ORM**: Prisma Client & Prisma CLI (`@prisma/client` ^6.7.0, `prisma` ^6.7.0).
* **Authentication**: JWT (`jsonwebtoken` v9.0.2) + `bcryptjs` for password hashing.
* **Validation**: Joi v17.13.3 (`validateBody` middleware).
* **Media Handling**: Cloudinary API with `multer` in-memory storage and stream upload/deletion.
* **Timezone Standard**: Western Indonesia Time (`Asia/Jakarta` / WIB) enforced via `dayjs`.
* **Containerization**: Dockerfile (multi-stage/optimized Alpine) + Docker Compose (v2+).

---

## 2. Directory & Component Architecture

```
/home/pinefeast/Projects/upnext-backend/
├── api/
│   └── app.js                 # Express server configuration, CORS, route binding, port listener
├── controllers/
│   ├── authController.js      # Signup (with proof upload), signin, JWT issuance
│   ├── eventController.js     # Event CRUD, file uploads, keyword search, user events
│   └── organizationController.js # Organization profile management, soft-deletion
├── middlewares/
│   ├── authMiddleware.js      # JWT token verification & superuser header bypass
│   ├── authValidation.js      # Joi schemas for request body validation
│   └── uploadMiddleware.js    # Multer memory storage configuration for file uploads
├── prisma/
│   ├── schema.prisma          # PostgreSQL models (Organization, Event, Banner, Document, EventPhoto)
│   └── seed.js                # Database seeder for demo organizations and sample events
├── routes/
│   ├── authRoutes.js          # /auth/signup, /auth/signin
│   ├── eventRoutes.js         # /events CRUD, /events/search, /events/my
│   └── organizationRoutes.js  # /organizations profile and directory endpoints
├── utils/
│   ├── cloudinary-*.js        # Upload, delete, and URL parsing utilities for Cloudinary
│   ├── delEventGeneral.js     # Soft-delete event & purge Cloudinary assets
│   ├── responseFormatter.js   # Standard JSON response envelopes (successResponse, errorResponse)
│   └── time.js                # WIB (Asia/Jakarta) timezone conversions
├── Dockerfile                 # (To be implemented) Production container build definition
├── docker-compose.yml         # (To be implemented) Multi-container orchestration (App + Postgres)
├── .dockerignore              # (To be implemented) Excludes local artifacts from build context
├── .env.example               # (To be implemented) Clean environment variable template
├── CHANGELOG.md               # Versioning and release log
├── README.md                  # Comprehensive task submission documentation
└── TASK_INSTRUCTIONS.md       # Rubric & evaluation guideline for Tugas 1
```

---

## 3. Mandatory Dockerization Requirements

Any agent executing changes on this workspace must strictly comply with the following containerization rules:

### A. Dockerfile Standards
1. **Base Image**: Use `node:20-alpine` for a lightweight and secure footprint.
2. **Alpine Dependency**: Alpine requires `openssl` for Prisma query engine binaries. The Dockerfile MUST execute:
   ```dockerfile
   RUN apk add --no-cache openssl
   ```
3. **Working Directory**: `/app`.
4. **Caching Layering**: Copy `package*.json` and run `npm install` before copying source code.
5. **Prisma Generation**: Copy `prisma/` directory and execute `npx prisma generate` during the build phase so Prisma client bindings are generated inside the container environment.
6. **Exposed Port**: Default application port is `5000`.

### B. Docker Compose Standards (`docker-compose.yml`)
1. **Service `db`**:
   * Image: `postgres:16-alpine`.
   * Environment: `POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_DB`.
   * Healthcheck: Must implement `pg_isready -U <user> -d <db>` with interval, timeout, and retries.
   * Named Volume: Must mount `postgres_data:/var/lib/postgresql/data` for data persistence.
   * Port: Expose `5432:5432` to host for inspection.
2. **Service `backend`**:
   * Build context: `.` pointing to `Dockerfile`.
   * Port mapping: `5000:5000`.
   * Dependencies: `depends_on` pointing to `db` with condition `service_healthy`.
   * Connection String: `DATABASE_URL` must use host `db:5432` (e.g., `postgresql://postgres:postgres_password@db:5432/upnext_db?schema=public`).
   * Database Synchronization: Must run `npx prisma db push` before `node api/app.js` to ensure PostgreSQL tables exist when starting up on a fresh database volume.
3. **Network**: Isolated bridge network (e.g., `upnext_network`).

---

## 4. Operational Guardrails for Agents

1. **Never Commit Secrets**:
   * Never commit `.env` containing real Cloudinary credentials or sensitive keys.
   * All example values in `.env.example` must be placeholders.
2. **Maintain Codebase Integrity**:
   * Do not alter the core business logic of controllers or existing API routes unless resolving a critical container compatibility bug.
   * Preserve existing comments and docstrings.
3. **Preserve Line Endings (LF)**:
   * All scripts and text files must use Unix line terminators (`\n` / LF).
4. **Prisma Schema Stability**:
   * Any change to `prisma/schema.prisma` requires running `npx prisma generate` and synchronizing with the database via `npx prisma db push`.
