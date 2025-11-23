{ config, pkgs, lib, ... }:

{
  virtualisation.containers.enable = true;
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };
  virtualisation.oci-containers.backend = "podman";

  virtualisation.oci-containers.containers.casaos = lib.mkForce {
    image = lib.mkForce "casaos/casaos:latest";
    autoStart = true;
    ports = [ "8080:80" ];
    volumes = [
      "/home/paul/casaos-data:/DATA"
      "/run/podman/podman.sock:/var/run/docker.sock"
    ];
    environment = {
      TZ = "Australia/Sydney";
    };
    extraOptions = [ "--privileged" ];  # Required for CasaOS Docker management
  };

  networking.firewall.allowedTCPPorts = [ 8080 ];
  users.groups.podman.members = [ "paul" ];  # For user access to podman commands
}
