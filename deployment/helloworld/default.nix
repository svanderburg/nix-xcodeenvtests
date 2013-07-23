{xcodeenv}:

xcodeenv.buildApp {
  name = "HelloWorld";
  src = ../../src/HelloWorld;
  scheme = "HelloWorld";
  
  /*release = true;
  certificateFile = ./certificate.p12;
  certificatePassword = "";
  codeSignIdentity = "iPhone Distribution: My Company";
  provisioningProfile = ./provision.mobileprovision;
  generateIPA = true;
  generateXCArchive = false;*/
}
