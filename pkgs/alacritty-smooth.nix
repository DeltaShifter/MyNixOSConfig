{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, cmake
, freetype
, fontconfig
, libX11
, libXi
, libXcursor
, libXrandr
, libxcb
, libxkbcommon
, scdoc
, installShellFiles
, makeWrapper
}:

rustPlatform.buildRustPackage rec {
  pname = "alacritty-smooth-cursor";
  version = "0.17.0.2464"; # 对应 PKGBUILD 的 pkgver

  src = fetchFromGitHub {
    owner = "gregthemadmonk";
    repo = "alacritty";
    rev = "all-patches"; # 对应 PKGBUILD 的 branch=all-patches
    # 这里的 hash 需要你在构建报错时更新，或使用 nix-prefetch-github 获取
    hash = "sha256-WgfXJYdCJDkcM2CJrIYWYUldpz6U/vgQIlEJKkNiFc0="; 
  };

  # 注意：更改源码后，必须更新此 hash
  cargoHash = "sha256-pbDuSvlTEUdf23LFXxK17UsXUzTUQsnnypoduUdsm+c=";

  nativeBuildInputs = [
    pkg-config
    cmake
    scdoc
    installShellFiles
    makeWrapper
  ];

  buildInputs = [
    freetype
    fontconfig
    libX11
    libXi
    libXcursor
    libXrandr
    libxcb
    libxkbcommon
  ];

  # 对应 PKGBUILD 的 build/check 逻辑
  # Nix 默认会进行 cargo build --release --locked
  doCheck = true;

  postInstall = ''
    # 1. 安装图标 (参考你之前安装 AppImage 的图标提取逻辑)
    install -Dm644 extra/logo/alacritty-term.svg $out/share/pixmaps/Alacritty.svg
    install -Dm644 extra/logo/compat/alacritty-term.png $out/share/pixmaps/Alacritty.png

    # 2. 安装 Desktop 文件
    install -Dm644 extra/linux/Alacritty.desktop -t $out/share/applications/
    install -Dm644 extra/linux/org.alacritty.Alacritty.appdata.xml -t $out/share/appdata/

    # 3. 生成并安装 Manpages (对应 PKGBUILD 中的 scdoc | gzip 逻辑)
    install -dm 755 "$out/share/man/man1"
    install -dm 755 "$out/share/man/man5"

    # scdoc < extra/man/alacritty.1.scd | gzip -c > $out/share/man/man1/alacritty.1.gz
    # scdoc < extra/man/alacritty-msg.1.scd | gzip -c > $out/share/man/man1/alacritty-msg.1.gz
    # scdoc < extra/man/alacritty.5.scd | gzip -c > $out/share/man/man5/alacritty.5.gz
    # scdoc < extra/man/alacritty-bindings.5.scd | gzip -c > $out/share/man/man5/alacritty-bindings.5.gz


    # 4. 安装补全脚本
    installShellCompletion --bash extra/completions/alacritty.bash
    installShellCompletion --zsh extra/completions/_alacritty
    installShellCompletion --fish extra/completions/alacritty.fish
  '';

  meta = with lib; {
    description = "GPU-accelerated terminal emulator with smooth cursor motion patch";
    homepage = "https://github.com/GregTheMadMonk/alacritty-smooth-cursor";
    license = licenses.asl20;
    platforms = platforms.linux;
    mainProgram = "alacritty";
  };
}
