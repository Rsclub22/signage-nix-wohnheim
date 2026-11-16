# signage-nix-wohnheim

NixOS-Konfiguration für einen Aushang-Bildschirm in einem Wohnheim: ein Server, an dem die Seiten gepflegt werden,
und ein Anzeige-Client am Bildschirm.

**Stand:** Grundinstallation des Servers. Die Signage-Software, das Netz zum Client und die automatischen Updates
fehlen noch.

## Aufbau

- `hosts/server/`: der Server `signage-mlr-sm-srv01` (Desktop-PC, Plasma, SSH nur mit Schlüssel). Er liefert dem
  Anzeige-Client beim Start über das Netz (PXE) ein Installationsabbild aus.
- `hosts/client/`: der Anzeige-Client. Bisher nur das Startabbild für die Erstinstallation.

Server und Client stehen in einem eigenen kleinen Netz hinter einem Router. Der Startdienst des Servers antwortet jedem
Rechner, der dort über das Netz startet; in ein größeres Netz gehört er nicht.

## Anwenden

Auf dem Server:

    sudo nixos-rebuild switch --flake github:Rsclub22/signage-nix-wohnheim#signage-mlr-sm-srv01

## Was nicht in dieses Repo gehört

Passwörter, private Schlüssel und die Inhalte der Aushänge. Sie entstehen auf dem Gerät und bleiben dort.
