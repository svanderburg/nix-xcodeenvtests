{ stdenv, which
, newName, newId, newDomain, newCompanyName
}:

assert newName != null && newId != null && newDomain != null && newCompanyName != null;

stdenv.mkDerivation {
  name = "renamed-source";
  src = ../..;
  buildInputs = [ which ];
  buildPhase = ''
    ${./rename.sh} "${newName}" "${newId}" "${newDomain}" "${newCompanyName}"
  '';
  installPhase = ''
    mkdir -p $out
    mv * $out
  '';
}
