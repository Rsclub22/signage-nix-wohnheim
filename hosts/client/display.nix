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
    options = [ "nofail" "x-systemd.device-timeout=60s" ];
  };
  users.users.signage = {
    isNormalUser = true;
    home = "/var/lib/signage/home";
    createHome = false;
    extraGroups = [ "video" "audio" "input" ];
  };
  # Das Heimatverzeichnis liegt auf der Datenpartition und wird erst nach deren Einhängen angelegt
  systemd.services.signage-home = {
    description = "Heimatverzeichnis der Anzeige auf der Datenpartition";
    wantedBy = [ "multi-user.target" ];
    before = [ "cage-tty1.service" ];
    after = [ "var-lib-signage.mount" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.coreutils}/bin/install -d -o signage -g users -m 0700 /var/lib/signage/home";
    };
  };

  hardware.graphics.enable = true;
  # Die Grafik (Radeon HD 6250) und die Netzwerkkarte brauchen Firmware aus linux-firmware; ohne sie gibt es kein Bild
  hardware.enableRedistributableFirmware = true;
  fonts.packages = with pkgs; [ dejavu_fonts liberation_ttf noto-fonts ];

  # Ein einziges Programm im Vollbild, ohne Desktop
  services.cage = {
    enable = true;
    user = "signage";
    program = "${xibo-player}/bin/xibo-player";
  };
  systemd.services."cage-tty1" = {
    after = [ "signage-home.service" "network-online.target" ];
    requires = [ "signage-home.service" ];
    wants = [ "network-online.target" ];
    serviceConfig.Restart = "always";
    serviceConfig.RestartSec = 5;
  };

  system.stateVersion = "26.05";
}
