{
  description = "Terraform development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };


  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
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
          ];


          shellHook = ''
            echo ""
            echo ""
            echo "🚀 Proxmox Terraform development environment loaded!"
            echo "Happy Terraforming with Proxmox! 🌍"
            echo ""
            echo ""
          '';

          # Environment variables
          TF_CLI_ARGS_init = "-upgrade";
          TF_CLI_ARGS_plan = "-parallelism=10";
          TF_CLI_ARGS_apply = "-parallelism=10";
        };
      });
} 
