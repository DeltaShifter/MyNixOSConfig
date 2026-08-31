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
  environment.sessionVariables = {
    GST_PLUGIN_SYSTEM_PATH_1_0 = "/run/current-system/sw/lib/gstreamer-1.0";
  };
}
