{
  description = "My little potato flake";

  inputs = {
    home-manager.url = "github:nix-community/home-manager";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, home-manager }@inputs :
    let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
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
