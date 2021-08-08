{ config, pkgs, ... }:

{

  imports = [
      ./editors/codium.nix
      # ./editos/vim.nix

      # TODO: ....
  ];
  # home-manager.useUserPackages = true;
  # home-manager.useGlobalPkgs = true;
  # home-manager.users.potatoq = {    

  #   programs.home-manager.enable = true;

  #   home.username = "potatoq";
  #   home.homeDirectory = "/home/potatoq"; 

  #   home.stateVersion = "21.11";
  # };
}
