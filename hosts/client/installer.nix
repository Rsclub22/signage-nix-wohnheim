# Startabbild für den Anzeige-Client. Der Server liefert es beim Start über das Netz aus (hosts/server/netboot.nix);
# es läuft im Arbeitsspeicher und lässt nur eine Anmeldung per SSH-Schlüssel zu.
{ modulesPath, ... }:
{
  imports = [ (modulesPath + "/installer/netboot/netboot-minimal.nix") ];

  networking.hostName = "signage-client-installer";
  console.keyMap = "de";
  users.users.nixos.openssh.authorizedKeys.keyFiles = [ ../server/authorized_keys ];

  system.stateVersion = "26.05";
}
