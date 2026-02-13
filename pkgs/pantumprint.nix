{ stdenv
, fetchurl
, autoPatchelfHook
, makeWrapper
, lib
, callPackage
, cups
, dbus
, jbigkit
, xz
, dbus-glib
, libusb1
, libsm
, libice
, libx11
, libxext
, ghostscript
, bc
, poppler-utils
, imagemagick
, coreutils
, gnugrep
, libredirect
, ...
} @ args:
stdenv.mkDerivation rec {
  pname = "pantumprint";
  version = "2.0.4-1+uos";
  src = fetchurl {
    url = "https://raw.githubusercontent.com/DeltaShifter/CM1115ADN-printer-assets/refs/heads/main/pantum-cm1115-assets.tar.gz";
    sha256 = "sha256-GdNduxwEuVkO6j6Qvqqu1k9pFJ3LwzjUxQdlIt2dLcw=";
  };

nativeBuildInputs = [ autoPatchelfHook makeWrapper ];
buildInputs = [
  cups
  dbus
  libusb1
  jbigkit
  xz
  dbus-glib
  libsm
  libice
  libx11
  libxext
  libredirect
  ];
  unpackPhase = ''
    tar -xzvf $src
    mkdir -p $out
  '';

  installPhase = ''
    runHook preInstall

    cp -r opt usr $out
    mkdir -p $out/lib/cups/filter
    cp -r $out/opt/pantum/com.pantum.pantumprint/bin/* $out/lib/cups/filter/
    
    # 重写pdfscale.sh的硬编码路径
    local scriptsDir="$out/opt/pantum/com.pantum.pantumprint/scripts"
    substituteInPlace "$scriptsDir/pdfscale.sh" \
      --replace 'GSBIN="$(which gs 2>/dev/null)"' 'GSBIN="${ghostscript}/bin/gs"' \
      --replace 'BCBIN="$(which bc 2>/dev/null)"' 'BCBIN="${bc}/bin/bc"' \
      --replace 'PDFINFOBIN="$(which pdfinfo 2>/dev/null)"' 'PDFINFOBIN="${poppler-utils}/bin/pdfinfo"' \
      --replace 'IDBIN=$(which identify 2>/dev/null)' 'IDBIN="${imagemagick}/bin/identify"' \
      --replace 'GREPBIN="$(which grep 2>/dev/null)"' 'GREPBIN="${gnugrep}/bin/grep"'
    patchShebangs "$scriptsDir/"

    # 重定向二进制文件的搜索路径
    for bin in $out/lib/cups/filter/*; do
      if [ -f "$bin" ] && [ ! -L "$bin" ]; then
        filename=$(basename "$bin")
        mv "$bin" "$out/lib/cups/filter/.$filename-wrapped"
        # /opt/pantum -> Nix Store 里的 opt 目录
        # /usr/lib/cups -> Nix Store 里的 cups 库
        local redirects="/opt/pantum=$out/opt/pantum:/usr/lib/cups=${cups}/lib/cups"

        makeWrapper "$out/lib/cups/filter/.$filename-wrapped" "$bin" \
          --prefix PATH : "${lib.makeBinPath [ coreutils ghostscript bc poppler-utils cups ]}" \
          --set LD_PRELOAD "${libredirect}/lib/libredirect.so" \
          --set NIX_REDIRECTS "$redirects" \
          --run '${coreutils}/bin/mkdir -p /tmp/pantum/com.pantum.pantumprint' \
          --run '${coreutils}/bin/ln -sfn '$out'/opt/pantum/com.pantum.pantumprint/scripts /tmp/pantum/com.pantum.pantumprint/scripts'
      fi
    done
      
  runHook postInstall
    '';

  # 声明私有库
  appendRunpaths = [ "$out/opt/pantum/com.pantum.pantumprint/lib" ];

  postFixup = ''
    # 把私有库暴露出来
    addAutoPatchelfSearchPath $out/opt/pantum/com.pantum.pantumprint/lib
    # 修依赖
    find $out -type f -executable | while read -r file; do
      autoPatchelf "$file"
    done
  '';

  meta = with lib; {
    description = "Pantum printer driver (based on UOS deb package)";
    platforms = platforms.linux;
    };
  }
