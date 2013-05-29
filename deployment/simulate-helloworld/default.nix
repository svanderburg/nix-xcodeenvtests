{stdenv, xcodeenv, helloworld, device}:

xcodeenv.simulateApp {
  name = "simulate-${helloworld.name}-${stdenv.lib.replaceChars [" " "(" ")"] ["_" "" ""] device}";
  appName = "HelloWorld";
  app = helloworld;
  inherit device;
}
