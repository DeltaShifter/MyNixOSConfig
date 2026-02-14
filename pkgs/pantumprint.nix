{ stdenv
, fetchurl
, autoPatchelfHook
, makeWrapper
, lib
, dpkg
, cups
, cups-filters
, dbus
, jbigkit
, xz
, dbus-glib
, libusb1
, ghostscript
, bc
, poppler-utils
, imagemagick
, coreutils
, gnugrep
, libredirect
, libjpeg
, libsm
, libice
, libx11
, libxext
, ...
}:

stdenv.mkDerivation {
  pname = "pantumprint";
  version = "2.0.4-1+uos";

  src = fetchurl {
    url = "https://raw.githubusercontent.com/DeltaShifter/CM1115ADN-printer-assets/main/signed_com_pantum_pantumprint_2_0_4-1%2Buos_amd64.deb";
    sha256 = "sha256-RBnClfDzOlszOW3RUMP6Q0C1eK6U+6pbtO3XNh5uNGk=";
  };

  sourceRoot = ".";

  nativeBuildInputs = [ autoPatchelfHook makeWrapper ];
  autoPatchelfIgnoreMissingDeps = [
  ];
  appendRunpaths = [ 
    "$out/opt/pantum/com.pantum.pantumprint/lib/"
    "$out/opt/pantum/com.pantum.pantumprint/lib/product_modules/" 
  ];

  buildInputs = [
    cups
    dbus
    dpkg
    libusb1
    jbigkit
    xz
    dbus-glib
    libredirect
    libjpeg
    cups-filters
    libsm
    libice
    libx11
    libxext
  ];

  unpackPhase = ''
    ls -R
    dpkg -x $src .
    rm -rf opt/apps
    '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    echo "test-----------------"
    ls -R
    echo "endtest"
    [ -d opt ] && cp -r opt $out/
    [ -d usr ] && cp -r usr $out/
    
    mkdir -p $out/lib/cups/filter
    if [ -d "$out/opt/pantum/com.pantum.pantumprint/bin" ]; then
      cp -r $out/opt/pantum/com.pantum.pantumprint/bin/* $out/lib/cups/filter/
    fi

    mkdir -p $out/share/cups/mime
    [ -d usr/share/cups/mime ] && cp usr/share/cups/mime/* $out/share/cups/mime/

    mkdir -p $out/share/cups/model/pantum
    if [ -d "usr/share/cups/model/pantum" ]; then
      cp usr/share/cups/model/pantum/* $out/share/cups/model/pantum/
    fi

    # 赋予执行权限以便 Patchelf 处理
    chmod +x $out/lib/cups/filter/*
    find $out/opt/pantum/com.pantum.pantumprint/lib -name "*.so*" -exec chmod +x {} +

    # 脚本路径修复
    local scriptsDir="$out/opt/pantum/com.pantum.pantumprint/scripts"
    if [ -d "$scriptsDir" ]; then
      substituteInPlace "$scriptsDir/pdfscale.sh" \
        --replace 'GSBIN="$(which gs 2>/dev/null)"' "GSBIN=${ghostscript}/bin/gs" \
        --replace 'BCBIN="$(which bc 2>/dev/null)"' "BCBIN=${bc}/bin/bc" \
        --replace 'PDFINFOBIN="$(which pdfinfo 2>/dev/null)"' "PDFINFOBIN=${poppler-utils}/bin/pdfinfo" \
        --replace 'IDBIN=$(which identify 2>/dev/null)' "IDBIN=${imagemagick}/bin/identify" \
        --replace 'GREPBIN="$(which grep 2>/dev/null)"' "GREPBIN=${gnugrep}/bin/grep"
      patchShebangs "$scriptsDir/"
    fi
    runHook postInstall
  '';


  postFixup = ''
    # 查找真正的系统 pdftopdf 路径（cups-filters 包提供）
    local sys_pdftopdf="${cups-filters}/lib/cups/filter/pdftopdf"
    
    # 路径重定向映射
    local r_opt="/opt/pantum=$out/opt/pantum"
    local r_mime="/usr/share/cups=$out/share/cups"
    local r_filter="/usr/lib/cups/filter/pdftopdf=$sys_pdftopdf"
    local redirects="$r_opt:$r_mime:$r_filter"

    for bin in $out/lib/cups/filter/*; do
      if [ -f "$bin" ] && [ ! -L "$bin" ]; then
        filename=$(basename "$bin")
        
        mv "$bin" "$out/lib/cups/filter/.$filename-wrapped"
        
        makeWrapper "$out/lib/cups/filter/.$filename-wrapped" "$bin" \
          --prefix PATH : "${lib.makeBinPath [ coreutils ghostscript bc poppler-utils cups cups-filters ]}" \
          --prefix LD_LIBRARY_PATH : "$out/opt/pantum/com.pantum.pantumprint/lib" \
          --set LD_PRELOAD "${libredirect}/lib/libredirect.so" \
          --set NIX_REDIRECTS "$redirects" \
          --set CUPS_SERVERBIN "${cups}/lib/cups" \
          --set CUPS_DATADIR "$out/share/cups" \
          --run "${coreutils}/bin/mkdir -p /tmp/pantum/com.pantum.pantumprint" \
          --run "${coreutils}/bin/ln -sfn $out/opt/pantum/com.pantum.pantumprint/scripts /tmp/pantum/com.pantum.pantumprint/scripts"
      fi
    done
  '';
}
