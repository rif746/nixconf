{ ... }: {
    flake.nixosModules.virtualisation = { config, lib, pkgs, ... }: let
        cfg = config.modules.virtualisation;
    in {
        options.modules.virtualisation = {
            kvm.enable = lib.mkEnableOption "Kernel-based Virtualisation";
            docker = {
                enable = lib.mkEnableOption "Docker container";
                storagePath = lib.mkOption {
                    type = lib.types.str;
                    default = "/var/lib/docker/";
                    description = "Storage for docker file path";
                };
            };
            mainUser = lib.mkOption {
                type = lib.types.str;
                default = "syarif";
                description = "Primary user to be granted libvirtd group permissions";
            };
        };


        config = {
            virtualisation = {
                libvirtd = lib.mkIf cfg.kvm.enable {
                    enable = true;
                    qemu.vhostUserPackages = with pkgs; [ virtiofsd ];
                };

                docker = lib.mkIf cfg.docker.enable {
                    enable = true;
                    rootless = {
                        enable = true;
                        setSocketVariable = true;
                    };
                    daemon.settings = {
                        experimental = true;
                        data-root = cfg.docker.storagePath;
                        default-address-pools = [
                            {
                                base = "172.30.0.0/16";
                                size = 24;
                            }
                        ];
                    };
                };

            };

            programs.virt-manager.enable = cfg.kvm.enable;


            services.qemuGuest.enable = cfg.kvm.enable;
            services.spice-vdagentd.enable = cfg.kvm.enable;
            users.users.${cfg.mainUser}.extraGroups = []  ++
                (lib.optional cfg.kvm.enable "libvirtd");
            networking.firewall.trustedInterfaces = []  ++
                (lib.optional cfg.kvm.enable "virbr0");
        };
    };
}
