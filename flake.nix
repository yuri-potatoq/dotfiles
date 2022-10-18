{
  description = "My little potato flake";

  inputs = {
    home-manager.url = "github:nix-community/home-manager";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    polymc.url = "github:PolyMC/PolyMC";

    emacs = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixDoomEmacs = {
      url = "github:nix-community/nix-doom-emacs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs :
    let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [ 
          inputs.polymc.overlay
          inputs.emacs.overlay
        ];
      };
      system = "x86_64-linux";
      username = "potatoq";
    in
    {
      homeConfigurations = {
        "${username}" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          modules = [
            ./home/home.nix

            ({ pkgs, ... }: {
              home.packages = with pkgs; [
                (callPackage ./pkgs/fzf-pods.nix { inherit pkgs; })
              ];
            })
          ];

          extraSpecialArgs = {
            inherit inputs pkgs username;
          };
        };
      };
      templates = import ./templates;
    };
}
