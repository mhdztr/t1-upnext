# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### Planned
- Final verification of local Docker Compose stack on developer machine.
- Video recording of deployment and persistence demonstration.
- Final PDF compilation for assignment submission.

---

## [1.1.0] - 2026-10-12

### Added
- **Dockerization**:
  - `Dockerfile` using lightweight `node:20-alpine` base image with `openssl` binary support for Prisma engine.
  - Multi-container orchestration via `docker-compose.yml` defining `backend` (Express.js) and `db` (PostgreSQL 16) services.
  - Named Docker volume (`postgres_data`) mapped to `/var/lib/postgresql/data` ensuring data persistence across container recreations.
  - Automatic database schema synchronization via `npx prisma db push` on container initialization.
  - Container healthchecks using `pg_isready` to guarantee ordered startup.
- **Environment & Git Hygiene**:
  - `.dockerignore` to prevent uploading `node_modules`, local `.env`, and git history to the Docker build context.
  - `.env.example` template with dummy credentials and Docker internal service hostnames.
- **Documentation**:
  - `README.md` containing complete setup, build, running, endpoint testing, and persistence verification instructions.
  - `AGENTS.md` containing architecture, guidelines, and execution standards for autonomous agents.
  - `TASK_INSTRUCTIONS.md` covering the rubrics and video recording script for Tugas 1 Study Club Backend Intermediate 2026.
  - `CHANGELOG.md` tracking architectural and infrastructure updates.

### Changed
- Configured local database connection string in Docker environment to resolve to the internal Docker Compose bridge network (`db:5432`).

---

## [1.0.0] - 2025-06-06

### Added
- Express.js (v5) REST API backend implementation for UpNext platform.
- Prisma ORM schema models: `Organization`, `Event`, `Banner`, `Document`, `EventPhoto`.
- Authentication module with JWT issuance and Bcrypt password hashing.
- File and media handling via Multer memory storage and Cloudinary stream uploads.
- Soft-delete mechanism with asset garbage collection (`delEventGeneral.js`).
- Joi request payload validation middleware.
- Western Indonesia Time (`Asia/Jakarta` / WIB) timezone standardization with Day.js.
- Seed script (`prisma/seed.js`) providing demo campus organizations and events.
