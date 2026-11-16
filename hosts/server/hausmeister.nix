# Arbeitsplatz für die Pflege der Aushänge: ein eigenes Konto ohne Verwaltungsrechte und ein Starter, der die
# Xibo-Oberfläche als eigenes Fenster öffnet (ohne Adressleiste, wie ein Programm).
{ pkgs, ... }:
let
  aushang = pkgs.makeDesktopItem {
    name = "aushang";
    desktopName = "Aushang bearbeiten";
    comment = "Seiten für den Bildschirm gestalten";
    exec = "${pkgs.chromium}/bin/chromium --app=http://localhost --start-maximized";
    icon = "preferences-desktop-display";
    categories = [ "Office" ];
  };
in
{
  # Das Passwort wird am Gerät gesetzt (sudo passwd hausmeister), nie hier
  users.users.hausmeister = {
    isNormalUser = true;
    description = "Hausmeister";
  };

  environment.systemPackages = [ pkgs.chromium aushang ];

  # Starter auch auf dem Schreibtisch; je nach Sprache heißt der Ordner Desktop oder Schreibtisch
  systemd.tmpfiles.rules = [
    "d /home/hausmeister/Desktop 0755 hausmeister users -"
    "d /home/hausmeister/Schreibtisch 0755 hausmeister users -"
    "C+ /home/hausmeister/Desktop/aushang.desktop 0755 hausmeister users - ${aushang}/share/applications/aushang.desktop"
    "C+ /home/hausmeister/Schreibtisch/aushang.desktop 0755 hausmeister users - ${aushang}/share/applications/aushang.desktop"
  ];
}
