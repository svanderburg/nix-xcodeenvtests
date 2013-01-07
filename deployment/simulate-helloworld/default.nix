{xcodeenv, helloworld, device}:

xcodeenv.simulateApp {
  name = "HelloWorld";
  app = helloworld;
  inherit device;
}
