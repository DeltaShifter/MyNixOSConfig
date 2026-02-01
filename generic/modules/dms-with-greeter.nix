{ config, pkgs, inputs, lib, ... }:

{
  imports = [
    inputs.dms.nixosModules.default
    inputs.dms.nixosModules.greeter
  ];

  programs.dank-material-shell.greeter = {
    enable = false;
    compositor.name = "niri";  # Or "hyprland" or "sway"
  };
  
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = ''
        ${pkgs.tuigreet}/bin/tuigreet \
          --time \
          --remember \
          --remember-user \
          --asterisks \
          --user-menu \
          --container-padding 2 \
          --width 40 \
          --greeting "ThinkPad X1 Carbon | Ready for Action" \
          --theme "border=blue;text=white;prompt=cyan;time=magenta;action=blue;button=white" \
          --cmd niri
      '';
        user = "greeter";
      };
    };
  };
  systemd.services.greetd.serviceConfig = {
  Environment = "LANG=en_US.UTF-8";
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
    inputs.dms.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];


}
