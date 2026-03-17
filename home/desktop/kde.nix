{ pkgs, lib, ... }:

let
  layan-kde = pkgs.stdenvNoCC.mkDerivation {
    pname = "layan-kde";
    version = "unstable-2024-08-15";
    src = pkgs.fetchFromGitHub {
      owner = "vinceliuice";
      repo = "Layan-kde";
      rev = "a0b6a4956022276aee33309b2e07d1d0ef3db30c";
      sha256 = "1mb7ihnh79gbnkdcfvbbczhfspla0ks2wvhiiaxqm8q2b8fyqbc3";
    };
    dontBuild = true;
    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/{plasma/desktoptheme,aurorae/themes,color-schemes}

      # Desktop theme (needs the shared "common" dir merged in)
      cp -r plasma/desktoptheme/Layan $out/share/plasma/desktoptheme/
      cp -r plasma/desktoptheme/common/* $out/share/plasma/desktoptheme/Layan/

      # Aurorae window decoration
      cp -r aurorae/themes/Layan $out/share/aurorae/themes/

      # Color scheme
      cp color-schemes/Layan.colors $out/share/color-schemes/

      runHook postInstall
    '';
  };
in
{
  home.packages = [
    layan-kde
    pkgs.papirus-icon-theme
    # plasma-manager scripts use "qdbus" but Plasma 6 ships "qdbus6"
    (pkgs.writeShellScriptBin "qdbus" ''exec qdbus6 "$@"'')
    # Intel GPU monitoring tools
    pkgs.intel-gpu-tools
    pkgs.plasma5Packages.plasma-intel-gpu-monitor
    # Helper script to manage intel-gpu-tools capabilities service
    (pkgs.writeShellScriptBin "intel-gpu-setup" ''
      #!/usr/bin/env bash
      set -e

      SERVICE_FILE="$HOME/.config/systemd-services/intel-gpu-tools-caps.service"
      SYSTEM_SERVICE="/etc/systemd/system/intel-gpu-tools-caps.service"

      case "''${1:-}" in
        install)
          echo "Installing intel-gpu-tools capabilities service..."
          if [ ! -f "$SERVICE_FILE" ]; then
            echo "Error: Service file not found at $SERVICE_FILE"
            echo "Please run 'home-manager switch' first."
            exit 1
          fi
          sudo cp "$SERVICE_FILE" "$SYSTEM_SERVICE"
          sudo systemctl daemon-reload
          sudo systemctl enable intel-gpu-tools-caps.service
          sudo systemctl start intel-gpu-tools-caps.service
          echo "✓ Service installed and started"
          echo "✓ Capabilities set on intel_gpu_top"
          ;;
        restart)
          echo "Restarting intel-gpu-tools capabilities service..."
          sudo cp "$SERVICE_FILE" "$SYSTEM_SERVICE"
          sudo systemctl daemon-reload
          sudo systemctl restart intel-gpu-tools-caps.service
          echo "✓ Service restarted"
          echo "✓ Capabilities updated"
          ;;
        status)
          echo "Checking intel_gpu_top capabilities..."
          ${pkgs.libcap}/bin/getcap ${pkgs.intel-gpu-tools}/bin/intel_gpu_top || echo "No capabilities set"
          echo ""
          echo "Service status:"
          systemctl status intel-gpu-tools-caps.service || true
          ;;
        uninstall)
          echo "Uninstalling intel-gpu-tools capabilities service..."
          sudo systemctl stop intel-gpu-tools-caps.service || true
          sudo systemctl disable intel-gpu-tools-caps.service || true
          sudo rm -f "$SYSTEM_SERVICE"
          sudo systemctl daemon-reload
          echo "✓ Service uninstalled"
          ;;
        *)
          echo "Intel GPU Monitor Capabilities Setup"
          echo ""
          echo "Usage: intel-gpu-setup <command>"
          echo ""
          echo "Commands:"
          echo "  install    - Install and enable the systemd service (run once)"
          echo "  restart    - Restart service after home-manager rebuild"
          echo "  status     - Check capabilities and service status"
          echo "  uninstall  - Remove the systemd service"
          echo ""
          echo "Quick start:"
          echo "  1. intel-gpu-setup install    # Run once to set up"
          echo "  2. home-manager switch        # After nix updates"
          echo "  3. intel-gpu-setup restart    # Update capabilities"
          ;;
      esac
    '')
  ];

  # Generate systemd service file for intel-gpu-tools capabilities
  # This service sets cap_perfmon on intel_gpu_top so the widget works without root
  home.file.".config/systemd-services/intel-gpu-tools-caps.service".text = ''
    [Unit]
    Description=Set capabilities for intel_gpu_top
    After=local-fs.target

    [Service]
    Type=oneshot
    ExecStart=${pkgs.libcap}/bin/setcap cap_perfmon=+ep ${pkgs.intel-gpu-tools}/bin/intel_gpu_top
    RemainAfterExit=yes

    [Install]
    WantedBy=multi-user.target
  '';

  # Back up KDE config files before plasma-manager overwrites them
  home.activation.backupKdeConfig = lib.hm.dag.entryBefore [ "configure-plasma" ] ''
    backup_dir="$HOME/kde-config-backup/pre-activate-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$backup_dir"
    for f in kdeglobals kwinrc plasmarc plasmashellrc kglobalshortcutsrc \
             breezerc baloofilerc plasma-localerc kcminputrc kded5rc kwalletrc \
             plasma-org.kde.plasma.desktop-appletsrc; do
      [ -f "$HOME/.config/$f" ] && cp "$HOME/.config/$f" "$backup_dir/"
    done
  '';

  # Inform user about intel-gpu-tools setup
  home.activation.intelGpuSetupReminder = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -f /etc/systemd/system/intel-gpu-tools-caps.service ]; then
      echo ""
      echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
      echo "  Intel GPU Monitor Setup Required"
      echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
      echo ""
      echo "  To enable the Intel GPU monitor widget, run:"
      echo "    intel-gpu-setup install"
      echo ""
      echo "  After future nix updates, refresh capabilities with:"
      echo "    intel-gpu-setup restart"
      echo ""
      echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
      echo ""
    fi
  '';

  # Ensure "qdbus" is available since Plasma 6 only ships "qdbus6"
  # but plasma-manager scripts call "qdbus".
  home.activation.ensureQdbus = lib.hm.dag.entryBefore [ "configure-plasma" ] ''
    mkdir -p "$HOME/.local/bin"
    ln -sf /usr/bin/qdbus6 "$HOME/.local/bin/qdbus"
    export PATH="$HOME/.local/bin:$PATH"
  '';

  # Run plasma-manager theme/panel scripts after config is written,
  # then reload KWin so changes apply immediately.
  home.activation.applyPlasmaScripts = lib.hm.dag.entryAfter [ "configure-plasma" ] ''
    if [ -n "''${DISPLAY:-}''${WAYLAND_DISPLAY:-}" ]; then
      export PATH="$HOME/.local/bin:/usr/bin:/usr/local/bin:$PATH"
      if [ -f "$HOME/.local/share/plasma-manager/run_all.sh" ]; then
        run bash "$HOME/.local/share/plasma-manager/run_all.sh"
      fi

      # Wait for plasmashell to flush config after panel script
      sleep 2

      # Fix plasma-manager's double-escaped JSON in sensor config
      # (writeConfig over-escapes quotes in JSON arrays)
      if [ -f "$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc" ]; then
        run ${pkgs.gnused}/bin/sed -i 's/\\\\"/"/g' "$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"
      fi

      # Fix panel properties the JS API doesn't apply correctly:
      # panelOpacity (translucent=2) and panelLengthMode (fill=1, fit=2)
      if [ -f "$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc" ] && [ -f "$HOME/.config/plasmashellrc" ]; then
        bottom_id=$(${pkgs.gawk}/bin/awk -F'[][]' '/^\[Containments\]\[[0-9]+\]$/{id=$4} /^location=4$/{print id}' \
          "$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc")
        top_id=$(${pkgs.gawk}/bin/awk -F'[][]' '/^\[Containments\]\[[0-9]+\]$/{id=$4} /^location=3$/{print id}' \
          "$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc")

        for panel_id in $bottom_id $top_id; do
          run kwriteconfig6 --file "$HOME/.config/plasmashellrc" \
            --group "PlasmaViews" --group "Panel $panel_id" --key "panelOpacity" 2
        done

        if [ -n "$bottom_id" ]; then
          run kwriteconfig6 --file "$HOME/.config/plasmashellrc" \
            --group "PlasmaViews" --group "Panel $bottom_id" --key "panelLengthMode" 2
        fi
        if [ -n "$top_id" ]; then
          run kwriteconfig6 --file "$HOME/.config/plasmashellrc" \
            --group "PlasmaViews" --group "Panel $top_id" --key "panelLengthMode" 1
        fi
      fi

      # Reload plasmashell and kwin to pick up all fixes
      run qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.refreshCurrentShell 2>/dev/null || true
      run qdbus6 org.kde.KWin /KWin reconfigure 2>/dev/null || true
    fi
  '';

  programs.plasma = {
    enable = true;

    #
    # Workspace appearance
    #
    workspace = {
      lookAndFeel = "org.kde.breezedark.desktop";
      theme = "Layan";
      iconTheme = "Papirus-Dark";
    };

    #
    # KWin (compositor, effects, window decorations)
    #
    kwin = {
      effects = {
        translucency.enable = true;
        blur = {
          enable = true;
          strength = 10;
        };
      };
    };

    #
    # Bottom panel: taskbar
    #
    panels = [
      {
        location = "bottom";
        floating = true;
        height = 52;
        lengthMode = "fit";
        opacity = "translucent";
        hiding = "dodgewindows";
        widgets = [
          {
            kickoff = {
              icon = "nix-snowflake-white";
              sortAlphabetically = true;
            };
          }
          "org.kde.plasma.pager"
          {
            iconTasks = {
              launchers = [
                "applications:systemsettings.desktop"
                "preferred://filemanager"
                "preferred://browser"
                "applications:Alacritty.desktop"
              ];
            };
          }
          "org.kde.plasma.marginsseparator"
          {
            systemTray.items = {
              # Always visible in tray
              shown = [
                "org.kde.plasma.battery"
                "org.kde.plasma.bluetooth"
                "org.kde.plasma.brightness"
                "org.kde.plasma.clipboard"
                "org.kde.plasma.networkmanagement"
                "org.kde.plasma.volume"
              ];
              # Hidden but available (disabled or show when needed)
              hidden = [
                "org.kde.plasma.devicenotifier"
                "org.kde.plasma.notifications"
                "org.kde.plasma.mediacontroller"
              ];
            };
          }
          "org.kde.plasma.analogclock"
          "org.kde.plasma.showdesktop"
        ];
      }

      #
      # Top panel: system monitors
      #
      {
        location = "top";
        floating = true;
        height = 54;
        lengthMode = "fill";
        opacity = "translucent";
        hiding = "dodgewindows";
        widgets = [
          "org.kde.plasma.intel-gpu-monitor"
          {
            systemMonitor = {
              title = "Network Speed";
              displayStyle = "org.kde.ksysguard.linechart";
              sensors = [
                {
                  name = "network/all/download";
                  color = "61,174,233";
                  label = "Download";
                }
                {
                  name = "network/all/upload";
                  color = "233,120,61";
                  label = "Upload";
                }
              ];
            };
          }
          {
            systemMonitor = {
              title = "Hard Disk Activity";
              displayStyle = "org.kde.ksysguard.linechart";
              sensors = [
                {
                  name = "disk/all/write";
                  color = "61,174,233";
                  label = "Write";
                }
                {
                  name = "disk/all/read";
                  color = "233,120,61";
                  label = "Read";
                }
              ];
            };
          }
          {
            systemMonitor = {
              title = "Disk Usage";
              displayStyle = "org.kde.ksysguard.horizontalbars";
              sensors = [
                {
                  name = "disk/.*/usedPercent";
                  color = "61,174,233";
                  label = "Disk Usage";
                }
              ];
              totalSensors = [ "disk/all/usedPercent" ];
            };
          }
          {
            systemMonitor = {
              title = "Individual Core Usage";
              displayStyle = "org.kde.ksysguard.barchart";
              sensors = [
                {
                  name = "cpu/cpu.*/usage";
                  color = "61,174,233";
                  label = "CPU Cores";
                }
              ];
              totalSensors = [ "cpu/all/usage" ];
            };
          }
          {
            systemMonitor = {
              title = "Memory Usage";
              displayStyle = "org.kde.ksysguard.linechart";
              sensors = [
                {
                  name = "memory/physical/used";
                  color = "61,174,233";
                  label = "Used";
                }
              ];
              totalSensors = [ "memory/physical/usedPercent" ];
            };
          }
        ];
      }
    ];

    #
    # Keyboard shortcuts (cleaned up from rc2nix — only non-default bindings)
    #
    shortcuts = {
      plasmashell = {
        "activate application launcher" = [ "Meta" "Alt+F1" ];
        "next activity" = "Meta+A";
        "previous activity" = "Meta+Shift+A";
        "manage activities" = "Meta+Q";
        "show-on-mouse-pos" = "Meta+V";
        "show dashboard" = "Ctrl+F12";
        clipboard_action = "Meta+Ctrl+X";
        cycle-panels = "Meta+Alt+P";
        "activate task manager entry 1" = "Meta+1";
        "activate task manager entry 2" = "Meta+2";
        "activate task manager entry 3" = "Meta+3";
        "activate task manager entry 4" = "Meta+4";
        "activate task manager entry 5" = "Meta+5";
        "activate task manager entry 6" = "Meta+6";
        "activate task manager entry 7" = "Meta+7";
        "activate task manager entry 8" = "Meta+8";
        "activate task manager entry 9" = "Meta+9";
      };

      kwin = {
        Overview = "Meta+W";
        "Grid View" = "Meta+G";
        "Show Desktop" = "Meta+D";
        "Edit Tiles" = "Meta+T";
        "Window Close" = "Alt+F4";
        "Window Maximize" = "Meta+PgUp";
        "Window Minimize" = "Meta+PgDown";
        "Window Quick Tile Left" = "Meta+Left";
        "Window Quick Tile Right" = "Meta+Right";
        "Window Quick Tile Top" = "Meta+Up";
        "Window Quick Tile Bottom" = "Meta+Down";
        "Switch One Desktop Down" = "Meta+Ctrl+Down";
        "Switch One Desktop Up" = "Meta+Ctrl+Up";
        "Switch One Desktop to the Left" = "Meta+Ctrl+Left";
        "Switch One Desktop to the Right" = "Meta+Ctrl+Right";
        "Window One Desktop Down" = "Meta+Ctrl+Shift+Down";
        "Window One Desktop Up" = "Meta+Ctrl+Shift+Up";
        "Window One Desktop to the Left" = "Meta+Ctrl+Shift+Left";
        "Window One Desktop to the Right" = "Meta+Ctrl+Shift+Right";
        "Switch Window Down" = "Meta+Alt+Down";
        "Switch Window Left" = "Meta+Alt+Left";
        "Switch Window Right" = "Meta+Alt+Right";
        "Switch Window Up" = "Meta+Alt+Up";
        "Window to Next Screen" = "Meta+Shift+Right";
        "Window to Previous Screen" = "Meta+Shift+Left";
        "Walk Through Windows" = [ "Meta+Tab" "Alt+Tab" ];
        "Walk Through Windows (Reverse)" = [ "Meta+Shift+Tab" "Alt+Shift+Tab" ];
        "Walk Through Windows of Current Application" = [ "Meta+\`" "Alt+\`" ];
        "Walk Through Windows of Current Application (Reverse)" = [ "Meta+~" "Alt+~" ];
        "Kill Window" = "Meta+Ctrl+Esc";
        "Window Operations Menu" = "Alt+F3";
        "Activate Window Demanding Attention" = "Meta+Ctrl+A";
        Expose = [ "Meta+F9" "Ctrl+F9" ];
        ExposeAll = [ "Meta+F10" "Launch (C)" "Ctrl+F10" ];
        ExposeClass = [ "Meta+F7" "Ctrl+F7" ];
        MoveMouseToCenter = "Meta+F6";
        MoveMouseToFocus = "Meta+F5";
        "Switch to Desktop 1" = [ "Meta+F1" "Ctrl+F1" ];
        "Switch to Desktop 2" = [ "Meta+F2" "Ctrl+F2" ];
        "Switch to Desktop 3" = [ "Meta+F3" "Ctrl+F3" ];
        "Switch to Desktop 4" = [ "Meta+F4" "Ctrl+F4" ];
        view_actual_size = "Meta+0";
        view_zoom_in = [ "Meta++" "Meta+=" ];
        view_zoom_out = "Meta+-";
        disableInputCapture = "Meta+Shift+Esc";
      };

      ksmserver = {
        "Lock Session" = [ "Meta+L" "Screensaver" ];
        "Log Out" = "Ctrl+Alt+Del";
      };

      kmix = {
        decrease_volume = "Volume Down";
        increase_volume = "Volume Up";
        decrease_volume_small = "Shift+Volume Down";
        increase_volume_small = "Shift+Volume Up";
        mute = "Volume Mute";
        mic_mute = [ "Microphone Mute" "Meta+Volume Mute" ];
        decrease_microphone_volume = "Microphone Volume Down";
        increase_microphone_volume = "Microphone Volume Up";
      };

      mediacontrol = {
        nextmedia = "Media Next";
        previousmedia = "Media Previous";
        playpausemedia = "Media Play";
        pausemedia = "Media Pause";
        stopmedia = "Media Stop";
        seekforwardmedia = "Media Fast Forward";
        seekbackwardmedia = "Media Rewind";
      };

      org_kde_powerdevil = {
        "Decrease Screen Brightness" = "Monitor Brightness Down";
        "Increase Screen Brightness" = "Monitor Brightness Up";
        "Decrease Screen Brightness Small" = "Shift+Monitor Brightness Down";
        "Increase Screen Brightness Small" = "Shift+Monitor Brightness Up";
        "Decrease Keyboard Brightness" = "Keyboard Brightness Down";
        "Increase Keyboard Brightness" = "Keyboard Brightness Up";
        "Toggle Keyboard Backlight" = "Keyboard Light On/Off";
        Sleep = "Sleep";
        Hibernate = "Hibernate";
        PowerDown = "Power Down";
        PowerOff = "Power Off";
        powerProfile = [ "Battery" "Meta+B" ];
      };

      "KDE Keyboard Layout Switcher" = {
        "Switch to Last-Used Keyboard Layout" = "Meta+Alt+L";
        "Switch to Next Keyboard Layout" = "Meta+Alt+K";
      };

      kaccess = {
        "Toggle Screen Reader On and Off" = "Meta+Alt+S";
      };
    };

    #
    # Raw config keys (from rc2nix, cleaned up)
    #

    configFile = {
      # --- kdeglobals ---
      kdeglobals.General.TerminalApplication = "alacritty";
      kdeglobals.General.TerminalService = "Alacritty.desktop";
      kdeglobals.General.XftHintStyle = "hintslight";
      kdeglobals.General.XftSubPixel = "none";
      kdeglobals.General.font = "FiraCode Nerd Font Mono,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1";
      kdeglobals.Icons.Theme = "Papirus-Dark";
      kdeglobals.KDE.contrast = 4;
      kdeglobals.KDE.frameContrast = 0.2;

      # Window manager title bar colors (Breeze Dark)
      kdeglobals.WM.activeBackground = "39,44,49";
      kdeglobals.WM.activeBlend = "252,252,252";
      kdeglobals.WM.activeForeground = "252,252,252";
      kdeglobals.WM.inactiveBackground = "32,36,40";
      kdeglobals.WM.inactiveBlend = "161,169,177";
      kdeglobals.WM.inactiveForeground = "161,169,177";

      # --- kwinrc ---
      kwinrc.Desktops.Number = 1;
      kwinrc.Desktops.Rows = 1;
      # BlurStrength is set via kwin.effects.blur.strength above
      # translucencyEnabled is set via kwin.effects.translucency.enable above
      kwinrc."Effect-translucency".DropdownMenus = 60;
      kwinrc."Effect-translucency".IndividualMenuConfig = true;
      kwinrc.Xwayland.Scale = 1;
      kwinrc."org.kde.kdecoration2".library = "org.kde.kwin.aurorae.v2";
      kwinrc."org.kde.kdecoration2".theme = "__aurorae__svg__Layan";

      # --- plasmarc ---
      plasmarc.Theme.name = "Layan";

      # --- breezerc ---
      breezerc.Style.MenuOpacity = 91;

      # --- kwalletrc ---
      kwalletrc.Wallet."First Use" = false;

      # --- baloofilerc (file indexing) ---
      baloofilerc."Basic Settings"."Indexing-Enabled" = false;

      # --- plasma-localerc ---
      plasma-localerc.Formats.LANG = "en_US.UTF-8";

      # --- kded5rc ---
      kded5rc."Module-device_automounter".autoload = false;
    };
  };
}
