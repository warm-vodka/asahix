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

      pkgs = import nixpkgs {
        inherit system;
        overlays = [ self.overlays.default ];
      };
    in
    {
      overlays.default = final: _prev: {
        linuxPackages_asahi-fairydust = final.callPackage ./package.nix { };
      };

      nixosModules.default = {
        nixpkgs.overlays = [ self.overlays.default ];
        nix.settings = {
          substituters = [ "https://asahix.cachix.org" ];
          trusted-public-keys = [
            "asahix.cachix.org-1:SDzLl9HW7kV2h/6yBCZwjhveL2HUjjdI0x+qFB0I54Y="
          ];
        };
      };

      packages.${system} = {
        inherit (pkgs) linuxPackages_asahi-fairydust;

        linux_asahi_fairydust =
          assert nixpkgs.lib.assertMsg false ''
            asahix: linux_asahi_fairydust has been renamed to linuxPackages_asahi-fairydust.
            Replace asahix.packages.${system}.linux_asahi_fairydust with
            asahix.packages.${system}.linuxPackages_asahi-fairydust, or import
            asahix.nixosModules.default and use pkgs.linuxPackages_asahi-fairydust.
          '';
          pkgs.linuxPackages_asahi-fairydust;
      };
    };
}
