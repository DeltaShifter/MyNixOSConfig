{ pkgs , ... }:
{
  nixpkgs.overlays = [
  (
    final: prev: 
    let     
      themeFallback = pkg: prev.symlinkJoin {
      name = "${pkg.pname or pkg.name}-${pkg.version or "0.0.0"}";
      paths = [ pkg ];
      nativeBuildInputs = [ final.makeWrapper ];
  
      postBuild = ''
        wrapProgram $out/bin/${pkg.pname or pkg.name} \
        --run 'export XDG_CONFIG_HOME="$HOME/.config/gtk-isolated"'

    '';
    };
    in
    {
      clapper = themeFallback prev.clapper;
      loupe = themeFallback prev.loupe;
    }
 )
 ];

}
