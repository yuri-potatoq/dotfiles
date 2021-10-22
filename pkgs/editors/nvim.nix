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

    plugins = with pkgs.vimPlugins; [
      vim-noctu
      telescope-nvim
      vim-polyglot
    ];

    extraConfig = '' 
      colorscheme noctu
        set rnu
        set nu

        " key bindings

        nnoremap <space> <nop>

        let mapleader=" "

        " Find files using Telescope command-line sugar.

        nnoremap <leader>ff <cmd>Telescope find_files<cr>
        nnoremap <leader>fg <cmd>Telescope live_grep<cr>
        nnoremap <leader>fb <cmd>Telescope buffers<cr>
        nnoremap <leader>fh <cmd>Telescope help_tags<cr>
        '';
  };
}
