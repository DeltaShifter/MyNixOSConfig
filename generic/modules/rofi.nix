{ pkgs , ... }:

let
  givemecustomPOWER = pkgs.writeShellScriptBin "dale-mod-power-menu"  ''
  ${pkgs.rofi-power-menu}/bin/rofi-power-menu "$@" | sed \
    -e 's/.*prompt.*Power menu.*/prompt\t⏻ 电源/' \
    -e 's/>Shut down</>关机</g' \
    -e 's/>Reboot</>重启</g' \
    -e 's/>Suspend</>挂起</g' \
    -e 's/>Hibernate</>休眠</g' \
    -e 's/>Log out</>注销</g' \
    -e 's/>Lock screen</>锁屏</g'
  '';
in
{
  environment.systemPackages = with pkgs;[
    (rofi.override{
      plugins = [
        rofi-calc
        rofi-pass
        rofimoji
        givemecustomPOWER
      ];
    })
    givemecustomPOWER
  ];
}
