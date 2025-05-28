#!/bin/bash

# Tailscale Setup Script for Cloud-init
# This script installs and configures Tailscale on Ubuntu/Debian systems

set -euo pipefail

# ログ設定
LOGFILE="/var/log/tailscale-setup.log"
exec 1> >(tee -a "$LOGFILE")
exec 2>&1

echo "$(date): Starting Tailscale setup..."

# 環境変数の確認
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

# システム更新
echo "$(date): Updating system packages..."
apt-get update -y

# Tailscaleのインストール
echo "$(date): Installing Tailscale..."
curl -fsSL https://tailscale.com/install.sh | sh

# systemdサービスの有効化
echo "$(date): Enabling Tailscale service..."
systemctl enable tailscaled
systemctl start tailscaled

# 認証キーでのログイン設定
TAILSCALE_CMD="tailscale up --auth-key=$TAILSCALE_AUTH_KEY"

# ホスト名の設定
if [[ -n "$TAILSCALE_HOSTNAME" ]]; then
    TAILSCALE_CMD="$TAILSCALE_CMD --hostname=$TAILSCALE_HOSTNAME"
fi

# SSH設定
if [[ "$TAILSCALE_SSH_ENABLED" == "true" ]]; then
    TAILSCALE_CMD="$TAILSCALE_CMD --ssh"
    echo "$(date): Tailscale SSH will be enabled"
fi

# Exit Node設定
if [[ "$TAILSCALE_EXIT_NODE" == "true" ]]; then
    TAILSCALE_CMD="$TAILSCALE_CMD --advertise-exit-node"
    echo "$(date): Configuring as exit node"
    
    # IP転送を有効化
    echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.conf
    echo 'net.ipv6.conf.all.forwarding = 1' >> /etc/sysctl.conf
    sysctl -p
fi

# サブネットルート設定
if [[ -n "$TAILSCALE_SUBNET_ROUTES" ]]; then
    TAILSCALE_CMD="$TAILSCALE_CMD --advertise-routes=$TAILSCALE_SUBNET_ROUTES"
    echo "$(date): Advertising subnet routes: $TAILSCALE_SUBNET_ROUTES"
fi

# ACLタグ設定
if [[ -n "$TAILSCALE_TAGS" ]]; then
    TAILSCALE_CMD="$TAILSCALE_CMD --advertise-tags=$TAILSCALE_TAGS"
    echo "$(date): Using ACL tags: $TAILSCALE_TAGS"
fi

# 接続の受け入れ
TAILSCALE_CMD="$TAILSCALE_CMD --accept-routes --accept-dns"

# Tailscaleに接続
echo "$(date): Connecting to Tailscale..."
echo "Command: tailscale up [auth-key-hidden] [options]"
eval "$TAILSCALE_CMD"

# 接続状態の確認
echo "$(date): Checking Tailscale status..."
for i in {1..30}; do
    if tailscale status >/dev/null 2>&1; then
        echo "$(date): Tailscale connected successfully!"
        tailscale status
        break
    fi
    echo "$(date): Waiting for Tailscale connection... ($i/30)"
    sleep 2
done

# SSH設定の追加調整
if [[ "$TAILSCALE_SSH_ENABLED" == "true" ]]; then
    echo "$(date): Configuring SSH for Tailscale..."
    
    # SSHDの設定を調整（必要に応じて）
    if ! grep -q "PasswordAuthentication no" /etc/ssh/sshd_config; then
        echo "PasswordAuthentication no" >> /etc/ssh/sshd_config
        systemctl restart sshd
        echo "$(date): Disabled SSH password authentication"
    fi
fi

# 完了メッセージ
echo "$(date): Tailscale setup completed!"
echo "$(date): Node hostname: $TAILSCALE_HOSTNAME"
echo "$(date): SSH enabled: $TAILSCALE_SSH_ENABLED"
echo "$(date): Use 'tailscale status' to check connection"

# Tailscale IPアドレスを表示
TAILSCALE_IP=$(tailscale ip -4 2>/dev/null || echo "Not available yet")
echo "$(date): Tailscale IPv4 address: $TAILSCALE_IP"

# 接続情報をファイルに保存
cat > /etc/tailscale-info.txt << EOF
Tailscale Setup Information
===========================
Hostname: $TAILSCALE_HOSTNAME
SSH Enabled: $TAILSCALE_SSH_ENABLED
Exit Node: $TAILSCALE_EXIT_NODE
Tags: $TAILSCALE_TAGS
Setup Date: $(date)
Tailscale IP: $TAILSCALE_IP

To SSH via Tailscale (from another Tailscale device):
  ssh $TAILSCALE_HOSTNAME
  or
  ssh root@$TAILSCALE_IP

To check status:
  tailscale status
EOF

echo "$(date): Setup information saved to /etc/tailscale-info.txt" 