#cloud-config
# Tailscale Cloud-init Configuration for VMs

# パッケージの更新
package_update: true
package_upgrade: true

# 必要なパッケージのインストール
packages:
  - curl
  - wget
  - git
  - htop
  - vim
  - net-tools

# Tailscale環境変数の設定
write_files:
  - path: /etc/tailscale-env
    content: |
      TAILSCALE_AUTH_KEY="${tailscale_auth_key}"
      TAILSCALE_HOSTNAME="${tailscale_hostname}"
      TAILSCALE_SSH_ENABLED="${tailscale_ssh_enabled}"
      TAILSCALE_EXIT_NODE="${tailscale_exit_node}"
      TAILSCALE_TAGS="${tailscale_tags}"
      TAILSCALE_SUBNET_ROUTES="${tailscale_subnet_routes}"
    permissions: '0600'
    owner: root:root

  - path: /usr/local/bin/setup-tailscale.sh
    content: |
      #!/bin/bash
      set -euo pipefail
      
      # 環境変数を読み込み
      source /etc/tailscale-env
      
      echo "Starting Tailscale setup for ${tailscale_hostname}..."
      
      # Tailscaleインストール
      curl -fsSL https://tailscale.com/install.sh | sh
      
      # サービス開始
      systemctl enable tailscaled
      systemctl start tailscaled
      
      # 認証キーで接続
      TAILSCALE_CMD="tailscale up --auth-key=$TAILSCALE_AUTH_KEY --hostname=${tailscale_hostname}"
      
      %{ if tailscale_ssh_enabled }
      TAILSCALE_CMD="$TAILSCALE_CMD --ssh"
      %{ endif }
      
      %{ if tailscale_exit_node }
      TAILSCALE_CMD="$TAILSCALE_CMD --advertise-exit-node"
      echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.conf
      echo 'net.ipv6.conf.all.forwarding = 1' >> /etc/sysctl.conf
      sysctl -p
      %{ endif }
      
      %{ if tailscale_subnet_routes != "" }
      TAILSCALE_CMD="$TAILSCALE_CMD --advertise-routes=${tailscale_subnet_routes}"
      %{ endif }
      
      %{ if tailscale_tags != "" }
      TAILSCALE_CMD="$TAILSCALE_CMD --advertise-tags=${tailscale_tags}"
      %{ endif }
      
      TAILSCALE_CMD="$TAILSCALE_CMD --accept-routes --accept-dns"
      
      # 接続実行
      eval "$TAILSCALE_CMD"
      
      # 接続確認
      sleep 10
      tailscale status
      
      # 情報保存
      cat > /etc/tailscale-info.txt << EOF
      Tailscale Setup Complete
      ========================
      Hostname: ${tailscale_hostname}
      SSH Enabled: ${tailscale_ssh_enabled}
      Setup Date: $(date)
      Tailscale IP: $(tailscale ip -4 2>/dev/null || echo "pending")
      
      SSH Command: ssh ${tailscale_hostname}
      EOF
      
      echo "Tailscale setup completed for ${tailscale_hostname}"
    permissions: '0755'
    owner: root:root

# システム起動時にTailscaleセットアップを実行
runcmd:
  # システムの基本設定
  - echo 'VM ${tailscale_hostname} starting up...'
  
  # Tailscaleセットアップ実行
  - /usr/local/bin/setup-tailscale.sh >> /var/log/tailscale-setup.log 2>&1
  
  # 完了通知
  - echo 'VM ${tailscale_hostname} setup complete' >> /var/log/cloud-init-tailscale.log

# 最終メッセージ
final_message: |
  Proxmox VM with Tailscale setup completed!
  Hostname: ${tailscale_hostname}
  SSH via Tailscale: ssh ${tailscale_hostname}
  
  Check Tailscale status: tailscale status
  Check setup log: tail -f /var/log/tailscale-setup.log 