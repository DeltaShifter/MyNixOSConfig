{ lib, appimageTools, fetchurl, }:

let
  pname = "coolapk-desktop";
  version = "1.32.0";

  src = fetchurl {
    url = "https://github.com/daimiaopeng/coolapk-desktop/releases/download/v${version}/coolapk-desktop_${version}_amd64.AppImage";
    hash = "sha256-JexM1urOVgu6aMXecBdf6Ojvf+mqmGVmEf0khEXxaXw=";
  };

  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
  };

in
appimageTools.wrapType2 {
  # 明确指定最终生成的命令名，避免默认生成带版本号的长名称导致桌面快捷方式找不到
  name = pname;
  inherit pname version src;

  extraPkgs = pkgs: with pkgs; [
    zstd
    wayland # 提供系统级的 libwayland-client.so.0
    libappindicator-gtk3 # 提供 libappindicator3.so.1
    libayatana-appindicator # 备用托盘库
    webkitgtk_4_1
    glib-networking
  ];

  profile = ''
    # 核心修复：强行使用 FHS 沙盒内 NixOS 原生的 Wayland 和托盘库
    # 这会无视 AppImage 内部的过期库，直接解决 EGL 崩溃和托盘缺失问题
    export LD_PRELOAD=/usr/lib/libwayland-client.so.0:/usr/lib/libappindicator3.so.1
    
    # 强制禁用 DMA-BUF 依然是一个好习惯，以防闪烁
    export WEBKIT_DISABLE_DMABUF_RENDERER=1
  '';

  extraInstallCommands = ''
    install -m 444 -D ${appimageContents}/coolapk-desktop.desktop $out/share/applications/coolapk-desktop.desktop
    install -m 444 -D ${appimageContents}/coolapk-desktop.png $out/share/icons/hicolor/512x512/apps/coolapk-desktop.png
    
    # 修复桌面启动项，使其执行我们包装好的 profile 环境
    substituteInPlace $out/share/applications/coolapk-desktop.desktop \
      --replace-warn "Exec=AppRun" "Exec=$out/bin/${pname}"
  '';
}
