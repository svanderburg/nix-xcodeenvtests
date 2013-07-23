{ nixpkgs ? <nixpkgs>
, rename ? false
, newName ? null
, newId ? null
, newDomain ? null
, newCompanyName ? null
, buildIPA ? false
, ipaCertificateFile ? null
, ipaCertificatePassword ? ""
, ipaCodeSignIdentity ? false
, ipaProvisioningProfile ? null
, buildXCArchive ? false
, xcArchiveCertificateFile ? null
, xcArchiveCertificatePassword ? ""
, xcArchiveCodeSignIdentity ? false
, xcArchiveProvisioningProfile ? null
}:

let
  pkgs = import nixpkgs { system = "x86_64-darwin"; };
in
rec {
  helloworld = import ./helloworld {
    inherit (pkgs) xcodeenv;
  };

  simulate_helloworld_iphone = import ./simulate-helloworld {
    inherit (pkgs) stdenv xcodeenv;
    inherit helloworld;
    device = "iPhone";
  };

  simulate_helloworld_ipad = import ./simulate-helloworld {
    inherit (pkgs) stdenv xcodeenv;
    inherit helloworld;
    device = "iPad";
  }; 
  
  simulate_helloworld_ipad_retina = import ./simulate-helloworld {
    inherit (pkgs) stdenv xcodeenv;
    inherit helloworld;
    device = "iPad (Retina)";
  };
  
  simulate_helloworld_iphone_retina_3_5_inch = import ./simulate-helloworld {
    inherit (pkgs) stdenv xcodeenv;
    inherit helloworld;
    device = "iPhone (Retina 3.5-inch)";
  };
  
  simulate_helloworld_iphone_retina_4_inch = import ./simulate-helloworld {
    inherit (pkgs) stdenv xcodeenv;
    inherit helloworld;
    device = "iPhone (Retina 4-inch)";
  };
} // (if buildIPA then {

  helloworld_ipa = import ./helloworld {
    inherit (pkgs) xcodeenv;
    release = true;
    generateIPA = true;
    certificateFile = ipaCertificateFile;
    certificatePassword = ipaCertificatePassword;
    codeSignIdentity = ipaCodeSignIdentity;
    provisioningProfile = ipaProvisioningProfile;
  };

} else {}) // (if buildXCArchive then {

  helloworld_xcarchive = import ./helloworld {
    inherit (pkgs) xcodeenv;
    release = true;
    generateXCArchive = true;
    certificateFile = xcArchiveCertificateFile;
    certificatePassword = xcArchiveCertificatePassword;
    codeSignIdentity = xcArchiveCodeSignIdentity;
    provisioningProfile = xcArchiveProvisioningProfile;
  };

} else {}) // (if rename then rec {
  
  renamed_source = import ./renamed-source {
    inherit (pkgs) stdenv which;
    inherit newName newId newDomain newCompanyName;
  };
  
  renamedPkgs = import "${renamed_source}/deployment" {
    inherit nixpkgs;
    rename = false;
    buildIPA = true;
    buildXCArchive = true;
    inherit ipaCertificateFile ipaCertificatePassword ipaCodeSignIdentity ipaProvisioningProfile;
    inherit xcArchiveCertificateFile xcArchiveCertificatePassword xcArchiveCodeSignIdentity xcArchiveProvisioningProfile;
  };
  
} else {})
