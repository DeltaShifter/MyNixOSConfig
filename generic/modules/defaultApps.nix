{...}:
{
  services.xserver.desktopManager.gnome.extraGSettingsOverrides = ''
    [org.gnome.desktop.default-applications.terminal]
    exec='alacritty'
  '';
}
