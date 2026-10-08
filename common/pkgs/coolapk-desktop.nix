{ pkgs, ... }:

pkgs.stdenv.mkDerivation rec {
  pname = "coolapk-desktop";
  version = "1.32.0";

  src = pkgs.fetchurl {
    url = "https://github.com/daimiaopeng/coolapk-desktop/releases/download/v${version}/coolapk-desktop_${version}_amd64.deb";
    sha256 = "ca82d062ab07f37740762a939caba467a73b1d881873a07ba26932773db3bb32";
  };

  # 构建时所需的工具
  nativeBuildInputs = with pkgs; [
    dpkg
    autoPatchelfHook
    makeWrapper
  ];

  # 软件运行时需要的依赖（通过 patchelf 自动链接）
  buildInputs = with pkgs; [
    webkitgtk_4_1
    gtk3
    glib
    glib-networking
    libayatana-appindicator
    cairo
    pango
    atk
    gdk-pixbuf
    libsoup_3
    openssl
    alsa-lib
    stdenv.cc.cc.lib # 提供基础 C++ 库，避免部分动态库 patch 失败
  ];

  unpackPhase = "dpkg-deb -x $src .";

  installPhase = ''
    mkdir -p $out
    
    # 核心修复：全量复制 usr 下的所有文件夹 (bin, share, 最重要的是 lib!)
    cp -r usr/* $out/

    # 兼容某些可能把文件释放在 opt 目录的打包习惯
    if [ -d "opt" ]; then
      cp -r opt $out/
    fi

    # 遍历并修复 bin 目录下的可执行文件
    for bin_file in $out/bin/*; do
      if [ -e "$bin_file" ] || [ -L "$bin_file" ]; then
        
        # 修复绝对路径软链接
        if [ -L "$bin_file" ]; then
          TARGET=$(readlink "$bin_file")
          if [[ "$TARGET" == /* ]]; then
            FIXED_TARGET=$(echo "$TARGET" | sed -e "s|^/opt|$out/opt|" -e "s|^/usr|$out|")
            rm "$bin_file"
            ln -s "$FIXED_TARGET" "$bin_file"
          fi
        fi

        # 确保文件具有可执行权限
        chmod +x "$bin_file"

        # 包装执行文件，注入环境变量解决 EGL/Wayland 崩溃
        wrapProgram "$bin_file" \
          --set WEBKIT_DISABLE_DMABUF_RENDERER 1 \
          --set GDK_BACKEND x11
      fi
    done
  '';
}
