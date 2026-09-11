{
  lib,
  stdenv,
  buildLinux,
  linuxPackagesFor,
  fetchFromGitHub,
}:
let
  # "Asahi config" values mirror apple-silicon-support/packages/linux-asahi/default.nix
  # from nixos-apple-silicon so the build matches the upstream helper.
  fairydust = buildLinux {
    inherit stdenv lib;

    pname = "linux-asahi";
    version = "7.1.13-fairydust";
    modDirVersion = "7.1.13-fairydust";
    extraMeta.branch = "7.1";

    src = fetchFromGitHub {
      owner = "AsahiLinux";
      repo = "linux";
      rev = "ce9f2eba72c061a50b2d790450e90af3439d8c24";
      hash = "sha256-W3yMSUe6xa+M/X0k86kbCS4g3d7jJmO3WV9L/5rQRhI=";
    };

    kernelPatches = [
      {
        name = "Asahi config";
        patch = null;
        structuredExtraConfig = with lib.kernel; {
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
        features.rust = true;
      }
      {
        name = "fairydust config";
        patch = null;
        structuredExtraConfig = with lib.kernel; {
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
        features.rust = true;
      }
    ];
  };
in
lib.recurseIntoAttrs (linuxPackagesFor fairydust)
