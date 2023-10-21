{
  description = "My little potato flake";

  inputs = {
    homeManager.url = "github:nix-community/home-manager";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    emacs = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, homeManager, ... }@inputs :
    let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          inputs.emacs.overlay
        ];
      };
      system = "x86_64-linux";
      username = "potatoq";
    in
    {
      homeConfigurations = {
        "${username}" = homeManager.lib.homeManagerConfiguration {
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
