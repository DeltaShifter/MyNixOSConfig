{ ... }:
{
nixpkgs.overlays = [
  (final: prev: {
    alacritty = prev.alacritty.overrideAttrs (oldAttrs: {
      # 替换为分叉的源码
      src = final.fetchFromGitHub {
        owner = "GregTheMadMonk";
        repo = "alacritty-smooth-cursor";
        # 建议锁定一个具体的 commit，这里用主分支最新的 commit
        rev = "master"; 
        # 第一次构建时先把 hash 设为空，Nix 会报错并告诉你正确的 hash
        hash = ""; 
      };
      version = "0.13.0-smooth-cursor"; 
    });
  })
];
}
