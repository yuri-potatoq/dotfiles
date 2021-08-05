{ config, pkgs, ... }:

{

  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;
  home-manager.users.potatoq = {
    imports = [
      ./editos/codium.nix
      # ./editos/vim.nix

      # TODO: ....
    ];

  programs.home-manager.enable = true;

  home.username = "potatoq";
  home.homeDirectory = "/home/potatoq"; 

  home.stateVersion = "21.11";

}
