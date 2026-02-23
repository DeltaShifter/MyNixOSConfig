{ config, pkgs, lib, ... }:

let
  isX1c = config.networking.hostName == "X1c";

  # 针对 wpsoffice-cn 的定制包装
  myWps = if isX1c then pkgs.symlinkJoin {
    name = "wpsoffice-cn-wrapped";
    paths = [ pkgs.wpsoffice-cn ]; # 包含原包所有文件（share, lib等）
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      # 遍历 bin 目录下所有可执行文件进行包装
      # 这样能确保 wps, et, wpp 以及相关的辅助工具都带上 DPI 参数
      for binary in $out/bin/*; do
        # 必须先删掉 symlink 才能创建 wrapper 脚本，否则会循环引用
        if [ -L "$binary" ]; then
          real_prog=$(readlink -f "$binary")
          rm "$binary"
          makeWrapper "$real_prog" "$binary" --set QT_FONT_DPI "144"
        fi
      done
    '';
  } else pkgs.wpsoffice-cn;

in {
  environment.systemPackages = [
    myWps
  ];
}
