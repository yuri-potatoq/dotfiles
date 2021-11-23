{
  # COPY FROM https://github.com/ratsclub/dotfiles

  # nix flake init -t github:yuri-potatoq/dotfiles#templates.<type>
  rust = {
    description = "Rust Project Template";
    path = ./rust;
  };

  go = {
    description = "Go Project Template";
    path = ./go;
  };

  python = {
    description = "Python Project Template";
    path = ./python;
  };
}
