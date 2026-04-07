# API-Logfile-Filebeat-Graylog-Dashboard

A complete Spring Boot CRUD API with logging pipeline to Graylog for centralized log management and visualization.

## Architecture Overview

Spring Boot API → application.log → Filebeat → Graylog (Beats Input) → Dashboard

## Features

- **Spring Boot 3.2.5** with Java 17
- **Full CRUD API** for Item resource (id, name, description)
- **Request/Response Logging** with detailed API call tracking
- **File-based Logging** to `application.log`
- **Filebeat Integration** for log shipping
- **Graylog Dashboard** for log visualization
- **Podman-based Deployment** for containerized infrastructure

## Project Structure

├── src/main/java/com/example/api/
│   ├── ApiLogfileFilebeatGraylogApplication.java  # Main application
│   ├── config/
│   │   └── WebConfig.java                         # Web configuration
│   ├── controller/
│   │   └── ItemController.java                    # REST API endpoints
│   ├── interceptor/
│   │   └── LoggingInterceptor.java                # Request logging
│   ├── model/
│   │   └── Item.java                              # Data model
│   └── repository/
│       └── ItemRepository.java                    # In-memory storage
├── src/main/resources/
│   └── application.properties                      # Configuration
├── graylog/
│   ├── docker-compose.yml                         # Graylog stack
│   ├── deploy-graylog.sh                          # Podman deployment
│   └── setup-beats-input.md                       # Graylog setup guide
├── filebeat.yml                                   # Filebeat configuration
├── podman-vs-docker.md                            # Container runtime comparison
└── pom.xml                                       # Maven configuration

## Quick Start

### Prerequisites

- Java 17+
- Maven 3.6+
- Podman (or Docker) for containerized deployment
- Filebeat 7.x+

### 1. Run Spring Boot API

```bash
# Build and run the application
mvn clean spring-boot:run

# Or build JAR and run
mvn clean package
java -jar target/api-logfile-filebeat-graylog-1.0.0.jar
```

The API will be available at `http://localhost:8080`

### 2. Test the API

```bash
# Create an item
curl -X POST http://localhost:8080/items \
  -H "Content-Type: application/json" \
  -d '{"name":"Book","description":"A good book"}'

# Get all items
curl http://localhost:8080/items

# Get specific item
curl http://localhost:8080/items/1

# Update an item
curl -X PUT http://localhost:8080/items/1 \
  -H "Content-Type: application/json" \
  -d '{"name":"Updated Book","description":"An updated description"}'

# Delete an item
curl -X DELETE http://localhost:8080/items/1
```

### 3. Deploy Graylog with Podman

```bash
cd graylog
chmod +x deploy-graylog.sh
./deploy-graylog.sh
```

Access Graylog at `http://localhost:9000` (admin/admin)

### 4. Configure Filebeat

1. Install Filebeat
2. Copy `filebeat.yml` to Filebeat configuration directory
3. Update log path if necessary
4. Start Filebeat:

```bash
sudo filebeat -e -c filebeat.yml
```

### 5. Set up Graylog Beats Input

Follow the setup guide in `graylog/setup-beats-input.md`

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| POST | `/items` | Create new item |
| GET | `/items` | Get all items |
| GET | `/items/{id}` | Get item by ID |
| PUT | `/items/{id}` | Update item by ID |
| DELETE | `/items/{id}` | Delete item by ID |

## Logging Configuration

The application logs to `application.log` with the following format:
- **Console**: `yyyy-MM-dd HH:mm:ss - message`
- **File**: `yyyy-MM-dd HH:mm:ss [thread] LEVEL logger - message`

### Log Examples

```
2026-03-26 14:30:15 [http-nio-8080-exec-1] INFO  c.e.api.controller.ItemController - Created item: Book with id=1
2026-03-26 14:30:16 [http-nio-8080-exec-2] INFO  c.e.api.interceptor.LoggingInterceptor - API Request - Method: GET, Path: /items, Query: none, Client IP: 127.0.0.1
2026-03-26 14:30:16 [http-nio-8080-exec-2] INFO  c.e.api.interceptor.LoggingInterceptor - API Response - Method: GET, Path: /items, Status: 200, Duration: 5ms
```

## Filebeat Configuration

Key settings in `filebeat.yml`:
- **Input type**: Log file monitoring
- **Path**: `/app/application.log`
- **Output**: Logstash to `graylog:5044`
- **Multiline**: Handles stack traces and multi-line logs
- **Fields**: Adds `logtype: springboot-api` and `service: item-crud-api`

## Graylog Dashboard

After setting up the Beats input, create a dashboard with widgets for:
- API request count over time
- Response time distribution  
- HTTP status code breakdown
- Most accessed endpoints
- Error rate monitoring

## Development

### Running Tests

```bash
mvn test
```

### Building

```bash
mvn clean package
```

### Docker/Podman Build

```bash
# Build container image
podman build -t springboot-api-logging .

# Run container
podman run -p 8080:8080 -v $(pwd)/application.log:/app/application.log springboot-api-logging
```

## Container Runtime: Podman vs Docker

This project uses Podman for enhanced security and daemonless operation. See `podman-vs-docker.md` for detailed comparison.

## Troubleshooting

### Common Issues

1. **Filebeat can't connect to Graylog**
   - Check Graylog is running and Beats input is started
   - Verify port 5044 is accessible
   - Check Filebeat configuration

2. **No logs appearing in Graylog**
   - Verify Spring Boot application is writing to `application.log`
   - Check Filebeat is running and has correct log path
   - Ensure Graylog Beats input is configured and started

3. **Podman deployment fails**
   - Check if ports 9000, 5044, 12201 are available
   - Verify Podman is installed and running
   - Check system resources (need at least 2GB RAM)

### Log Locations

- **Spring Boot logs**: `./application.log`
- **Filebeat logs**: `/var/log/filebeat/`
- **Graylog logs**: `podman pod logs graylog-pod`

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License.