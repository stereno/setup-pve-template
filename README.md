# setup-pve-template

簡単に Proxmox を使おう

## 開発環境

このプロジェクトではNixとdirenvを使用してTerraform開発環境を自動的にセットアップします。

### 前提条件

- [Nix](https://nixos.org/download.html) がインストールされていること
- [direnv](https://direnv.net/docs/installation.html) がインストールされていること
- [nix-direnv](https://github.com/nix-community/nix-direnv) がインストール・設定されていること

### 使用方法

1. このディレクトリに移動すると、direnvが自動的に開発環境をロードします：
   ```bash
   cd setup-pve-template
   # direnvがTerraform環境を自動的にセットアップします
   ```

2. 初回アクセス時は、direnvの許可が必要です：
   ```bash
   direnv allow
   ```

3. 環境がロードされると、以下のツールが利用可能になります：
   - `terraform` - メインのTerraformCLI
   - `terragrunt` - Terraformのラッパーツール
   - `terraform-docs` - ドキュメント生成
   - `tflint` - Terraformの静的解析
   - `terrascan` - セキュリティスキャン
   - `awscli2`, `azure-cli`, `google-cloud-sdk` - クラウドプロバイダーCLI
   - `jq`, `yq` - JSON/YAML処理ツール

### 手動での環境ロード

direnvを使わない場合は、以下のコマンドで手動でdevShellに入ることもできます：

```bash
nix develop
```

### Terraform設定

環境には以下のTerraform設定が自動的に適用されます：
- 初期化時の自動アップグレード
- plan/apply時の並列実行数を10に設定
