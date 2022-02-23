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
          gnumake
                    
          (python3.withPackages (ps: with ps; [
            poetry
            ipython
            ipytho
          ]));
        ];
      in
      rec {
        # `nix develop`
        devShell = with pkgs; mkShell {
          buildInputs = tools;
        };

        defaultPackage = with pkgs.poetry2nix; mkPoetryApplication {
          projectDir = ./.;
          preferWheels = true;
        };
      });
}
