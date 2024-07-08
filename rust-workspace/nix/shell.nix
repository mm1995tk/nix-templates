{
  pkgs,
  rustBins,
}:
pkgs.mkShell {
  inputsFrom = [];
  buildInputs = with pkgs;
    [
      rustBins
      evcxr
      bacon
    ]
    ++ (
      if pkgs.stdenv.isDarwin
      then [pkgs.darwin.apple_sdk.frameworks.SystemConfiguration]
      else []
    );
  DUMMY = "world";
}
