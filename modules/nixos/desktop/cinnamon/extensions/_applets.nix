{
  pkgs,
}:
let
  sysmonUuid = "combined-monitor@danipin";
  menuUuid = "classic-menu@fredcw";
in
pkgs.stdenvNoCC.mkDerivation {
  pname = "cinnamon-custom-applets";
  version = "2026-11-24";

  src = pkgs.fetchFromGitHub {
    owner = "linuxmint";
    repo = "cinnamon-spices-applets";
    rev = "976c007";
    hash = "sha256-k64FCHBYMt/XN/l2Et3TD2/hMWSPES7KHJCISI+j/5I=";
    sparseCheckout = [
      sysmonUuid
      menuUuid
    ];
  };

  installPhase = ''
    mkdir -p $out/share/cinnamon/applets
    cp -r ${sysmonUuid}/files/${sysmonUuid} $out/share/cinnamon/applets/
    cp -r ${menuUuid}/files/${menuUuid} $out/share/cinnamon/applets/

    substituteInPlace $out/share/cinnamon/applets/${sysmonUuid}/applet.js \
      --replace-warn "gnome-system-monitor" "superlight"
  '';

  passthru = {
    inherit sysmonUuid menuUuid;
  };
}
