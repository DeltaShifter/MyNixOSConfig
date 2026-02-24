{ config, pkgs, inputs, lib, pkgs-stable, ... }:

{
  imports = [
    inputs.dms.nixosModules.default
    inputs.dms.nixosModules.greeter
  ];

  programs.dank-material-shell.greeter = {
    enable = false;
    compositor.name = "niri";  # Or "hyprland" or "sway"
  };
   
  services.upower.enable = true;

  programs.dms-shell = {
    enable = true;
    
    quickshell.package = inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.quickshell;
    
    systemd.enable = false;
    enableSystemMonitoring = true;
    enableDynamicTheming = true;
    enableAudioWavelength = true;
    enableVPN = true;
  };

  environment.systemPackages = [
    pkgs.qt6.qtwebsockets
    pkgs.qt6.qtbase
    inputs.dms.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];


  environment.variables = {
    QML2_IMPORT_PATH = [
      "${pkgs.qt6.qtwebsockets}/lib/qt-6/qml"
    ];
  };

}
