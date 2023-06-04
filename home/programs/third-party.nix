{ super, pkgs, ... }:

{
  home.packages =
    let
      jetbrains-ides = with pkgs.jetbrains; [
        idea-community
        pycharm-community
      ];
    in
    with pkgs; [
      # chat
      discord

      # misc
      bitwarden

      # browser
      google-chrome
    ] ++ jetbrains-ides;
}
