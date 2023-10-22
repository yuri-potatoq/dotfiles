{ super, pkgs, ... }:

{
  home.packages =
    let
      jetbrains-ides = with pkgs.jetbrains; [
        idea-ultimate
        rider
        goland
        pycharm-professional
      ];
    in
    with pkgs; [
      # chat
      discord

      # misc
      bitwarden

      # browser
      google-chrome

#      prismlauncher
    ] ++ jetbrains-ides;
}
