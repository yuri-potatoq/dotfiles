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
      slack

      # misc
      bitwarden

      # browser
      google-chrome

      # minecraft launcher
      polymc
    ] ++ jetbrains-ides;
}
