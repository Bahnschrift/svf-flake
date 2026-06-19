{
  description = "SVF";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages = rec {
          svf = pkgs.callPackage ./pkgs/svf.nix { };
          pysvf = pkgs.callPackage ./pkgs/pysvf.nix { inherit svf; };
          svfir = pkgs.callPackage ./pkgs/svfir.nix { inherit svf; };

          default = svf;
        };

        devShells.default = pkgs.mkShell {
          packages = with self.packages.${system}; [
            svf
            (pkgs.python3.withPackages (_: [ pysvf ]))
            svfir
          ];
        };
      }
    );
}
