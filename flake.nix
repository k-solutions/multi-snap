# SPDX-FileCopyrightText: 2021 Serokell <https://serokell.io/>
#
# SPDX-License-Identifier: CC0-1.0

{
  description = "Multy-snap is tool to execute multiple system tools and collect and analyze results";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    hls = { 
      url = "github:haskell/haskell-language-server";
      inputs.nixpkgs.follows = "nixpkgs";
    };  
  };

  outputs = { self, nixpkgs, flake-utils, hls }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        haskellPackages = pkgs.haskellPackages;
        
        jailbreakUnbreak = pkg:
          pkgs.haskell.lib.doJailbreak (pkg.overrideAttrs (_: { meta = { }; }));

          packageName = "multy-snap";
          
          hlsFlake = hls.defaultPackage.${system};
      in {
        packages.${packageName} =
          haskellPackages.callCabal2nix packageName self rec {
            # Dependency overrides go here
          };

        defaultPackage = self.packages.${system}.${packageName};

        devShell = pkgs.mkShell {
          buildInputs = with haskellPackages; [
            hlsFlake
            stack
            cabal-install
          ];
          inputsFrom = builtins.attrValues self.packages.${system};
        };
      });
}
