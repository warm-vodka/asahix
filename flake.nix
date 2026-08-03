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
        localSystem.system = system;
        crossSystem.system = system;
      };

      fairydustSrc = pkgs.fetchFromGitHub {
        owner = "AsahiLinux";
        repo = "linux";
        rev = "e3e35907c17a05773d481e58a566bf9108166cc5";
        hash = "sha256-hmxu1NcS3Ce8VpJahgZLs7mjh3ZBHq3sW5NVO3DqglU=";
      };

      # "Asahi config" values mirror apple-silicon-support/packages/linux-asahi/default.nix
      # from nixos-apple-silicon so the build matches the upstream helper.
      asahiConfig = with pkgs.lib.kernel; {
        # Needed for GPU
        ARM64_16K_PAGES = yes;

        ARM64_MEMORY_MODEL_CONTROL = yes;
        ARM64_ACTLR_STATE = yes;

        # Might lead to the machine rebooting if not loaded soon enough
        APPLE_WATCHDOG = yes;

        # Can not be built as a module, defaults to no
        APPLE_M1_CPU_PMU = yes;

        # Defaults to 'y', but we want to allow the user to set options in modprobe.d
        HID_APPLE = module;

        APPLE_PMGR_MISC = yes;
        APPLE_PMGR_PWRSTATE = yes;
      };

      fairydustConfig = with pkgs.lib.kernel; {
        RUST = yes;
        LOCALVERSION = freeform "-fairydust";

        DRM_ASAHI = module;
        DRM_APPLE = module;

        RUST_FW_LOADER_ABSTRACTIONS = yes;
        RUST_DRM_SCHED = yes;
        RUST_DRM_GEM_SHMEM_HELPER = yes;
        RUST_DRM_GPUVM = yes;
        RUST_APPLE_MAILBOX = yes;
        RUST_APPLE_RTKIT = yes;

        TYPEC_DP_ALTMODE = module;
        TYPEC_NVIDIA_ALTMODE = module;
        TYPEC_TBT_ALTMODE = module;
      };

      linuxAsahiFairydust = pkgs.buildLinux {
        inherit (pkgs) stdenv lib;

        pname = "linux-asahi";
        version = "7.1.5-fairydust";
        modDirVersion = "7.1.5-fairydust";
        extraMeta.branch = "7.1";

        src = fairydustSrc;

        kernelPatches = [
          {
            name = "Asahi config";
            patch = null;
            structuredExtraConfig = asahiConfig;
            features.rust = true;
          }
          {
            name = "fairydust config";
            patch = null;
            structuredExtraConfig = fairydustConfig;
            features.rust = true;
          }
        ];
      };
    in
    {
      packages.${system}.linux_asahi_fairydust = linuxAsahiFairydust;
    };
}
