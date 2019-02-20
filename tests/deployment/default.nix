{ nixpkgs ? <nixpkgs>
, xcodeVersion ? "10.1"
, xcodeBaseDir ? "/Applications/Xcode.app"
, sdkVersion ? "12.1"
, rename ? false
, newName ? "Renamed"
, newId ? "renamedapp"
, newDomain ? "com.myrenamedcompany"
, newCompanyName ? "My renamed company"
, newTeamName ? "My renamed team"
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
, appVersion ? "1.0"
, useUpstream ? false
}:

let
  pkgs = import nixpkgs { system = "x86_64-darwin"; };

  getXcodeEnv = pkgs:
    if useUpstream then pkgs.xcodeenv else import ../../xcodeenv {
      inherit (pkgs) stdenv;
    };
in
rec {
  helloworld = import ./helloworld {
    xcodeenv = getXcodeEnv pkgs;
    inherit sdkVersion;
  };

  simulate_helloworld = import ./simulate-helloworld {
    inherit (pkgs) stdenv;
    inherit helloworld;
    bundleId = "MyCompany.HelloWorld";
    xcodeenv = getXcodeEnv pkgs;
  };
} // (if buildIPA then {

  helloworld_ipa = import ./helloworld {
    inherit sdkVersion;
    release = true;
    generateIPA = true;
    certificateFile = ipaCertificateFile;
    certificatePassword = ipaCertificatePassword;
    codeSignIdentity = ipaCodeSignIdentity;
    provisioningProfile = ipaProvisioningProfile;
    inherit enableWirelessDistribution installURL appVersion signMethod;
    bundleId = "${newDomain}.${newName}";
    xcodeenv = getXcodeEnv pkgs;
  };

} else {}) // (if buildXCArchive then {

  helloworld_xcarchive = import ./helloworld {
    inherit sdkVersion signMethod;
    release = true;
    generateXCArchive = true;
    certificateFile = xcArchiveCertificateFile;
    certificatePassword = xcArchiveCertificatePassword;
    codeSignIdentity = xcArchiveCodeSignIdentity;
    provisioningProfile = xcArchiveProvisioningProfile;
    xcodeenv = getXcodeEnv pkgs;
  };

} else {}) // (if rename then rec {

  renamed_source = import ./renamed-source {
    inherit (pkgs) stdenv which;
    inherit newName newId newDomain newCompanyName newTeamName ipaCodeSignIdentity;
  };

  renamedPkgs = import "${renamed_source}/tests/deployment" {
    inherit nixpkgs xcodeVersion xcodeBaseDir sdkVersion;
    rename = false;
    buildIPA = true;
    buildXCArchive = true;
    inherit newDomain newTeamName;
    inherit ipaCertificateFile ipaCertificatePassword ipaCodeSignIdentity ipaProvisioningProfile;
    inherit xcArchiveCertificateFile xcArchiveCertificatePassword xcArchiveCodeSignIdentity xcArchiveProvisioningProfile;
    inherit enableWirelessDistribution installURL appVersion useUpstream;
  };

} else {})
