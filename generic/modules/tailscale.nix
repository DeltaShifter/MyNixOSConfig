{config , ... ;}

{
services.tailscale.enable = true;
services.tailscale.extraDaemonFlags = ["--no-logs-no-support"];

}
