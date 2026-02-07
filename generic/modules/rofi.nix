{ pkgs , ... }:

let
  givemecustomMPOWER = pkgs.writeShellScriptBin "custom-power-menu"  ''
  ${pkgs.rofi-power-menu}/bin/rofi-power-menu "$@" | sed 's/^promptPower menu$/prompt ⏻ Power/'
  '';
in
{
  environment.systemPackages = with pkgs;[
    (rofi.override{
      plugins = [
        rofi-calc
        rofi-pass
        rofimoji
        givemecustomMPOWER
      ];
    })
    givemecustomMPOWER
  ];
}
