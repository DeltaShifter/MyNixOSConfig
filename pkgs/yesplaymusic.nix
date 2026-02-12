{ lib, appimageTools, fetchurl }:

let
  pname = "yesplaymusic";
  version = "0.4.10";
in
appimageTools.wrapType2 {
  inherit pname version;

  src = fetchurl {
    url = "https://github.com/qier222/YesPlayMusic/releases/download/v${version}/YesPlayMusic-${version}.AppImage";
    # 如果 hash 不对，nix 会报错并给出正确的 hash
    sha256 = "sha256-RInFjS8PzC45iP+SjO4hSg7iC19NnJjR8XqW+rX1I0A="; 
  };

  # 重点：在这里列出所有 Electron/X11 运行时需要的库
  extraPkgs = pkgs: with pkgs; [
    libxshmfence      # 解决你刚才看到的错误
    libglvnd          # 显卡驱动支持
    libappindicator-gtk3 # 托盘支持
    gtk3
    nss
    alsa-lib          # 声音支持
    at-spi2-atk
    at-spi2-core
    cups
    libdrm
    mesa
  ];

  extraInstallCommands = ''
    # 创建 bin 目录下的软链接，方便直接调用
    mv $out/bin/${pname}-${version} $out/bin/${pname}
    
    # 安装图标 (AppImage 通常带一个 .DirIcon)
    # 这里可以根据需要提取图标并安装到 $out/share/icons
  '';
}
