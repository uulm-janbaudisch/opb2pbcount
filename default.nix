{
  format ? false,
  lint ? false,
  craneLibDefault,
  fenix,
  stdenv,
  lib,
}:
let
  target = stdenv.targetPlatform.rust.rustcTarget;

  toolchain =
    pkgs:
    let
      system = pkgs.stdenv.buildPlatform.system;
    in
    fenix.packages.${system}.combine [
      fenix.packages.${system}.stable.minimalToolchain
      fenix.packages.${system}.stable.rustfmt
      fenix.packages.${system}.stable.clippy
      fenix.packages.${system}.targets.${target}.stable.rust-std
    ];

  craneLib = craneLibDefault.overrideToolchain (p: toolchain p);
  metadata = craneLib.crateNameFromCargoToml { cargoToml = ./Cargo.toml; };

  craneAction =
    if format then
      "cargoFmt"
    else if lint then
      "cargoClippy"
    else
      "buildPackage";

  crate = {
    meta = {
      mainProgram = "opb2pbcount";
      description = "Converter for the OPB format to be used by pbcount";
      homepage = "https://github.com/uulm-janbaudisch/opb2pbcount.git";
      license = lib.licenses.lgpl3Plus;
      platforms = lib.platforms.unix;
    };

    pname = metadata.pname;
    version = metadata.version;

    src = craneLib.cleanCargoSource ./.;
    strictDeps = true;

    CARGO_BUILD_TARGET = target;
  };

  cargoArtifacts = craneLib.buildDepsOnly crate;
in
craneLib.${craneAction} (
  crate
  // {
    inherit cargoArtifacts;
    cargoClippyExtraArgs = "-- --deny warnings";
  }
)
