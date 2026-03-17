{
  description = "My little potato flake";

  inputs = {
    homeManager.url = "github:nix-community/home-manager";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "homeManager";
    };

    # emacs = {
    #   url = "github:nix-community/emacs-overlay";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };

  outputs = { self, nixpkgs, homeManager, plasma-manager, ... }@inputs :
    let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        # overlays = [
        #   inputs.emacs.overlay
        # ];
      };
      system = "x86_64-linux";
      username = "potatoq";
    in
    {
      homeConfigurations = {
        "${username}" = homeManager.lib.homeManagerConfiguration {
          inherit pkgs;

          modules = [
            plasma-manager.homeModules.plasma-manager
            ./home/home.nix

            ({ pkgs, ... }: {
              home.packages = with pkgs; [
                (callPackage ./pkgs/fzf-pods.nix { inherit pkgs; })
                (callPackage ./pkgs/discord-krisp-patch.nix { inherit pkgs; })
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
