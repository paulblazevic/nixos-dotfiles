{ config, pkgs, lib, ... }:

{
  home.username = "paul";
  home.homeDirectory = "/home/paul";
  home.stateVersion = "25.05";

  nixpkgs.config.allowUnfree = true;
  programs.home-manager.enable = true;

  # Shell
  programs.fish.enable = true;
  programs.fish.shellAbbrs = { cd5 = "cd /mnt/data500"; cd18 = "cd /mnt/data18tb"; };
  programs.fish.loginShellInit = ''
    [ ! -L ~/Data500 ]  && ln -sf /mnt/data500  ~/Data500
    [ ! -L ~/Data18TB ] && ln -sf /mnt/data18tb ~/Data18TB
  '';

  programs.starship.enable = true;
  programs.zoxide.enable = true;

  # Packages
  home.packages = with pkgs; [
    firefox brave vivaldi discord signal-desktop telegram-desktop vlc spotify
    obsidian bitwarden megasync syncthing boxbuddy btop neofetch
  ];

  # Rootless Podman setup (required for services.podman)
  virtualisation.podman.enable = true;

  # CasaOS – stable rootless Podman service via Home Manager module
  services.podman = {
    enable = true;
    dockerSocket.enable = true;
    defaultNetwork.settings.dns_enabled = true;
    autoStart = true;

    containers.casaos = {
      image = "casaos/casaos:latest";
      autoStart = true;
      ports = [ "8080:80" ];
      volumes = [
        "${config.home.homeDirectory}/casaos-data:/DATA"
        "/run/user/1000/podman/podman.sock:/var/run/docker.sock"
      ];
      environment = {
        TZ = "Australia/Sydney";
      };
      extraOptions = [ "--userns=keep-id" ];
    };
  };
}
