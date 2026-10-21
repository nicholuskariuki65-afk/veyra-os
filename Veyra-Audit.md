# Veyra OS — Technical Audit Report
**Target System:** HP Folio 13 (Intel Core i5 / HD Graphics, 8 GB RAM, Synaptics Touchpad, UEFI/BIOS)  
**Distribution Base:** Debian GNU/Linux 12 (Bookworm) `amd64`  
**Desktop Environment:** KDE Plasma 5.27 LTS  
**Audit Date:** October 2026  
**Auditor:** Antigravity (AI System Architecture)

---

## Executive Summary

This audit assesses the current state of the Veyra OS codebase, configuration trees, live ISO build scripts, desktop customization layers, hardware enablement, and CI/CD pipelines.

The repository establishes a Debian 12 (Bookworm) Live Build configuration configured with non-free firmware, a customized KDE Plasma configuration (Veyra Midnight Navy and Muted Teal color palette with macOS-style left-aligned window controls), and a GitHub Actions workflow compiling the hybrid ISO in a container.

This report documents the current implementation across all 9 audit dimensions, details exact file paths and configuration values, and identifies missing components with actionable architectural recommendations.

---

## 1. Complete Project Folder & File Structure

### 1.1 Root Repository Layout

```text
veyra-os/
├── .github/
│   └── workflows/
│       └── build-iso.yml          # GitHub Actions CI workflow (Docker-based Debian Bookworm builder)
├── .gitignore                     # Git exclusion rules for build artifacts, ISOs, and OS caches
├── branding/                      # Visual branding reference assets committed to Git
│   ├── veyra-brand-mark.png       # Minimalist brand logo mark
│   └── veyra-ui-reference.png     # Full multi-screen visual design specification sheet
├── live-build/                    # Debian Live Build (lb) workspace
│   ├── auto/                      # Live-build lifecycle hook scripts
│   │   ├── build                  # lb build wrapper script
│   │   ├── clean                  # lb clean wrapper script
│   │   └── config                 # lb config generation script with core parameters
│   └── config/                    # Live-build customization tree
│       ├── includes.chroot/       # Filesystem overlay copied directly into rootfs (/)
│       │   └── etc/
│       │       ├── sddm.conf.d/
│       │       │   └── 10-veyra.conf   # SDDM display manager auto-login & theme settings
│       │       └── skel/               # User skeleton directory (/etc/skel -> /home/veyra)
│       │           ├── .config/
│       │           │   ├── kdeglobals  # Global KDE fonts, color scheme, widget style, icon theme
│       │           │   └── kwinrc      # KWin window manager decorator & button configuration
│       │           └── .local/
│       │               └── share/
│       │                   └── color-schemes/
│       │                       └── VeyraDark.colors # Custom Veyra Qt/KDE color palette
│       └── package-lists/
│           └── veyra.list.chroot  # Chroot Debian package selection list
├── scripts/
│   └── build.sh                   # Standalone local build script for Linux/WSL2 environments
├── DESIGN.md                      # UI/UX design specification and reference analysis document
└── README.md                      # Project documentation and architectural overview
```

### 1.2 Inventory of Tracked Files & Exact Relative Paths

