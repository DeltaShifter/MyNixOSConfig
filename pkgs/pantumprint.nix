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
, cups-filters
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
    "$out/usr/lib/x86_64-linux-gnu/sane/"
    "$out/local/lib/sane/"
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
    dpkg -x $src .
    rm -rf opt/apps
    '';

  installPhase = ''
  runHook preInstall
    
    mkdir -p $out
    mkdir -p $out/lib/cups/filter/
    mkdir -p $out/share/cups/mime/
    mkdir -p $out/share/cups/model/pantum/
    mkdir -p $out/opt/scripts # 在报错日志发行scripts后处理这些
    
    cp -rf opt/pantum/com.pantum.pantumprint/bin/* $out/lib/cups/filter/
    cp -rf usr/share/cups/mime/* $out/share/cups/mime/
    cp -rf usr/share/cups/model/pantum/* $out/share/cups/model/pantum/
    cp -rf opt/pantum/com.pantum.pantumprint/scripts/* $out/opt/scripts/

    mkdir -p $out/opt/pantum/com.pantum.pantumprint/lib # 处理私有库，保持文件夹结构
    mkdir -p $out/usr/local/lib
    mkdir -p $out/usr/lib

    cp -rf opt/pantum/com.pantum.pantumprint/lib/* $out/opt/pantum/com.pantum.pantumprint/lib
    cp -rf usr/local/lib/* $out/usr/local/lib
    cp -rf usr/lib/* $out/usr/lib
    
    # 赋予执行权限以便 Patchelf 处理
    find $out/lib/cups/filter/* -exec chmod +x {} +
    find $out/ -name "*.so*" -exec chmod +x {} +

    # 脚本路径修复
    scriptsDir="$out/opt/scripts"
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
  
  #   路径重定向映射
  #   local r_opt="/opt/pantum=$out/opt/pantum"
  #   local r_mime="/usr/share/cups=$out/share/cups"
  #   local r_filter="/usr/lib/cups/filter/pdftopdf=$pdftopdf"
  #   local redirects="$r_opt:$r_mime:$r_filter" 

    for bin in $out/lib/cups/filter/*; do
      filename=$(basename "$bin")
      if [ -f "$bin" ] && [ ! -L "$bin" ]; then

        # 这里的花招是，把原文件改名，再包装他们
        # 这样生成的包装文件就会替换掉原二进制文件
        mv "$bin" "$out/lib/cups/filter/.$filename-wrapped"
        local rdScripts="/opt/pantum/com.pantum.pantumprint/scripts/=$scriptsDir/"
        local rdPdf2pdf="/usr/lib/cups/filter/pdftopdf=${cups-filters}/lib/cups/filter/pdftopdf"
        local redirects="$rdScripts:$rdPdf2pdf"
  #       # 如果修补的是pdftopdf，不要动它自己的路径避免递归错误
  #       if [ "$filename" = "pantumprint-pdftopdf" ];then
  #         local redirects="$r_opt:$r_mime" 
  #       else
  #         local redirects="$r_opt:$r_mime:$r_filter"
        # fi
        
        makeWrapper "$out/lib/cups/filter/.$filename-wrapped" "$bin" \
          --prefix PATH : "${lib.makeBinPath [ coreutils ghostscript ]}" \
          --set LD_PRELOAD "${libredirect}/lib/libredirect.so" \
          --set NIX_REDIRECTS "$redirects" \
          # --prefix LD_LIBRARY_PATH : "$all_lib_dirs" \
          # --set CUPS_SERVERBIN "${cups}/lib/cups" \
          # --set CUPS_DATADIR "$out/share/cups" \
          # --run "${coreutils}/bin/mkdir -p /tmp/pantum/com.pantum.pantumprint" \
          # --run "${coreutils}/bin/ln -sfn $out/opt/pantum/com.pantum.pantumprint/scripts /tmp/pantum/com.pantum.pantumprint/scripts"
      fi
    done
  
  '';
}
