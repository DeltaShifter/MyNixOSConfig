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
, gnused
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
  stdenv
  jbigkit
  xz
  dbus-glib
  libsm
  libice
  libx11
  libxext
  ghostscript
  bc
  poppler-utils
  imagemagick
  coreutils
  ];
  unpackPhase = ''
    tar -xzvf $src
    mkdir -p filter lib scripts ppd mime
    mv opt/pantum/com.pantum.pantumprint/bin/* filter
    mv opt/pantum/com.pantum.pantumprint/lib/* lib
    mv opt/pantum/com.pantum.pantumprint/scripts/* scripts
    mv usr/share/cups/model/pantum/* ppd
    mv usr/share/cups/mime/* mime
    ls -R
    echo "test dic tree========================"
  '';

  installPhase = ''
  runHook preInstall
    mkdir -p $out/lib/cups/filter
    mkdir -p $out/lib/pantum
    mkdir -p $out/lib/pantum/scripts/
    mkdir -p $out/share/cups/model/pantum
    mkdir -p $out/share/cups/mime/
    
    cp -r filter/* $out/lib/cups/filter/
    cp -r lib/* $out/lib/pantum/
    cp -r scripts/* $out/lib/pantum/scripts/
    cp -r ppd/* $out/share/cups/model/pantum/
    cp -r mime/* $out/share/cups/mime/

    # 重写ppd文件中的硬编码路径
    for f in $out/share/cups/model/pantum/*.ppd; do
      substituteInPlace "$f" \
      --replace-quiet "pantumprint-commandtodev" "$out/lib/cups/filter/pantumprint-commandtodev" \
      --replace-quiet "pantumprint-pcltobackend" "$out/lib/cups/filter/pantumprint-pcltobackend" \
      --replace-quiet "pantumprint-pdftopcl" "$out/lib/cups/filter/pantumprint-pdftopcl" \
      --replace-quiet "pantumprint-pdftopdf" "$out/lib/cups/filter/pantumprint-pdftopdf" \
      --replace-quiet "pantumprint-rastertogdi_m" "$out/lib/cups/filter/pantumprint-rastertogdi_m" \
      --replace-quiet "pantumprint-rastertogdi_s" "$out/lib/cups/filter/pantumprint-rastertogdi_s"
    done
       
    # 重写pdfscale.sh的硬编码路径
    substituteInPlace $out/lib/pantum/scripts/pdfscale.sh \
      --replace 'GSBIN=""' 'GSBIN="${ghostscript}/bin/gs"' \
      --replace 'BCBIN=""' 'BCBIN="${bc}/bin/bc"' \
      --replace 'PDFINFOBIN=""' 'PDFINFOBIN="${poppler-utils}/bin/pdfinfo"' \
      --replace 'IDBIN=""' 'IDBIN="${imagemagick}/bin/identify"'

    find $out -type f -exec sed -i "s|/opt/pantum/com.pantum.pantumprint|$out/lib/pantum|g" {} +
    for f in $out/lib/cups/filter/*; do
      if [ -f "$f" ] && [ -x "$f" ]; then
        wrapProgram "$f" \
          --prefix PATH : "${lib.makeBinPath [ ghostscript bc poppler-utils imagemagick coreutils gnused ]}" \
          --prefix LD_LIBRARY_PATH : "$out/lib/pantum:${lib.makeLibraryPath buildInputs}"
      fi
    done
    
  runHook postInstall
    '';

  appendRunpaths = ["${placeholder "out"}/lib/pantum"];

  meta = with lib; {
    description = "Pantum printer driver (based on UOS deb package)";
    platforms = platforms.linux;
    license = licenses.unfree;
    };
  }
