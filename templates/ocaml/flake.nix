{
  description = "Ocaml project template.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils }: utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        inherit system;
      };
      project-name = "project-name";

      # Legacy packages that have not been converted to flakes
      legacyPackages = nixpkgs.legacyPackages.${system};
      # OCaml packages available on nixpkgs
      ocamlPackages = legacyPackages.ocamlPackages;
    in
    rec {
      # Used by `nix develop`
      devShell = with legacyPackages; mkShell {
        buildInputs = [
          # Source file formatting
          legacyPackages.nixpkgs-fmt
          legacyPackages.ocamlformat
          # For `dune build --watch ...`
          legacyPackages.fswatch          
          # OCaml editor support
          ocamlPackages.ocaml-lsp
          # Nicely formatted types on hover
          ocamlPackages.ocamlformat-rpc-lib
          # Fancy REPL thing
          ocamlPackages.utop
        ];

        nativeBuildInputs = [
          ocamlPackages.dune_3
          ocamlPackages.ocaml
          # For `dune build @doc`
          ocamlPackages.odoc
        ];
      };
    }
  );
}
