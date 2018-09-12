{stdenv, xcodeenv, helloworld, bundleId}:

xcodeenv.simulateApp {
  name = "simulate-${helloworld.name}";
  app = helloworld;
  inherit bundleId;
}
