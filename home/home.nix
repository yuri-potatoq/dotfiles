{ config, pkgs, inputs, username, ... }:

{
  imports = [
    # editors
    ./editors/codium.nix
    ./editors/nvim
    ./editors/helix
    #./editors/emacs

    ./programs/third-party.nix
    ./programs/podman.nix

    # cli
    ./programs/bash.nix
    ./programs/git.nix
  ];

  # home config
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "23.11";

  programs = {
    bash.enable = true;
    home-manager.enable = true;
    git.enable = true;
  };

  nix.registry.nixpkgs.flake = inputs.nixpkgs;
  nix.package = pkgs.nixUnstable;
}
