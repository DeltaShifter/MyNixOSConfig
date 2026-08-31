{ pkgs , ... }:

let
  rofi-power-menu = pkgs.rofi-power-menu.overrideAttrs (oldAttrs: {
    postPatch = ''
      substituteInPlace rofi-power-menu \
        --replace 'texts[lockscreen]="lock screen"' 'texts[lockscreen]="锁屏"' \
        --replace 'texts[logout]="log out"' 'texts[logout]="注销"' \
        --replace 'texts[suspend]="suspend"' 'texts[suspend]="挂起"' \
        --replace 'texts[hibernate]="hibernate"' 'texts[hibernate]="休眠"' \
        --replace 'texts[reboot]="reboot"' 'texts[reboot]="重启"' \
        --replace 'texts[shutdown]="shut down"' 'texts[shutdown]="关机"' \
        --replace 'prompt\x1fPower menu' 'prompt\x1f ⏻ 电源管理' \
        --replace 'prompt\x1fAre you sure' 'prompt\x1f ⚠️ 确定执行吗？' \
        --replace 'Yes, ' '是的, ' \
        --replace 'No, cancel' '算了, 点错了'
    '';
  });

  rofi-calc = pkgs.rofi-calc.overrideAttrs (oldAttrs: {
  postPatch = (oldAttrs.postPatch or "") + ''
    substituteInPlace src/calc.c \
      --replace-fail '#define HINT_RESULT_STR "Result: "' '#define HINT_RESULT_STR "结果: "' \
      --replace-fail '#define HINT_WELCOME_STR "Calculator"' '#define HINT_WELCOME_STR "󰪚 计算器"' \
      --replace-fail 'return g_strdup("Add to history");' 'return g_strdup("󰄶 存入历史记录");'
    '';
  });
  
in
{
  environment.systemPackages = with pkgs;[
    (rofi.override{
      plugins = [
        rofi-calc
        rofi-pass
      ];
    })
    rofimoji
    rofi-power-menu
  ];
}
