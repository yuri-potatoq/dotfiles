{pkgs, ...}:

{
    home.packages = with pkgs ; [
        # Haskell
        ghc
        stack
        cabal-install

        # Ocaml
        opam
        ocaml
        # ocaml-nox
    ];
}