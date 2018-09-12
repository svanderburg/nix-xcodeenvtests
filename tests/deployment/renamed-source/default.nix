{ stdenv, which
, newName, newId, newDomain, newCompanyName, ipaCodeSignIdentity
}:

assert newName != null && newId != null && newDomain != null && newCompanyName != null && ipaCodeSignIdentity != null;

stdenv.mkDerivation {
  name = "renamed-source";
  src = ../../..;
  buildInputs = [ which ];
  buildPhase = ''
    cd tests
    ${./rename.sh} "${newName}" "${newId}" "${newDomain}" "${newCompanyName}" "${ipaCodeSignIdentity}"
    cd ..
  '';
  installPhase = ''
    mkdir -p $out
    mv * $out
  '';
}
