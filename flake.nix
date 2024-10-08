{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?rev=9f4128e00b0ae8ec65918efeba59db998750ead6";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix/fix-214";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-darwin" "x86_64-darwin" ];
      imports = [
        inputs.treefmt-nix.flakeModule
      ];
      perSystem = { system, config, pkgs, ... }:
        {
          devShells.default = pkgs.mkShell {
            packages = [ pkgs.esphome ];
            inputsFrom = [
              config.treefmt.build.devShell
            ];
          };

          treefmt.config = {
            projectRootFile = "flake.nix";

            programs = {
              nixpkgs-fmt.enable = true;
              # yamlls uses prettier under the hood but it might change https://github.com/redhat-developer/yaml-language-server/issues/933
              prettier.enable = true;
            };
          };
        };
    };
}

