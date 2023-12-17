{ pkgs, ... }:

{
  programs.helix = {
    enable = true;
    
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

    languages = { 
      language = [
        { name = "rust"; }
        { name = "scala"; }
        { name = "go"; }
        { name = "nix"; }
        { name = "python"; }
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
