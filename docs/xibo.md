# Xibo: Einrichtung und Erfahrungen

Stand 16.11.2026, aus dem ersten Testaufbau. Die Verwaltung läuft auf dem Server unter `http://<Server>/`
(am Server-PC `http://localhost`, Starter „Aushang bearbeiten“ im Konto `hausmeister`).

## Anzeige anmelden

1. Der Anzeige-Client startet über das Netz und zeigt den Einrichtungsbildschirm des Abspielers.
2. Dort Adresse der Verwaltung und den Schlüssel eintragen (Verwaltung: Einstellungen → Bildschirme). Die Angaben
   landen auf der Datenpartition des Clients (`/var/lib/signage/home/.config/xibo-player/`) und überleben Neustarts.
3. In der Verwaltung unter „Bildschirme“ erscheint das Gerät als nicht genehmigt. Menü am Zeilenende →
   „Autorisieren“. Erst danach zeigt es Inhalte.

## Inhalt auf den Bildschirm bringen

- **Layout:** Gestaltung → Layouts → „Layout hinzufügen“. Elemente (Text, Bild, Webseite …) aus der linken Leiste auf
  die Fläche ziehen, an den Ecken auf Größe ziehen. Ein Layout wirkt erst nach „Veröffentlichen“ (Menü oben rechts).
- **Standard-Layout:** Bildschirme → Menü am Zeilenende → „Standard Layout“. Das läuft immer dann, wenn nichts
  anderes eingeplant ist.
- **Mehrere Layouts im Wechsel:** Gestaltung → Kampagnen → „Kampagne hinzufügen“ (Typ „Layout Liste“), im Reiter
  „Layouts“ die Layouts aufnehmen. Eine Kampagne läuft erst, wenn sie eingeplant ist: Kalender → Events →
  „Neues Ereignis“, Ereignistyp „Kampagne“, Bildschirm wählen, Zeitraum festlegen.
  Achtung bei den Begriffen: „Playlisten“ sind in Xibo Abfolgen von Medien *innerhalb* eines Layouts. Der Wechsel
  zwischen ganzen Layouts heißt „Kampagne“.

## Webseiten einbetten

Element „Webseite“, Einstellung „Nativ öffnen“. Xibo kann nur eine Adresse aufrufen: kein Formular absenden, kein
Cookie vorab setzen. Eine Seite muss sich also vollständig über ihre Adresse steuern lassen.

- **Dunkler Modus:** Seiten, die sich nach der Systemeinstellung richten (`prefers-color-scheme`), bekommen vom
  Abspieler „hell“ gemeldet. Mit der Umgebungsvariable `GTK_THEME=Adwaita:dark` für das Anzeigeprogramm meldet er
  „dunkel“ (am Gerät ausprobiert, wirkt). Noch nicht fest in der Konfiguration.
- **Symbole:** Ohne Emoji-Schrift im Abbild erscheinen Emojis als leere Kästchen. `noto-fonts-color-emoji` ist
  deshalb in der Schriftliste des Anzeige-Clients.
- **Leistung:** Eine Seite mit Tabelle, die sich alle 90 Sekunden aktualisiert, lastet den einen Kern des
  Thin Clients kaum aus (Last 0,4, Abspieler um 9 %, 1,7 GB Arbeitsspeicher frei).

## Abfahrtstafel

`https://abfahrtstafel2.wagnersnetz.de` (Quelle: `Rsclub22/DB-JSON-Stationboard`) nimmt die Station bisher nur über
ihr Formular an und merkt sie sich in einem Cookie. Für die Anzeige braucht sie die Station in der Adresse.
Vorgesehen: `/?station_name=USMS&dark=1` (USMS ist das Kürzel für Schmalkalden). Die Änderung an der Seite ist
vorbereitet, aber noch nicht veröffentlicht; bis dahin zeigt die Anzeige die Seite ohne Station.

## Stand des Testaufbaus

- Display `signage-mlr-sm-display01` autorisiert.
- Zwei veröffentlichte Testlayouts („Untitled 2026-11-16 16:47:34“ mit Text und Abfahrtstafel, „Untitled
  2026-11-16 16:52:53“). Das erste ist Standard-Layout des Displays.
- Kampagne „Test-Schleife“ mit beiden Layouts angelegt, **noch nicht eingeplant**.
- Die Verwaltung hat noch das Standardpasswort von Xibo. Vor dem Aufstellen ändern.
