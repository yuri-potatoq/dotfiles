{ config, pkgs, ... }:

{

  imports = [
      ./editors/codium.nix
      # ./editos/vim.nix

      ./programs/docker.nix
      ./programs/haskell.nix
      ./programs/bash.nix

      # TODO: ....
  ];
  
  programs = {
    bash.enable = true;
    home-manager.enable = true;
    home-manager.path = https://github.com/rycee/home-manager/archive/release-18.03.tar.gz;
  };

  # home-manager.useUserPackages = true;
  # home-manager.useGlobalPkgs = true;
  # home-manager.users.potatoq = {    

  #   programs.home-manager.enable = true;

  #   home.username = "potatoq";
  #   home.homeDirectory = "/home/potatoq"; 

  #   home.stateVersion = "21.11";
  # };
}
