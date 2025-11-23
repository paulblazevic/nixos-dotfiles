{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
  # ... your other imports (if any)
];

  # ── Nix settings ─────────────────────
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  # ── Bootloader ───────────────────────
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # ── Basic system ─────────────────────
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  time.timeZone = "Australia/Sydney";
  i18n.defaultLocale = "en_AU.UTF-8";

  # ── Desktop (Plasma 6) ───────────────
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.xserver.xkb.layout = "au";

  # ── Audio (PipeWire) ─────────────────
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # ── Services you actually want system-wide ──
  services.printing.enable = true;
  services.cockpit.enable = true;
  services.flatpak.enable = true;

  # Firewall – web stuff + Cockpit
  networking.firewall.allowedTCPPorts = [ 80 443 7080 8090 8083 8443 ];

  # ── 1Password (system-wide is fine) ──
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "paul" ];
  };

  # ── Podman (Docker compatible) ───────
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };
  virtualisation.docker.enable = lib.mkForce false;

  # Distrobox extra volume (recommended)
  environment.etc."distrobox/distrobox.conf".text = ''
    container_additional_volumes="/nix/store:/nix/store:ro"
  '';

  # ── User paul ────────────────────────
  users.users.paul = {
    isNormalUser = true;
    description = "Paul Blazevic";
    extraGroups = [ "wheel" "networkmanager" "podman" "audio" "video" ];
    initialPassword = "changeme"; # change this ASAP
    subUidRanges = [{ startUid = 100000; count = 65536; }];
    subGidRanges = [{ startGid = 100000; count = 65536; }];
  };

  # ── System packages ──────────────────
  environment.systemPackages = with pkgs; [
    distrobox
    podman-compose
    boxbuddy
    btop
    git
    wget
    curl
    openssl
    proton-pass
    firefox
    vivaldi
  ];

  # ── Flatpaks (run once on user login) ──
  system.userActivationScripts.installFlatpaks = lib.mkAfter ''
    ${pkgs.flatpak}/bin/flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    ${pkgs.flatpak}/bin/flatpak install --user --or-update -y flathub \
      com.bitwarden.desktop \
      com.spotify.Client \
      com.valvesoftware.Steam \
      com.github.megasync.MEGAsync \
      com.protonvpn.www \
      com.github.FreeTube \
      com.github.jean28518.Upscayl \
      com.reaper.Reaper \
      org.kde.krusader \
      org.kde.kid3 \
      org.gnome.SoundJuicer \
      io.github.alpaka.Alpaka \
      org.kde.nota \
      org.kde.karp \
      md.obsidian.Obsidian \
      com.github.witcher3d.puddletag \
      org.kde.haruna \
      org.KDE.dragon \
      com.github.tchx84.Flatseal \
      org.xnview.XnViewMP \
      || true
  '';

  # Optional: auto-start BoxBuddy
  systemd.user.services.boxbuddy = {
    description = "BoxBuddy – Distrobox GUI";
    wantedBy = [ "graphical-session.target" ];
    serviceConfig = { ExecStart = "${pkgs.boxbuddy}/bin/boxbuddy"; Restart = "on-failure"; };
  };

  # ──────────────────────────────────────
  # AUTO-MOUNT THE TWO EXTRA DRIVES AT BOOT
  # ──────────────────────────────────────
  fileSystems."/mnt/data500" = {
    device = "/dev/disk/by-uuid/05daed79-cf4e-4379-90b5-eb8c89d11693";
    fsType = "ext4";
    options = [ "defaults" "nofail" ];
  };

  fileSystems."/mnt/data18tb" = {
    device = "/dev/disk/by-uuid/d34f950d-8125-43be-9f4c-2976fd420265";
    fsType = "ext4";
    options = [ "defaults" "nofail" ];
  };

  # ── End of file ──────────────────────
  system.stateVersion = "25.05";
}

# Quadlet user generator for rootless Podman (fixes generation of .service files)
environment.etc."systemd/user-generators/podman-user-generator".source = "${pkgs.podman}/lib/systemd/user-generators/podman-user-generator";
