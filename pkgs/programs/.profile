if [ -e $HOME/.nix-profile/etc/profile.d/nix.sh ]; then 
    . $HOME/.nix-profile/etc/profile.d/nix.sh;
fi

export XDG_DATA_DIRS=$HOME/.nix-profile/share:/usr/local/share/:/usr/share/