Nix xcode tests
===============

This package contains a simple tutorial case, taken from Apple's iOS tutorial:
[/nix/store/rghvj55gkmnwza1mikn0i852ds2kdh2c-node-v0.8.15.tar.gz](/nix/store/rghvj55gkmnwza1mikn0i852ds2kdh2c-node-v0.8.15.tar.gz)
to the test the `xcodeenv.buildApp {}` function that can be used with the
[Nix package manager](http://nixos.org/nix).

Apart from the tutorial, it has two additions:

* It implements an iPad storyboard (the process is the same as for an iPhone storyboard), so that it can be tested for iPad devices
* It contains some very ugly icons (created myself :-) ), to allow releases to pass validation

Usage
=====
In order to run the examples, you must have the Nix package manager installed
and a copy of [Nixpkgs](http://nixos.org/nixpkgs). Consult the Nix manual for
more details on this.

Then a debug app for the iPhone simulator can be built by entering the
`deployment/` directory and by running:

    $ nix-build -A helloworld

By editing the `helloworld/default.nix` Nix expression and by enabling the
release parameter, a release can be built. In order to do this you need
a distribution certificate and provisioning profile from Apple. The paths
to the keys must be adapted to suit your environment.

We can also automatically start a simulator instance running the app.
The following command-line instruction runs the app on a simulated iPhone
instance:

    $ nix-build -A simulate_helloworld_iphone
    $ ./result/bin/run-test-simulator

The following command-line instruction runs the app on a simulated iPad
instance:

    $ nix-build -A simulate_helloworld_ipad
    $ ./result/bin/run-test-simulator

The above `nix-build` instruction produces a shell script taking care of
the starting process. By running the shell script, a particular simulator
instance is launched.
