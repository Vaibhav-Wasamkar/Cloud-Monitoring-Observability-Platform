#!/bin/bash
set -e

echo "Starting monitoring server bootstrap..."

# ============================================================
# 1. Update system
# ============================================================

apt-get update

# ============================================================
# 2. Install required packages
# ============================================================

apt-get install -y \
	docker.io \
	docker-compose-v2 \
	git

# ============================================================
# 3. Enable Docker
# ============================================================

systemctl enable docker
systemctl start docker

# ============================================================
# 4. Clone only monitoring directory
# ============================================================

REPOSITORY_URL="${repository_url}"
MONITORING_DIR="/opt/cloud-monitoring/repository/monitoring"

mkdir -p /opt/cloud-monitoring

cd /opt/cloud-monitoring

git clone \
	--filter=blob:none \
	--no-checkout \
	"$REPOSITORY_URL" \
	repository

cd repository

git sparse-checkout init --cone
git sparse-checkout set monitoring

git checkout

# ============================================================
# 5. Start monitoring stack
# ============================================================

cd "$MONITORING_DIR"

sudo docker compose up -d

# ============================================================
# 6. Verify monitoring containers
# ============================================================

sleep 10

sudo docker compose ps

echo "=============================================="
echo "Monitoring server bootstrap completed."
echo "=============================================="
echo "Monitoring directory: $MONITORING_DIR"
echo "=============================================="
