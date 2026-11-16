# Xibo-Verwaltung (CMS) in Containern, nach dem offiziellen Compose-Paket von Xibo (xibo-docker 4.5.6).
# Daten und das Datenbankpasswort liegen unter /var/lib/xibo auf dem Gerät und nie in diesem Repo.
{ pkgs, ... }:
let
  compose = pkgs.writeText "xibo-compose.yml" ''
    name: xibo
    services:
      cms-db:
        image: mysql:8.4
        volumes:
          - ./shared/db:/var/lib/mysql
        environment:
          - MYSQL_DATABASE=cms
          - MYSQL_USER=cms
          - MYSQL_RANDOM_ROOT_PASSWORD=yes
        mem_limit: 1g
        env_file: config.env
        restart: unless-stopped
      cms-xmr:
        image: ghcr.io/xibosignage/xibo-xmr:1.5
        ports:
          - "9505:9505"
        mem_limit: 256m
        env_file: config.env
        restart: unless-stopped
      cms-web:
        image: ghcr.io/xibosignage/xibo-cms:release-4.5.6
        volumes:
          - ./shared/cms/custom:/var/www/cms/custom
          - ./shared/backup:/var/www/backup
          - ./shared/cms/library:/var/www/cms/library
          - ./shared/cms/web/userscripts:/var/www/cms/web/userscripts
          - ./shared/cms/ca-certs:/var/www/cms/ca-certs
        environment:
          - MYSQL_HOST=cms-db
          - XMR_HOST=cms-xmr
          - CMS_USE_MEMCACHED=true
          - MEMCACHED_HOST=cms-memcached
        env_file: config.env
        ports:
          - "80:80"
        mem_limit: 1g
        restart: unless-stopped
      cms-memcached:
        image: memcached:alpine
        command: memcached -m 15
        mem_limit: 100M
        restart: unless-stopped
      cms-quickchart:
        image: ianw/quickchart
        restart: unless-stopped
  '';
  dc = "${pkgs.docker-compose}/bin/docker-compose -f ${compose} --project-directory /var/lib/xibo";
in
{
  virtualisation.docker.enable = true;

  systemd.services.xibo = {
    description = "Xibo-Verwaltung (Container)";
    wantedBy = [ "multi-user.target" ];
    after = [ "docker.service" "network-online.target" ];
    requires = [ "docker.service" ];
    wants = [ "network-online.target" ];
    path = [ pkgs.docker pkgs.coreutils ];
    # Das Datenbankpasswort entsteht beim ersten Start auf dem Gerät (nur Buchstaben und Ziffern, wie Xibo es verlangt)
    preStart = ''
      mkdir -p /var/lib/xibo
      if [ ! -s /var/lib/xibo/config.env ]; then
        umask 077
        printf 'MYSQL_PASSWORD=%s\n' "$(head -c 64 /dev/urandom | base64 | tr -dc A-Za-z0-9 | head -c 24)" > /var/lib/xibo/config.env
      fi
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${dc} up -d";
      ExecStop = "${dc} stop";
      TimeoutStartSec = "30min";   # der erste Start lädt die Abbilder
    };
  };

  # Weboberfläche und der Nachrichtenkanal zu den Anzeigen, nur im eigenen kleinen Netz erreichbar
  networking.firewall.allowedTCPPorts = [ 80 9505 ];
}
