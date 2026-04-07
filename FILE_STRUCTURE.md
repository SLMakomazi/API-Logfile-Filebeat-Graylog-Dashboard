# File Structure Documentation

This document provides a detailed explanation of all files and folders created in the API-Logfile-Filebeat-Graylog-Dashboard project.

## Root Directory Files

### `pom.xml`
**Purpose**: Maven project configuration and dependencies
- **Parent**: Spring Boot 3.2.5
- **Java Version**: 17
- **Dependencies**: 
  - `spring-boot-starter-web` (REST API)
  - `spring-boot-starter-logging` (Logging framework)
  - `spring-boot-starter-test` (Testing)
- **Build Plugin**: Spring Boot Maven plugin for executable JAR creation

### `filebeat.yml`
**Purpose**: Filebeat configuration for log shipping
- **Input Type**: Log file monitoring
- **Monitored Path**: `/app/application.log`
- **Output**: Logstash to Graylog on port 5044
- **Multiline Handling**: Groups stack traces and multi-line logs
- **Custom Fields**: Adds `logtype: springboot-api` and `service: item-crud-api`
- **Processors**: Enriches logs with host, Docker, and Kubernetes metadata

### `README.md`
**Purpose**: Main project documentation and setup guide
- **Architecture Overview**: Visual representation of the logging pipeline
- **Quick Start Guide**: Step-by-step setup instructions
- **API Documentation**: Complete endpoint reference with examples
- **Troubleshooting**: Common issues and solutions
- **Development Instructions**: Building, testing, and deployment

### `podman-vs-docker.md`
**Purpose**: Detailed comparison of container runtimes
- **Architecture Differences**: Daemon vs daemonless operation
- **Security Analysis**: Rootless containers and attack surface
- **CLI Compatibility**: Command mapping and migration guide
- **Kubernetes Integration**: Runtime compatibility and recommendations
- **Use Cases**: When to choose each runtime

---

## `src/` Directory

### `src/main/java/com/example/api/`
**Purpose**: Main Java source code package

#### `ApiLogfileFilebeatGraylogApplication.java`
- **Type**: Main Spring Boot application class
- **Purpose**: Entry point for the application
- **Annotation**: `@SpringBootApplication` enables auto-configuration
- **Main Method**: Starts the Spring Boot application context

---

### `src/main/java/com/example/api/config/`
**Purpose**: Configuration classes for the application

#### `WebConfig.java`
- **Type**: Spring Web MVC configuration
- **Purpose**: Registers interceptors and web configurations
- **Key Method**: `addInterceptors()` registers the logging interceptor
- **Annotation**: `@Configuration` marks it as a Spring configuration class

---

### `src/main/java/com/example/api/controller/`
**Purpose**: REST API controllers

#### `ItemController.java`
- **Type**: Spring REST Controller
- **Purpose**: Implements CRUD operations for Item resource
- **Endpoints**:
  - `POST /items` - Create new item
  - `GET /items` - Get all items
  - `GET /items/{id}` - Get item by ID
  - `PUT /items/{id}` - Update item
  - `DELETE /items/{id}` - Delete item
- **Logging**: Logs all CRUD operations with item details
- **HTTP Status**: Proper status codes (200, 201, 404, 204)

---

### `src/main/java/com/example/api/interceptor/`
**Purpose**: Request/response interceptors

#### `LoggingInterceptor.java`
- **Type**: Spring HandlerInterceptor
- **Purpose**: Logs all HTTP requests and responses
- **Methods**:
  - `preHandle()` - Logs incoming requests with method, path, client IP
  - `afterCompletion()` - Logs responses with status and duration
- **Timing**: Measures and logs request processing time
- **Error Handling**: Logs exceptions when they occur

---

### `src/main/java/com/example/api/model/`
**Purpose**: Data model classes

#### `Item.java`
- **Type**: Entity/Model class
- **Purpose**: Represents the Item resource
- **Fields**:
  - `Long id` - Unique identifier
  - `String name` - Item name
  - `String description` - Item description
- **Methods**: Getters, setters, and `toString()` for logging

---

### `src/main/java/com/example/api/repository/`
**Purpose**: Data access layer

