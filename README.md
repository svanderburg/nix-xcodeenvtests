iOS build environment for Nix
=============================
This component is basically a wrapper/workaround that makes it possible to
expose an Xcode installation as a Nix package by means of symlinking to the
relevant executables on the host system.

Since Xcode can't be packaged with Nix, nor we can publish it as a Nix package
(because of its license) this is basically the only integration strategy
making it possible to do iOS application builds that integrate with other
components of the Nix ecosystem

The primary objective of this project is to use the Nix expression language to
specify how iOS apps can be built from source code, and to automatically spawn
iOS simulator instances for testing.

This project also makes it possible to use [Hydra](http://nixos.org/hydra),
the Nix-based continuous integration server to regularly build iOS apps and to
do wireless ad-hoc installations of enterprise IPAs on iOS devices through
Hydra.

The content of this repository is a standalone version for
experimentation/testing purposes. All changes in this repository are supposed to
(eventually) land in the upstream Nixpkgs repository.

Prerequisites
=============
* A single user installation of the [Nix package manager](http://nixos.org).
  Multi-user installations will not work. We need access to the Keychain of
  the logged in user to be able to sign the IPA file.
* [Nixpkgs](http://nixos.org/nixpkgs)
* A manual Xcode installation with all relevant iOS development plugins. You can
  install it from the Apple App store or download DMGs from the Apple developer
  portal.

Usage
=====
The Xcode build environment implements a number of features.

Deploying a proxy component wrapper exposing Xcode
--------------------------------------------------
The first use case is deploying a Nix package that provides symlinks to the Xcode
installation on the host system. This package can be used as a build input to
any build function implemented in the Nix expression language that requires
Xcode.

```nix
{xcodeenv}:

xcodeenv.composeXcodeWrapper {
  version = "9.2";
  xcodeBaseDir = "/Applications/Xcode.app";
}
```

By deploying the above expression with `nix-build` and inspecting its content
you will notice that several Xcode-related executables are exposed as a Nix
package:

```bash
$ ls result/bin
lrwxr-xr-x  1 sander  staff  94  1 jan  1970 Simulator -> /Applications/Xcode.app/Contents/Developer/Applications/Simulator.app/Contents/MacOS/Simulator
lrwxr-xr-x  1 sander  staff  17  1 jan  1970 codesign -> /usr/bin/codesign
lrwxr-xr-x  1 sander  staff  17  1 jan  1970 security -> /usr/bin/security
lrwxr-xr-x  1 sander  staff  21  1 jan  1970 xcode-select -> /usr/bin/xcode-select
lrwxr-xr-x  1 sander  staff  61  1 jan  1970 xcodebuild -> /Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild
lrwxr-xr-x  1 sander  staff  14  1 jan  1970 xcrun -> /usr/bin/xcrun
```

Building an iOS application
---------------------------
We can build an iOS app executable for the simulator, or an IPA/xcarchive file
for release purposes, e.g. ad-hoc, enterprise or store installations, by
executing the `xcodeenv.buildApp {}` function:

```nix
{xcodeenv}:

xcodeenv.buildApp {
  name = "MyApp";
  src = ./myappsources;
  sdkVersion = "11.2";

  target = null; # Corresponds to the name of the app by default
  configuration = null; # Release for release builds, Debug for debug builds
  scheme = null; # -scheme will correspond to the app name by default
  sdk = null; # null will set it to 'iphonesimulator` for simulator builds or `iphoneos` to real builds
  xcodeFlags = "";

  release = true;
  certificateFile = ./mycertificate.p12;
  certificatePassword = "secret"
  provisioningProfile = ./myprovisioning.profile;
  signMethod = "ad-hoc"; # 'enterprise' or 'store'
  generateIPA = true;
  generateXCArchive = false;

  enableWirelessDistribution = true;
  installURL = "/installipa.php";
  bundleId = "mycompany.myapp";
  appVersion = "1.0";

  # Supports all xcodewrapper parameters as well
  xcodeBaseDir = "/Applications/Xcode.app";
}
```

The above function takes a variety of parameters:
* The `name` and `src` parameters are mandatory and specify the name of the app
  and the location where the source code resides
* `sdkVersion` specifies which version of the iOS SDK to use.

It also possile to adjust the `xcodebuild` parameters. This is only needed in
rare circumstances. In most cases the default values should suffice:

* Specifies which `xcodebuild` target to build. By default it takes the target
  that has the same name as the app.
* The `configuration` parameter can be overridden if desired. By default, it
  will do a debug build for the simulator and a release build for real devices.
* The `scheme` parameter specifies which `-scheme` parameter to propagate to
  `xcodebuild`. By default, it corresponds to the app name.
* The `sdk` parameter specifies which SDK to use. By default, it picks
  `iphonesimulator` for simulator builds and `iphoneos` for release builds.
* The `xcodeFlags` parameter specifies arbitrary command line parameters that
  should be propagated to `xcodebuild`.

By default, builds are carried out for the iOS simulator. To do release builds
(builds for real iOS devices), you must set the `release` parameter to `true`.
In addition, you need to set the following parameters:

* `certificateFile` refers to a P12 certificate file.
* `certificatePassword` specifies the password of the P12 certificate.
* `provisioningProfile` refers to the provision profile needed to sign the app
* `signMethod` should refer to `ad-hoc` for signing the app with an ad-hoc
  certificate, `enterprise` for enterprise certificates and `app-store` for App
  store certificates.
* `generateIPA` specifies that we want to produce an IPA file (this is probably
  what you want)
* `generateXCArchive` specifies thet we want to produce an xcarchive file.

When building IPA files on Hydra and when it is desired to allow iOS devices to
install IPAs by browsing to the Hydra build products page, you can enable the
`enableWirelessDistribution` parameter.

When enabled, you need to configure the following options:

* The `installURL` parameter refers to the URL of a PHP script that composes the
  `itms-services://` URL allowing iOS devices to install the IPA file.
* `bundleId` refers to the bundle ID value of the app
* `appVersion` refers to the app's version number

To use wireless adhoc distributions, you must also install the corresponding
PHP script on a web server (see section: 'Installing the PHP script for wireless
ad hoc installations from Hydra' for more information).

In addition to the build parameters, you can also specify any parameters that
the `xcodeenv.composeXcodeWrapper {}` function takes. For example, the
`xcodeBaseDir` parameter can be overridden to refer to a different Xcode
version.

Spawning simulator instances
----------------------------
In addition to building iOS apps, we can also automatically spawn simulator
instances:

```nix
{xcodeenv}:

xcode.simulateApp {
  name = "simulate";

  # Supports all xcodewrapper parameters as well
  xcodeBaseDir = "/Applications/Xcode.app";
}

The above expression produces a script that starts the simulator from the
provided Xcode installation. The script can be started as follows:

```bash
./result/bin/run-test-simulator
```

By default, the script will show an overview of UDID for all available simulator
instances and asks you to pick one. You can also provide a UDID as a
command-line parameter to launch an instance automatically:

```bash
./result/bin/run-test-simulator 5C93129D-CF39-4B1A-955F-15180C3BD4B8
```

You can also extend the simulator script to automatically deploy and launch an
app in the requested simulator instance:

```nix
{xcodeenv}:

xcode.simulateApp {
  name = "simulate";
  bundleId = "mycompany.myapp";
  app = xcode.buildApp { ... };

  # Supports all xcodewrapper parameters as well
  xcodeBaseDir = "/Applications/Xcode.app";
}
```

By providing the result of an `xcode.buildApp {}` function and configuring the
app bundle id, the app gets deployed automatically and started.

Installing the PHP script for wireless ad hoc installations from Hydra
======================================================================
To allow iOS device users to install IPA files produced from Hydra by using the
browser on a tablet/phone, you need a Hydra installation with a reverse proxy
server. Consult the Hydra installation documentation for more information.

The PHP scripts must be installed by enabling PHP on the reverse proxy,
setting the document root to the `distribution-proxy` folder that is part of this
package and by defining adding rules for these PHP scripts not to forward
connections to Hydra's Catalyst server.

If NixOS is used for deploying the Hydra machine, the reverse proxy's
configuration could look as follows:

```nix
services.httpd = {
  enable = true;
  enablePHP = true;
  adminAddr = "admin@example.com";
  hostName = "hydra.example.com";
  documentRoot = pkgs.stdenv.mkDerivation {
    name = "distribution-proxy";
    src =./distribution-proxy;
    buildCommand = ''
      mkdir -p $out
      cp $src/distribution-proxy/*.php $out
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

License
=======
The contents of this package (except for the iOS example project) is covered by
the same license as Nixpkgs -- the
[MIT license](https://opensource.org/licenses/MIT).
