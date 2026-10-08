{ pkgs, ... }:

pkgs.stdenv.mkDerivation rec {
  pname = "coolapk-desktop";
  version = "1.32.0";

  src = pkgs.fetchurl {
    url = "https://github.com/daimiaopeng/coolapk-desktop/releases/download/v${version}/coolapk-desktop_${version}_amd64.deb";
    sha256 = "ca82d062ab07f37740762a939caba467a73b1d881873a07ba26932773db3bb32";
  };

  # nativeBuildInputs 里的工具会在打包阶段执行
  nativeBuildInputs = with pkgs; [
    dpkg
    autoPatchelfHook
    makeWrapper
    # 这个 Hook 是重中之重，它会自动包装程序，注入所有必需的 GTK/GDK 图形环境和 Schema
    wrapGAppsHook3
  ];

  # buildInputs 里的库是程序运行必需的依赖
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
    librsvg
    libsoup_3
    openssl
    alsa-lib
    xdg-utils # 提供 Tauri 可能调用的 xdg-open 等命令
    stdenv.cc.cc.lib
  ];

  unpackPhase = "dpkg-deb -x $src .";

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r usr/* $out/

    if [ -d "opt" ]; then
      cp -r opt $out/
    fi

    # 修复软链接路径
    for bin_file in $out/bin/*; do
      if [ -L "$bin_file" ]; then
        TARGET=$(readlink "$bin_file")
        if [[ "$TARGET" == /* ]]; then
          FIXED_TARGET=$(echo "$TARGET" | sed -e "s|^/opt|$out/opt|" -e "s|^/usr|$out|")
          rm "$bin_file"
          ln -s "$FIXED_TARGET" "$bin_file"
        fi
      fi
      chmod +x "$bin_file"
    done

    runHook postInstall
  '';

  # 使用 gappsWrapperArgs 统一注入我们的补丁环境变量，和 wrapGAppsHook3 完美配合
  preFixup = ''
    gappsWrapperArgs+=(
      --set WEBKIT_DISABLE_DMABUF_RENDERER 1
      --set GDK_BACKEND x11
      --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.xdg-utils ]}
    )
  '';
}
