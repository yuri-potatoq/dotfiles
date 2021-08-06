{
    decription = "My Nix Entrypoint";

    inputs = {
        home-manager.url = "github:nix-community/home-manager";
    };

    outputs = { self, home-manager, nur, nixpkgs, ... }@inputs: {
        nixosConfigurations.desktop = nixpkgs.lib.nixosSystem rec {
            system = "x86_64-linux";
            modules = [
                ./home.nix
            ];        
        };
  };

}