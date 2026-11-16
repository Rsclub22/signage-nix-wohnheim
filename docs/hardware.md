# Erfahrungen mit der Hardware

Stand 16.11.2026, aus dem Aufbau. Was hier steht, ist beobachtet; Vermutungen sind als solche gekennzeichnet.

## Server (`signage-mlr-sm-srv01`)

Desktop-PC: Intel Core i7-860 (8 Threads), 8 GB Arbeitsspeicher, NVIDIA GeForce GT 330, Samsung-Festplatte 149 GB,
ein Netzwerkanschluss, startet im BIOS-Modus.

**Ruhezustand.** Plasma schickt den Rechner nach einer Viertelstunde ohne Eingabe schlafen. Für einen Server ist das
fatal: Verwaltung und Startdienst sind dann weg, der Anzeige-Client findet beim Einschalten nichts. Der Ruhezustand ist
deshalb systemweit gesperrt (`systemd.targets.{sleep,suspend,hibernate,hybrid-sleep}.enable = false`).

**Grafik.** Für die GT 330 gibt es nur den freien Treiber `nouveau`; den Treiber des Herstellers gibt es für aktuelle
Kernel nicht mehr.

- Mit Hardware-Beschleunigung läuft Plasma flüssig. Nach harten Neustarts (Reset-Taste) steht im Kernel-Protokoll beim
  Start des Anmeldebildschirms ein Schwall `nouveau … gr: TRAP_CCACHE … [FAULT]`. Der Bildschirm arbeitet trotzdem.
- Ohne Beschleunigung (`nouveau.noaccel=1`) verschwinden die Meldungen, aber Plasma ist unbenutzbar langsam. Der
  Versuch wurde zurückgenommen. **Nicht wieder einschalten.**

**Einfrieren unter Last.** Einmal ist der Rechner mitten in einem Neubau eingefroren (16:38 Uhr), ohne jede Meldung
im Protokoll; er war vom Netz verschwunden und musste hart neu gestartet werden. Zu dem Zeitpunkt wurde mit allen
Kernen gebaut, dazu liefen fünf Container und der Desktop. Die Ursache ist nicht geklärt. Seitdem:

- Bauen läuft gebremst und mit Nachrang (`nix.settings.max-jobs = 1`, `cores = 2`, `nix.daemonCPUSchedPolicy = "idle"`,
  `nix.daemonIOSchedClass = "idle"`).
- Das Abbild für den Anzeige-Client wird leichter gepackt (`netboot.squashfsCompression`, zstd Stufe 6).
- Zwei gebremste Neubauten liefen danach ohne Einfrieren durch: je 8 bis 13 Minuten, höchste Last 7,2, freier
  Speicher immer über 6 GB, Temperatur um 54 °C. Speichermangel und Hitze sind damit unwahrscheinlich; ob die Bremse
  die Ursache beseitigt oder nur seltener macht, ist offen.

**Neustart.** Nach einem Reset startet der Rechner in etwa zweieinhalb Minuten bis zur Erreichbarkeit.

## Anzeige-Client (`signage-mlr-sm-display01`)

Fujitsu Thin Client: AMD G-T44R (ein Kern, 1,2 GHz), 3,4 GB Arbeitsspeicher, Radeon HD 6250, 64-GB-SSD (mSATA),
startet im BIOS-Modus über das Netz.

**Firmware.** Ohne Firmware für die Radeon gibt es kein Grafikgerät: Der Kernel meldet
`radeon … Direct firmware load for radeon/PALM_pfp.bin failed` und `Fatal error during GPU init`, der Bildschirm bleibt
im Textmodus in grober Auflösung stehen, das Anzeigeprogramm findet „0 GPUs“.

Wichtig: `hardware.enableRedistributableFirmware = true` wirkt in diesem Abbild **nicht**. Das Netzwerkstart-Profil
von NixOS (`netboot-minimal.nix`) schaltet den Schalter fest ab und setzt sich ohne Warnung über die eigene
Einstellung hinweg. Die Firmware-Ordner `radeon` und `rtl_nic` kommen deshalb gezielt über `hardware.firmware` ins
Abbild. Prüfen lässt sich das am fertigen System unter `/run/current-system/firmware/radeon`.

**Datenpartition.** Die SSD meldet sich beim Start spät: gemessen 88 Sekunden nach dem Einschalten, rund 50 Sekunden
nach dem Erkennen der Verbindung. Mit 15 und mit 60 Sekunden Wartezeit kam „Timed out waiting for device“, der Start
blieb danach am Dienst `signage-home` hängen. Jetzt sind es 300 Sekunden. Hilfe am Gerät, falls es doch passiert:
`sudo systemctl start var-lib-signage.mount`. Das Heimatverzeichnis der Anzeige wird erst nach dem Einhängen angelegt (Dienst
`signage-home`), sonst landet es im Arbeitsspeicher und wird überdeckt.

**Leistung.** Das Abbild läuft im Arbeitsspeicher; mit laufendem Abspieler bleiben rund 1,4 GB frei. Ob der eine
langsame Kern für Aushänge mit eingebetteten Webseiten reicht, ist noch nicht gemessen.

**Rechnerschlüssel.** Das System entsteht bei jedem Start neu, also auch seine SSH-Schlüssel. Eine Warnung über einen
geänderten Schlüssel ist bei diesem Gerät normal.

## Netz

Server und Anzeige-Client stehen in einem eigenen kleinen Netz hinter einem Router mit NAT (im Aufbau ein
TP-Link TL-WR841N mit Original-Firmware, `192.168.0.1`). Beide brauchen Internet: der Server für Updates, der
Anzeige-Client für eingebettete Webseiten. Der Router vergibt die Adressen; der Server meldet sich zusätzlich als
Startquelle (ProxyDHCP über pixiecore), ohne in die Adressvergabe einzugreifen.
