{ pkgs, ... }:

{
  programs.git = {
      enable = true;
      package = pkgs.gitFull;

      settings.user.name = "Yuri Lemos Rodrigues";
      settings.user.email = "yuri.ylr@outlook.com";
    };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
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
}