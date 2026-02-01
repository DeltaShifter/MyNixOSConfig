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
  
  programs.regreet = {
  enable = true;
  settings = {
    GTK = {
      application_prefer_dark_theme = true;
      cursor_theme_name = "Adwaita";
      icon_theme_name = "Adwaita";
      theme_name = "Adwaita"; 
    };
    appearance = {
      greeting = "ThinkPad X1 Carbon | Ready to roll";
    };
    widget.clock = {
      format = "%a %H:%M";
      resolution = "500ms";
    };
    extraCss = ''
      window {background-color:#1a1b26;}
    '';
  };
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
