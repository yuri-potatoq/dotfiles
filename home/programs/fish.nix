{ pkgs, lib, config, ... }:
{
  fonts.fontconfig = {
    enable = true;
  };

  # Rebuild fontconfig cache after switching generations so native apps
  # (e.g. Alacritty installed via pacman) can find Nix-managed fonts
  # without stale store paths causing "Cannot open resource" warnings.
  home.activation.refreshFontCache = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${pkgs.fontconfig}/bin/fc-cache -fv
  '';

  home.packages = with pkgs; [
    fzf
    tree
    entr
    fd
    jq
    ripgrep
    lazygit
    # cloud cli
    # awscli2
    #kubectl
    # google-cloud-sdk
    # dev
    claude-code
    python3Packages.ipython
    # nerd fonts
    nerd-fonts.fira-code
    nerd-fonts.fira-mono
    nerd-fonts.droid-sans-mono
    # alacritty wrapper: prefer native binary, fall back to Nix
    (writeShellScriptBin "alacritty" ''
      if [ -x /usr/bin/alacritty ]; then
        exec /usr/bin/alacritty "$@"
      else
        exec ${alacritty}/bin/alacritty "$@"
      fi
    '')
  ];

  # tmux config
  programs.tmux = {
    enable = true;
    extraConfig = builtins.readFile ./tmux.conf;
    prefix = "C-a";
    plugins = with pkgs.tmuxPlugins; [
      resurrect
      sensible
      dracula
    ];
  };

  programs.fzf = {
    enable = true;
    enableFishIntegration = true;  # changed from enableBashIntegration
  };

  programs.starship = {
    enable = true;
    enableFishIntegration = true;  # changed from default bash
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

  # Alacritty terminal (prefer native binary, fall back to Nix)
  xdg.configFile."alacritty/alacritty.toml".source =
    (pkgs.formats.toml { }).generate "alacritty.toml" {
      terminal.shell = {
        program = "${pkgs.tmux}/bin/tmux";
        args = [ "new-session" "-A" "-s" "main" ];
      };
      font = {
        normal = {
          family = "FiraCode Nerd Font";
          style = "Regular";
        };
        bold = {
          family = "FiraCode Nerd Font";
          style = "Bold";
        };
        size = 13.0;
      };
      window = {
        padding = { x = 8; y = 8; };
        decorations = "Full";
        opacity = 1.0;
      };
      colors = {
        primary = {
          background = "0x282a36";
          foreground = "0xf8f8f2";
        };
        cursor = {
          text   = "0x282a36";
          cursor = "0xf8f8f2";
        };
        normal = {
          black   = "0x000000";
          red     = "0xff5555";
          green   = "0x50fa7b";
          yellow  = "0xf1fa8c";
          blue    = "0xcaa9fa";
          magenta = "0xff79c6";
          cyan    = "0x8be9fd";
          white   = "0xbfbfbf";
        };
        bright = {
          black   = "0x4d4d4d";
          red     = "0xff6e67";
          green   = "0x5af78e";
          yellow  = "0xf4f99d";
          blue    = "0xcaa9fa";
          magenta = "0xff92d0";
          cyan    = "0x9aedfe";
          white   = "0xe6e6e6";
        };
      };
    };

  programs.fish = {
    enable = true;

    # Equivalent to bash shellAliases
    shellAliases = {
      c   = "clear";
      b   = "cd -";
      se  = "sudoedit";
      ns  = "nix-shell -p";
      ll  = "ls -aHl";
      lg  = "lazygit";
      nix-fmt = "nix-shell -p nixpkgs-fmt --run 'nixpkgs-fmt .'";
      ni      = "nix-shell -p nix-info --run 'nix-info -m'";
    };

    # Equivalent to bash sessionVariables
    # In fish, env vars are set via `set -gx` in interactiveShellInit
    interactiveShellInit = ''
      set -gx EDITOR hx
      set -gx TERMINAL alacritty
      set -gx FZF_DEFAULT_OPTS '--prompt " λ "'
      set -gx TERM xterm-256color

      # Suppress the default fish greeting
      set -g fish_greeting ""
    '';

    # Equivalent to bash profileExtra — runs at login (fish login shell)
    loginShellInit = ''
      # Source nix profile if available (important on non-NixOS)
      if test -f $HOME/.nix-profile/etc/profile.d/nix.sh
        fenv source $HOME/.nix-profile/etc/profile.d/nix.sh
      end

      # Add ~/.local/bin to PATH
      if test -d $HOME/.local/bin
        fish_add_path $HOME/.local/bin
      end

      # Useful for showing icons on non-NixOS systems
      set -gx XDG_DATA_DIRS $HOME/.nix-profile/share $XDG_DATA_DIRS
    '';

    # fish_add_path is idempotent, so this is safe to keep here too
    shellInit = ''
      fish_add_path $HOME/.local/bin
    '';

    # fenv lets fish source bash/sh scripts (needed for nix.sh above)
    plugins = [
      {
        name = "foreign-env";
        src = pkgs.fishPlugins.foreign-env.src;
      }
      {
        name = "fzf-fish";
        src = pkgs.fishPlugins.fzf-fish.src;
      }
    ];
  };
}

