{ config, pkgs, lib, ... }:

{
# ← ADD THESE TWO LINES
  nixpkgs.config.allowUnfree = true;           # ← allows Vivaldi, Spotify, etc.
  # (or more precise version below if you prefer)
  # nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "vivaldi" "spotify" ];
  # ── Home Manager basics ─────────────────────
  home.username = "paul";
  home.homeDirectory = "/home/paul";
  home.stateVersion = "25.05";

  programs.home-manager.enable = true;

  # ── Shell (fish) ────────────────────────────
  programs.fish = {
    enable = true;
    shellAbbrs = {
      # Quick access to your big drives
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

  # ── User packages (GUI + everything else) ─────────────────────
  home.packages = with pkgs; [
    # ── Browsers ─────────────────────────────
    firefox
    brave
    vivaldi
    tor-browser-bundle-bin

    # ── Chat / Communication ─────────────────
    discord
    signal-desktop
    telegram-desktop
    element-desktop

    # ── Media ────────────────────────────────
    vlc
    mpv
    haruna
    spotify
    audacious

    # ── Productivity / Notes ─────────────────
    obsidian
    logseq
    trilium-desktop
    joplin-desktop

    # ── File management ──────────────────────
    krusader
    doublecmd
    ranger
    pcmanfm-qt

    # ── Utilities ────────────────────────────
    bitwarden
    proton-pass
    keepassxc
    megasync
    syncthing
    rclone
    rsync
    yt-dlp
    gallery-dl

    # ── Image / Video tools ──────────────────
    gimp
    inkscape
    krita
    darktable
    shotwell
    xnviewmp

    # ── Audio production ─────────────────────
    reaper
    yabridge
    yabridgectl
    wineWowPackages.staging

    # ── Misc ─────────────────────────────────
    appimage-run
    distrobox
    boxes
    neofetch
    onefetch
    btop
    htop
    # ... your other packages ...
    boxbuddy     # ← add this line
    # ... rest ...
  ];

  # ── End of file ─────────────────────────────
}
