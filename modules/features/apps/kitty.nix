{ ... }: {
  flake.homeModules.apps-jetbrains =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.features.apps.kitty;
    in
    {
      options.features.apps.kitty.enable = lib.mkEnableOption "Enable kitty terminal";

      config = lib.mkIf cfg.enable {
        programs.kitty = {
          enable = true;

          font = {
            name = lib.mkDefault "FiraCode Nerd Font Propo";
            size = lib.mkDefault 9.0;
          };

          settings = {
            adjust_line_height = 2;
            disable_ligatures = "never";

            scrollback_lines = 10000;
            scrollback_pager = "less +G -R";
            scrollback_in_new_tab = "no";
            mouse_hide_wait = "3.0";
            wheel_scroll_multiplier = "5.0";
            click_interval = "0.5";
            select_by_word_characters = ":@-./_~?&=%+#";

            cursor_shape = "block";
            cursor_blink_interval = "0.4";
            cursor_stop_blinking_after = "4.0";

            remember_window_size = "no";
            initial_window_width = 640;
            initial_window_height = 400;
            enabled_layouts = "*";
            focus_follows_mouse = "yes";
            repaint_delay = 10;
            input_delay = 3;

            window_padding_width = "2 2 1 2";
            window_border_width = 1;

            open_url_modifiers = "ctrl+shift";
            open_url_with = "default";
            clipboard_control = "write-clipboard write-primary";
            use_system_wcwidth = "yes";
            term = "xterm-kitty";
            enable_audio_bell = "no";

            tab_bar_style = "powerline";
            tab_powerline_style = "round";

            active_border_color = lib.mkDefault "#00ff00";
            inactive_border_color = lib.mkDefault "#cccccc";
            active_tab_foreground = lib.mkDefault "#000000";
            active_tab_background = lib.mkDefault "#eeeeee";
            inactive_tab_foreground = lib.mkDefault "#444444";
            inactive_tab_background = lib.mkDefault "#999999";
          };

          # Key Mappings
          keybindings = {
            # Clipboard
            "ctrl+shift+v" = "paste_from_clipboard";
            "ctrl+shift+s" = "paste_from_selection";
            "ctrl+shift+c" = "copy_to_clipboard";
            "shift+insert" = "paste_from_selection";
            "ctrl+shift+o" = "pass_selection_to_program qutebrowser";

            # Scrolling
            "ctrl+shift+up" = "scroll_line_up";
            "ctrl+shift+down" = "scroll_line_down";
            "ctrl+shift+k" = "scroll_line_up";
            "ctrl+shift+j" = "scroll_line_down";
            "ctrl+shift+page_up" = "scroll_page_up";
            "ctrl+shift+page_down" = "scroll_page_down";
            "ctrl+shift+home" = "scroll_home";
            "ctrl+shift+end" = "scroll_end";

            # Window management
            "ctrl+shift+enter" = "new_window";
            "ctrl+shift+w" = "close_window";
            "ctrl+shift+]" = "next_window";
            "ctrl+shift+[" = "previous_window";
            "ctrl+shift+f" = "move_window_forward";
            "ctrl+shift+b" = "move_window_backward";
            "ctrl+shift+`" = "move_window_to_top";
            "ctrl+shift+1" = "first_window";
            "ctrl+shift+2" = "second_window";
            "ctrl+shift+3" = "third_window";
            "ctrl+shift+4" = "fourth_window";
            "ctrl+shift+5" = "fifth_window";
            "ctrl+shift+6" = "sixth_window";
            "ctrl+shift+7" = "seventh_window";
            "ctrl+shift+8" = "eighth_window";
            "ctrl+shift+9" = "ninth_window";
            "ctrl+shift+0" = "tenth_window";

            # Tab management
            "ctrl+shift+l" = "next_tab";
            "ctrl+shift+h" = "previous_tab";
            "ctrl+shift+t" = "new_tab";
            "ctrl+shift+q" = "close_tab";
            "ctrl+shift+." = "move_tab_forward";
            "ctrl+shift+," = "move_tab_backward";

            # Miscellaneous
            "ctrl+shift+equal" = "increase_font_size";
            "ctrl+shift+minus" = "decrease_font_size";
            "ctrl+shift+backspace" = "restore_font_size";
            "ctrl+shift+f11" = "toggle_fullscreen";
          };
        };
      };
    };
}
