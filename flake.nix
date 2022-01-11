{
  description = "My little potato flake";

  inputs = {
    home-manager.url = "github:nix-community/home-manager";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, home-manager }:
    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
      username = "potatoq";
    in
    {
      homeConfigurations = {
        "${username}" = home-manager.lib.homeManagerConfiguration {
          inherit username system;

          configuration = ./pkgs/home.nix;
          homeDirectory = "/home/${username}";

          extraSpecialArgs = {
            inherit pkgs;
          };
        };
      };

      templates = import ./templates;
    };
}
