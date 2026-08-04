{
  description = "Asahi Linux fairydust kernel (USB-C DP Alt Mode) for Apple Silicon";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    {
      self,
      nixpkgs,
    }:
    let
      system = "aarch64-linux";

      pkgs = import nixpkgs { inherit system; };
    in
    {
      packages.${system}.linux_asahi_fairydust = pkgs.callPackage ./package.nix { };
    };
}
