{ config, pkgs, inputs, lib, pkgs-stable, ... }:

{
  programs.dms-shell = {
    enable = true;

    systemd = {
      enable = true; # Systemd service for auto-start
      restartIfChanged = true; # Auto-restart dms.service when dms-shell changes
    };

    # Core features
    enableSystemMonitoring = true; # System monitoring widgets
    enableVPN = true; # VPN management widget
    enableDynamicTheming = true; # Wallpaper-based theming (matugen)
    enableAudioWavelength = true; # Audio visualizer (cava)
    enableCalendarEvents = true; # Calendar integration (khal)
  };

  services.displayManager.dms-greeter = {
    enable = true;
    compositor.name = "niri"; # Or "hyprland" or "sway"
  };

  services.upower.enable = true;

  # environment.systemPackages = [
  # pkgs.qt6.qtwebsockets
  # pkgs.qt6.qtbase
  # inputs.dms.packages.${pkgs.stdenv.hostPlatform.system}.default
  # ];

  # environment.variables = {
  # QML2_IMPORT_PATH = [
  # "${pkgs.qt6.qtwebsockets}/lib/qt-6/qml"
  # ];
  # };

}
