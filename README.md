Nix xcode tests
===============

This package contains a simple tutorial case, taken from Apple's iOS tutorial:
[http://developer.apple.com/library/ios/#documentation/iphone/conceptual/iphone101/Articles/00_Introduction.html](http://developer.apple.com/library/ios/#documentation/iphone/conceptual/iphone101/Articles/00_Introduction.html)
to the test the `xcodeenv.buildApp {}` function that can be used with the
[Nix package manager](http://nixos.org/nix) to build iOS apps. Additionally, it
can be used with `xcodeenv.simulateApp {}` to generate a script that
automatically starts an iOS app.

Apart from the tutorial, it has two additions:

* It implements an iPad storyboard (the process is the same as for an iPhone storyboard), so that it can be tested for iPad devices
* It contains some very ugly icons (created myself :-) ), to allow releases to pass validation

Prerequisites
=============
In order to run the examples, you must have the [Nix package manager](http://nixos.org/nix)
installed and a copy of [Nixpkgs](http://nixos.org/nixpkgs). Consult the Nix
manual for more details on this.

Usage
=====
There are two ways to build the example app through Nix. One option is to use the
iPhone simulator which is the most convenient way of trying this out. It does not
require any signing.

In order to test the app on an Apple device or release it to the App store, you
must obtain a certficate and mobile provisioning profile from Apple's developer
portal and sign the app with it.

Building the app for the simulator
----------------------------------
A debug app for the iPhone simulator can be built by entering the `deployment/`
directory and by running:

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

Building the app for a device or for release
--------------------------------------------
Building the app for a real Apple device or for the App store is more
complicated, since Apple's permissions are required for that.

For testing purposes, you can 'rename' this example app and use the certificate
and mobile provisioning profile of an existing app to produce an IPA archive that
can be deployed to any Apple device that has been granted permissions to run it.

The composition expression `default.nix` contains a collection of extra
parameters that can be set to accomplish that. When setting the `rename`
parameter to `true` and setting a collection of additional parameters:

    $ nix-build --arg rename true \
      --argstr newName "Renamed" \
      --argstr newId "renamedapp" \
      --argstr newDomain "com.example" \
      --argstr newCompanyName "My Renamed Company" \
      --arg ipaCertificateFile /path/to/certificate.p12 \
      --argstr ipaCertificatePassword secret \
      --argstr ipaCodeSignIdentity "iPhone Distribution: My Renamed Company" \
      --argstr ipaProvisioningProfile /path/to/provisioning.mobileprovision \
      --arg xcArchiveCertificateFile /path/to/certificate.p12 \
      --argstr xcArchiveCertificatePassword secret \
      --argstr xcArchiveCodeSignIdentity "iPhone Distribution: My Renamed Company" \
      --argstr xcArchiveProvisioningProfile /path/to/provisioning.mobileprovision \
      -A renamedPkgs.renamedapp_ipa

a sub attribute set called `renamedPkgs` is generated referring to an app that
has renamed several of its standard properties to those provided by the `new*`
parameters.  The `new*` parameters should be changed to match those in your
certificate and mobile provisioning profile.

To find out what they are use the Keychain to inspect the certificate (p12 file)
and Xcode (or a text editor) to inspect the mobile provisioning profile.

The IPA attribute inside this sub attribute set can be used to produce an IPA
that can be actually deployed to an Apple device if all attributes are set
correctly.
