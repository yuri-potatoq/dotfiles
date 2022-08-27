{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    withNodeJs = true;
    withPython3 = true;
    withRuby = true;
    
    extraPackages = with pkgs; [
      # LSPs
      gopls
      nodePackages.bash-language-server
      nodePackages.vscode-langservers-extracted
      nodePackages.yaml-language-server
      nodePackages.pyright
      rnix-lsp
      rust-analyzer
      ocamlPackages.ocaml-lsp
    ];

    plugins = with pkgs.vimPlugins; [
      vim-noctu
      telescope-nvim
      vim-polyglot

      # lsp
      nvim-lspconfig

      # Completion
      nvim-cmp
      cmp-nvim-lsp
      cmp-nvim-lsp-signature-help
      cmp-buffer
      cmp-path
      cmp-cmdline
      cmp-nvim-lua
      cmp-emoji
      luasnip
      cmp_luasnip
    ];

    extraConfig = ''
      colorscheme noctu
      set rnu
      set nu

      " key bindings

      nnoremap <space> <nop>

      let mapleader=" "

      lua require('init')
    '';
  };

  xdg.configFile = {
    "nvim/lua" = {
      source = ./lua;
      recursive = true;
    };
  };
}
