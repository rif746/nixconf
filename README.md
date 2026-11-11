# ❄️ NixOS & Home Manager Configuration

This repository contains the NixOS system and Home Manager user environment configuration, built declaratively, modularly, and on top of **Flakes** (`flake-parts`).

---

## 🏗️ Architecture & Design Principles

1. **Single Source of Truth (`specialArgs.user`)**  
   User metadata (name, description, hashed password, default shell, and HM feature profile) is explicitly defined at the host level (`modules/hosts/<hostname>/default.nix`) and injected through `specialArgs`. There are no longer isolated, separate HM profiles.

2. **Separation of System and User Scope**
   - `modules/nixos/`: OS/system-level settings (hardware, display manager, bootloader, system services).
   - `modules/features/` & `modules/home/`: User-space settings (CLI tools, GUI apps, dotfiles, shell configs).

3. **Inter-Module Communication (`osConfig`)**  
   Home Manager modules safely read the active status of NixOS system services through `osConfig.nixos.*` to avoid *infinite recursion errors*.

4. **Dynamic & Granular CLI Integration**  
   - The terminal shell is resolved dynamically through the path `(./. + "/_${user.shell}.nix")`.
   - Developer tools are split into granular modules (`vcs.nix`, `neovim/`, `direnv`, `devenv`).
   - The **Starship** prompt is fully configured through Nix attributes (`programs.starship.settings`) with visual VCS indicators (Nerd Font glyphs), multiple language runtimes, `devenv`, and `nix-shell`.

---

## 📂 Directory Structure

```text
.
├── flake.nix
├── modules/
│   ├── features/                  # Home Manager feature modules (user space)
│   │   ├── apps/                  # GUI applications (browser, communications, godot, jetbrains)
│   │   └── cli/                   # CLI tools (vcs, neovim, llm, shell)
│   │       ├── shell/             # Main shell module & dynamic _<shell>.nix loader
│   │       └── vcs.nix            # Version Control System (Git, LazyGit, GitHub CLI)
│   ├── hosts/                     # Host-specific definitions
│   │   └── pc-a520m/              # AMD A520M host and hardware configuration (_hardware.nix)
│   └── nixos/                     # NixOS system-space modules
│       ├── desktop/               # Desktop Environment (Plasma 6, DWM)
│       ├── system/                # Core OS (bootloader, audio, joystick, users)
│       └── tools/                 # System services and development tools (webserver, gaming, virtualization)
```

---

## ⚙️ Main Namespace Options

### NixOS (`nixos.*`)

| Opsi | Tipe | Deskripsi |
| --- | --- | --- |
| `nixos.desktop.plasma.enable` | `bool` | Enable the KDE Plasma 6 desktop environment |
| `nixos.tools.gaming.enable` | `bool` | Enable the gaming environment (Steam, GameMode) |
| `nixos.tools.webserver.enable` | `bool` | Local development stack (Apache, PHP 8.3/8.5, MariaDB, Dnsmasq `*.test`) |
| `nixos.tools.virtualisation.kvm.enable` | `bool` | KVM / QEMU and Libvirtd virtualization |
| `nixos.tools.virtualisation.docker.enable` | `bool` | Docker container engine |

### Home Manager (`features.*`)

| Opsi | Tipe | Deskripsi |
| --- | --- | --- |
| `features.apps.browser.enable` | `bool` | Browser suite with XDG default browser wrapper |
| `features.apps.jetbrains.enable` | `bool` | JetBrains IDEs (PhpStorm, DataGrip, PyCharm, etc.) |
| `features.cli.vcs.enable` | `bool` | Modular VCS toolchain (Git, LazyGit, GH CLI) |
| `features.cli.nvim.enable` | `bool` | Neovim text editor setup |
| `features.cli.llm.enable` | `bool` | CLI LLM tools wrapper |

---

## 🚀 Usage

### 1. Hardware Initialization (Required for New Clones or Machines)

Each machine (host/VM) has disk UUIDs and specific kernel modules. When cloning the repository or adding a new host, **always generate the hardware configuration in the target host directory**:

```bash
# 1. Generate the hardware configuration directly in the host-specific directory
sudo nixos-generate-config --dir modules/hosts/<hostname>

# 2. Change to the host directory
cd modules/hosts/<hostname>

# 3. Rename hardware-configuration.nix to _hardware.nix
mv hardware-configuration.nix _hardware.nix

# 4. Remove the generated configuration.nix (to avoid disrupting the Flake structure)
rm configuration.nix
```

> **Note:** Ensure the host module (`modules/hosts/<hostname>/default.nix`) imports `./_hardware.nix`.

### 2. Build and Switch the Configuration

To apply configuration changes to a machine (for example, `pc-a520m`):

```bash
# Use the shell module's built-in alias:
rebuild

# Or use the native NixOS command:
sudo nixos-rebuild switch --flake .#pc-a520m
```

### 3. Store Cleanup (Garbage Collection)

```bash
# Use the built-in alias:
nix-clear

# Or use the native command:
sudo nix-collect-garbage -d
```

### 4. Adding a New Host

1. Create a new directory under `modules/hosts/<hostname>/`.
2. Follow the **Hardware Initialization** steps above to create `_hardware.nix`.
3. Create `default.nix` in that host directory, then declare `specialArgs.user` and its feature profile.
4. Register the new host in `flake.nix`.
