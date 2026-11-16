{
  description = "Aushang-Bildschirm im Wohnheim: Server und Anzeige-Client als NixOS-Konfiguration";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      # Startabbild für den Anzeige-Client: läuft im Arbeitsspeicher und dient der Erstinstallation über das Netz
      clientInstaller = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [ ./hosts/client/installer.nix ];
      };
    in
    {
      nixosConfigurations.signage-mlr-sm-srv01 = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { clientInstaller = clientInstaller.config.system.build; };
        modules = [ ./hosts/server/configuration.nix ./hosts/server/netboot.nix ./hosts/server/xibo.nix ];
      };
      nixosConfigurations.client-installer = clientInstaller;
    };
}
