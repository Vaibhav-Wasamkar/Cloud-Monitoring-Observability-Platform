#!/bin/bash
set -e

echo "Starting monitoring application instance bootstrap..."

# ============================================================
# 1. Update system packages
# ============================================================

apt-get update

apt-get install -y \
	nodejs \
	npm \
	curl \
	wget

# ============================================================
# 2. Install Node Exporter
# ============================================================

NODE_EXPORTER_VERSION="1.9.1"

useradd \
	--no-create-home \
	--shell /bin/false \
	node_exporter || true

cd /tmp

wget -q \
	"https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz"

tar -xzf \
	"node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz"

cp \
	"node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64/node_exporter" \
	/usr/local/bin/node_exporter

chown \
	node_exporter:node_exporter \
	/usr/local/bin/node_exporter

# ============================================================
# 3. Configure Node Exporter systemd service
# ============================================================

cat >/etc/systemd/system/node_exporter.service <<'SERVICE'
[Unit]
Description=Prometheus Node Exporter
After=network.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
SERVICE

systemctl daemon-reload
systemctl enable node_exporter
systemctl start node_exporter

# ============================================================
# 4. Create monitoring demo application
# ============================================================

mkdir -p /opt/monitoring-app

cd /opt/monitoring-app

cat >package.json <<'APP_PACKAGE'
{
  "name": "monitoring-demo-app",
  "version": "1.0.0",
  "description": "Demo application for Cloud Monitoring and Observability Platform",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {
    "express": "^5.1.0",
    "prom-client": "^15.1.3"
  }
}
APP_PACKAGE

cat >server.js <<'APP_SERVER'
const express = require("express");
const client = require("prom-client");
const os = require("os");

const app = express();
const PORT = 8080;

const register = new client.Registry();

// Collect default Node.js process metrics
client.collectDefaultMetrics({
  register,
  prefix: "app_"
});

// Custom application request counter
const httpRequests = new client.Counter({
  name: "app_http_requests_total",
  help: "Total number of HTTP requests",
  labelNames: ["method", "route", "status_code"],
  registers: [register]
});

// Track HTTP requests
app.use((req, res, next) => {
  res.on("finish", () => {
    httpRequests.inc({
      method: req.method,
      route: req.route?.path || req.path,
      status_code: res.statusCode
    });
  });

  next();
});

// Application endpoint
app.get("/", (req, res) => {
  res.json({
    application: "Cloud Monitoring Demo",
    status: "running",
    hostname: os.hostname(),
    timestamp: new Date().toISOString()
  });
});

// ALB health check endpoint
app.get("/health", (req, res) => {
  res.status(200).json({
    status: "healthy",
    hostname: os.hostname()
  });
});

// Prometheus application metrics
app.get("/metrics", async (req, res) => {
  res.set("Content-Type", register.contentType);
  res.end(await register.metrics());
});

// Start application
app.listen(PORT, "0.0.0.0", () => {
  console.log(
    "Monitoring demo application listening on port " + PORT
  );
});
APP_SERVER

# ============================================================
# 5. Install application dependencies
# ============================================================

npm install --omit=dev

# ============================================================
# 6. Configure application systemd service
# ============================================================

cat >/etc/systemd/system/monitoring-demo.service <<'SERVICE'
[Unit]
Description=Cloud Monitoring Demo Application
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/monitoring-app
ExecStart=/usr/bin/node /opt/monitoring-app/server.js

Restart=on-failure
RestartSec=5

Environment=NODE_ENV=production

[Install]
WantedBy=multi-user.target
SERVICE

systemctl daemon-reload
systemctl enable monitoring-demo
systemctl start monitoring-demo

# ============================================================
# 7. Verify services
# ============================================================

systemctl is-active --quiet node_exporter
systemctl is-active --quiet monitoring-demo

# Verify application health
curl --fail http://localhost:8080/health >/dev/null

# Verify Node Exporter
curl --fail http://localhost:9100/metrics >/dev/null

echo "=============================================="
echo "Monitoring application bootstrap completed."
echo "=============================================="
echo "Application : http://localhost:8080/"
echo "Health      : http://localhost:8080/health"
echo "App Metrics : http://localhost:8080/metrics"
echo "Node Exporter: http://localhost:9100/metrics"
echo "=============================================="
