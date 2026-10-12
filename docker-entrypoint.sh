#!/bin/sh
set -e

echo "==> [UpNext Backend] Container initializing..."
echo "==> [UpNext Backend] Synchronizing database schema with Prisma (npx prisma db push)..."
npx prisma db push --skip-generate

echo "==> [UpNext Backend] Database schema synchronization complete!"
echo "==> [UpNext Backend] Starting application server..."
exec "$@"
