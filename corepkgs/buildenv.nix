with import <nix/config.nix>;

{ derivations, manifest }:

derivation {
  name = "user-environment";
  system = builtins.currentSystem;
  builder = perl;
  args = [ "-w" ./buildenv.pl ];

  manifest = manifest;

  # !!! grmbl, need structured data for passing this in a clean way.
  derivations =
    map (d:
      [ (d.meta.active or "true")
        (d.meta.priority or 5)
        (builtins.length d.outputs)
      ] ++ map (output: builtins.getAttr output d) d.outputs)
      derivations;

  # Building user environments remotely just causes huge amounts of
  # network traffic, so don't do that.
  preferLocalBuild = true;

  __impureHostDeps = [
    "/usr/lib/libSystem.dylib"
    "/usr/lib/libSystem.B.dylib"
    "/usr/lib/libobjc.A.dylib"
    "/usr/lib/libobjc.dylib"
    "/usr/lib/libauto.dylib"
    "/usr/lib/libc++abi.dylib"
    "/usr/lib/libc++.1.dylib"
    "/usr/lib/libDiagnosticMessagesClient.dylib"
    "/usr/lib/system"
  ];

  inherit chrootDeps;
}
