# Contributing

This repository is an assignment artifact for the Backend Intermediate study club (KSM Veterantech UPNVJ 2026). Contributions are welcome, but keep the teaching intent intact: the Nginx single-ingress gateway, three backend replicas, rate limiting, and security headers are the subject of the task, not incidental details.

## Ground rules

- Preserve the single-ingress design: only Nginx publishes a host port. Backend and database stay on the internal Docker network.
- Keep `deploy.replicas: 3` and the `X-Upstream` response header; they are how load balancing is demonstrated.
- Keep `limit_req_status` at `429`. Changing it back to the default `503` defeats the assignment.
- If you change Compose or Nginx configuration, update the overview, the service map, and the cURL evidence in `README.md` in the same change.

## Local verification

```sh
cp .env.example .env
docker compose up --build -d
docker compose ps
```

Expected: one Nginx container publishing `0.0.0.0:80->80/tcp`, three backend replicas and one PostgreSQL container with no host ports.

```sh
# Load balancing: X-Upstream should rotate across three replicas
for i in {1..6}; do curl -s -D - http://localhost/api/organizations -o /dev/null | grep -E "HTTP/|X-Upstream"; sleep 0.2; done

# Rate limiting: some requests should return 429
for i in {1..8}; do curl -s -D - http://localhost/api/organizations -o /dev/null | grep "HTTP/"; done

# Security header and gzip
curl -I -H "Accept-Encoding: gzip" http://localhost/api/organizations

docker compose down
```

## Commits

Use one-line conventional commit messages in English, for example `docs: clarify nginx gateway setup` or `fix: correct rate limit status`. Include the command output when you change behavior that the README documents as evidence.

## License

By contributing you agree that your contribution is licensed under the MIT License, the same as the rest of this repository.
