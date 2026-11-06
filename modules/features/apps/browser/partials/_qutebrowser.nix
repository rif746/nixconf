{
  osConfig,
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.features.apps.browser;
  isLowspec = osConfig.nixos.lowspec.enable;
in
{
  programs.qutebrowser = lib.mkIf cfg.qutebrowser.enable {
    enable = true;

    loadAutoconfig = false;
    searchEngines = {
      DEFAULT = "https://google.com/search?q={}";
      nxp = "https://search.nixos.org/packages?query={}";
      nxo = "https://search.nixos.org/options?query={}";
      yt = "https://youtube.com/results?search_query={}";
    };
    settings = {
      # Content & Adblocking
      "content.javascript.enabled" = true;
      "content.javascript.clipboard" = "access-paste";
      "content.javascript.prompt" = false;
      "content.pdfjs" = false;
      "content.notifications.enabled" = false;
      "content.blocking.method" = "both";

      "content.blocking.adblock.lists" = [
        "https://easylist.to/easylist/easylist.txt"
        "https://easylist.to/easylist/easyprivacy.txt"
        "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/filters.txt"
        "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/filters-2021.txt"
        "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/legacy.txt"
        "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/privacy.txt"
        "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/badware.txt"
        "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/resource-abuse.txt"
        "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/unbreak.txt"
        "https://raw.githubusercontent.com/brave/adblock-lists/master/brave-lists/brave-social.txt"
      ];

      "content.blocking.hosts.lists" = [
        "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
        "https://pgl.yoyo.org/adservers/serverlist.php?hostformat=hosts&showintro=1&mimetype=plaintext&_=223428"
      ];

      "colors.webpage.preferred_color_scheme" = "dark";

      # Downloads
      "downloads.position" = "bottom";
      "downloads.remove_finished" = 1000;

      # File Picker Integration (Kitty + LF)
      "fileselect.handler" = "external";
      "fileselect.folder.command" = [
        "kitty"
        "-e"
        "lf"
        "-command"
        "set last-dir-path {}"
      ];
      "fileselect.single_file.command" = [
        "kitty"
        "-e"
        "lf"
        "-selection-path={}"
      ];
      "fileselect.multiple_files.command" = [
        "kitty"
        "-e"
        "lf"
        "-selection-path={}"
      ];

      # Tabs Alignment & Layout
      "tabs.show" = "multiple";
      "tabs.position" = "left";
      "tabs.title.format" = "{current_title}";
      "tabs.width" = 45;
      "tabs.indicator.width" = 0;
      "tabs.title.alignment" = "center";

      # Status Bar
      "statusbar.show" = "in-mode";
      "statusbar.position" = "top";

      # External Editor (Kitty + Neovim)
      "editor.command" = [
        "kitty"
        "-e"
        "nvim"
        "{file}"
      ];

      "url.start_pages" = [ "https://google.com" ];
      "url.default_page" = "https://google.com";
    };

    extraConfig = ''
      c.tabs.padding = {
          'top': 12,
          'bottom': 12,
          'left': 10,
          'right': 10
      }

      c.statusbar.padding = {
          'top': 0,
          'bottom': 0,
          'left': 0,
          'right': 0
      }
    '';
  };
}
