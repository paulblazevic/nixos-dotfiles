{ config, pkgs, ... }:

{
  virtualisation.containers.enable = true;
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;  # For container networking
  };
  virtualisation.oci-containers.backend = "podman";

  virtualisation.oci-containers.containers.casaos = {
    image = "casaos/casaos:latest";
    autoStart = true;
    ports = [ "8080:80" ];
    volumes = [
      "/home/paul/casaos-data:/DATA"
      "/run/podman/podman.sock:/var/run/docker.sock"
    ];
    environment = {
      TZ = "Australia/Sydney";
    };
    extraOptions = [ "--userns=keep-id" ];
  };

  networking.firewall.allowedTCPPorts = [ 8080 ];
  users.groups.podman.members = [ "paul" ];  # Rootless access for your user
}
