FROM openjdk:17-jdk-slim

WORKDIR /app

COPY target/app.jar app.jar

# Create log directory
RUN mkdir -p /logs

# Run app
ENTRYPOINT ["java", "-jar", "app.jar"]
