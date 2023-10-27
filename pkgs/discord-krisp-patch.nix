{ pkgs }:


# Ref: https://github.com/surfaceflinger/flake/blob/2f7982c5584ed49266df5f031247d5537279dc3b/packages/krisp-patch/default.nix

let 
 writeShellApplication = pkgs.writeShellApplication;
 rizin = pkgs.rizin;               
 discord = pkgs.discord;
in writeShellApplication rec {
  name = "krisp-patch";

  runtimeInputs = [ rizin ];

  text = ''
    discord_version="${discord.version}"
    file="$HOME/.config/discord/$discord_version/modules/discord_krisp/discord_krisp.node"
    addr=$(rz-find -x '4881ec00010000' "$file" | head -n1)
    rizin -q -w -c "s $addr + 0x30 ; wao nop" "$file"
  '';
}
