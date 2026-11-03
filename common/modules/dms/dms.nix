{ config, pkgs, inputs, lib, pkgs-stable, ... }:

{
  imports = [
    inputs.dms.nixosModules.dank-material-shell
  ];

  services.displayManager.dms-greeter = {
    enable = true;
    compositor.name = "niri"; # Or "hyprland" or "sway"
  };

  services.upower.enable = true;

  programs.dank-material-shell = {
    enable = true;
  };

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
