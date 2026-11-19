{ cfg }:
{ lib, pkgs, ... }:
{
  config = lib.mkIf cfg.cpp.enable {
    environment.systemPackages = with pkgs; [
      gcc
      clang
      clang-tools # clangd LSP & clang-format
      cmake
      ninja
      gnumake
      pkg-config
      gdb
      valgrind
    ];
  };
}
