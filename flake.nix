{
    decription = "My Nix Entrypoint";

    inputs = {
        home-manager.url = "github:nix-community/home-manager";
    };

    outputs = { self, nixpkgs }: {

    defaultPackage.x86_64-linux = with import nixpkgs { system = "x86_64-linux"; };
        stdenv.mkDerivation {
            name = "hello";
            src = self;
            buildPhase = "gcc -o hello ./hello.c";
            installPhase = "mkdir -p $out/bin; install -t $out/bin hello";
        };
  };

}