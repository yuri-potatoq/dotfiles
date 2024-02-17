{ pkgs, ... }:

{
  programs.helix = {
    enable = true;
    
    
    extraPackages = with pkgs; [
      nil
      nodePackages.bash-language-server
    ];
    
    settings = {
      keys = {
        normal = {
          C-g = ":sh tmux popup -d \"#{pane_current_path}\" -xC -yC -w80% -h80% -E lazygit";
        };
      };
      theme = "ayu_mirage";
      editor = {
        line-number = "relative";
        gutters = ["diagnostics" "spacer" "line-numbers" "spacer" "diff"];
        auto-save = true;
        true-color = true;
        lsp = {
          display-messages = true;
        };
        whitespace = {
          characters = { space = "·"; tab = "→"; };
        };
        indent-guides = {
          render = true;
          character = "┊";
        };
      };
    };

    # ref: https://discourse.nixos.org/t/helix-lsp-servers/34833/3
    languages = { 
      language-server = {
         nil = {
          # command = "${inputs.nil.packages.${pkgs.system}.default}/bin/nil";          
          command = "nil";
          config.nil = {
            # formatting.command = [ "${nixpkgs-fmt}/bin/nixpkgs-fmt" ];          
            nix.flake.autoEvalInputs = true;
          };
        };
        metals = {
          command = "metals";
        };
      };
      language = [
        { name = "rust"; }
        { 
          name = "scala";
          language-servers = ["metals"];           
        }
        { name = "go"; }
        { 
          name = "nix";
          language-servers = ["nil"];
        }
        { name = "python"; }
        { 
          name = "clojure";
          language-servers = [ "clojure-lsp" ];
        } 
        { name = "dockerfile"; }
        { name = "gomod"; }
        { name = "html"; }
        { name = "java"; }
        { name = "json"; }
        { name = "just"; }
        { name = "kotlin"; }
        { name = "markdown"; }
        { name = "toml"; }
        { name = "sql"; }
        { name = "yaml"; }
      ];
    };

  };
}
