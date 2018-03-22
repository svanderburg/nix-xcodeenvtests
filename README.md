Nix xcode tests
===============

This package contains a simple tutorial case, taken from Apple's iOS tutorial:
[http://developer.apple.com/library/ios/#documentation/iphone/conceptual/iphone101/Articles/00_Introduction.html](http://developer.apple.com/library/ios/#documentation/iphone/conceptual/iphone101/Articles/00_Introduction.html)
to the test the `xcodeenv.buildApp {}` function that can be used with the
[Nix package manager](http://nixos.org/nix) to build iOS apps. Additionally, it
can be used with `xcodeenv.simulateApp {}` to generate a script that
automatically starts an iOS app.

Apart from the tutorial, it has two additions:

* It implements an iPad storyboard (the process is the same as for an iPhone
  storyboard), so that it can be tested for iPad devices
* It contains some very ugly icons (created myself :-) ), to allow releases to
  pass validation

Prerequisites
=============
In order to run the examples, you must have the
[Nix package manager](http://nixos.org/nix) installed and a copy of
[Nixpkgs](http://nixos.org/nixpkgs). Consult the Nix manual for more details on
this.

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

```bash
nix-build -A helloworld
```

By editing the `helloworld/default.nix` Nix expression and by enabling the
release parameter, a release can be built. In order to do this you need
a distribution certificate and provisioning profile from Apple. The paths
to the keys must be adapted to suit your environment.

Running the app in the iOS simulator
------------------------------------
We can also automatically start a simulator instance running the app.
When building the simulate job and running the resulting script:

```bash
$ nix-build -A simulate_helloworld
$ ./result/bin/run-test-simulator
```

You are asked to select an iOS simulator instance (by its UDID) and for
confirmation when the simulator has actually started. Finally, the app is
installed and launched automatically.

For convenience, the UDID of the simulator instance can also be provided as a
command-line parameter so that there is only little user interaction needed:

```bash
$ ./result/bin/run-test-simulator 9611697B-6F21-4479-AF74-4FA2DEEF06EE
```

Defining build variability points
---------------------------------
By default, the example case has been configured to use the latest version of
Xcode that resides in the default location on the filesystem and the latest
version of the iPhone SDKs.

These values can be overridden by setting a number of parameters, e.g.:

```bash
$ nix-build --argstr xcodeVersion 6.0.1 \
  --argstr xcodeBaseDir "/Applications/Xcode.app" \
  --argstr sdkVersion 8.0 \
  -A helloworld
```

The above parameters specify that Xcode version 6.0.1 should be used that can be
found in `/Applications/Xcode.app` on the filesystem. The iPhone SDK version 8.0
should be used for building.

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

```bash
$ nix-build --arg rename true \
  --argstr newName "Renamed" \
  --argstr newId "renamedapp" \
  --argstr newDomain "com.example" \
  --argstr newCompanyName "My Renamed Company" \
  --arg ipaCertificateFile /path/to/certificate.p12 \
  --argstr ipaCertificatePassword secret \
  --argstr ipaCodeSignIdentity "iPhone Distribution: My Renamed Company" \
  --arg ipaProvisioningProfile /path/to/provisioning.mobileprovision \
  --arg xcArchiveCertificateFile /path/to/certificate.p12 \
  --argstr xcArchiveCertificatePassword secret \
  --argstr xcArchiveCodeSignIdentity "iPhone Distribution: My Renamed Company" \
  --arg xcArchiveProvisioningProfile /path/to/provisioning.mobileprovision \
  --argstr signMethod "ad-hoc" \ # or: 'enterprise', 'app-store'
  -A renamedPkgs.renamedapp_ipa
```

a sub attribute set called `renamedPkgs` is generated referring to an app that
has renamed several of its standard properties to those provided by the `new*`
parameters.  The `new*` parameters should be changed to match those in your
certificate and mobile provisioning profile.

To find out what they are, use the Keychain to inspect the certificate (p12 file)
and Xcode (or a text editor) to inspect the mobile provisioning profile.

The resulting IPA file can actually be deployed to an Apple device if all
attributes are set correctly.

Enabling wireless ad-hoc distributions of iOS apps
--------------------------------------------------
It is also possible to do automatic installs of ad-hoc IPA files from Hydra, the
Nix-based continuous integration server.

To allow users to do such tasks, we must add a forwarding HTML page build product
to a build and install a couple of PHP scripts on the Hydra server generating a
plist configuration file.

By adding a number of extra parameters to the previous composition expression,
such as `enableWirelessDistribution`, we can generate the forwarding HTML page
build product and provide all relevant settings for generating a plist file:

```bash
$ nix-build --arg rename true \
  --argstr newName "Renamed" \
  --argstr newId "renamedapp" \
  --argstr newDomain "com.example" \
  --argstr newCompanyName "My Renamed Company" \
  --arg ipaCertificateFile /path/to/certificate.p12 \
  --argstr ipaCertificatePassword secret \
  --argstr ipaCodeSignIdentity "iPhone Distribution: My Renamed Company" \
  --arg ipaProvisioningProfile /path/to/provisioning.mobileprovision \
  --arg xcArchiveCertificateFile /path/to/certificate.p12 \
  --argstr xcArchiveCertificatePassword secret \
  --argstr xcArchiveCodeSignIdentity "iPhone Distribution: My Renamed Company" \
  --arg xcArchiveProvisioningProfile /path/to/provisioning.mobileprovision \
  --argstr signMethod "ad-hoc" \ # or: 'enterprise', 'app-store'
  --arg enableWirelessDistribution true \
  --arg installURL "/installipa.php" \
  --argstr bundleId "com.mycoolcompany.renamed" \
  --argstr version "1.0" \
  --argstr title "Renamed" \
  -A renamedPkgs.renamedapp_ipa
```

We have also configured an `installURL`, which is a PHP script responsible for
doing the generation.

The PHP scripts must be installed by enabling PHP on the reverse proxy of Hydra,
setting the document root to the `distribution-proxy` folder that is part of this
package and by defining adding rules for these PHP scripts not to forward
connections to Hydra's Catalyst server.

If NixOS is used for deploying the Hydra machine, the reverse proxy's
configuration can be defined as follows:

```nix
services.httpd = {
  enable = true;
  adminAddr = "admin@example.com";
  hostName = "hydra.example.com";
  extraModules = [
    { name = "php5"; path = "${pkgs.php}/modules/libphp5.so"; }
  ];
  documentRoot = pkgs.stdenv.mkDerivation {
    name = "distribution-proxy";
    src =./src/distribution-proxy;
    buildCommand = ''
      mkdir -p $out
      cp $src/src/distribution-proxy/*.php $out
    '';
  };
  extraConfig = ''
    <proxy>
      Order deny,allow
      Allow from all
    </proxy>

    ProxyPass /installipa.php !
    ProxyPass /distribution.plist.php !

    ProxyRequests     Off
    ProxyPreserveHost On
    ProxyPass         /  http://localhost:3000/ retry=5 disablereuse=on
    ProxyPassReverse  /  http://localhost:3000/
  '';
};
```
