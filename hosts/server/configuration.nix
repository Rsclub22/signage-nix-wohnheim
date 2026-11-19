# Server des Aushang-Bildschirms: Arbeitsplatz für die Pflege der Seiten und Quelle für den Anzeige-Client.
# Stand: Grundinstallation. Signage-Software, das Netz zum Client und die Updates kommen noch.
{ config, pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/disk/by-id/ata-SAMSUNG_HD161GJ_S14DJ9GZ604824";

  networking.hostName = "signage-mlr-sm-srv01";
  networking.networkmanager.enable = true;
  # Keine feste Adresse (Philipp, 20.11.2026): Der Server meldet sich per mDNS als signage-mlr-sm-srv01.local.
  # Anzeige und Xibo-Adressen nutzen diesen Namen statt der IP, die der Router vergibt.
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
    publish = { enable = true; addresses = true; };
  };
  # Updates holt sich der Server nachts selbst aus dem öffentlichen Repo. Ohne Internet schlägt der Lauf fehl
  # und die laufende Generation bleibt. Kein automatischer Neustart; der Anzeige-Client bekommt das neue Abbild
  # bei seinem nächsten Start.
  system.autoUpgrade = {
    enable = true;
    flake = "github:Rsclub22/signage-nix-wohnheim#signage-mlr-sm-srv01";
    dates = "03:30";
    randomizedDelaySec = "30min";
    allowReboot = false;
  };

  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "de_DE.UTF-8";
  console.keyMap = "de";

  # Der Rechner bedient die Anzeige und darf nie von selbst schlafen gehen, auch nicht auf Wunsch des Desktops
  # (Plasma hatte ihn nach einer Viertelstunde ohne Eingabe in den Ruhezustand geschickt).
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  services.xserver.enable = true;
  services.xserver.xkb.layout = "de";
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  users.users.philipp = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    openssh.authorizedKeys.keyFiles = [ ./authorized_keys ];
  };
  # Nur für den Aufbau: Das Konto hat noch kein Passwort, Anmeldung geht allein per SSH-Schlüssel.
  # Wird wieder entfernt, sobald das Passwort am Gerät gesetzt ist.
  security.sudo.wheelNeedsPassword = false;

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
    settings.PermitRootLogin = "no";
  };

  environment.systemPackages = with pkgs; [ git vim smartmontools ];
  # Die Platte des Servers ist alt (Samsung HD161GJ): SMART-Werte überwachen, Ausfälle im Journal
  services.smartd.enable = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  # Der alte Rechner ist beim Bauen unter Volllast eingefroren (16.11.2026): Bauen läuft gebremst und mit Nachrang,
  # damit Verwaltung und Anzeige dabei weiterlaufen.
  nix.settings.max-jobs = 1;
  nix.settings.cores = 2;
  nix.daemonCPUSchedPolicy = "idle";
  nix.daemonIOSchedClass = "idle";

  system.stateVersion = "26.05";
}
