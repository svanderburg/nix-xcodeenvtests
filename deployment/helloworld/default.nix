{ xcodeenv, sdkVersion, release ? false
, certificateFile ? null, certificatePassword ? "", codeSignIdentity ? null, provisioningProfile ? null
, generateIPA ? false, generateXCArchive ? false
}:

xcodeenv.buildApp {
  name = "HelloWorld";
  src = ../../src/HelloWorld;
  scheme = "HelloWorld";
  
  inherit sdkVersion release;
  inherit certificateFile certificatePassword codeSignIdentity provisioningProfile;
  inherit generateIPA generateXCArchive;
}
