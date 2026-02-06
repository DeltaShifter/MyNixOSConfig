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
    extraCss = ''
    .main-box {
      background-color: #1e1e1e;
      border-radius: 24px;
      padding: 48px;
      margin: 24px;
      box-shadow: 0 10px 30px rgba(0, 0, 0, 0.5);
      border: 1px solid rgba(255, 255, 255, 0.05);
    }
    entry {
      background-color: rgba(255, 255, 255, 0.05);
      border: none;
      border-bottom: 2px solid #bb86fc; 
      border-radius: 4px 4px 0 0;
      padding: 12px;
      margin-bottom: 16px;
      transition: all 0.2s ease;
    }
    entry:focus {
      background-color: rgba(255, 255, 255, 0.08);
      border-bottom: 2px solid #03dac6;
        }
      button {
      background-color: #bb86fc;
      color: #000000;
      border-radius: 20px;
      padding: 8px 24px;
      font-weight: bold;
      margin-top: 12px;
    }
    button:hover {
      background-color: #d7b4ff;
      box-shadow: 0 4px 12px rgba(187, 134, 252, 0.3);
    }
    .view {
      background-color: transparent;
    }
    '';
  };
};
  
}
