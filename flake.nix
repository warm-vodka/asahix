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
      };

      # Share the CI package set without evaluating it against a consumer's nixpkgs.
      linuxPackages_asahi-fairydust = pkgs.callPackage ./package.nix { };
    in
    {
      overlays.default = _final: _prev: {
        inherit linuxPackages_asahi-fairydust;
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
        inherit linuxPackages_asahi-fairydust;

        linux_asahi_fairydust =
          assert nixpkgs.lib.assertMsg false ''
            asahix: linux_asahi_fairydust has been renamed to linuxPackages_asahi-fairydust.
            Replace asahix.packages.${system}.linux_asahi_fairydust with
            asahix.packages.${system}.linuxPackages_asahi-fairydust, or import
            asahix.nixosModules.default and use pkgs.linuxPackages_asahi-fairydust.
          '';
          linuxPackages_asahi-fairydust;
      };
    };
}
