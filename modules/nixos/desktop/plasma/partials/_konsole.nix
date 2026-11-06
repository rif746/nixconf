{
  config,
  pkgs,
  lib,
  osConfig ? { },
  ...
}:
{
  programs.konsole = {
    enable = true;
    defaultProfile = "Default";

    profiles = {
      "Default" = {
        name = "Default";
        command = "/bin/sh -c $SHELL";
        font = {
          name = "fira-code-symbols";
          size = 10;
        };
      };
    };

    customColorSchemes = {
      Breeze = {
        General = {
          Anchor = "0.5,0.5";
          Blur = true;
          ColorRandomization = false;
          Description = "Breeze";
          FillStyle = "Tile";
          Opacity = 0.96;
        };

        # Text and Window Canvas Roles
        Foreground.Color = "#${config.lib.stylix.colors.base05}"; # Default Foreground
        ForegroundFaint.Color = "#${config.lib.stylix.colors.base04}"; # Darker Foreground
        ForegroundIntense.Color = "#${config.lib.stylix.colors.base06}"; # Light Foreground

        Background.Color = "#${config.lib.stylix.colors.base00}"; # Default Background
        BackgroundFaint.Color = "#${config.lib.stylix.colors.base01}"; # Lighter Background
        BackgroundIntense.Color = "#${config.lib.stylix.colors.base02}"; # Selection Background

        # ANSI Colors 0-7 (Normal)
        Color0.Color = "#${config.lib.stylix.colors.base00}"; # Black
        Color1.Color = "#${config.lib.stylix.colors.base08}"; # Red
        Color2.Color = "#${config.lib.stylix.colors.base0B}"; # Green
        Color3.Color = "#${config.lib.stylix.colors.base0A}"; # Yellow
        Color4.Color = "#${config.lib.stylix.colors.base0D}"; # Blue
        Color5.Color = "#${config.lib.stylix.colors.base0E}"; # Magenta
        Color6.Color = "#${config.lib.stylix.colors.base0C}"; # Cyan
        Color7.Color = "#${config.lib.stylix.colors.base05}"; # White

        # ANSI Colors 0-7 Intense (Bright Modifications)
        Color0Intense.Color = "#${config.lib.stylix.colors.base03}"; # Bright Black (Comments)
        Color1Intense.Color = "#${config.lib.stylix.colors.base08}"; # Bright Red
        Color2Intense.Color = "#${config.lib.stylix.colors.base0B}"; # Bright Green
        Color3Intense.Color = "#${config.lib.stylix.colors.base0A}"; # Bright Yellow
        Color4Intense.Color = "#${config.lib.stylix.colors.base0D}"; # Bright Blue
        Color5Intense.Color = "#${config.lib.stylix.colors.base0E}"; # Bright Magenta
        Color6Intense.Color = "#${config.lib.stylix.colors.base0C}"; # Bright Cyan
        Color7Intense.Color = "#${config.lib.stylix.colors.base07}"; # Bright White

        # ANSI Colors 0-7 Faint (Dim Modifications)
        Color0Faint.Color = "#${config.lib.stylix.colors.base01}";
        Color1Faint.Color = "#${config.lib.stylix.colors.base08}";
        Color2Faint.Color = "#${config.lib.stylix.colors.base0B}";
        Color3Faint.Color = "#${config.lib.stylix.colors.base0A}";
        Color4Faint.Color = "#${config.lib.stylix.colors.base0D}";
        Color5Faint.Color = "#${config.lib.stylix.colors.base0E}";
        Color6Faint.Color = "#${config.lib.stylix.colors.base0C}";
        Color7Faint.Color = "#${config.lib.stylix.colors.base04}";
      };
    };
  };
}
