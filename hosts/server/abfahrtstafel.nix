# Abfahrtstafel für den Aushang, lokal auf dem Server statt abfahrtstafel2.wagnersnetz.de.
# Gleiches Image wie dort (Quelle github.com/Rsclub22/DB-JSON-Stationboard), per Digest festgenagelt.
# Die Tafel holt ihre Daten weiter aus dem Internet (HAFAS der Bahn), hängt aber nicht mehr an fremden Servern.
# Aufruf in Xibo: http://<Server>:8080/?station_name=USMS&dark=1
{ ... }:
{
  virtualisation.docker.enable = true;
  virtualisation.oci-containers.backend = "docker";
  virtualisation.oci-containers.containers.abfahrtstafel = {
    image = "rsclub22/hafas-db-depature-board@sha256:cdf60a47243b1f2aa97a3e09973e163200f805fd4022d7c7425c7463b4a7a76e";
    ports = [ "8080:5000" ];
    extraOptions = [ "--memory=256m" ];
  };

  # nur im eigenen kleinen Netz erreichbar (Anzeige-Client und Server-PC)
  networking.firewall.allowedTCPPorts = [ 8080 ];
}
