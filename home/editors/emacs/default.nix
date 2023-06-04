{ inputs, pkgs, ... }:

let
  # snippet got from https://git.sr.ht/~glorifiedgluer/nix-config/tree/main/item/home/modules/emacs/default.nix
  emacsConfig = pkgs.writeTextDir "config/init.el" ''
    (load "${./init.el}")
  '';

  customEmacs = pkgs.emacsWithPackagesFromUsePackage {
    config = ./init.el;
    alwaysEnsure = true;
    package = pkgs.emacsUnstable;
    extraEmacsPackages = epkgs: with epkgs; [
      evil
      evil-leader
      evil-collection
      
      lsp-mode
      lsp-java
    ];
  };
in
{
  programs.emacs = {
    enable = true;
    package = customEmacs;
  };

  home.file.".emacs.d/init.el".source = ./init.el;
}
