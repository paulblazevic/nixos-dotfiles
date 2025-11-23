{ config, pkgs, ... }:

{
  virtualisation.podman.enable = true;
  virtualisation.oci-containers.backend = "podman";

  virtualisation.oci-containers.containers.casaos = {
    image = "docker.io/icewhaleoss/casaos:latest";
    autoStart = true;
    ports = [ "80:80" ];
    volumes = [
      "/home/paul/casaos-data:/DATA"
      "/var/run/podman/podman.sock:/var/run/docker.sock"
    ];
    environment = {
      TZ = "Australia/Sydney";
      PUID = "1000";
      PGID = "1000";
    };
    extraOptions = [ "--userns=keep-id" ];
  };

  networking.firewall.allowedTCPPorts = [ 80 ];
}
