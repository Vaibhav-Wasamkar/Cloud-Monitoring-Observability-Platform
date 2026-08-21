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
	git \
	docker.io \
	docker-compose-v2 \
	jq \
	curl \
	unzip

cd /tmp

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" \
	-o "awscliv2.zip"

unzip -q awscliv2.zip

sudo ./aws/install

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

SECRET_JSON=$(aws secretsmanager get-secret-value \
	--secret-id "${webhook_secret_arn}" \
	--region ap-south-1 \
	--query SecretString \
	--output text)

SLACK_WEBHOOK_URL=$(echo "$SECRET_JSON" | jq -r '.SLACK_WEBHOOK_URL')

sed -i "s|SLACK_WEBHOOK_URL_PLACEHOLDER|$${SLACK_WEBHOOK_URL}|g" \
	alertmanager/alertmanager.yml

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
