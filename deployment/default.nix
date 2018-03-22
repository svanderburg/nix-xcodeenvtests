{ nixpkgs ? <nixpkgs>
, xcodeVersion ? "9.2"
, xcodeBaseDir ? "/Applications/Xcode.app"
, sdkVersion ? "11.2"
, rename ? false
, newName ? "Renamed"
, newId ? "renamedapp"
, newDomain ? "com.myrenamedcompany"
, newCompanyName ? "My renamed company"
, buildIPA ? false
, signMethod ? "ad-hoc"
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

  simulate_helloworld = import ./simulate-helloworld {
    inherit (pkgs) stdenv;
    inherit xcodeenv helloworld;
    bundleId = "MyCompany.HelloWorld";
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
    inherit enableWirelessDistribution installURL version signMethod;
    bundleId = "${newDomain}.${newName}";
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
    inherit newName newId newDomain newCompanyName ipaCodeSignIdentity;
  };
  
  renamedPkgs = import "${renamed_source}/deployment" {
    inherit nixpkgs xcodeVersion xcodeBaseDir sdkVersion;
    rename = false;
    buildIPA = true;
    buildXCArchive = true;
    inherit newDomain;
    inherit ipaCertificateFile ipaCertificatePassword ipaCodeSignIdentity ipaProvisioningProfile;
    inherit xcArchiveCertificateFile xcArchiveCertificatePassword xcArchiveCodeSignIdentity xcArchiveProvisioningProfile;
    inherit enableWirelessDistribution installURL version;
  };
  
} else {})
