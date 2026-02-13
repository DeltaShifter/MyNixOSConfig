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
, gnugrep
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
  gnugrep
  ];
  unpackPhase = ''
    tar -xzvf $src
    mkdir -p filter lib scripts ppd mime
    mv opt/pantum/com.pantum.pantumprint/bin/* filter
    mv opt/pantum/com.pantum.pantumprint/lib/* lib
    mv opt/pantum/com.pantum.pantumprint/scripts/* scripts
    mv usr/share/cups/model/pantum/* ppd
    mv usr/share/cups/mime/* mime
  '';

  installPhase = ''
  runHook preInstall
    mkdir -p $out/lib/cups/filter
    mkdir -p $out/lib/pantum
    mkdir -p $out/lib/pantum/scripts/
    mkdir -p $out/share/cups/model/pantum
    mkdir -p $out/share/cups/mime/
    
    cp -r filter/* $out/lib/
    cp -r lib/* $out/lib/pantum/
    cp -r scripts/* $out/lib/pantum/scripts/
    cp -r ppd/* $out/share/cups/model/pantum/
    cp -r mime/* $out/share/cups/mime/

    # 重写pdfscale.sh的硬编码路径
    local pdfscale="$out/lib/pantum/scripts/pdfscale.sh"
    substituteInPlace "$pdfscale" \
      --replace 'GSBIN="$(which gs 2>/dev/null)"' 'GSBIN="${ghostscript}/bin/gs"' \
      --replace 'BCBIN="$(which bc 2>/dev/null)"' 'BCBIN="${bc}/bin/bc"' \
      --replace 'PDFINFOBIN="$(which pdfinfo 2>/dev/null)"' 'PDFINFOBIN="${poppler-utils}/bin/pdfinfo"' \
      --replace 'IDBIN=$(which identify 2>/dev/null)' 'IDBIN="${imagemagick}/bin/identify"' \
      --replace 'GREPBIN="$(which grep 2>/dev/null)"' 'GREPBIN="${gnugrep}/bin/grep"'
    patchShebangs $out/lib/pantum/scripts/
      
  runHook postInstall
    '';

  appendRunpaths = ["${placeholder "out"}/lib/pantum"];

  postFixup = ''
    find $out -type f -executable -exec autoPatchelf {} +
  '';

  meta = with lib; {
    description = "Pantum printer driver (based on UOS deb package)";
    platforms = platforms.linux;
    };
  }
