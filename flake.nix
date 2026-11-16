{
  description = "Aushang-Bildschirm im Wohnheim: Server und Anzeige-Client als NixOS-Konfiguration";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      # Abbild des Anzeige-Clients: Der Server liefert es bei jedem Start über das Netz aus, es läuft im Arbeitsspeicher
      clientDisplay = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [ ./hosts/client/display.nix ];
      };
      # Reines Wartungsabbild ohne Anzeige, wird derzeit nicht ausgeliefert
      clientInstaller = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [ ./hosts/client/installer.nix ];
      };
    in
    {
      nixosConfigurations.signage-mlr-sm-srv01 = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { clientImage = clientDisplay.config.system.build; };
        modules = [ ./hosts/server/configuration.nix ./hosts/server/netboot.nix ./hosts/server/xibo.nix ./hosts/server/hausmeister.nix ];
      };
      nixosConfigurations.client-display = clientDisplay;
      nixosConfigurations.client-installer = clientInstaller;
    };
}
