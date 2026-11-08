# asahix

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

## Binary Cache

Prebuilt store paths are pushed to `https://asahix.cachix.org`. Add it to your substituters to avoid building locally:

```nix
nix.settings = {
  substituters = [ "https://asahix.cachix.org" ];
  trusted-public-keys = [ "asahix.cachix.org-1:SDzLl9HW7kV2h/6yBCZwjhveL2HUjjdI0x+qFB0I54Y=" ];
};
```

## Automatic kernel updates

Every Monday at 07:00 UTC, the update workflow checks the upstream fairydust
branch. When it changes, the workflow updates `package.nix`, commits directly to
`dev`, and starts the build/cache workflow. No pull request or manual merge is
required. You can also run it manually from GitHub Actions.

The workflow uses the built-in `GITHUB_TOKEN` with contents and actions write
permissions; `UPDATE_BOT_TOKEN` is no longer needed. Branch protection or rulesets
must permit the workflow to push directly to `dev`.
