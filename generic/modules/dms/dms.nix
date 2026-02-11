{ config, pkgs, inputs, lib, ... }:

{
  imports = [
    inputs.dms.nixosModules.default
    inputs.dms.nixosModules.greeter
  ];

  nixpkgs.overlays = [
    (final: prev: {
      # 针对 dms 进行包装以支持qt6环境
      dms-shell = prev.dms-shell.overrideAttrs (oldAttrs: {
        nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [ pkgs.makeWrapper ];
        postFixup = (oldAttrs.postFixup or "") + ''
          wrapProgram $out/bin/DankMaterialShell \
            --prefix QML2_IMPORT_PATH : "${pkgs.qt6.qtwebsockets}/lib/qt-6/qml"
        '';
      });
    })
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


}
