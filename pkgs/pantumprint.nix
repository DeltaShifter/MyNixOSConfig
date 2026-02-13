{ stdenv
, fetchurl
, autoPatchelfHook
, makeWrapper
, lib
, callPackage
, ...
} @ args:
stdenv.mkDerivation rec {
  pname = "pantumprint";
  version = "2.0.4-1+uos";
  src = fetchurl {
    url = "https://raw.githubusercontent.com/DeltaShifter/CM1115ADN-printer-assets/refs/heads/main/pantum-cm1115-assets.tar.gz";
    sha256 = "sha256-kitxqt9oEm8+PfliN6iau64j2he5Te9Ps1gcl4Xf4BA=";
  };

nativeBuildInputs = [ autoPatchelfHook makeWrapper ];
  unpackPhase = ''
    tar -xzvf $src
    echo "--- Current directory content ---"
    ls -R
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
