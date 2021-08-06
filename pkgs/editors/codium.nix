{pkgs, ...}:

{
  programs = {
    vscode = {
      enable = true;
      package = pkgs.vscodium;
      userSettings = {
        # auto update tags when edited
        "editor.linkedEditing" = true;
        "editor.rulers" = [ 72 79 ];
        "editor.formatOnSave" = true;

        "workbench.colorTheme" = "GitHub Dark";
        "workbench.iconTheme" = "material-icon-theme";

        "window.titleBarStyle" = "custom";
        "window.zoomLevel" = 0;
        "terminal.integrated.tabs.enabled" = true;
        "[html]" = {
          "editor.defaultFormatter" = "esbenp.prettier-vscode";
        };
        "nix.enableLanguageServer" = true;
      };
      extensions = with pkgs.vscode-extensions; [
        # Theme
        github.github-vscode-theme

        # Icons
        pkief.material-icon-theme

        # Nix
        jnoortheen.nix-ide

        # Go
        golang.go

        # Python
        ms-python.python

        # Rust
        matklad.rust-analyzer

        # Markdown
        foam.foam-vscode
        svsool.markdown-memo
        yzhang.markdown-all-in-one

        # Misc
        eamodio.gitlens
        esbenp.prettier-vscode
      ];
    };
  };
}