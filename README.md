# asahix

Nix flake that builds the Asahi Linux `fairydust` kernel (7.1.5) with USB-C DisplayPort Alt Mode support for Apple Silicon.

## Build

```console
$ nix build .#packages.aarch64-linux.linux_asahi_fairydust
```

## Use in a flake

```nix
{
  inputs.asahix.url = "github:skiletro/asahix";

  outputs = { self, nixpkgs, asahix }: {
    nixosConfigurations.mymac = nixpkgs.lib.nixosSystem {
      modules = [
        ({ pkgs, ... }: {
          boot.kernelPackages = asahix.packages.${pkgs.system}.linux_asahi_fairydust;
        })
      ];
    };
  };
}
```

## Binary cache (Cachix)

Prebuilt store paths are pushed to `https://asahix.cachix.org`. Add it to your substituters to avoid building locally:

```nix
nix.settings = {
  substituters = [ "https://asahix.cachix.org" ];
  trusted-public-keys = [ "asahix.cachix.org-1:SDzLl9HW7kV2h/6yBCZwjhveL2HUjjdI0x+qFB0I54Y=" ];
};
```
