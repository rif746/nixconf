# ❄️ NixOS & Home Manager Configuration

Repositori ini berisi konfigurasi sistem NixOS dan lingkungan pengguna Home Manager yang dibangun secara **declarative**, **modular**, dan berbasis **Flakes** (`flake-parts`).

---

## 🏗️ Arsitektur & Prinsip Desain

1. **Single Source of Truth (`specialArgs.user`)**  
   Metadata pengguna (nama, deskripsi, hashed password, default shell, hingga profil fitur HM) didefinisikan secara eksplisit di level host (`modules/hosts/<hostname>/default.nix`) dan di-inject via `specialArgs`. Tidak ada lagi profil HM terpisah yang terisolasi.

2. **Pemisahan Ruang Lingkup Sistem vs Pengguna**  
   - `modules/nixos/`: Pengaturan level OS/sistem (hardware, display manager, bootloader, layanan sistem).
   - `modules/features/` & `modules/home/`: Pengaturan level user-space (CLI tools, GUI apps, dotfiles, shell configs).

3. **Inter-Module Communication (`osConfig`)**  
   Modul Home Manager membaca status aktif layanan sistem NixOS secara aman melalui `osConfig.nixos.*` untuk menghindari *infinite recursion error*.

4. **Dynamic & Granular CLI Integration**  
   - Terminal shell di-resolve secara dinamis via path `(./. + "/_${user.shell}.nix")`.
   - Tool Developer dipecah secara granular (`vcs.nix`, `neovim/`, `direnv`, `devenv`).
   - Prompt **Starship** dikonfigurasi penuh via atribut Nix (`programs.starship.settings`) dengan visual indikator VCS (Nerd Font glyphs), multi-runtime language, `devenv`, dan `nix-shell`.

---

## 📂 Struktur Direktori

```text
.
├── flake.nix
├── modules/
│   ├── features/                  # Modul fitur Home Manager (User-space)
│   │   ├── apps/                  # Aplikasi GUI (browser, communications, godot, jetbrains)
│   │   └── cli/                   # Perangkat CLI (vcs, neovim, llm, shell)
│   │       ├── shell/             # Main shell module & dynamic _<shell>.nix loader
│   │       └── vcs.nix            # Version Control System (Git, LazyGit, GitHub CLI)
│   ├── hosts/                     # Definisi Host / Mesin Spesifik
│   │   └── pc-a520m/              # Konfigurasi Host AMD A520M & Hardware
│   └── nixos/                     # Modul NixOS System-space
│       ├── desktop/               # Desktop Environment (Plasma 6, DWM)
│       ├── system/                # Core OS (bootloader, audio, joystick, users)
│       └── tools/                 # Layanan & Devkit Sistem (webserver, gaming, virt)

```

---

## ⚙️ Opsi Namespace Utama

### NixOS (`nixos.*`)

| Opsi | Tipe | Deskripsi |
| --- | --- | --- |
| `nixos.desktop.plasma.enable` | `bool` | Mengaktifkan KDE Plasma 6 Desktop Environment |
| `nixos.tools.gaming.enable` | `bool` | Mengaktifkan lingkungan gaming (Steam, GameMode) |
| `nixos.tools.webserver.enable` | `bool` | Development stack lokal (Apache, PHP 8.3/8.5, MariaDB, Dnsmasq `*.test`) |
| `nixos.tools.virtualisation.kvm.enable` | `bool` | Virtualisasi KVM / QEMU & Libvirtd |

### Home Manager (`features.*`)

| Opsi | Tipe | Deskripsi |
| --- | --- | --- |
| `features.apps.browser.enable` | `bool` | Browser suite dengan wrapping XDG default browser |
| `features.apps.jetbrains.enable` | `bool` | IDE JetBrains (PhpStorm, DataGrip, PyCharm, dll.) |
| `features.cli.vcs.enable` | `bool` | Modular VCS toolchain (Git, LazyGit, GH CLI) |
| `features.cli.nvim.enable` | `bool` | Neovim text editor setup |
| `features.cli.llm.enable` | `bool` | CLI LLM tools wrapper |

---

## 🚀 Cara Penggunaan

### 1. Build & Switch Konfigurasi

Untuk menerapkan perubahan konfigurasi pada mesin `pc-a520m`:

```bash
# Menggunakan alias bawaan modul shell:
rebuild

# Atau perintah NixOS native:
sudo nixos-rebuild switch --flake .#pc-a520m

```

### 2. Pembersihan Store (Garbage Collection)

```bash
# Menggunakan alias bawaan:
nix-clear

# Atau perintah native:
sudo nix-collect-garbage -d

```

### 3. Menambahkan Host Baru

1. Buat folder baru di bawah `modules/hosts/<hostname>/`.
2. Deklarasikan `specialArgs.user` beserta profil fiturnya.
3. Daftarkan host baru tersebut ke dalam `flake.nix`.

---

## 📝 Lisensi

Distributed under the MIT License.
