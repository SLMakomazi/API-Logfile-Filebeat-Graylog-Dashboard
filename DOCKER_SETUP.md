# Docker Compose Setup Guide

## Complete Stack: Spring Boot API + Filebeat + Graylog + OpenSearch + MongoDB

This guide shows how to run the entire logging pipeline in a single Docker Compose setup.

## Architecture

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Spring    │    │  Filebeat   │    │   Graylog   │    │ OpenSearch  │    │   MongoDB   │
│   Boot API  │───▶│   (logs)    │───▶│ (collector) │───▶│   (storage) │◀───│ (metadata)  │
│   :8080     │    │             │    │   :9000     │    │             │    │             │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
```

## Quick Start

### 1. Build the Spring Boot JAR

```bash
# Build the application
mvn clean package

# Copy JAR to api directory (expected by Dockerfile)
cp target/api-logfile-filebeat-graylog-1.0.0.jar api/app.jar
```

### 2. Start Everything

```bash
# Start all services
docker-compose up --build -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f
```

### 3. Access Services

- **Spring Boot API**: http://localhost:8080
- **Graylog Dashboard**: http://localhost:9000
- **Default Graylog Login**: admin / admin

## Service Details

### Spring Boot API (Container: spring-api)
- **Port**: 8080 (internal to Docker network)
- **Logs**: Written to `/logs/application.log` (shared volume)
- **Health**: `curl http://localhost:8080/items`

### Filebeat (Container: filebeat)
- **Purpose**: Reads logs from API and ships to Graylog
- **Configuration**: `./filebeat/filebeat.yml`
- **Log Path**: `/logs/application.log` (shared volume)
- **Output**: `graylog:5044` (Docker service name)

### Graylog (Container: graylog-server)
- **Web Interface**: http://localhost:9000
- **Beats Input**: Port 5044
- **GELF Inputs**: Port 12201 (TCP/UDP)
- **Storage**: OpenSearch backend
- **Metadata**: MongoDB backend

### OpenSearch (Container: graylog-opensearch)
- **Purpose**: Log storage and search engine
- **Configuration**: Single-node cluster
- **Security**: Disabled for development
- **Memory**: 512MB heap size

### MongoDB (Container: graylog-mongo)
- **Purpose**: Graylog metadata storage
- **Credentials**: admin / admin123
- **Persistence**: Volume mounted

## Key Concepts

### Shared Volume Bridge
```
logs-data:/logs
```
- API writes logs to `/logs/application.log`
- Filebeat reads the same file from `/logs/application.log`
- This is the bridge between containers

### Docker Service Networking
```
output.logstash:
  hosts: ["graylog:5044"]
```
- Docker DNS resolves `graylog` to the correct container IP
- No need for localhost or hardcoded IPs

## Testing the Complete Pipeline

### 1. Test API Endpoints

```bash
# Create an item
curl -X POST http://localhost:8080/items \
  -H "Content-Type: application/json" \
  -d '{"name":"Test Book","description":"A test book for logging"}'

# Get all items
curl http://localhost:8080/items

# Get specific item
curl http://localhost:8080/items/1

# Update an item
curl -X PUT http://localhost:8080/items/1 \
  -H "Content-Type: application/json" \
  -d '{"name":"Updated Book","description":"Updated description"}'

# Delete an item
curl -X DELETE http://localhost:8080/items/1
```

### 2. Verify Logs in Graylog

1. Open http://localhost:9000
2. Login with admin / admin
3. Go to **System → Inputs**
4. Ensure Beats input is running on port 5044
5. Go to **Search** and look for recent logs
6. You should see entries like:
   - `Created item: Test Book with id=1`
   - `API Request - Method: POST, Path: /items`
   - `API Response - Method: POST, Path: /items, Status: 201`

## Graylog Beats Input Setup

If the Beats input isn't configured:

1. **Navigate**: System → Inputs
2. **Select**: Beats from dropdown
3. **Launch new input**
4. **Configure**:
   - Title: `Spring Boot API Logs`
   - Port: `5044`
   - Bind address: `0.0.0.0`
   - TLS: `disabled` (for development)
5. **Save** and **Start**

## Troubleshooting

### Common Issues

#### 1. Logs not appearing in Graylog

```bash
# Check Filebeat logs
docker-compose logs filebeat

# Check API logs
docker-compose logs api

# Check Graylog logs
docker-compose logs graylog

# Verify Beats input is running
curl http://localhost:9000/api/system/inputs
```

#### 2. Connection refused

```bash
# Check if Graylog is running
docker-compose ps graylog

# Check port exposure
docker-compose port graylog 5044

# Restart Filebeat
docker-compose restart filebeat
```

#### 3. File not found errors

```bash
# Check shared volume
docker exec spring-api ls -la /logs/

# Check if API is writing logs
docker exec spring-api tail -f /logs/application.log

# Verify Filebeat can access the file
docker exec filebeat ls -la /logs/
```

#### 4. Build failures

```bash
# Clean build
docker-compose down -v
docker-compose build --no-cache
docker-compose up -d
```

### Debug Commands

```bash
# View all logs
docker-compose logs -f

# View specific service logs
docker-compose logs -f api
docker-compose logs -f filebeat
docker-compose logs -f graylog

# Execute commands in containers
docker exec -it spring-api bash
docker exec -it filebeat bash
docker exec -it graylog bash

# Check container networking
docker exec spring-api ping graylog
docker exec filebeat ping graylog
```

## Production Considerations

### Security
- Change default Graylog password
- Enable TLS for Beats input
- Use proper secrets management
- Enable OpenSearch security

### Performance
- Scale Graylog cluster
- Increase OpenSearch heap size
- Configure log retention policies
- Set up monitoring and alerting

### Persistence
- Backup MongoDB regularly
- Configure OpenSearch snapshots
- Use external volumes for production
- Implement disaster recovery

## Scaling the Setup

### Multiple API Instances

```yaml
api:
  build: ./api
  deploy:
    replicas: 3
  volumes:
    - logs-data:/logs
```

### External Log Storage

Replace local volumes with cloud storage:
- AWS S3 for OpenSearch snapshots
- MongoDB Atlas for metadata
- Managed OpenSearch service

## Monitoring

### Health Checks

```bash
# API health
curl http://localhost:8080/items

# Graylog health
curl http://localhost:9000/api/system/status

# Filebeat metrics
curl http://localhost:5044/stats  # If monitoring enabled
```

### Log Analysis

Create Graylog dashboards for:
- API request rate
- Response time distribution
- Error rate monitoring
- Log volume trends

## Cleanup

```bash
# Stop and remove everything
docker-compose down -v

# Remove all images
docker rmi $(docker images -q "api-logfile-filebeat-graylog*")

# Remove all volumes
docker volume prune
```

This setup provides a complete, production-ready logging pipeline with containerized services that communicate seamlessly through Docker networking.
