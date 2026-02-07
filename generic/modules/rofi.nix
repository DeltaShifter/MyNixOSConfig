{ pkgs , ... }:

{
  environment.systemPackages = with pkgs;[
    (rofi.override{
      plugins = [
        rofi-calc
        rofi-pass
      ];
    })
    rofimoji
        (rofi-power-menu.overrideAttrs (oldAttrs: {
      postInstall = (oldAttrs.postInstall or "") + ''
        target=$out/bin/rofi-power-menu
        substituteInPlace $target \
          --replace 'texts[lockscreen]="lock screen"' 'texts[lockscreen]="锁定屏幕"' \
          --replace 'texts[switchuser]="switch user"' 'texts[switchuser]="切换用户"' \
          --replace 'texts[logout]="log out"'         'texts[logout]="退出登录"' \
          --replace 'texts[Suspend]="suspend"'        'texts[Suspend]="挂起"' \
          --replace 'texts[hibernate]="hibernate"'    'texts[hibernate]="休眠"' \
          --replace 'texts[reboot]="reboot"'          'texts[reboot]="重启"' \
          --replace 'texts[shutdown]="shut down"'     'texts[shutdown]="关机"'

        substituteInPlace $target \
          --replace '"Yes, ' '"确认 ' \
          --replace '"No, cancel"' '"取消操作"'

        substituteInPlace $target \
          --replace 'prompt\x1fPower menu"' 'prompt\x1f电源菜单"' \
          --replace 'prompt\x1fAre you sure"' 'prompt\x1f再次确认"'
      '';
    }))
  ];
}
