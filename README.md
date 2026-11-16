<div align=center>
  <h1>asahix</h1>
</div>

## NixOS

Import the NixOS module to configure the binary cache and add the kernel overlay,
then select the fairydust kernel package set:

```nix
{
  inputs.asahix.url = "github:skiletro/asahix";

  outputs = { self, nixpkgs, asahix }: {
    nixosConfigurations.mymac = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        asahix.nixosModules.default
        ({ pkgs, ... }: {
          boot.kernelPackages = pkgs.linuxPackages_asahi-fairydust;
        })
      ];
    };
  };
}
```

The module does not change `boot.kernelPackages` automatically. It adds the
Asahix cache alongside your existing substituters and trusted public keys.

For overlay-only use, add `asahix.overlays.default` to `nixpkgs.overlays`; this
provides `pkgs.linuxPackages_asahi-fairydust` without configuring the cache.
The package set is also available directly as
`asahix.packages.aarch64-linux.linuxPackages_asahi-fairydust`.

All three interfaces expose the same kernel package set, constructed with
Asahix's pinned nixpkgs rather than the consumer's nixpkgs. This keeps the
default overlay and module aligned with the derivation built and cached by CI,
even when your system uses a different nixpkgs revision. Consumer overlays and
nixpkgs configuration do not implicitly customize this package set.

Keep Asahix's nixpkgs input at its locked revision to use the cached build.
Overriding that input, including making it follow your system's nixpkgs input,
can change the derivation and require a local build.

### Package rename

`packages.aarch64-linux.linux_asahi_fairydust` has been renamed to
`packages.aarch64-linux.linuxPackages_asahi-fairydust` because it is a kernel
package set, not just a kernel derivation. Accessing the old name fails with a
migration assertion. Use `.kernel` on the new package set when building only the
kernel:

```console
nix build github:skiletro/asahix#packages.aarch64-linux.linuxPackages_asahi-fairydust.kernel
```

## Binary Cache

Prebuilt store paths are pushed to `https://asahix.cachix.org`. The NixOS module
above configures this automatically. Without the module, add the cache manually:

```nix
nix.settings = {
  substituters = [ "https://asahix.cachix.org" ];
  trusted-public-keys = [ "asahix.cachix.org-1:SDzLl9HW7kV2h/6yBCZwjhveL2HUjjdI0x+qFB0I54Y=" ];
};
```

## Automatic Kernel Updates

Every Monday at 07:00 UTC, the update workflow checks the upstream fairydust
branch. When it changes, the workflow updates `package.nix`, commits directly to
`dev`, and starts the build/cache workflow.
