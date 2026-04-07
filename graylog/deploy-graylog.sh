#!/bin/bash

# Graylog Deployment Script using Podman
# This script deploys Graylog with MongoDB and Elasticsearch

echo "Starting Graylog deployment with Podman..."

# Check if Podman is installed
if ! command -v podman &> /dev/null; then
    echo "Error: Podman is not installed. Please install Podman first."
    exit 1
fi

# Create pod for Graylog services
echo "Creating Graylog pod..."
podman pod create \
    --name graylog-pod \
    --publish 9000:9000 \
    --publish 5044:5044 \
    --publish 12201:12201/tcp \
    --publish 12201:12201/udp \
    --share

# Create volumes
echo "Creating persistent volumes..."
podman volume create graylog-mongo-data
podman volume create graylog-es-data
podman volume create graylog-data
podman volume create graylog-journal

# Start MongoDB
echo "Starting MongoDB..."
podman run -d \
    --name graylog-mongo \
    --pod graylog-pod \
    -e MONGO_INITDB_ROOT_USERNAME=admin \
    -e MONGO_INITDB_ROOT_PASSWORD=admin123 \
    -v graylog-mongo-data:/data/db \
    --restart unless-stopped \
    mongo:6.0

# Wait for MongoDB to start
echo "Waiting for MongoDB to start..."
sleep 10

# Start Elasticsearch
echo "Starting Elasticsearch..."
podman run -d \
    --name graylog-elasticsearch \
    --pod graylog-pod \
    -e discovery.type=single-node \
    -e xpack.security.enabled=false \
    -e "ES_JAVA_OPTS=-Xms512m -Xmx512m" \
    -v graylog-es-data:/usr/share/elasticsearch/data \
    --restart unless-stopped \
    docker.elastic.co/elasticsearch/elasticsearch:8.11.0

# Wait for Elasticsearch to start
echo "Waiting for Elasticsearch to start..."
sleep 20

# Start Graylog
echo "Starting Graylog..."
podman run -d \
    --name graylog-server \
    --pod graylog-pod \
    -e GRAYLOG_PASSWORD_SECRET=somepasswordpepper \
    -e GRAYLOG_ROOT_PASSWORD_SHA2=8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918 \
    -e GRAYLOG_HTTP_BIND_ADDRESS=0.0.0.0:9000 \
    -e GRAYLOG_HTTP_EXTERNAL_URI=http://localhost:9000/ \
    -e GRAYLOG_ELASTICSEARCH_HOSTS=http://localhost:9200 \
    -e GRAYLOG_MONGODB_URI=mongodb://admin:admin123@localhost:27017/graylog \
    -v graylog-data:/usr/share/graylog/data \
    -v graylog-journal:/usr/share/graylog/data/journal \
    --restart unless-stopped \
    graylog/graylog:5.2

echo "Graylog deployment completed!"
echo "Access Graylog web interface at: http://localhost:9000"
echo "Default login: admin / admin"
echo ""
echo "Beats input is available on port 5044"
echo "GELF inputs are available on port 12201 (TCP/UDP)"
echo ""
echo "To check status: podman pod logs graylog-pod"
echo "To stop: podman pod stop graylog-pod"
echo "To remove: podman pod rm graylog-pod"
