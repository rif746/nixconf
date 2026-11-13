{ ... }:
{
  flake.nixosModules.dev-flutter =
    {
      config,
      lib,
      pkgs,
      ...
    }:

    let
      adbCfg = config.nixos.tools.dev.adb;
      flutterCfg = config.nixos.tools.dev.flutter;

      androidComposition = pkgs.androidenv.composeAndroidPackages {
        cmdLineToolsVersion = "13.0";
        platformToolsVersion = "35.0.2";
        buildToolsVersions = [
          "34.0.0"
          "35.0.0"
        ];
        platformVersions = [
          "34"
          "35"
        ];
        includeEmulator = false;
        includeNDK = false;
        includeSystemImages = false;
        extraLicenses = [
          "android-sdk-license"
          "android-sdk-preview-license"
          "android-googletv-license"
          "android-sdk-arm-dbt-license"
          "google-gdk-license"
          "intel-android-extra-license"
        ];
      };

      androidSdk = androidComposition.androidsdk;
    in
    {
      options.nixos.tools.dev = {
        adb.enable = lib.mkEnableOption "ADB and fastboot USB debugging tools";
        flutter.enable = lib.mkEnableOption "Flutter and full Android SDK CLI environment";
      };

      config = lib.mkMerge [
        # Minimal ADB-only configuration
        (lib.mkIf (adbCfg.enable || flutterCfg.enable) {
          environment.systemPackages = [ pkgs.android-tools ];
        })

        # Full Flutter + Android SDK configuration
        (lib.mkIf flutterCfg.enable {
          nixpkgs.config.android_sdk.accept_license = true;

          environment.systemPackages = with pkgs; [
            flutter
            jdk17
            androidSdk
          ];

          environment.sessionVariables = {
            ANDROID_HOME = "${androidSdk}/libexec/android-sdk";
            ANDROID_SDK_ROOT = "${androidSdk}/libexec/android-sdk";
            JAVA_HOME = "${pkgs.jdk17}";
            CHROME_EXECUTABLE = "firefox";
          };
        })
      ];
    };
}
