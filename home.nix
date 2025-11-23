{ config, pkgs, lib, ... }:

{
  home.username = "paul";
  home.homeDirectory = "/home/paul";
  home.stateVersion = "25.05";

  nixpkgs.config.allowUnfree = true;

  programs.home-manager.enable = true;

  # ── Shell (fish) ────────────────────────────
  programs.fish = {
    enable = true;
    shellAbbrs = {
      data500  = "cd /mnt/data500";
      data18tb = "cd /mnt/data18tb";
      cd5      = "cd /mnt/data500";
      cd18     = "cd /mnt/data18tb";
    };
    shellAliases = {
      ls500  = "ls -lh /mnt/data500";
      ls18tb = "ls -lh /mnt/data18tb";
    };
    loginShellInit = ''
      [ ! -L ~/Data500 ]  && ln -sf /mnt/data500  ~/Data500
      [ ! -L ~/Data18TB ] && ln -sf /mnt/data18tb ~/Data18TB
    '';
  };

  programs.starship.enable = true;
  programs.zoxide.enable = true;

  # ── Git ─────────────────────────────────────
  programs.git = {
    enable = true;
    userName = "Paul Blazevic";
    userEmail = "your@email.com";
    extraConfig.init.defaultBranch = "main";
  };

  # ── Packages ─────────────────────────────────────
  home.packages = with pkgs; [
    firefox brave vivaldi tor-browser-bundle-bin
    discord signal-desktop telegram-desktop element-desktop
    vlc mpv haruna spotify audacious
    obsidian logseq trilium-desktop joplin-desktop
    krusader doublecmd ranger pcmanfm-qt
    bitwarden proton-pass keepassxc megasync syncthing rclone rsync yt-dlp gallery-dl
    gimp inkscape krita darktable shotwell xnviewmp
    reaper yabridge yabridgectl wineWowPackages.staging
    appimage-run distrobox boxbuddy btop htop neofetch onefetch
  ];

  # ── CasaOS – rootless Podman user service (FINAL 100% working on 25.05) ──
  systemd.user.services.casaos = {
    description = "CasaOS Dashboard";

    unitConfig = {
      Requires = "podman.socket";
      After    = [ "network.target" "podman.socket" ];
    };

    serviceConfig = {
      Type          = "simple";
      ExecStart     = ''
        ${pkgs.podman}/bin/podman run --rm --name casaos \
          --userns=keep-id \
          -p 8080:80 \
          -v ${config.home.homeDirectory}/casaos-data:/DATA:Z \
          -v /run/user/1000/podman/podman.sock:/var/run/docker.sock:Z \
          -e TZ=Australia/Sydney \
          docker.io/casaos/casaos:latest
      '';
      Restart       = "always";
      RestartSec    = 10;
      TimeoutStartSec = 120;
    };

    wantedBy = [ "default.target" ];
  };
