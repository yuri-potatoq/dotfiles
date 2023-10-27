{ pkgs, lib, config, ... }:

let
  complete-alias = builtins.fetchGit {
    url = "https://github.com/cykerway/complete-alias";
    rev = "b16b183f6bf0029b9714b0e0178b6bd28eda52f3";
  };
  tab-completion = builtins.fetchGit {
    url = "https://github.com/lincheney/fzf-tab-completion";
    rev = "53eb325f573265a6105c9bd0aa56cd865c4e14b7";
  };
in
{
  fonts.fontconfig = {
    enable = true;
  }; 

  home.packages = with pkgs ; [
    fzf
    tree
    entr
    fd
    ripgrep

    # cloud cli
    awscli2
    kubectl
    google-cloud-sdk
    
    # dev
    python3Packages.ipython

    # apply customized font
    (nerdfonts.override { fonts = [ "FiraCode" "FiraMono" "DroidSansMono" ]; })
  ];

  # tmux config
  programs.tmux = {
    enable = true; 
    extraConfig = builtins.readFile ./tmux.conf;
    prefix = "C-a";
    plugins = with pkgs; [
      tmuxPlugins.resurrect
    ];
  };

  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      format = lib.concatStrings [
        "$directory"
        "$git_branch"
        "$git_status"

        # langs
        "$python"
        "$rust"
        "$golang"
        "$kotlin"
        "$nodejs"
        "$ocaml"
        "$java"

        "$docker_context"
        "$nix_shell"
        "$time"
        "$line_break"
        "$status"
        "$character"
      ];
      nix_shell = {
        symbol = "❄️ ";
      };

      git_branch = {
        symbol = "🌱 ";
      };

      time = {
        disabled = false;
      };
    };
  };

  programs = {
    bash = {
      enable = true;
      historySize = 10000;
      shellOptions = [
        # Auto cd to directories
        "autocd"

        # Append to history file rather than replacing it.
        "histappend"

        # check the window size after each command and, if
        # necessary, update the values of LINES and COLUMNS.
        "checkwinsize"

        # Extended globbing.
        "extglob"
        "globstar"

        # Warn if closing shell with running jobs.
        "checkjobs"
      ];

      historyControl = [
        "erasedups"
        "ignoredups"
        "ignorespace"
      ];

      shellAliases = {
        c = "clear";
        b = "cd -";
        se = "sudoedit";
        ns = "nix-shell -p";
        ll = "ls -aHl";
        nix-fmt = ''
          nix-shell -p nixpkgs-fmt --run "nixpkgs-fmt ."
        '';
        ni = ''
          nix-shell -p nix-info --run "nix-info -m"
        '';
      };

      # TODO: These don't get loaded when using a display manager.
      # workaround: Link ~/.profile to ~/.xprofile
      sessionVariables = {
        EDITOR = "vim";
        FZF_DEFAULT_OPTS = ''--prompt \" λ \"'';
        TERM = "xterm-256color";
      };

      # profileExtra = builtins.readFile ./.profile;
      profileExtra = ''
        [ -f $HOME/.nix-profile/etc/profile.d/nix.sh ] && . $HOME/.nix-profile/etc/profile.d/nix.sh

        if [ -d "$HOME/.local/bin" ] ; then
          PATH="$HOME/.local/bin:$PATH"
        fi

        # useful for showing icons on non-NixOS systems
        export XDG_DATA_DIRS=$HOME/.nix-profile/share:$XDG_DATA_DIRS
      '';
    };

  };
}
