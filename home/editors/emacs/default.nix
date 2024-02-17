{ inputs, pkgs, ... }:

let
  # snippet got from https://git.sr.ht/~glorifiedgluer/nix-config/tree/main/item/home/modules/emacs/default.nix
  emacsConfig = pkgs.writeTextDir "config/init.el" ''
    (load "${./init.el}")
  '';

  customEmacs = pkgs.emacs29.override {
    withTreeSitter = true;
  };
in
{
  programs.emacs = {
    enable = true;
    package = customEmacs;
    extraPackages = epkgs: with epkgs; [ 
      # lsp stuff
      fsharp-mode
      nix-mode
      lsp-mode
      rustic
      treesit-grammars.with-all-grammars
      flycheck
      treemacs

      # theme
      kaolin-themes
      
      # keybinds
      evil
      company
      which-key

      # git
      magit
    ];
  };

  home.file.".emacs.d/init.el".source = ./init.el;
}
