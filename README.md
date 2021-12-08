# dotfiles


*Enable experimental features*
```sh
# ~/.config/nix or /etc/nix/nix.conf

$ mkdir ~/.config/nix && echo "experimental-features = nix-command flakes" >> $_/nix.conf
```

*Declarative way to switch modifications*
```sh
$ nix build '.#homeConfigurations.potatoq.activationPackage' && ./result/activate
```
