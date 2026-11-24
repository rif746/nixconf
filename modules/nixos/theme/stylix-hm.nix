{ ... }:
{
  flake.homeModules.system-stylix =
    {
      osConfig,
      lib,
      options,
      ...
    }: {
        stylix.targets = {
          wayprompt.enable = false;
        };
      };
}
