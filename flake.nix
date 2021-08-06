{
    description = "My little potato flake";

    inputs = {
        home-manager.url = "github:nix-community/home-manager";
    };

    outputs = { self, nixpkgs, home-manager }: {

        nixosConfigurations.desktop = nixpkgs.lib.nixosSystem rec {
            system = "x86_64-linux";
            modules = [
                ./pkgs/home.nix

                home-manager.nixosModules.home-manager
            ];
        };
        packages.x86_64-linux.hello = nixpkgs.legacyPackages.x86_64-linux.hello;

        defaultPackage.x86_64-linux = self.packages.x86_64-linux.hello;

    };
}
