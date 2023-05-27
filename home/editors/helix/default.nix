{ pkgs, ... }:

{
  programs.helix = {
    enable = true;
    
    languages = [
      {
        auto-format = false;
        name = "rust";
      }
    ];

  };
}
