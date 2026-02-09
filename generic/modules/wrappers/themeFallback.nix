{ pkgs , ... }:
{
  nixpkgs.overlays = [
  (
    final: prev: 
    let     
    themeFallback = pkg: prev.symlinkJoin {
    name = "${pkg.pname or pkg.name}";
    paths = [ pkg ];
    nativeBuildInputs = [ final.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/${pkg.pname or pkg.name} \
        --set XDG_CONFIG_HOME "$HOME/.config/gtk-4.0-isolated" \
      '';
      };
    in
    {
      clapper = themeFallback prev.clapper;
      loupe = themeFallback prev.loupe;
      ghostty = themeFallback prev.ghostty;
    }
  )
  ];

}
