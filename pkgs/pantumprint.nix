{ stdenv
, fetchurl
, autoPatchelfHook
, makeWrapper
, lib
, dpkg
, cups
, xz
, dbus-glib
, dbus
, jbigkit
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
    libredirect
    libjpeg
    libsm
    libice
    libx11
    libxext
    xz
    dbus-glib
  ];

  unpackPhase = ''
    ls -R
    dpkg -x $src .
    rm -rf opt/apps
    '';

  installPhase = ''
  runHook preInstall
    
    mkdir -p $out
    cp -r opt usr $out/
        
    mkdir -p $out/lib/cups/filter
    mkdir -p $out/share/cups/mime
    mkdir -p $out/share/cups/model/pantum
    cp -r $out/opt/pantum/com.pantum.pantumprint/bin/* $out/lib/cups/filter/
    cp usr/share/cups/mime/* $out/share/cups/mime/
    cp usr/share/cups/model/pantum/* $out/share/cups/model/pantum/

    # 赋予执行权限以便 Patchelf 处理
    chmod +x $out/lib/cups/filter/*
    find $out/ -name "*.so*" -exec chmod +x {} +

    # 脚本路径修复
    local scriptsDir="$out/opt/pantum/com.pantum.pantumprint/scripts"
      substituteInPlace "$scriptsDir/pdfscale.sh" \
        --replace 'GSBIN="$(which gs 2>/dev/null)"' "GSBIN=${ghostscript}/bin/gs" \
        --replace 'BCBIN="$(which bc 2>/dev/null)"' "BCBIN=${bc}/bin/bc" \
        --replace 'PDFINFOBIN="$(which pdfinfo 2>/dev/null)"' "PDFINFOBIN=${poppler-utils}/bin/pdfinfo" \
        --replace 'IDBIN=$(which identify 2>/dev/null)' "IDBIN=${imagemagick}/bin/identify" \
        --replace 'GREPBIN="$(which grep 2>/dev/null)"' "GREPBIN=${gnugrep}/bin/grep"
      patchShebangs "$scriptsDir/"

    runHook postInstall
  '';


  postFixup = ''
    local pdftopdf="$out/opt/pantum/com.pantum.pantumprint/bin/pantumprint-pdftopdf"
    
    # 路径重定向映射
    local r_opt="/opt/pantum=$out/opt/pantum"
    local r_mime="/usr/share/cups=$out/share/cups"
    local r_filter="/usr/lib/cups/filter/pdftopdf=$pdftopdf"
    local redirects="$r_opt:$r_mime:$r_filter" 

    for bin in $out/lib/cups/filter/*; do
      filename=$(basename "$bin")
      if [ -f "$bin" ] && [ ! -L "$bin" ]; then

        # 这里的花招是，把原文件改名，再包装他们
        # 这样生成的包装文件就会替换掉原二进制文件
        mv "$bin" "$out/lib/cups/filter/.$filename-wrapped"

        # 如果修补的是pdftopdf，不要动它自己的路径避免递归错误
        if [ "$filename" = "pantumprint-pdftopdf" ];then
          local redirects="$r_opt:$r_mime" 
        else
          local redirects="$r_opt:$r_mime:$r_filter"
        fi
        
        makeWrapper "$out/lib/cups/filter/.$filename-wrapped" "$bin" \
          --prefix PATH : "${lib.makeBinPath [ coreutils cups ghostscript bc poppler-utils imagemagick gnugrep ]}" \
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
