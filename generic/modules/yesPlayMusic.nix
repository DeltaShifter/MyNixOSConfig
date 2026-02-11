{ pkgs, lib, ... }:

pkgs.stdenv.mkDerivation rec {
  pname = "yesplaymusic";
  version = "0.4.10";

  # 直接使用你给出的那个 pacman 包链接
  src = pkgs.fetchurl {
    url = "https://github.com/qier222/YesPlayMusic/releases/download/v${version}/YesPlayMusic-${version}.pacman";
    sha256 = "e93b279cf2e916be661586990390b272c471ba1405ff665a27246c3fa1efac9f";
  };

  # pacman 包本质是压缩包，nix 会自动处理解压，但可能需要指定解压工具
  nativeBuildInputs = with pkgs; [ 
    autoPatchelfHook 
    makeWrapper 
    libarchive # 用于处理复杂的压缩格式
  ];

  # 补充 PKGBUILD 里没写全但 Electron 必带的运行库
  buildInputs = with pkgs; [
    gtk3 nss alsa-lib at-spi2-atk atk cairo cups dbus expat fontconfig 
    freetype gdk-pixbuf glib libdrm libglvnd libnotify libpulseaudio 
    libuuid libxkbcommon mesa nspr pango systemd
    xorg.libX11 xorg.libXcomposite xorg.libXcursor xorg.libXdamage 
    xorg.libXext xorg.libXfixes xorg.libXi xorg.libXrandr xorg.libXrender 
    xorg.libXtst xorg.libxcb xorg.libxshmfence
  ];

  # 模仿 PKGBUILD 的 package() 逻辑
  installPhase = ''
    runHook preInstall

    # 创建目标目录（模仿 /opt）
    mkdir -p $out/opt/YesPlayMusic
    cp -r . $out/opt/YesPlayMusic/

    # 清理 Arch 专用的元数据文件
    rm -f $out/opt/YesPlayMusic/{.PKGINFO,.MTREE,.INSTALL}

    # 安装图标和桌面文件（从 opt 挪到标准路径）
    mkdir -p $out/share/applications
    cp -r usr/share/icons $out/share/ 2>/dev/null || true
    cp usr/share/applications/yesplaymusic.desktop $out/share/applications/

    # 模仿 PKGBUILD 的 sed 修改逻辑
    substituteInPlace $out/share/applications/yesplaymusic.desktop \
      --replace 'Exec=/opt/YesPlayMusic/yesplaymusic' "Exec=$out/bin/yesplaymusic" \
      --replace 'Categories=Music;' 'Categories=Music;AudioVideo;Player;'

    # 建立二进制软链接（对应 post_install 逻辑）
    mkdir -p $out/bin
    makeWrapper $out/opt/YesPlayMusic/yesplaymusic $out/bin/yesplaymusic \
      --argv0 "yesplaymusic" \
      --add-flags "--enable-features=UseOzonePlatform --ozone-platform=wayland"

    runHook postInstall
  '';
}
