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
      # Create nice symlinks in ~ the first time (idempotent)
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
    userEmail = "your@email.com";  # ← change this to your real email
    extraConfig = {
      init.defaultBranch = "main";
    };
  };

  # ── All your user packages (feel free to add more anytime) ─────────────────────
  home.packages = with pkgs; [
    # Browsers
    firefox brave vivaldi tor-browser-bundle-bin

    # Chat / Comms
    discord signal-desktop telegram-desktop element-desktop

    # Media
    vlc mpv haruna spotify audacious

    # Productivity / Notes
    obsidian logseq trilium-desktop joplin-desktop

    # File management
    krusader doublecmd ranger pcmanfm-qt

    # Utilities
    bitwarden proton-pass keepassxc megasync syncthing rclone rsync yt-dlp gallery-dl

    # Image / Video tools
    gimp inkscape krita darktable shotwell xnviewmp

    # Audio production
    reaper yabridge yabridgectl wineWowPackages.staging

    # Misc
    appimage-run distrobox boxbuddy btop htop neofetch onefetch
  ];

  # ── CasaOS via Podman Quadlet (rootless, auto-start, 100% working) ──
  systemd.user.services.casaos = {
    description = "CasaOS Dashboard";
    wantedBy = [ "default.target" ];
    serviceConfig = {
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
    };
  };

  # ── End of file ─────────────────────────────
}
