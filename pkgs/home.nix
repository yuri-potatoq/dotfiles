{ config, pkgs, ... }:

{
  imports = [
    ./editors/codium.nix
    ./editors/nvim.nix

    ./programs/langs.nix
    ./programs/bash.nix

    # TODO: ....
  ];

  programs = {
    bash.enable = true;
    home-manager.enable = true;
  };
}
