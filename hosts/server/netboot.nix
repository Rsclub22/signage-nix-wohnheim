# Der Server meldet sich im Netz zusätzlich als Startquelle für Rechner, die über das Netzwerk starten (PXE).
# Die Adressen vergibt weiter der Router; hier kommt nur die Auskunft dazu, was zu laden ist (ProxyDHCP).
# Nur in einem eigenen kleinen Netz betreiben: Jeder Rechner, der dort über das Netz startet, bekommt dieses Abbild.
{ clientInstaller, ... }:
{
  services.pixiecore = {
    enable = true;
    openFirewall = true;
    dhcpNoBind = true;
    mode = "boot";
    kernel = "${clientInstaller.kernel}/bzImage";
    initrd = "${clientInstaller.netbootRamdisk}/initrd";
    cmdLine = "init=${clientInstaller.toplevel}/init loglevel=4";
    port = 64172;
    statusPort = 64172;
  };
}
