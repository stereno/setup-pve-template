# Proxmox Terraform Template

🚀 **Template Repository** - ProxmoxでVM・LXCを管理するためのTerraformテンプレート

[![Use this template](https://img.shields.io/badge/Use%20this-Template-blue?style=for-the-badge)](https://github.com/your-username/setup-pve-template/generate)

## 📋 概要

このテンプレートリポジトリは、ProxmoxVE環境でVM（仮想マシン）とLXC（Linuxコンテナ）を効率的に管理するためのTerraform設定を提供します。

### ✨ 主な機能

- 🖥️ **VM管理**: Cloud-init対応のVMテンプレートからのクローン作成
- 📦 **LXC管理**: 軽量なLinuxコンテナの作成・管理
- 🔧 **柔軟な設定**: VM・LXCを個別または組み合わせて使用可能
- 🏗️ **モジュール化**: 再利用可能なTerraformモジュール構成
- 🔒 **セキュア**: API Token認証対応
- 🚀 **Tailscale SSH**: apply直後から即座にSSHアクセス可能
- 🛠️ **開発環境**: Nix + direnv による一貫した開発環境

## 🚀 クイックスタート

### 💫 Tailscale SSH対応（推奨）

**terraform apply直後にSSH接続可能！**

```bash
# 1. リポジトリをクローン
git clone https://github.com/your-username/your-new-project.git
cd your-new-project/terraform

# 2. Terraform初期化
terraform init

# 3. 対話形式で設定入力
terraform plan
# ↑ tailscale_enabled = true を入力
# ↑ tailscale_auth_key = "tskey-auth-xxx" を入力（事前にTailscaleで作成）

# 4. デプロイ実行
terraform apply

# 5. 即座にSSH接続可能！
ssh proxmox-vm-1        # VM (デフォルトユーザー)
ssh root@proxmox-lxc-1  # LXC (rootユーザー)
```

**必要なもの：**
- [Tailscaleアカウント](https://tailscale.com)
- [認証キー](https://login.tailscale.com/admin/settings/keys)（Reusableを推奨）

詳細は [📚 Tailscale SSHガイド](docs/TAILSCALE_GUIDE.md) を参照

### 方法1: 対話形式で即座に開始（推奨）

リポジトリをクローンして、何の事前設定もなしに即座に開始できます：

```bash
# 1. リポジトリをクローン
git clone https://github.com/your-username/your-new-project.git
cd your-new-project

# 2. Terraformディレクトリに移動
cd terraform

# 3. Terraform初期化
terraform init

# 4. 対話形式で設定を入力しながらplan実行
terraform plan
# ↑ 必要な変数（Proxmox URL、ノード名など）を順次入力

# 5. デプロイ実行
terraform apply
```

**入力例：**
- `proxmox_api_url`: `https://192.168.1.100:8006/api2/json`
- `proxmox_node`: `pve`
- `vm_count`: `1` (VMを1台作成)
- `vm_template`: `ubuntu-22.04-cloudinit`
- その他の設定項目...

### 方法2: このテンプレートを使用（設定ファイル使用）

[![Use this template](https://img.shields.io/badge/Use%20this-Template-green?style=flat-square)](https://github.com/your-username/setup-pve-template/generate)

GitHubで「**Use this template**」ボタンをクリックして新しいリポジトリを作成

```bash
git clone https://github.com/your-username/your-new-project.git
cd your-new-project
```

### 3. プロジェクトを初期化

```bash
# 初期化スクリプトを実行（インタラクティブ）
./scripts/init-project.sh

# または非インタラクティブ
./scripts/init-project.sh \
  --name my-infrastructure \
  --url https://192.168.1.100:8006/api2/json \
  --node pve \
  --type standalone
```

### 4. 設定をカスタマイズ

```bash
cd terraform
# 生成されたterraform.tfvarsを編集
vi terraform.tfvars
```

### 5. デプロイ

```bash
# 便利なMakefileコマンドを使用
make tf-init
make plan
make apply

# または直接Terraformコマンド
terraform init
terraform plan
terraform apply
```

## 📁 プロジェクト構造

```
your-project/
├── terraform/                 # 🏗️ Terraform設定
│   ├── main.tf                # メイン設定
│   ├── variables.tf           # 変数定義
│   ├── outputs.tf             # 出力定義
│   ├── terraform.tfvars       # 実際の設定値（初期化後に生成）
│   ├── modules/               # 再利用可能モジュール
│   │   ├── proxmox-vm/        # VMモジュール
│   │   └── proxmox-lxc/       # LXCモジュール
│   └── examples/              # 使用例
├── ansible/                   # ⚙️ 設定管理（プレースホルダー）
├── scripts/                   # 🔧 自動化スクリプト
│   └── init-project.sh        # プロジェクト初期化
├── docs/                      # 📚 ドキュメント
├── Makefile                   # 🛠️ 便利なコマンド
├── flake.nix                  # ❄️ Nix開発環境
├── .envrc                     # 🔄 direnv設定
└── PROJECT_README.md          # 📝 プロジェクト固有のREADME（初期化後に生成）
```

## 🎯 使用パターン

### パターン1: VMのみ
```hcl
vm_count = 2      # VM 2台
lxc_count = 0     # LXC なし
```

### パターン2: LXCのみ
```hcl
vm_count = 0      # VM なし
lxc_count = 3     # LXC 3台
```

### パターン3: 混合環境
```hcl
vm_count = 1      # データベース用VM
lxc_count = 2     # アプリケーション用LXC
```

## 🛠️ 開発環境

### 前提条件

- [Nix](https://nixos.org/download.html) がインストールされていること
- [direnv](https://direnv.net/docs/installation.html) がインストールされていること  
- [nix-direnv](https://github.com/nix-community/nix-direnv) が設定されていること
- Proxmoxサーバーへのアクセス権限

### 環境のセットアップ

```bash
# ディレクトリに入ると自動的に環境がロード
cd your-project
direnv allow

# 手動でのセットアップ
make setup
```

### 利用可能なツール

- 🏗️ `terraform` - メインのTerraformCLI
- 📦 `terragrunt` - Terraformラッパー
- 📖 `terraform-docs` - ドキュメント生成
- 🔍 `tflint` - 静的解析
- 🛡️ `terrascan` - セキュリティスキャン
- 🔧 `jq`, `yq` - JSON/YAML処理
- 🚀 `openssh`, `curl`, `git` - その他ユーティリティ

## 📚 使用例

初期化後、`terraform/examples/` に以下の使用例が含まれます：

- 🖥️ [**basic-vm**](terraform/examples/basic-vm/) - 基本的なVM環境
- 📦 [**basic-lxc**](terraform/examples/basic-lxc/) - 基本的なLXC環境  
- 🔀 [**mixed-environment**](terraform/examples/mixed-environment/) - VM・LXC混合環境
- 🚀 [**tailscale-enabled**](terraform/examples/tailscale-enabled/) - Tailscale SSH対応環境

### 設定ファイル使用方式
例をコピーして使用：
```bash
cp terraform/examples/basic-vm/terraform.tfvars terraform/
```

### 対話形式方式（推奨）
事前設定なしで即座に開始：
```bash
cd terraform
terraform init
terraform plan  # 必要な設定を対話形式で入力
terraform apply
```

詳細は [対話形式モード使用ガイド](docs/INTERACTIVE_MODE.md) を参照してください。

### Tailscale SSH対応
```bash
# Tailscale対応例を使用
cp terraform/examples/tailscale-enabled/terraform.tfvars terraform/
# tailscale_auth_keyを設定してから
terraform apply
```

詳細は [📚 Tailscale SSHガイド](docs/TAILSCALE_GUIDE.md) を参照してください。

## 🎛️ Makefileコマンド

便利なMakefileコマンドが利用可能：

```bash
make help           # 利用可能なコマンドを表示
make init           # プロジェクトを初期化
make setup          # 開発環境をセットアップ  
make plan           # Terraform plan実行
make apply          # Terraform apply実行
make destroy        # Terraform destroy実行
make status         # 現在の状態を表示
make examples       # 使用例を表示
make clean          # 一時ファイルを削除
```

## 🔧 カスタマイズ

### 新しいモジュールの追加

```bash
mkdir terraform/modules/your-custom-module
cd terraform/modules/your-custom-module
touch main.tf variables.tf outputs.tf
```

### 複数環境の管理

```bash
mkdir terraform/environments/{dev,staging,prod}
# 環境別にterraform.tfvarsを配置
```

### Ansible統合

```bash
# Terraformでインフラ作成後
cd terraform
terraform output vm_ip_addresses

# Ansibleでソフトウェア設定
cd ../ansible
# インベントリファイルを作成して実行
```

## 🤝 貢献

このテンプレートの改善にご協力ください：

1. 🐛 **Issues** - バグ報告や機能提案
2. 🔧 **Pull Requests** - 機能追加や修正
3. 📖 **Documentation** - ドキュメントの改善

## 📄 ライセンス

このテンプレートは [MIT License](LICENSE) の下で提供されています。

## 🔗 関連リンク

- 📖 [Template使用ガイド](docs/TEMPLATE_USAGE.md)
- 🎯 [対話形式モード使用ガイド](docs/INTERACTIVE_MODE.md)
- 🚀 [Tailscale SSH統合ガイド](docs/TAILSCALE_GUIDE.md)
- 🏗️ [Proxmox Terraform Provider](https://registry.terraform.io/providers/Telmate/proxmox/latest/docs)
- 🌐 [Proxmox VE API Documentation](https://pve.proxmox.com/wiki/Proxmox_VE_API)
- 🏆 [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/)

---

<div align="center">

**[⭐ このテンプレートが役に立ったら、スターをお願いします！](https://github.com/your-username/setup-pve-template)**

</div>
