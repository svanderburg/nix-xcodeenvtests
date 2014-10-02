{ nixpkgs ? <nixpkgs>
, xcodeVersion ? "6.0.1"
, xcodeBaseDir ? "/Applications/Xcode.app"
, sdkVersion ? "7.0"
, rename ? false
, newName ? "Renamed"
, newId ? "renamedapp"
, newDomain ? "com.myrenamedcompany"
, newCompanyName ? "My renamed company"
, buildIPA ? false
, ipaCertificateFile ? null
, ipaCertificatePassword ? ""
, ipaCodeSignIdentity ? "iPhone Distribution: My Company"
, ipaProvisioningProfile ? null
, buildXCArchive ? false
, xcArchiveCertificateFile ? null
, xcArchiveCertificatePassword ? ""
, xcArchiveCodeSignIdentity ? "iPhone Distribution: My Company"
, xcArchiveProvisioningProfile ? null
, enableWirelessDistribution ? false
, installURL ? null
, version ? "1.0"
}:

let
  pkgs = import nixpkgs { system = "x86_64-darwin"; };
  xcodeenv = pkgs.xcodeenv.override {
    inherit xcodeBaseDir;
    version = xcodeVersion;
  };
in
rec {
  helloworld = import ./helloworld {
    inherit xcodeenv sdkVersion;
  };

  simulate_helloworld_iphone = import ./simulate-helloworld {
    inherit (pkgs) stdenv;
    inherit xcodeenv helloworld;
    device = "iPhone";
  };

  simulate_helloworld_ipad = import ./simulate-helloworld {
    inherit (pkgs) stdenv;
    inherit xcodeenv helloworld;
    device = "iPad";
  }; 
  
  simulate_helloworld_ipad_retina = import ./simulate-helloworld {
    inherit (pkgs) stdenv;
    inherit xcodeenv helloworld;
    device = "iPad (Retina)";
  };
  
  simulate_helloworld_iphone_retina_3_5_inch = import ./simulate-helloworld {
    inherit (pkgs) stdenv;
    inherit xcodeenv helloworld;
    device = "iPhone (Retina 3.5-inch)";
  };
  
  simulate_helloworld_iphone_retina_4_inch = import ./simulate-helloworld {
    inherit (pkgs) stdenv;
    inherit xcodeenv helloworld;
    device = "iPhone (Retina 4-inch)";
  };
} // (if buildIPA then {

  helloworld_ipa = import ./helloworld {
    inherit xcodeenv sdkVersion;
    release = true;
    generateIPA = true;
    certificateFile = ipaCertificateFile;
    certificatePassword = ipaCertificatePassword;
    codeSignIdentity = ipaCodeSignIdentity;
    provisioningProfile = ipaProvisioningProfile;
    inherit enableWirelessDistribution installURL version;
    bundleId = "${newDomain}.${newId}";
    title = newName;
  };

} else {}) // (if buildXCArchive then {

  helloworld_xcarchive = import ./helloworld {
    inherit xcodeenv sdkVersion;
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
    inherit nixpkgs xcodeVersion sdkVersion;
    rename = false;
    buildIPA = true;
    buildXCArchive = true;
    inherit ipaCertificateFile ipaCertificatePassword ipaCodeSignIdentity ipaProvisioningProfile;
    inherit xcArchiveCertificateFile xcArchiveCertificatePassword xcArchiveCodeSignIdentity xcArchiveProvisioningProfile;
    inherit enableWirelessDistribution installURL version;
  };
  
} else {})
