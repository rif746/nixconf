{ cfg, user }:
{
  lib,
  pkgs,
  config,
  ...
}:
let
  adbCfg = cfg.adb;
  sdkCfg = cfg.sdk;
  flutterCfg = cfg.flutter;
  defaultBrowser = config.home-manager.users.${user.name}.features.apps.browser.default or "firefox";

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
  config = lib.mkMerge [
    # 1. ADB & Fastboot (aktif jika adb, sdk, atau flutter dinyalakan)
    (lib.mkIf (adbCfg.enable || sdkCfg.enable || flutterCfg.enable) {
      environment.systemPackages = [ pkgs.android-tools ];
    })

    # 2. Android SDK & JDK 17 (aktif jika sdk atau flutter dinyalakan)
    (lib.mkIf (sdkCfg.enable || flutterCfg.enable) {
      nixpkgs.config.android_sdk.accept_license = true;

      environment.systemPackages = with pkgs; [
        jdk17
        androidSdk
      ];

      environment.sessionVariables = {
        ANDROID_HOME = "${androidSdk}/libexec/android-sdk";
        ANDROID_SDK_ROOT = "${androidSdk}/libexec/android-sdk";
        JAVA_HOME = "${pkgs.jdk17}";
      };
    })

    # 3. Flutter SDK (khusus paket flutter dan browser target web)
    (lib.mkIf flutterCfg.enable {
      environment.systemPackages = [ pkgs.flutter ];

      environment.sessionVariables = {
        CHROME_EXECUTABLE = defaultBrowser;
      };
    })
  ];
}
