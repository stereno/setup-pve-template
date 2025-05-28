{
  description = "Terraform development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # Terraform
            terraform

            # Terraform utilities
            terragrunt
            terraform-docs
            tflint
            terrascan

            # Other useful tools
            jq
            yq
            curl
            git
            openssh
          ];

          shellHook = ''
            echo "🚀 Proxmox Terraform development environment loaded!"
            echo "Available tools:"
            echo "  • terraform $(terraform version --json | jq -r '.terraform_version')"
            echo "  • terragrunt $(terragrunt --version | head -1)"
            echo "  • terraform-docs $(terraform-docs version)"
            echo "  • tflint $(tflint --version | head -1)"
            echo ""
            echo "Happy Terraforming with Proxmox! 🌍"
          '';

          # Environment variables
          TF_CLI_ARGS_init = "-upgrade";
          TF_CLI_ARGS_plan = "-parallelism=10";
          TF_CLI_ARGS_apply = "-parallelism=10";
        };
      });
} 