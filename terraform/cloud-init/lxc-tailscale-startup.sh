#!/bin/bash

# LXC Tailscale Setup Script
# This script runs at LXC container startup to configure Tailscale

set -euo pipefail

LOGFILE="/var/log/lxc-tailscale-setup.log"
exec 1> >(tee -a "$LOGFILE")
exec 2>&1

echo "$(date): LXC Tailscale setup starting..."

# 環境変数（Terraformから注入される想定）
TAILSCALE_AUTH_KEY="${TAILSCALE_AUTH_KEY:-}"
TAILSCALE_HOSTNAME="${TAILSCALE_HOSTNAME:-}"
TAILSCALE_SSH_ENABLED="${TAILSCALE_SSH_ENABLED:-true}"
TAILSCALE_EXIT_NODE="${TAILSCALE_EXIT_NODE:-false}"
TAILSCALE_TAGS="${TAILSCALE_TAGS:-}"
TAILSCALE_SUBNET_ROUTES="${TAILSCALE_SUBNET_ROUTES:-}"

if [[ -z "$TAILSCALE_AUTH_KEY" ]]; then
    echo "Warning: TAILSCALE_AUTH_KEY not provided, skipping Tailscale setup"
    exit 0
fi

# システムが完全に起動するまで待機
sleep 30

# パッケージマネージャーの更新
echo "$(date): Updating package manager..."
if command -v apt-get >/dev/null 2>&1; then
    apt-get update -y
    apt-get install -y curl wget
elif command -v apk >/dev/null 2>&1; then
    apk update
    apk add curl wget bash
fi

# Tailscaleのインストール
echo "$(date): Installing Tailscale..."
curl -fsSL https://tailscale.com/install.sh | sh

# systemdまたはOpenRCでサービス管理
if command -v systemctl >/dev/null 2>&1; then
    echo "$(date): Using systemd to manage Tailscale..."
    systemctl enable tailscaled
    systemctl start tailscaled
elif command -v rc-service >/dev/null 2>&1; then
    echo "$(date): Using OpenRC to manage Tailscale..."
    rc-update add tailscaled
    rc-service tailscaled start
else
    echo "$(date): Starting Tailscale daemon manually..."
    tailscaled --state=/var/lib/tailscale/tailscaled.state --socket=/var/run/tailscale/tailscaled.sock &
    sleep 5
fi

# Tailscale接続コマンドの構築
TAILSCALE_CMD="tailscale up --auth-key=$TAILSCALE_AUTH_KEY"

if [[ -n "$TAILSCALE_HOSTNAME" ]]; then
    TAILSCALE_CMD="$TAILSCALE_CMD --hostname=$TAILSCALE_HOSTNAME"
fi

if [[ "$TAILSCALE_SSH_ENABLED" == "true" ]]; then
    TAILSCALE_CMD="$TAILSCALE_CMD --ssh"
fi

if [[ "$TAILSCALE_EXIT_NODE" == "true" ]]; then
    TAILSCALE_CMD="$TAILSCALE_CMD --advertise-exit-node"
    # IP転送を有効化
    echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.conf
    echo 'net.ipv6.conf.all.forwarding = 1' >> /etc/sysctl.conf
    sysctl -p || echo "sysctl not available, IP forwarding may need manual configuration"
fi

if [[ -n "$TAILSCALE_SUBNET_ROUTES" ]]; then
    TAILSCALE_CMD="$TAILSCALE_CMD --advertise-routes=$TAILSCALE_SUBNET_ROUTES"
fi

if [[ -n "$TAILSCALE_TAGS" ]]; then
    TAILSCALE_CMD="$TAILSCALE_CMD --advertise-tags=$TAILSCALE_TAGS"
fi

TAILSCALE_CMD="$TAILSCALE_CMD --accept-routes --accept-dns"

# Tailscaleに接続
echo "$(date): Connecting to Tailscale network..."
eval "$TAILSCALE_CMD"

# 接続確認
echo "$(date): Verifying Tailscale connection..."
for i in {1..30}; do
    if tailscale status >/dev/null 2>&1; then
        echo "$(date): Tailscale connected successfully!"
        tailscale status
        break
    fi
    echo "$(date): Waiting for Tailscale connection... ($i/30)"
    sleep 2
done

# 情報ファイルの作成
TAILSCALE_IP=$(tailscale ip -4 2>/dev/null || echo "Not available")
cat > /etc/tailscale-info.txt << EOF
LXC Tailscale Setup Information
==============================
Container Hostname: $TAILSCALE_HOSTNAME
SSH Enabled: $TAILSCALE_SSH_ENABLED
Exit Node: $TAILSCALE_EXIT_NODE
Tags: $TAILSCALE_TAGS
Setup Date: $(date)
Tailscale IP: $TAILSCALE_IP

SSH Command (from Tailscale network):
  ssh root@$TAILSCALE_HOSTNAME
  or
  ssh root@$TAILSCALE_IP

Status Check:
  tailscale status
EOF

echo "$(date): LXC Tailscale setup completed!"
echo "$(date): Container accessible via: ssh root@$TAILSCALE_HOSTNAME"
echo "$(date): Setup information saved to /etc/tailscale-info.txt" 