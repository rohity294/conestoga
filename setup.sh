#!/bin/bash
set -e

echo "🔧 Setting up OpenTelemetry Monolith Demo..."

# 1. Install npm dependencies
echo "Installing npm dependencies..."
npm install

# 2. Generate docker-compose.yml if missing
if [ ! -f docker-compose.yml ]; then
cat <<'EOF' > docker-compose.yml
services:
  otel-collector:
    image: otel/opentelemetry-collector:latest
    container_name: otel-collector
    command: ["--config=/etc/otel-collector-config.yaml"]
    volumes:
      - ./otel-collector-config.yaml:/etc/otel-collector-config.yaml
    ports:
      - "4317:4317"
      - "4318:4318"
      - "55679:55679"
      - "9464:9464"

  jaeger:
    image: jaegertracing/all-in-one:latest
    container_name: jaeger
    environment:
      - COLLECTOR_OTLP_ENABLED=true
    ports:
      - "16686:16686"
      - "4317"
      - "4318"

  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
    ports:
      - "9090:9090"
EOF
fi

# 3. Generate otel-collector-config.yaml if missing
if [ ! -f otel-collector-config.yaml ]; then
cat <<'EOF' > otel-collector-config.yaml
receivers:
  otlp:
    protocols:
      grpc:
      http:

exporters:
  logging:
    loglevel: debug
  jaeger:
    endpoint: jaeger:4317
    tls:
      insecure: true
  prometheus:
    endpoint: "0.0.0.0:9464"

service:
  pipelines:
    traces:
      receivers: [otlp]
      exporters: [logging, jaeger]
    metrics:
      receivers: [otlp]
      exporters: [logging, prometheus]
    logs:
      receivers: [otlp]
      exporters: [logging]
EOF
fi

# 4. Generate prometheus.yml if missing
if [ ! -f prometheus.yml ]; then
cat <<'EOF' > prometheus.yml
global:
  scrape_interval: 5s

scrape_configs:
  - job_name: "otel-collector"
    static_configs:
      - targets: ["otel-collector:9464"]
EOF
fi

# 5. Fully clean old Docker Compose state and caches
echo "Cleaning up previous Docker Compose state and builder cache..."
docker compose down --remove-orphans || true
docker builder prune -af || true
docker image prune -af || true
rm -f docker-compose.override.yml || true
rm -rf .docker || true

# 6. Start observability stack with BuildKit disabled & unique project name
PROJECT_NAME="otelstack"
echo "Starting observability stack (Collector, Jaeger, Prometheus)..."
DOCKER_BUILDKIT=0 docker compose -p $PROJECT_NAME up -d

echo "Setup complete!"

echo ""
echo "🌐 Access the following:"
echo " - Monolith App (already running via npm start): http://localhost:3000"
echo " - Jaeger (Traces):  http://localhost:16686"
echo " - Prometheus:       http://localhost:9090"
echo ""
echo "👉 Generate traffic from another terminal:"
echo "   curl http://localhost:3000/"
echo "   curl http://localhost:3000/error"
echo ""
echo "Then:"
echo " - See spans in Jaeger"
echo " - Query RED metrics in Prometheus"
echo " - View logs in collector: docker logs -f otel-collector"
