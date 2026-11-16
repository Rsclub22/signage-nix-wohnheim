# Arbeitsplatz für die Pflege der Aushänge: ein eigenes Konto (ohne Verwaltungsrechte am System) und ein Starter, der die
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
  # Der Rechner steht im Raum des Hausmeisters und startet ohne Anmeldung direkt in dessen Konto. Das Konto hat
  # bewusst kein Passwort; von außen ist es nicht nutzbar, weil SSH nur Schlüssel annimmt.
  users.users.hausmeister = {
    isNormalUser = true;
    description = "Hausmeister";
    initialHashedPassword = "";
  };
  services.displayManager.autoLogin = {
    enable = true;
    user = "hausmeister";
  };
  # Keine Bildschirmsperre: Ein Konto ohne Passwort soll sich nicht selbst aussperren
  environment.etc."xdg/kscreenlockerrc".text = ''
    [Daemon]
    Autolock=false
    LockOnResume=false
  '';

  environment.systemPackages = [ pkgs.chromium aushang ];

  # Starter auch auf dem Schreibtisch; je nach Sprache heißt der Ordner Desktop oder Schreibtisch
  systemd.tmpfiles.rules = [
    "d /home/hausmeister/Desktop 0755 hausmeister users -"
    "d /home/hausmeister/Schreibtisch 0755 hausmeister users -"
    "C+ /home/hausmeister/Desktop/aushang.desktop 0755 hausmeister users - ${aushang}/share/applications/aushang.desktop"
    "C+ /home/hausmeister/Schreibtisch/aushang.desktop 0755 hausmeister users - ${aushang}/share/applications/aushang.desktop"
  ];
}
