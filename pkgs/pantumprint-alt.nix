
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
    mkdir -p $out/lib/cups/filter
    mkdir -p $out/share/cups/mime
    mkdir -p $out/share/cups/model/pantum
    
    cp -r opt $out/
    cp -r usr $out/

    for file in $out/opt/pantum/com.pantum.pantumprint/bin/*; do
      ln -s "$file" "$out/lib/cups/filter/$(basename "$file")"
    done

    for file in $out/usr/share/cups/mime/*; do
      ln -s "$file" "$out/share/cups/mime/$(basename "$file")"
    done
    
    for file in $out/usr/share/cups/model/pantum/*; do
      ln -s "$file" "$out/share/cups/model/pantum/$(basename "$file")"
    done

    
    # 赋予执行权限以便 Patchelf 处理
    find $out/opt/pantum/com.pantum.pantumprint/bin/* -exec chmod +x {} +
    find $out/ -name "*.so*" -exec chmod +x {} +

    # 脚本路径修复
    scriptsDir="$out/opt/pantum/com.pantum.pantumprint/scripts/"
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
    # 查找真正的系统 pdftopdf 路径（cups-filters 包提供）
    local sys_pdftopdf="${cups-filters}/lib/cups/filter/pdftopdf"
    
    # 路径重定向映射
    local rdScript="/opt/pantum/com.pantum.pantumprint/scripts=$out/opt/pantum/com.pantum.pantumprint/scripts"
    local rdOpt="/opt/pantum=$out/opt/pantum"
    local rdMime="/usr/share/cups=$out/share/cups"
    local rdFilter="/usr/lib/cups/filter/pdftopdf=$sys_pdftopdf"
    local redirects="$rdScript:$rdOpt:$rdMime:$rdFilter"

    for bin in $out/lib/cups/filter/*; do
      if [ -f "$bin" ] && [ ! -L "$bin" ]; then
        filename=$(basename "$bin")
        
        mv "$bin" "$out/lib/cups/filter/.$filename-wrapped"
        
        makeWrapper "$out/lib/cups/filter/.$filename-wrapped" "$bin" \
          --prefix PATH : "${lib.makeBinPath [ coreutils ghostscript bc poppler-utils cups cups-filters ]}" \
          --prefix LD_LIBRARY_PATH : "$out/opt/pantum/com.pantum.pantumprint/lib" \
          --set LD_PRELOAD "${libredirect}/lib/libredirect.so" \
          --set NIX_REDIRECTS "$redirects"
      fi
    done
  '';
  
}
