{
  description = "Nix flake for LibreSpeed Rust backend with frontend and NixOS module. Tracks upstream main branches by default for easy updates; override inputs to pin versions.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    backend-src = {
      url = "github:librespeed/speedtest-rust";  # Tracks main; override URL to pin (e.g., /v1.3.8)
      flake = false;
    };

    frontend-src = {
      url = "github:librespeed/speedtest";  # Tracks main; override URL to pin (e.g., /5.4.1)
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, backend-src, frontend-src }:
    let
      overlay = final: prev: {
        librespeed-rs = prev.callPackage ./package.nix {
          inherit backend-src frontend-src;
        };
      };
    in
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ overlay ];
      };
    in {
      packages = {
        default = pkgs.librespeed-rs;
        librespeed-rs = pkgs.librespeed-rs;
      };
    }) // {
      overlays.default = overlay;
      nixosModules = rec {
        default = librespeed;
        librespeed = import ./module.nix;
      };
    };
}
