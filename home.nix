{ config, pkgs, lib, ... }:

{
  home.username = "paul";
  home.homeDirectory = "/home/paul";
  home.stateVersion = "25.05";

  nixpkgs.config.allowUnfree = true;
  programs.home-manager.enable = true;

  # ── Shell ─────────────────────────────────────
  programs.fish = {
    enable = true;
    shellAbbrs = {
      cd5  = "cd /mnt/data500";
      cd18 = "cd /mnt/data18tb";
    };
    loginShellInit = ''
      [ ! -L ~/Data500 ]  && ln -sf /mnt/data500  ~/Data500
      [ ! -L ~/Data18TB ] && ln -sf /mnt/data18tb ~/Data18TB
    '';
  };

  programs.starship.enable = true;
  programs.zoxide.enable = true;

  # ── Git ───────────────────────────────────────
  programs.git = {
    enable = true;
    userName = "Paul Blazevic";
    userEmail = "your@email.com";
    extraConfig.init.defaultBranch = "main";
  };

  # ── Packages ──────────────────────────────────
  home.packages = with pkgs; [
    firefox brave vivaldi discord signal-desktop telegram-desktop vlc spotify
    obsidian bitwarden megasync syncthing boxbuddy btop neofetch
    # ← add whatever else you want here anytime
  ];

  # ── CasaOS – rootless Podman (FINAL working version) ──
  systemd.user.services.casaos = {
    description = "CasaOS Dashboard";

    unitConfig = {
      Requires = "podman.socket";
      After    = [ "network.target" "podman.socket" ];
    };

    serviceConfig = {
      Type = "simple";
      ExecStart = ''
        ${pkgs.podman}/bin/podman run --rm --name casaos \
          --userns=keep-id \
          -p 8080:80 \
          -v ${config.home.homeDirectory}/casaos-data:/DATA:Z \
          -v /run/user/1000/podman/podman.sock:/var/run/docker.sock:Z \
          -e TZ=Australia/Sydney \
          docker.io/casaos/casaos:latest
      '';
      Restart = "always";
      RestartSec = 10;
      TimeoutStartSec = 120;
    };

    install = {
      WantedBy = [ "default.target" ];
    };
  };
}
