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
  home.packages = with pkgs ; [
    fzf
  ];

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
      };

      # TODO: These don't get loaded when using a display manager.
      # workaround: Link ~/.profile to ~/.xprofile
      sessionVariables = {
        EDITOR = "vim";
        FZF_DEFAULT_OPTS = ''--prompt \" λ \"'';
      };

      profileExtra = builtins.readFile ./.profile;
    };

    git = {
      enable = true;
      package = pkgs.gitFull;

      userName = "Yuri Lemos Rodrigues";
      userEmail = "yuri.ylr@outlook.com";

      delta = {
        enable = true;
        options = {
          features = "side-by-side line-numbers decorations";
          syntax-theme = "GitHub";
          decorations = {
            commit-decoration-style = "bold yellow box ul";
            file-style = "bold yellow ul";
            file-decoration-style = "none";
            hunk-header-decoration-style = "cyan box ul";
          };
          delta = {
            navigate = true;
          };
          line-numbers = {
            line-numbers-left-style = "cyan";
            line-numbers-right-style = "cyan";
            line-numbers-minus-style = 124;
            line-numbers-plus-style = 28;
          };
        };
      };
    };
  };
}
