{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, cmake
, freetype
, fontconfig
, libxcb
, libxkbcommon
, scdoc
, installShellFiles
, makeWrapper
, wayland
, libxxf86vm
, libxcursor
, libxi
, expat
, libGL
, libx11
, xdg-utils
}:
let
  rpathLibs=[
    expat
    fontconfig
    freetype
    libGL
    libx11
    libxcursor
    libxi
    libxxf86vm
    libxcb
    libxkbcommon
    wayland
  ];
in  
rustPlatform.buildRustPackage {
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

  buildInputs = rpathLibs;
  dontPatchELF = true;
  doCheck = true;

  postInstall = ''
    install -Dm644 extra/logo/alacritty-term.svg $out/share/pixmaps/Alacritty.svg
    install -Dm644 extra/logo/compat/alacritty-term.png $out/share/pixmaps/Alacritty.png

    install -Dm644 extra/linux/Alacritty.desktop -t $out/share/applications/
    install -Dm644 extra/linux/org.alacritty.Alacritty.appdata.xml -t $out/share/appdata/

    install -dm 755 "$out/share/man/man1"
    install -dm 755 "$out/share/man/man5"

    $STRIP -S $out/bin/alacritty
    patchelf --add-rpath "${lib.makeLibraryPath rpathLibs}" $out/bin/alacritty

    installShellCompletion --bash extra/completions/alacritty.bash
    installShellCompletion --zsh extra/completions/_alacritty
    installShellCompletion --fish extra/completions/alacritty.fish
  '';

  postPatch = ''
    substituteInPlace alacritty/src/config/ui_config.rs \
      --replace xdg-open ${xdg-utils}/bin/xdg-open
  '';

  meta = with lib; {
    description = "GPU-accelerated terminal emulator with smooth cursor motion patch";
    homepage = "https://github.com/GregTheMadMonk/alacritty-smooth-cursor";
    license = licenses.asl20;
    platforms = platforms.linux;
    mainProgram = "alacritty";
  };
}
