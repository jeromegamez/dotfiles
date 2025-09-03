# Docker Guidelines

## Core Principles
- Use official base images when possible
- Use specific tags, not `latest`
- Run as non-root user for security
- Minimize layers and attack surface

## Conventions

### Dockerfile Best Practices

#### Structure
- Multi-stage builds for production images
- Order instructions by change frequency (least to most)

#### Security
- Use `.dockerignore` to exclude unnecessary files
- Scan images for vulnerabilities
- Minimize attack surface with distroless/alpine images

#### Optimization
- Combine RUN commands to reduce layers
- Use build cache effectively
- Copy only what's needed
- Clean up package managers in same RUN command:
  ```dockerfile
  RUN apt-get update && apt-get install -y \
      package1 \
      package2 \
   && rm -rf /var/lib/apt/lists/*
  ```

#### Example Structure
```dockerfile
# Use specific version
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Install dependencies first (better caching)
COPY package*.json ./
RUN npm ci --only=production

# Copy source code
COPY . .

# Create non-root user
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nextjs -u 1001

# Change ownership and switch user
RUN chown -R nextjs:nodejs /app
USER nextjs

# Expose port
EXPOSE 3000

# Start application
CMD ["npm", "start"]
```

### Docker Compose

#### Best Practices
- Use version 3.8+ for compose files
- Define networks explicitly
- Use environment files for configuration
- Set resource limits
- Use health checks
- Pin service versions

#### Structure
```yaml
version: '3.8'

services:
  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
    env_file:
      - .env
    depends_on:
      db:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
    deploy:
      resources:
        limits:
          memory: 512M
        reservations:
          memory: 256M

  db:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: user
      POSTGRES_PASSWORD_FILE: /run/secrets/db_password
    volumes:
      - postgres_data:/var/lib/postgresql/data
    secrets:
      - db_password
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U user -d myapp"]
      interval: 10s
      timeout: 5s
      retries: 5

volumes:
  postgres_data:

secrets:
  db_password:
    file: ./secrets/db_password.txt

networks:
  default:
    name: myapp_network
```

## Recommended MCPs
- **Serena**: Perfect for analyzing multi-language containerized applications, understanding code structure across different services, and navigating complex Docker projects
- **Sequential Thinking**: Helpful for multi-stage build optimization and complex container orchestration

## Best Practices

### Development Workflow

#### Local Development
- Use bind mounts for live code reloading
- Separate development and production compose files
- Use override files: `docker-compose.override.yml`

#### Commands
```bash
# Development
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up

# Production
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d

# Clean up
docker system prune -af
docker volume prune -f
```

### Production Considerations

#### Image Management
- Tag images with semantic versions
- Use private registries for production
- Implement image scanning in CI/CD
- Regular security updates

#### Deployment
- Use orchestration (Kubernetes, Docker Swarm)
- Implement proper logging and monitoring
- Set up backup strategies for volumes
- Use secrets management
- Configure restart policies

#### Resource Management
- Set memory and CPU limits
- Monitor resource usage
- Use appropriate restart policies
- Implement graceful shutdowns
