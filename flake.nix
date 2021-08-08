{
    description = "My little potato flake";

    inputs = {
        home-manager.url = "github:nix-community/home-manager";
    };

    outputs = { self, nixpkgs, home-manager }: {
        homeConfigurations = {
            main = home-manager.lib.homeManagerConfiguration {
                configuration = ./home-manager/home.nix;
                system = "x86_64-linux";
                homeDirectory = "/home/potatoq";
                username = "potatoq";
            };       
        };
    };
}
