{
  description = "Python Project Template";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils }:
    utils.lib.eachDefaultSystem (system:
      let
        version = "0.0.1";
        pkgs = import nixpkgs {
          inherit system;
        };
        tools = with pkgs; [
          # pipenv
          python3Packages.poetry
          python3Packages.ipython
          mypy
          # nodePackages.pyright
        ];
      in
      rec {
        # `nix develop`
        devShell = with pkgs; mkShell {
          buildInputs = [ python3 ] ++ tools;
        };

        defaultPackage = with pkgs.poetry2nix; mkPoetryApplication {
            projectDir = ./.;
            preferWheels = true;
        };
      });
}
