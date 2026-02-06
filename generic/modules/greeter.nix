{ config, pkgs , lib, ... }:

{
  environment.systemPackages = with pkgs;[
    materia-theme
  ];
  
  programs.regreet = {
  enable = true;
  settings = {
    background = {
      path = ../asset/Night.png;
      fit = "Cover";
    };
    GTK = {
      application_prefer_dark_theme = true;
      cursor_theme_name = "Adwaita";
      theme_name = lib.mkForce "Materia"; 
    };
    widget.clock = {
      format = "%a %H:%M";
      resolution = "500ms";
    };
  };
};

 }
