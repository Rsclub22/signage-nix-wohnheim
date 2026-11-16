# Xibo-Abspieler (Electron) aus dem offiziellen Debian-Paket von https://github.com/xibosignage/electron-player
{ lib, stdenv, fetchurl, dpkg, autoPatchelfHook, makeWrapper
, alsa-lib, at-spi2-atk, at-spi2-core, cairo, cups, dbus, expat, glib, gtk3, libdrm, libgbm, libnotify
, libxkbcommon, nspr, nss, pango, systemd, libGL
, libx11, libxcomposite, libxdamage, libxext, libxfixes, libxrandr, libxcb
}:
stdenv.mkDerivation rec {
  pname = "xibo-player";
  version = "4.0.13";

  src = fetchurl {
    url = "https://github.com/xibosignage/electron-player/releases/download/v${version}/xibo-player_${version}_amd64.deb";
    hash = "sha256-jaQhFTNEbp74wHiOyLJjz5U38UICpzF9Rd7y773ZHEk=";
  };

  nativeBuildInputs = [ dpkg autoPatchelfHook makeWrapper ];
  buildInputs = [
    alsa-lib at-spi2-atk at-spi2-core cairo cups dbus expat glib gtk3 libdrm libgbm libnotify libxkbcommon nspr nss
    pango stdenv.cc.cc.lib
    libx11 libxcomposite libxdamage libxext libxfixes libxrandr libxcb
  ];
  # mitgelieferte Fassung eines Moduls für musl-Systeme, hier ungenutzt
  autoPatchelfIgnoreMissingDeps = [ "libc.musl-x86_64.so.1" ];
  # zur Laufzeit nachgeladen
  runtimeDependencies = [ (lib.getLib systemd) libGL ];

  unpackPhase = ''
    dpkg-deb --fsys-tarfile $src | tar -x --no-same-owner --no-same-permissions
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib $out/bin $out/share
    cp -r usr/lib/xibo-player $out/lib/
    cp -r usr/share/applications $out/share/
    # Ohne den setuid-Helfer nimmt Chromium die Sandbox über Benutzer-Namensräume
    rm -f $out/lib/xibo-player/chrome-sandbox
    makeWrapper $out/lib/xibo-player/xibo-player $out/bin/xibo-player
    runHook postInstall
  '';

  meta = {
    description = "Xibo digital signage player (Electron)";
    homepage = "https://github.com/xibosignage/electron-player";
    license = lib.licenses.agpl3Only;
    platforms = [ "x86_64-linux" ];
    mainProgram = "xibo-player";
  };
}
