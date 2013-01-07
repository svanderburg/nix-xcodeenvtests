let
  pkgs = import <nixpkgs> {};
in
rec {
  helloworld = import ./helloworld {
    inherit (pkgs) xcodeenv;
  };

  simulate_helloworld_iphone = import ./simulate-helloworld {
    inherit (pkgs) xcodeenv;
    inherit helloworld;
    device = "iPhone";
  };

  simulate_helloworld_ipad = import ./simulate-helloworld {
    inherit (pkgs) xcodeenv;
    inherit helloworld;
    device = "iPad";
  }; 
  
  simulate_helloworld_ipad_retina = import ./simulate-helloworld {
    inherit (pkgs) xcodeenv
    inehrit helloworld;
    device = "iPad (Retina)";
  };
  
  simulate_helloworld_iphone_retina_3_5_inch = import ./simulate-helloworld {
    inherit (pkgs) xcodeenv;
    inherit helloworld;
    device = "iPhone (Retina 3.5-inch)";
  };
  
  simulate_helloworld_iphone_retina_4_inch = import ./simulate-helloworld {
    inherit (pkgs) xcodeenv;
    inherit helloworld;
    device = "iPhone (Retina 4-inch)";
  };
}
