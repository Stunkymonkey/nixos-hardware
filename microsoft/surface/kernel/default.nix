{ config, lib, pkgs, ... }:

# To test the kernel build:
# nix-build -E "with import <nixpkgs> {}; (pkgs.callPackage ./. {}).boot.kernelPackages.kernel"

let
  inherit (lib) kernel recurseIntoAttrs;
  inherit (pkgs) buildLinux linuxPackagesFor;
  repos = pkgs.callPackage ../repos.nix {};

  linuxPackage =
    { version,
      modDirVersion ? version,
      branch,
      src,
      kernelPatches ? [],
      ...
    }: let
      buildLinux' = buildLinux {
        inherit version src kernelPatches;
        modDirVersion = version;
        extraMeta.branch = branch;
      };
      linuxPackagesFor' = linuxPackagesFor buildLinux';
    in recurseIntoAttrs linuxPackagesFor';

  linux-5_19_17 = linuxPackage (
    pkgs.callPackage ./linux-5.19.17.nix { inherit repos; }
  );

  linux-6_0_11 = linuxPackage (
    pkgs.callPackage ./linux-6.0.11.nix { inherit repos; }
  );

in {
  boot.kernelPackages = linux-6_0_11;
}
