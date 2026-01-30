{ config, pkgs, ... }:

{
  virtualisation.docker.enable = true;
  users.users.dale.extraGroups = [ "docker" ];
  virtualisation.docker.autoPrune.enable = true;

  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      portainer = {
        image = "6053537/portainer-ce";
        ports = [ "9000:9000" ];
        volumes = [
          "/var/run/docker.sock:/var/run/docker.sock"
          "portainer_data:/data"
        ];
      };
    };
  };

  environment.systemPackages = with pkgs; [
    docker-compose
    ctop
  ];
}
