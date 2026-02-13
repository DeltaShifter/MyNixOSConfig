{ stdenv
, fetchurl
, autoPatchelfHook
, makeWrapper
, lib
, callPackage
, dpkg
, ...
} @ args:
stdenv.mkDerivation rec {
  pname = "pantumprint";
  version = "2.0.4-1+uos";
  src = fetchurl {
    url = "https://github.com/DeltaShifter/CM1115ADN-printer-assets/raw/refs/heads/main/pantum-cm1115-assets.tar.gz";
    sha256 = "sha256-kK6K2I7PKtzCrJOijNPU+o6lgZ4Aq4fHrDtwoeLK5l4=";
  };

nativeBuildInputs = [ autoPatchelfHook makeWrapper dpkg ];
  unpackPhase = ''
    dpkg -x $src .
    mv opt/pantum/com.pantum.pantumprint/bin/* filter
    mv opt/pantum/com.pantum.pantumprint/lib/* lib
    mv usr/share/cups/model/pantum/* ppd
  '';

  installPhase = ''
  runHook preInstall
    mkdir -p $out/lib/cups/filter
    mkdir -p $out/lib/pantum
    mkdir -p $out/share/cups/model/pantum
    
    cp -r filter/* $out/lib/cups/filter/
    cp -r lib/* $out/lib/pantum/
    cp -r ppd/* $out/share/cups/model/pantum/

    # 重写ppd文件中的硬编码路径
    for f in $out/share/cups/model/pantum/*.ppd; do
      substituteInPlace "$f" \
        --replace 'pantumprint-pdftopcl' "$out/lib/cups/filter/pantumprint-pdftopcl"
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
