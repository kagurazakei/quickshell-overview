{
  # keep-sorted start
  lib,
  makeWrapper,
  quickshell,
  stdenvNoCC,
  # keep-sorted end
}:
let
  inherit (lib)
    # keep-sorted start
    cleanSource
    getExe
    # keep-sorted end
    ;
in
stdenvNoCC.mkDerivation {
  pname = "hyprview";
  version = "unstable";

  src = cleanSource ./.;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    install -dm755 "$out/share/hyprview"
    cp -r ./* "$out/share/hyprview/"

    install -dm755 "$out/bin"
    makeWrapper ${getExe quickshell} "$out/bin/hyprview" \
      --add-flags "-p $out/share/hyprview"

    runHook postInstall
  '';

  meta = with lib; {
    # keep-sorted start
    description = "Quickshell-based workspace overview";
    homepage = "https://github.com/kagurazakei/hyprview";
    license = licenses.gpl3Only;
    mainProgram = "hyprview";
    platforms = platforms.linux;
    # keep-sorted end
  };
}
