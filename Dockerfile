# Base image: Node.js 20 Alpine for lightweight and secure footprint
FROM node:20-alpine

# Install OpenSSL required by Prisma engine binaries on Alpine Linux
RUN apk add --no-cache openssl

# Set working directory inside the container
WORKDIR /app

# Copy dependency definitions and Prisma schema
COPY package*.json ./
COPY prisma ./prisma

# Install dependencies
RUN npm install

# Generate Prisma Client bindings inside the Alpine container
RUN npx prisma generate

# Copy the rest of the application source code
COPY . .

# Ensure entrypoint script has execution permissions
RUN chmod +x ./docker-entrypoint.sh

# Expose default application port
EXPOSE 5000

# Set entrypoint to run database migration/push before starting the server
ENTRYPOINT ["./docker-entrypoint.sh"]

# Default command to start the Express application
CMD ["node", "api/app.js"]
