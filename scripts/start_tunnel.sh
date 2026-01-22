#!/bin/bash

cd "$(dirname "$0")/../terraform"

echo "🔍 Fetching dynamic cluster IPs from Terraform..."

EDGE_IP=$(terraform output -raw edge_external_ip)

MASTER_INTERNAL_IP=$(terraform output -raw master_internal_ip)

if [ -z "$EDGE_IP" ] || [ -z "$MASTER_INTERNAL_IP" ]; then
    echo "❌ Error: Could not fetch IPs. Run 'terraform apply' first."
    exit 1
fi

echo "✅ Edge Node (Public):   $EDGE_IP"
echo "✅ Master Node (Private): $MASTER_INTERNAL_IP"
echo "🚀 Starting Tunnel to Spark UI..."
echo "👉 Open your browser at: http://localhost:8080"
echo "⚠️  Press Ctrl+C to stop."

# Dynamic Edge IP -> Dynamic Master IP
ssh -i ~/.ssh/google_compute_engine \
    -o StrictHostKeyChecking=no \
    -o UserKnownHostsFile=/dev/null \
    -L 8080:${MASTER_INTERNAL_IP}:8080 \
    -N \
    mpsi_mekkaoui_ossama_moussa_gmai@${EDGE_IP}