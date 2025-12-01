{
  description = "Converter for the OPB format to be used by pbcount";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    crane.url = "github:ipetkov/crane/v0.21.2";
  };

  outputs =
    {
      self,
      nixpkgs,
      fenix,
      crane,
      ...
    }:
    let
      lib = nixpkgs.lib;

      # All supported build systems.
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];
    in
    {
      formatter = lib.genAttrs systems (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);
      packages = lib.genAttrs systems (
        system:
        let
          # Shorthands for different package sets.
          pkgs = nixpkgs.legacyPackages.${system};
          pkgsStatic = pkgs.pkgsStatic;
        in
        {
          default = pkgsStatic.callPackage ./default.nix {
            craneLibDefault = crane.mkLib pkgs;
            inherit fenix;
          };
        }
      );
      checks = lib.genAttrs systems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};

          defaultAttrs = {
            craneLibDefault = crane.mkLib pkgs;
            inherit fenix;
          };
        in
        {
          format = pkgs.callPackage ./default.nix (defaultAttrs // { format = true; });
          lint = pkgs.callPackage ./default.nix (defaultAttrs // { lint = true; });
        }
      );
    };
}