| File Path | Purpose |
|---|---|
| [`.github/workflows/build-iso.yml`](file:///.github/workflows/build-iso.yml) | GitHub Actions workflow: builds hybrid ISO inside native Debian container and publishes release assets |
| [`.gitignore`](file:///.gitignore) | Filters out `.build/`, `binary/`, `chroot/`, `cache/`, `*.iso`, `*.hybrid.iso`, logs, and temporary caches |
| [`branding/veyra-brand-mark.png`](file:///branding/veyra-brand-mark.png) | High-resolution Veyra logo mark (3D folding ribbon "V") |
| [`branding/veyra-ui-reference.png`](file:///branding/veyra-ui-reference.png) | High-resolution 12-screen design reference sheet |
| [`live-build/auto/build`](file:///live-build/auto/build) | Shell script invoking `lb build noauto "${@}"` |
| [`live-build/auto/clean`](file:///live-build/auto/clean) | Shell script invoking `lb clean noauto "${@}"` and removing staged configs |
| [`live-build/auto/config`](file:///live-build/auto/config) | Shell script executing `lb config noauto` with Debian 12 Bookworm parameters |
| [`live-build/config/includes.chroot/etc/sddm.conf.d/10-veyra.conf`](file:///live-build/config/includes.chroot/etc/sddm.conf.d/10-veyra.conf) | SDDM configuration: specifies Breeze theme, default user `veyra`, and remember user |
| [`live-build/config/includes.chroot/etc/skel/.config/kdeglobals`](file:///live-build/config/includes.chroot/etc/skel/.config/kdeglobals) | KDE Plasma global defaults: Inter font, VeyraDark color scheme, Breeze widget style, Breeze-dark icons |
| [`live-build/config/includes.chroot/etc/skel/.config/kwinrc`](file:///live-build/config/includes.chroot/etc/skel/.config/kwinrc) | KWin decorator: macOS-style left traffic lights (`ButtonsOnLeft=XIA`, `ButtonsOnRight=`) |
| [`live-build/config/includes.chroot/etc/skel/.local/share/color-schemes/VeyraDark.colors`](file:///live-build/config/includes.chroot/etc/skel/.local/share/color-schemes/VeyraDark.colors) | KDE Color Scheme file with Veyra Midnight Navy (`#172337`), Warm Ivory (`#F5F4EF`), and Muted Teal (`#69B7A0`) |
| [`live-build/config/package-lists/veyra.list.chroot`](file:///live-build/config/package-lists/veyra.list.chroot) | Complete package manifest installed into live chroot (kernel, KDE, firmware, tools) |
| [`scripts/build.sh`](file:///scripts/build.sh) | Local Linux/WSL2 build automation script checking dependencies and running `lb clean`, `config`, `build` |
| [`DESIGN.md`](file:///DESIGN.md) | Comprehensive UI/UX specification, color tokens, layout geometry, dock, snap rules, and typography |
| [`README.md`](file:///README.md) | Architectural documentation, hardware target specs, and instructions |

---

## 2. Debian Live ISO Build Architecture

### 2.1 Configuration Engine: `live-build/auto/config`
The build configuration is declared in [`live-build/auto/config`](file:///live-build/auto/config):
```sh
lb config noauto \
    --mode debian \
    --distribution bookworm \
    --architectures amd64 \
    --linux-flavours amd64 \
    --archive-areas "main contrib non-free non-free-firmware" \
    --parent-mirror-bootstrap "http://deb.debian.org/debian" \
    --parent-mirror-chroot "http://deb.debian.org/debian" \
    --mirror-bootstrap "http://deb.debian.org/debian" \
    --mirror-chroot "http://deb.debian.org/debian" \
    --binary-images iso-hybrid \
    --bootloaders syslinux,grub-efi \
    --debian-installer false \
    --iso-application "Veyra OS Live" \
    --iso-publisher "Veyra Project" \
    --iso-volume "VEYRA_OS_LIVE" \
    --memtest none \
    --source false \
    --firmware-binary true \
    --firmware-chroot true \
    --security false \
    --apt-recommends true \
    --bootappend-live "boot=live components quiet splash timezone=UTC locales=en_US.UTF-8 username=veyra user-default-groups=audio,cdrom,dip,floppy,video,plugdev,netdev,sudo,bluetooth" \
    "${@}"
```

**Key Parameters Analyzed:**
- `--distribution bookworm`: Targets Debian 12 (stable LTS foundation).
- `--archive-areas "main contrib non-free non-free-firmware"`: Enables Debian 12's dedicated `non-free-firmware` section required for modern Intel and Realtek hardware.
- `--binary-images iso-hybrid`: Generates a hybrid ISO image bootable from optical media or raw block USB flash drives (`dd`, Rufus, Ventoy).
- `--bootloaders syslinux,grub-efi`: Dual bootloader configuration providing SYSLINUX for legacy BIOS systems and GRUB2 for 64-bit UEFI firmware.
- `--debian-installer false`: Explicitly excludes the Debian installer, ensuring the media functions purely as a live OS without modifying internal drives.
- `--bootappend-live`: Configures the kernel command line:
  - `boot=live components`: Activates `live-boot` initialization scripts.
  - `quiet splash`: Suppresses verbose boot text (splash screen ready).
  - `username=veyra`: Provisions the default unprivileged user account.
  - `user-default-groups=...`: Grants `veyra` access to `sudo`, `video`, `audio`, `netdev`, `plugdev`, `bluetooth`.

### 2.2 Package Manifest: `live-build/config/package-lists/veyra.list.chroot`
The chroot package manifest contains 48 explicitly selected packages:
1. **Core Kernel & Live Environment:**
   `linux-image-amd64`, `live-boot`, `live-config`, `live-config-systemd`, `systemd-sysv`, `sudo`, `locales`.
2. **Bootloader & Hybrid ISO Tooling:**
   `syslinux`, `syslinux-utils`, `syslinux-common`, `isolinux`.
3. **Firmware:**
   `firmware-linux`, `firmware-linux-free`, `firmware-linux-nonfree`, `firmware-misc-nonfree`, `firmware-iwlwifi`, `firmware-realtek`, `firmware-atheros`, `intel-microcode`.
4. **Networking & Wireless:**
   `network-manager`, `network-manager-gnome`, `plasma-nm`, `bluez`, `plasma-widgets-addons`, `pulseaudio-module-bluetooth`, `rfkill`, `curl`, `wget`, `ca-certificates`.
5. **Display Server & Drivers:**
   `xorg`, `xserver-xorg-video-all`, `xserver-xorg-input-all`, `xserver-xorg-input-synaptics`, `xserver-xorg-input-libinput`, `sddm`, `sddm-theme-breeze`.
6. **KDE Plasma Core:**
   `plasma-desktop`, `plasma-workspace`, `plasma-workspace-wayland`, `kwin-x11`, `kwin-wayland`, `kwin-addons`, `plasma-pa`, `kscreen`, `powerdevil`, `polkit-kde-agent-1`, `breeze`, `breeze-cursor-theme`, `breeze-icon-theme`.
7. **Typography:**
   `fonts-inter`, `fonts-noto-core`, `fonts-noto-color-emoji`.
8. **Applications & Utilities:**
   `firefox-esr`, `dolphin`, `konsole`, `kate`, `kcalc`, `gwenview`, `vlc`, `plasma-systemmonitor`.
9. **Storage & Filesystems:**
   `p7zip-full`, `unzip`, `tar`, `ntfs-3g`, `dosfstools`, `exfat-fuse`.

---

## 3. Desktop Environment, Theming, and Session Configuration

### 3.1 KDE Plasma Version & Stack
- **Upstream Version:** Debian 12 Bookworm packages **KDE Plasma 5.27.5 LTS** (Frameworks 5.103, Qt 5.15.8).
- **Session Support:** Both X11 and Wayland sessions are installed via `kwin-x11`, `kwin-wayland`, `plasma-workspace`, and `plasma-workspace-wayland`.
- **Default Display Server:** SDDM starts X11 by default in Debian 12 unless Wayland is explicitly designated in SDDM configurations.

### 3.2 Window Chrome & Decorator: `kwinrc`
Configured via [`live-build/config/includes.chroot/etc/skel/.config/kwinrc`](file:///live-build/config/includes.chroot/etc/skel/.config/kwinrc):
```ini
[org.kde.kdecoration2]
BorderSize=None
ButtonsOnLeft=XIA
ButtonsOnRight=
CloseOnDoubleClickOnMenu=false
ShowToolTips=true
ThemeName=Breeze
```
- `ButtonsOnLeft=XIA`: Sets window controls strictly on the **Left side** (macOS layout):
  - `X` = Close
  - `I` = Minimize
  - `A` = Maximize
- `ButtonsOnRight=`: Removes all window controls from the right side.
- `ThemeName=Breeze`: Uses the standard Breeze decoration engine colored by the active palette.

### 3.3 Color Scheme: `VeyraDark.colors`
Configured in [`live-build/config/includes.chroot/etc/skel/.local/share/color-schemes/VeyraDark.colors`](file:///live-build/config/includes.chroot/etc/skel/.local/share/color-schemes/VeyraDark.colors):
- **Base Canvas (`BackgroundNormal`):** `23,35,55` (`#172337` Midnight Navy).
- **Alternate / Card Surfaces (`BackgroundAlternate`):** `30,45,66` (`#1E2D42`).
- **Primary Text (`ForegroundNormal`):** `245,244,239` (`#F5F4EF` Warm Ivory).
- **Secondary / Subtitles (`ForegroundInactive`):** `201,209,216` (`#C9D1D8` Cool Mist).
- **Interactive Accents (`ForegroundActive`, `ForegroundLink`, `ForegroundPositive`):** `105,183,160` (`#69B7A0` Muted Teal).
- **Selection Highlight (`Colors:Selection BackgroundNormal`):** `105,183,160` with Midnight Navy text.

### 3.4 Fonts and Widget Styling: `kdeglobals`
Configured in [`live-build/config/includes.chroot/etc/skel/.config/kdeglobals`](file:///live-build/config/includes.chroot/etc/skel/.config/kdeglobals):
- **System Font:** `Inter,10,-1,5,50,0,0,0,0,0` (Inter Regular 10pt).
- **Active Window Title Font:** `Inter,10,-1,5,63,0,0,0,0,0` (Inter Semi-Bold 10pt).
- **Fixed Font:** `Hack,10,-1,5,50,0,0,0,0,0`.
- **Icon Theme:** `breeze-dark` (standard Breeze dark icons).
- **Widget Style:** `Breeze`.

### 3.5 Display Manager & Login: `10-veyra.conf`
Configured in [`live-build/config/includes.chroot/etc/sddm.conf.d/10-veyra.conf`](file:///live-build/config/includes.chroot/etc/sddm.conf.d/10-veyra.conf):
```ini
[Theme]
Current=breeze
CursorTheme=breeze_cursors

[Users]
DefaultUser=veyra
RememberLastUser=true

[General]
InputMethod=
```
- **Login Theme:** Default Breeze SDDM theme.
- **Missing Auto-Login Parameter:** While `DefaultUser=veyra` is defined under `[Users]`, SDDM auto-login requires `User=veyra` and `Session=plasma` (or `plasmawayland`) under an `[Autologin]` section in SDDM. Currently, SDDM prompts at the login greeter rather than booting directly into the desktop session automatically unless bypassed by `live-config`.

---

## 4. Trackpad Configuration & Tap-to-Click Analysis

### 4.1 Installed Touchpad Drivers
In [`veyra.list.chroot`](file:///live-build/config/package-lists/veyra.list.chroot#L42-L43):
- `xserver-xorg-input-synaptics`
- `xserver-xorg-input-libinput`

### 4.2 Why Tap-to-Click Is Currently Disabled
In Debian and upstream KDE Plasma:
1. **Upstream Default Policy:** Both `libinput` and `synaptics` ship with **Tap-to-Click disabled by default** for physical touchpads to prevent accidental clicks while typing.
2. **Missing Driver Configuration in `/etc/X11/xorg.conf.d/`:**
   There is no xorg configuration file (such as `40-libinput.conf` or `70-synaptics.conf`) in `includes.chroot/etc/X11/xorg.conf.d/` enabling `Option "Tapping" "on"`.
3. **Missing Plasma User Preferences:**
   KDE Plasma stores touchpad tapping preferences in `~/.config/kcminputrc` under:
   ```ini
   [Libinput][<Touchpad_Device_ID>]
   TapToClick=true
   ```
   or globally:
   ```ini
   [Touchpad]
   TapToClick=true
   ```
   Because `kcminputrc` is not included in `/etc/skel/.config/`, KDE initializes the trackpad in its default mode where only physical mechanical clicks register.
4. **Driver Conflict Potential:**
   Installing both `xserver-xorg-input-synaptics` and `xserver-xorg-input-libinput` simultaneously can cause X11 to prefer the legacy Synaptics driver over `libinput`. The HP Folio 13 Clickpad behaves significantly better under modern `libinput` than `synaptics`.

---

## 5. Power Management, Shutdown, Sleep & Session Controls

### 5.1 Installed Components
In [`veyra.list.chroot`](file:///live-build/config/package-lists/veyra.list.chroot#L56):
- `powerdevil`: KDE Plasma's official power management daemon (monitors battery levels, manages AC/battery profiles, handles display dimming, sleep timeouts, and lid-close actions).
- `systemd-sysv`: Systemd init system providing native `systemctl poweroff`, `systemctl reboot`, `systemctl suspend`, and `logind`.
- `polkit-kde-agent-1`: PolicyKit authentication agent allowing unprivileged desktop users to trigger shutdown and reboot actions without manual root passwords.

### 5.2 User Privilege Allocation
In [`live-build/auto/config`](file:///live-build/auto/config#L26):
- `user-default-groups=...sudo,video,audio,plugdev,netdev...`
- The `veyra` live user is provisioned with `sudo` permissions via `live-config`, enabling unhindered session termination, restart, shutdown, and sleep via the KDE Application Launcher, lock screen, and terminal.

### 5.3 Power Management Evaluation
- **Lid Close on HP Folio 13:** Governed by `systemd-logind` and `powerdevil`. By default, closing the lid triggers suspend to RAM (S3).
- **Battery Status:** Rendered in the system tray via `powerdevil` and Plasma workspace battery widget.
- **Screen Brightness:** Backlight brightness controls work out of the box through `powerdevil` via the Linux `/sys/class/backlight/intel_backlight` sysfs interface.

---

## 6. Installer Status & Boot Mechanics

### 6.1 Does an Installer Exist?
**No.** There is deliberately **no system installer present**.
- In [`live-build/auto/config`](file:///live-build/auto/config#L16), the installer is explicitly turned off: `--debian-installer false`.
- Calamares, Debian Installer (`d-i`), and Ubiquity are absent from the package list.
- **Safety Impact:** This guarantees non-destructive evaluation. The live environment runs strictly in memory (`overlayfs`) and cannot accidentally format, partition, or overwrite the host system's Windows installation.

### 6.2 How the ISO Boots
1. **Media Structure (`iso-hybrid`):**
   The ISO is mastered using `xorriso` and processed with `isohybrid`. It contains:
   - An MBR partition table containing an El Torito boot record for legacy BIOS.
   - An EFI System Partition (ESP) formatted as FAT containing `bootx64.efi` and `grub.cfg` for 64-bit UEFI systems.
2. **Boot Stage 1 (Firmware):**
   - **UEFI:** Firmware loads `/EFI/BOOT/bootx64.efi` (GRUB2).
   - **Legacy BIOS:** BIOS loads `isolinux.bin` via MBR.
3. **Boot Stage 2 (Kernel & Initramfs):**
   The bootloader presents the live boot choice and loads:
   - Kernel: `/live/vmlinuz`
   - Initial RAM Disk: `/live/initrd.img`
   - Command line arguments from `--bootappend-live`:
     `boot=live components quiet splash timezone=UTC locales=en_US.UTF-8 username=veyra user-default-groups=audio,cdrom,dip,floppy,video,plugdev,netdev,sudo,bluetooth`
4. **Boot Stage 3 (Live-Boot & OverlayFS):**
   The initramfs scripts scan storage buses for the `VEYRA_OS_LIVE` filesystem signature, locate `/live/filesystem.squashfs`, mount it read-only on loopback, and stack a writable `tmpfs` RAM overlay on top.
5. **Boot Stage 4 (Systemd & Session):**
   `live-config` scripts run at early boot to create user `veyra`, set group memberships, disable password requirements for sudo, and hand over control to SDDM.

---

## 7. Package Repositories & Update Mechanism

### 7.1 Upstream Package Repositories
The ISO draws packages strictly from official Debian 12 Bookworm repositories configured in [`live-build/auto/config`](file:///live-build/auto/config#L10-L14):
- **Mirror Bootstrap / Chroot:** `http://deb.debian.org/debian`
- **Distribution:** `bookworm`
- **Sections Enabled:** `main contrib non-free non-free-firmware`
- **Security Updates Mirror:** Disabled during bootstrap (`--security false`) to prevent mirror release file synchronization mismatches during isolated container builds.

### 7.2 Custom Veyra Repositories
- **Status:** **None configured.**
- There is currently no dedicated Veyra APT repository (e.g., `apt.veyra-os.org` or GitHub Pages APT repository) added to `/etc/apt/sources.list.d/`.
- No custom Veyra `.deb` packages or automated OTA update mechanisms exist. All installed software originates from standard Debian Bookworm repositories.
- Custom Veyra desktop assets (themes, configs, and wallpaper references) are currently bundled statically through the `includes.chroot` tree at ISO build time.

---

## 8. Hardware Support Evaluation (HP Folio 13)

| Subsystem | Driver / Package in Repo | Support Assessment | Deficiencies / Notes |
|---|---|---|---|
| **CPU / Microcode** | `intel-microcode`, `linux-image-amd64` | **Full** | Intel 2nd-gen Core i5 microcode patches loaded by early initramfs |
| **Graphics** | `xserver-xorg-video-all`, `xserver-xorg` | **Full** | Intel HD Graphics 3000 accelerated via kernel `i915` driver and Mesa |
| **Wi-Fi** | `firmware-iwlwifi`, `network-manager`, `plasma-nm` | **Full** | Intel Centrino Wireless-N 1030 supported via `firmware-iwlwifi` |
| **Ethernet** | `firmware-realtek`, `network-manager` | **Full** | Realtek Gigabit NIC supported by `r8169` + `firmware-realtek` |
| **Audio** | `plasma-pa`, `pulseaudio-module-bluetooth` | **Partial** | PulseAudio integration present; PipeWire not yet configured |
| **Bluetooth** | `bluez`, `rfkill`, `pulseaudio-module-bluetooth` | **Full** | Intel Centrino Bluetooth 3.0 + HS handled by BlueZ stack |
| **Touchpad** | `xserver-xorg-input-synaptics`, `xserver-xorg-input-libinput` | **Partial** | Hardware supported, but **Tap-to-click is disabled** due to missing config |
| **Backlight** | `powerdevil`, `kscreen` | **Full** | Intel backlight sysfs interface supported natively |
| **Battery** | `powerdevil`, `upower` | **Full** | ACPI battery reporting and battery saver profiles active |
| **Suspend / Sleep** | `systemd-sysv`, `powerdevil` | **Full** | Standard S3 sleep supported; swap partition absent in live mode |

---

## 9. GitHub Actions & Automated Build / Release Pipelines

### 9.1 Workflow Architecture: `.github/workflows/build-iso.yml`
The CI/CD pipeline runs on GitHub Actions using `ubuntu-latest`:

1. **Triggers:**
   - Manual execution via `workflow_dispatch`.
   - Push to `main` modifying `live-build/**`, `branding/**`, or `.github/workflows/build-iso.yml`.
2. **Containerized Build Step:**
   Spawns a clean `debian:bookworm` container with `--privileged` permissions:
   ```yaml
   docker run --privileged --rm \
     -v "${{ github.workspace }}:/workspace" \
     -w /workspace/live-build \
     debian:bookworm bash -c "
       set -ex
       apt-get update
       DEBIAN_FRONTEND=noninteractive apt-get install -y \
         live-build debootstrap syslinux syslinux-utils syslinux-common \
         isolinux xorriso squashfs-tools mtools
       chmod +x auto/*
       lb clean --purge
       lb config
       lb build
     "
   ```
3. **Workspace Inspection & Verification:**
   - Restores workspace file ownership (`sudo chown -R $USER:$USER`).
   - Executes diagnostics (`pwd`, `ls -la`).
   - Searches recursively for generated `.iso` files (`FOUND_ISO`).
   - Validates that the ISO file exists and is greater than 200 MB.
   - Standardizes the image name to `live-build/veyra-os-live-amd64.hybrid.iso`.
   - Generates SHA-256 checksum file (`veyra-os-live-amd64.hybrid.iso.sha256`).
4. **Artifact Retention:**
   Uploads the ISO and checksum to GitHub Actions artifacts (`actions/upload-artifact@v4`) retained for 14 days.
5. **Release Distribution:**
   Uses GitHub CLI (`gh release upload --clobber`) to publish the ISO directly to the `v0.1.0-alpha` release page on GitHub.

### 9.2 Verification of Successful Build Run
- **Build Run ID:** `39176872704`
- **Result:** **Success (17m 32s execution time)**
- **Release Verification:** Both `veyra-os-live-amd64.hybrid.iso` and `veyra-os-live-amd64.hybrid.iso.sha256` are published and downloadable from release `v0.1.0-alpha`.

---

## 10. Gap Analysis & Missing Components

While the foundational live operating system is functional and reproducible, the following components remain unconfigured relative to the full vision outlined in [`DESIGN.md`](file:///DESIGN.md):

| Feature Area | Current State | Missing Component | Architectural Remedy |
|---|---|---|---|
| **Touchpad Tapping** | Mechanical click only | No `/etc/skel/.config/kcminputrc` or `xorg.conf.d` | Add `kcminputrc` with `[Touchpad] TapToClick=true` and `/etc/X11/xorg.conf.d/40-touchpad.conf` |
| **Auto-Login** | Greeter prompt | SDDM `10-veyra.conf` lacks `[Autologin]` stanza | Add `[Autologin] User=veyra Session=plasma` to `10-veyra.conf` |
| **Desktop Wallpaper** | Default KDE Breeze background | Veyra landscape wallpapers not placed in `/usr/share/wallpapers` | Convert reference landscapes into JPG/PNG assets and set in `plasma-org.kde.plasma.desktop-appletsrc` |
| **Floating Dock** | Default KDE panel | Latte Dock or KDE floating panel not configured | Deploy pre-configured `plasma-org.kde.plasma.desktop-appletsrc` with centered floating bottom panel |
| **Left Sidebar Rail** | Not present | Persistent left navigation strip not defined | Add secondary slim left vertical panel with shortcuts to Home, PC, Documents, Settings |
| **Snap Layouts** | Standard KDE tiling | Custom 2/3/4-zone snap layout visual overlay | Configure KWin script or KDE 5.27 built-in tiling zones (`Super+T`) in `kwinrc` |
| **Audio Server** | PulseAudio | Modern PipeWire + WirePlumber stack | Replace `pulseaudio` packages with `pipewire`, `wireplumber`, and `pipewire-audio-client-libraries` |
| **App Ecosystem** | Generic KDE utilities (Kate, Dolphin) | Dedicated Veyra Notes, Veyra Settings, Veyra Link | Develop native QML/C++ or Qt applications progressively |
| **System Installer** | Disabled (by design for milestone 1) | Calamares installer for permanent installation | Package Calamares with custom Veyra branding modules when ready for milestone 2 |

---

## Conclusion

The Veyra OS repository establishes a clean, reproducible operating system foundation based on Debian 12 (Bookworm) and KDE Plasma 5.27 LTS. The build automation generates a non-destructive hybrid live ISO tailored for x86_64 hardware like the HP Folio 13. The foundational color palette, typography, window controls, and cloud build pipeline are verified and operational. Addressing the trackpad tap-to-click configuration, SDDM auto-login, and Plasma shell layout files will bring the live desktop into full visual alignment with the Veyra design identity.
