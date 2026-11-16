# signage-nix-wohnheim

NixOS-Konfiguration für einen Aushang-Bildschirm in einem Wohnheim: ein Server, an dem die Seiten gepflegt werden,
und ein Anzeige-Client am Bildschirm.

**Stand:** Aufbau im Versuch. Der Server betreibt die Xibo-Verwaltung in Containern und liefert dem Anzeige-Client sein
System über das Netz aus. Automatische Updates fehlen noch.

## Aufbau

- `hosts/server/`: der Server `signage-mlr-sm-srv01` (Desktop-PC, Plasma, SSH nur mit Schlüssel). Er liefert dem
  Anzeige-Client beim Start über das Netz (PXE) ein Installationsabbild aus.
- `hosts/client/`: der Anzeige-Client. Er wird nicht installiert, sondern startet bei jedem Einschalten das Abbild
  vom Server und zeigt den Xibo-Abspieler im Vollbild. Auf seiner Platte liegt nur eine Datenpartition
  (`signage-data`) für die Anmeldung am Server und den Zwischenspeicher.
- `pkgs/xibo-player.nix`: der Xibo-Abspieler aus dem offiziellen Debian-Paket.

Server und Client stehen in einem eigenen kleinen Netz hinter einem Router. Der Startdienst des Servers antwortet jedem
Rechner, der dort über das Netz startet; in ein größeres Netz gehört er nicht.

Was beim Aufbau an der Hardware aufgefallen ist, steht in [docs/hardware.md](docs/hardware.md).

## Anwenden

Auf dem Server:

    sudo nixos-rebuild switch --flake github:Rsclub22/signage-nix-wohnheim#signage-mlr-sm-srv01

## Was nicht in dieses Repo gehört

Passwörter, private Schlüssel und die Inhalte der Aushänge. Sie entstehen auf dem Gerät und bleiben dort.
