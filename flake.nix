{
  description = "My little potato flake";

  inputs = {
    home-manager.url = "github:nix-community/home-manager";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, home-manager }: let pkgs = import nixpkgs {system="x86_64-linux";}; in {
    homeConfigurations = {
      potatoq = home-manager.lib.homeManagerConfiguration {
        configuration = ./pkgs/home.nix;
        system = "x86_64-linux";
        homeDirectory = "/home/potatoq";
        username = "potatoq";
	
	extraSpecialArgs = {
		inherit pkgs;
	};

      };
    };
  };
}
