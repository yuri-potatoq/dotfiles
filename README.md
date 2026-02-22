# dotfiles


*Enable experimental features*
```sh
# ~/.config/nix or /etc/nix/nix.conf

$ mkdir -p ~/.config/nix && echo "experimental-features = nix-command flakes" >> $_/nix.conf
```

*Declarative way to switch modifications*
```sh
# use HOME_MANAGER_BACKUP_EXT=backup to let nix backup old config files
$ nix build '.#homeConfigurations.potatoq.activationPackage' && HOME_MANAGER_BACKUP_EXT=backup ./result/activate
```

## KDE Plasma Configuration

KDE Plasma 6 desktop settings are managed declaratively via [plasma-manager](https://github.com/nix-community/plasma-manager) in `home/desktop/kde.nix`.

### What's managed

- Workspace appearance (Breeze Dark look-and-feel, Layan plasma theme, Papirus-Dark icons)
- KWin effects (blur, translucency, Layan aurorae window decoration)
- Panel layout (widgets, system monitors, hiding behavior)
- Keyboard shortcuts
- General settings (terminal, fonts, locale, file indexing)

### Themes and icons (offline derivations)

Themes are fetched by Nix at **build time**, not downloaded by KDE at runtime:

- **Layan KDE theme** is a custom Nix derivation that fetches from [vinceliuice/Layan-kde](https://github.com/vinceliuice/Layan-kde) during `nix build`. It installs the plasma desktop theme, aurorae window decoration, and color scheme into the nix store.
- **Papirus-Dark icons** come from nixpkgs (`pkgs.papirus-icon-theme`) and are downloaded from the Nix binary cache.

Both are installed into `~/.nix-profile/share/` and KDE discovers them via `XDG_DATA_DIRS`. After the initial build, everything is fully offline.

### Pre-activation backup

Every activation automatically backs up your current KDE config files **before** plasma-manager overwrites them. Backups are saved to:

```
~/kde-config-backup/pre-activate-YYYYMMDD-HHMMSS/
```

This includes `kdeglobals`, `kwinrc`, `plasmarc`, `plasmashellrc`, `kglobalshortcutsrc`, panel applet config, and other KDE files. If something goes wrong, you can restore any file from the timestamped backup directory.

### Syncing manual KDE changes back to Nix

When you make changes through KDE System Settings (themes, shortcuts, panel tweaks, etc.), those changes live in `~/.config/` and are **not** automatically reflected in the Nix config. To capture them:

1. Run `rc2nix` to generate a Nix expression from your current KDE config:
   ```sh
   nix run github:nix-community/plasma-manager#rc2nix > /tmp/rc2nix-output.nix
   ```

2. Diff the output against your current `home/desktop/kde.nix` to see what changed.

3. Update `kde.nix` with the settings you want to keep.

This is necessary because the raw KDE config files contain many auto-generated and session-specific keys that don't belong in a declarative config. `rc2nix` is the bridge between KDE's imperative config and the Nix declarative model.

> **Tip**: After making changes in KDE System Settings, also compare the raw config files against the pre-activation backup to quickly spot what changed:
> ```sh
> diff ~/kde-config-backup/pre-activate-*/kdeglobals ~/.config/kdeglobals
> ```