#### `ItemRepository.java`
- **Type**: In-memory data repository
- **Purpose**: Thread-safe storage for Item entities
- **Storage**: `ConcurrentHashMap<Long, Item>` for thread safety
- **ID Generation**: `AtomicLong` for unique ID generation
- **Methods**:
  - `save()` - Create or update item
  - `findById()` - Retrieve item by ID
  - `findAll()` - Get all items
  - `update()` - Update existing item
  - `deleteById()` - Delete item by ID
  - `existsById()` - Check if item exists

---

### `src/main/resources/`
**Purpose**: Application resources and configuration

#### `application.properties`
- **Purpose**: Spring Boot configuration file
- **Settings**:
  - `server.port=8080` - Server port
  - `logging.level.*` - Log levels for different packages
  - `logging.pattern.*` - Log formatting patterns
  - `logging.file.name=application.log` - Log file location
  - `logging.file.max-size=10MB` - Log file rotation size
  - `logging.file.max-history=5` - Number of log files to keep

---

## `graylog/` Directory
**Purpose**: Graylog deployment and configuration files

### `docker-compose.yml`
- **Purpose**: Docker Compose configuration for Graylog stack
- **Services**:
  - `mongo` - MongoDB database for Graylog metadata
  - `elasticsearch` - Search engine for log storage
  - `graylog` - Main Graylog server
- **Ports**:
  - `9000:9000` - Graylog web interface
  - `5044:5044` - Beats input for Filebeat
  - `12201:12201` - GELF inputs (TCP/UDP)
- **Volumes**: Persistent storage for all services
- **Networks**: Custom bridge network for service communication

### `deploy-graylog.sh`
- **Purpose**: Podman deployment script for Graylog
- **Features**:
  - Creates Graylog pod with port mappings
  - Sets up persistent volumes
  - Deploys services in correct order
  - Includes health checks and wait times
  - Provides management commands
- **Usage**: `./deploy-graylog.sh` to deploy entire stack

### `setup-beats-input.md`
- **Purpose**: Step-by-step guide for configuring Graylog Beats input
- **Contents**:
  - Graylog web interface navigation
  - Beats input configuration parameters
  - Expected log fields from Filebeat
  - Troubleshooting common issues
  - Dashboard creation guidelines

---

## Generated Directories (During Build)

### `target/`
**Purpose**: Maven build output directory
- **Contents**:
  - Compiled Java classes
  - Executable JAR file
  - Test reports
  - Build artifacts

### `application.log`
**Purpose**: Runtime log file created by Spring Boot
- **Location**: Project root directory
- **Content**: Application logs, API requests/responses, error messages
- **Rotation**: Automatic rotation at 10MB with 5-file history

---

## File Dependencies and Relationships

```
pom.xml (Dependencies)
    ↓
src/main/java/ (Source Code)
    ↓
src/main/resources/application.properties (Configuration)
    ↓
application.log (Runtime Logs)
    ↓
filebeat.yml (Log Shipping Configuration)
    ↓
graylog/ (Log Processing and Visualization)
```

## Configuration Flow

1. **Maven** (`pom.xml`) downloads Spring Boot and logging dependencies
2. **Spring Boot** reads `application.properties` for configuration
3. **Application** writes structured logs to `application.log`
4. **Filebeat** reads `filebeat.yml` and ships logs to Graylog
5. **Graylog** stack processes and visualizes logs

## Security Considerations

- **ItemRepository**: Uses `ConcurrentHashMap` for thread safety
- **LoggingInterceptor**: Sanitizes input before logging
- **Filebeat**: Configured with proper TLS settings (disabled for dev)
- **Graylog**: Default credentials should be changed in production

## Development Workflow

1. **Code Changes**: Modify files in `src/main/java/`
2. **Configuration**: Update `application.properties`
3. **Testing**: Run `mvn test` (creates `target/` directory)
4. **Building**: Run `mvn package` (creates executable JAR)
5. **Running**: Execute JAR or use `spring-boot:run`
6. **Monitoring**: Check `application.log` and Graylog dashboard

## Production Considerations

- Replace in-memory repository with database
- Configure proper TLS for Filebeat → Graylog
- Set up log rotation and archival policies
- Configure monitoring and alerting
- Implement backup strategies for Graylog data
