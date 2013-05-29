{stdenv, xcodeenv, helloworld, device}:

xcodeenv.simulateApp {
  name = "simulate-${helloworld.name}-${stdenv.lib.replaceChars [" " "(" ")"] ["_" "" ""] device}";
  app = helloworld;
  inherit device;
}
