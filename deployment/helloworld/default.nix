{ xcodeenv, release ? false
, certificateFile ? null, certificatePassword ? "", codeSignIdentity ? null, provisioningProfile ? null
, generateIPA ? false, generateXCArchive ? false
}:

xcodeenv.buildApp {
  name = "HelloWorld";
  src = ../../src/HelloWorld;
  scheme = "HelloWorld";
  
  inherit release;
  inherit certificateFile certificatePassword codeSignIdentity provisioningProfile;
  inherit generateIPA generateXCArchive;
}
