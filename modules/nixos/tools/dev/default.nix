{ ... }:
{
  flake.nixosModules.tools-devkit =
    {
      user,
      config,
      lib,
      ...
    }:
    let
      cfg = config.nixos.tools.devkit;
    in
    {
      imports = [
        (import ./partials/_android.nix { inherit cfg user; })
        (import ./partials/_cpp.nix { inherit cfg; })
        (import ./partials/_golang.nix { inherit user cfg; })
        (import ./partials/_python.nix { inherit cfg; })
      ];

      options.nixos.tools.devkit = {
        adb.enable = lib.mkEnableOption "ADB and fastboot USB debugging tools";
        sdk.enable = lib.mkEnableOption "Android SDK, JDK 17, and command-line build tools";
        flutter.enable = lib.mkEnableOption "Flutter SDK and full Android development environment";
        cpp.enable = lib.mkEnableOption "C/C++ Development Environment (GCC, Clang, CMake, Ninja, GDB)";
        golang.enable = lib.mkEnableOption "Go Development Environment (Go, gopls, delve, golangci-lint)";
        python.enable = lib.mkEnableOption "Python Development Environment (Python 3, uv, ruff, basedpyright)";
      };
    };
}
