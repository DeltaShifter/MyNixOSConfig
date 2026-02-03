{ config, lib, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
  samba
  gst_all_1.gstreamer
  gst_all_1.gst-plugins-base
  gst_all_1.gst-plugins-good
  gst_all_1.gst-plugins-bad
  gst_all_1.gst-plugins-ugly  # SMB 支持通常在这里
  gst_all_1.gst-libav
  glib-networking 
];
  environment.sessionVariables.GST_PLUGIN_SYSTEM_PATH_1_0 = lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0" (with pkgs.gst_all_1; [
  gst-plugins-good
  gst-plugins-bad
  gst-plugins-ugly
  gst-libav
  ]);
}
