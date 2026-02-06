{ config, pkgs , lib, ... }:

{
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
      icon_theme_name = "Adwaita";
      theme_name = "Adwaita"; 
    };
    appearance = {
      greeting = "Welcome back,Commander!";
    };
    widget.clock = {
      format = "%a %H:%M";
      resolution = "500ms";
    };
  };
};
  
}
