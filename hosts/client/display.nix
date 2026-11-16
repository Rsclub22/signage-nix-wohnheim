# Anzeige-Client: startet bei jedem Einschalten über das Netz vom Server, läuft im Arbeitsspeicher und zeigt nur den
# Xibo-Abspieler im Vollbild. Auf der eingebauten Platte liegt allein, was einen Neustart überleben muss
# (Anmeldung der Anzeige am Server, Zwischenspeicher der Seiten).
{ modulesPath, pkgs, ... }:
let
  xibo-player = pkgs.callPackage ../../pkgs/xibo-player.nix { };
in
{
  imports = [ (modulesPath + "/installer/netboot/netboot-minimal.nix") ];

  networking.hostName = "signage-mlr-sm-display01";
  time.timeZone = "Europe/Berlin";
  console.keyMap = "de";

  # Zugang für die Pflege, nur per SSH-Schlüssel
  users.users.nixos.openssh.authorizedKeys.keyFiles = [ ../server/authorized_keys ];

  # Datenpartition auf der eingebauten Platte; fehlt sie, startet die Anzeige trotzdem (dann ohne Gedächtnis)
  fileSystems."/var/lib/signage" = {
    device = "/dev/disk/by-label/signage-data";
    fsType = "ext4";
    options = [ "nofail" "x-systemd.device-timeout=15s" ];
  };
  users.users.signage = {
    isNormalUser = true;
    home = "/var/lib/signage/home";
    createHome = false;
    extraGroups = [ "video" "audio" "input" ];
  };
  systemd.tmpfiles.rules = [ "d /var/lib/signage/home 0700 signage users -" ];

  hardware.graphics.enable = true;
  fonts.packages = with pkgs; [ dejavu_fonts liberation_ttf noto-fonts ];

  # Ein einziges Programm im Vollbild, ohne Desktop
  services.cage = {
    enable = true;
    user = "signage";
    program = "${xibo-player}/bin/xibo-player";
  };
  systemd.services."cage-tty1" = {
    after = [ "var-lib-signage.mount" "systemd-tmpfiles-setup.service" "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig.Restart = "always";
    serviceConfig.RestartSec = 5;
  };

  system.stateVersion = "26.05";
}
