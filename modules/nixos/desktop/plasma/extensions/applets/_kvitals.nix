{
  stdenvNoCC,
  fetchFromGitHub,
  lib,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "kvitals";
  version = "3.2.1";

  src = fetchFromGitHub {
    owner = "yassine20011";
    repo = "kvitals";
    rev = "v3.2.1";
    hash = "sha256-DnF4dgZZXtnM6+hDneaykaDYopVnEo9CD86NYFCYPGY=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/plasma/plasmoids/org.kde.plasma.kvitals
    cp -r * $out/share/plasma/plasmoids/org.kde.plasma.kvitals/
    runHook postInstall
  '';
}
