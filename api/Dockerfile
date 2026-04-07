FROM eclipse-temurin:17-jdk-jammy

WORKDIR /app

COPY target/api-logfile-filebeat-graylog-1.0.0.jar app.jar

# Create log directory
RUN mkdir -p /logs

# Run app
ENTRYPOINT ["java", "-jar", "app.jar"]
