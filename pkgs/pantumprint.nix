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
, ...
} @ args:
stdenv.mkDerivation rec {
  pname = "pantumprint";
  version = "2.0.4-1+uos";
  src = fetchurl {
    url = "https://raw.githubusercontent.com/DeltaShifter/CM1115ADN-printer-assets/refs/heads/main/pantum-cm1115-assets.tar.gz";
    sha256 = "sha256-i9DOxGR5JXW4lt6yFJ4tVImLfFHoieE9VjUTyx/X2Og=";
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
  ];
  unpackPhase = ''
    tar -xzvf $src
    mkdir -p filter lib ppd mime
    mv opt/pantum/com.pantum.pantumprint/bin/* filter
    mv opt/pantum/com.pantum.pantumprint/lib/* lib
    mv usr/share/cups/model/pantum/* ppd
    mv usr/share/cups/mime/* mime
    ls -R
    echo "test dic tree========================"
  '';

  installPhase = ''
  runHook preInstall
    mkdir -p $out/lib/cups/filter
    mkdir -p $out/lib/pantum
    mkdir -p $out/share/cups/model/pantum
    mkdir -p $out/share/cups/mime/
    
    cp -r filter/* $out/lib/cups/filter/
    cp -r lib/* $out/lib/pantum/
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
       
  runHook postInstall
    '';

  appendRunpaths = ["${placeholder "out"}/lib/pantum"];

  meta = with lib; {
    description = "Pantum printer driver (based on UOS deb package)";
    platforms = platforms.linux;
    license = licenses.unfree;
    };
  }
