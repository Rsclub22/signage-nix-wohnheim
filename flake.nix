{
  description = "Aushang-Bildschirm im Wohnheim: Server und Anzeige-Client als NixOS-Konfiguration";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

  outputs = { self, nixpkgs }: {
    nixosConfigurations.signage-mlr-sm-srv01 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ ./hosts/server/configuration.nix ];
    };
  };
}
