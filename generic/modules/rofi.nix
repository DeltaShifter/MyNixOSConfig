{ pkgs , ... }:
{
  environment.systemPackages = with pkgs;[
    (rofi.override{
      plugins = [
        rofi-calc
        rofi-pass
        rofi-power-menu
        rofimoji
      ];
    })
  ];
}
