# Nix Setup on Non-NixOS Systems

This document explains how to configure Nix on non-NixOS systems (like CachyOS, Arch, Ubuntu, etc.) to work with binary caches and flakes.

## System-Level Configuration

Since home-manager cannot modify system-level Nix settings, you need to manually configure `/etc/nix/nix.conf`.

### Required `/etc/nix/nix.conf` Content

Replace or merge the following into `/etc/nix/nix.conf`:

```conf
build-users-group = nixbld
max-jobs = auto
cores = 0
max-substitution-jobs = 8

# Allow your user to use custom substituters and flakes
trusted-users = root potatoq

# Enable flakes and nix-command
experimental-features = nix-command flakes

# Binary caches (substituters)
substituters = https://cache.nixos.org https://nix-community.cachix.org https://crane.cachix.org
trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCUSeBo= crane.cachix.org-1:8Scfpmn9w+hGdXH/Q9tTLiYAE/2dnJYRJP7kl80GuRk=
```

### How to Apply

```bash
# Backup existing config
sudo cp /etc/nix/nix.conf /etc/nix/nix.conf.backup

# Edit the config
sudo nano /etc/nix/nix.conf  # or use your preferred editor

# Restart nix daemon to apply changes
sudo systemctl restart nix-daemon
```

### Quick One-Liner (if file doesn't have complex config)

```bash
sudo tee /etc/nix/nix.conf > /dev/null << 'EOF'
build-users-group = nixbld
max-jobs = auto
cores = 0
max-substitution-jobs = 8

# Allow your user to use custom substituters and flakes
trusted-users = root potatoq

# Enable flakes and nix-command
experimental-features = nix-command flakes

# Binary caches (substituters)
substituters = https://cache.nixos.org https://nix-community.cachix.org https://crane.cachix.org
trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCUSeBo= crane.cachix.org-1:8Scfpmn9w+hGdXH/Q9tTLiYAE/2dnJYRJP7kl80GuRk=
EOF

sudo systemctl restart nix-daemon
```

## User-Level Configuration

The user-level configuration is managed by home-manager in `home/home.nix` and includes:

- Flakes registry
- User-specific nix settings
- Preferred substituters and public keys

After updating `/etc/nix/nix.conf`, apply the home-manager configuration:

```bash
home-manager switch --flake ~/dotfiles
```

## Verification

After applying both configurations, verify they work:

```bash
# Check if you're a trusted user
nix show-config | grep trusted-users

# Check if flakes are enabled
nix show-config | grep experimental-features

# Check substituters
nix show-config | grep substituters

# Test with a flake build (should not show warnings)
cd ~/projects/plentysound
nix build .#plentysound --print-build-logs
```

## Why Both Configs Are Needed

- **`/etc/nix/nix.conf`**: System-level settings that require root privileges
  - `trusted-users`: Security setting that allows users to override substituters
  - Controls daemon behavior

- **`home/home.nix`**: User-level preferences
  - Personal nix settings
  - User-specific packages and configurations
  - Can be version-controlled and shared

## Common Issues

### "ignoring untrusted substituter" warnings

**Cause**: Your user is not in the `trusted-users` list in `/etc/nix/nix.conf`

**Fix**: Add `trusted-users = root potatoq` to `/etc/nix/nix.conf` and restart nix-daemon

### "unknown experimental feature" errors

**Cause**: Flakes not enabled in system config

**Fix**: Add `experimental-features = nix-command flakes` to `/etc/nix/nix.conf`

### Daemon not recognizing new settings

**Fix**: Always restart the daemon after changing `/etc/nix/nix.conf`:
```bash
sudo systemctl restart nix-daemon
```
