{ xcodeenv, sdkVersion, release ? false
, certificateFile ? null, certificatePassword ? "", codeSignIdentity ? null, provisioningProfile ? null, signMethod ? null
, generateIPA ? false, generateXCArchive ? false
, enableWirelessDistribution ? false, installURL ? null, bundleId ? null, version ? null, title ? null
}:

xcodeenv.buildApp {
  name = "HelloWorld";
  src = ../../src/HelloWorld;
  scheme = "HelloWorld";
  
  inherit sdkVersion release;
  inherit certificateFile certificatePassword codeSignIdentity provisioningProfile signMethod;
  inherit generateIPA generateXCArchive;
  inherit enableWirelessDistribution installURL bundleId version title;
}
