# AGENTS.md: Veyra OS

Read this file first, every session. Do not re-audit the repo; `Veyra-Audit.md` (branch `audit/report`) already exists.

## What this project is
Veyra OS is a Debian 12 (Bookworm) amd64 live ISO with KDE Plasma 5.27, built with `live-build` inside GitHub Actions (`.github/workflows/build-iso.yml`). Tagline: "A calmer way to compute." Goal: an installable, updatable, lightweight OS with its own calm visual identity. Target hardware: older laptops (HP Folio 13, 8 GB RAM class).

## Hard rules
1. `main` is the known-working baseline. Never commit to `main`. Work only on the branch named in the task.
2. Never build the ISO locally. Push the branch and let GitHub Actions build it, then stop.
3. One risk category per branch (touchpad, audio, visuals, installer, updates). Do not mix them.
4. Only touch the files listed in the task. No refactors, renames, or "while I'm here" fixes.
5. Do not merge, delete branches, or modify the release `v0.1.0-alpha`.
6. Do not add packages unless the task lists them. Check package names exist in Bookworm before adding.
7. If something unexpected happens, STOP and report. Do not retry in a loop.
8. Final reply: 5 lines or fewer (branch, files changed, commit hash, anything unexpected).

## Technical constraints
- Session is X11 by default. Do not assume Wayland.
- Config skeleton lives in `live-build/config/includes.chroot/` (`etc/skel/...`, `etc/X11/xorg.conf.d/...`, `usr/share/...`).
- Package list: `live-build/config/package-lists/veyra.list.chroot`.
- Prefer config files and Plasma/QML over new compiled code. No Electron for system components.
- Plasma layout files (`plasma-org.kde.plasma.desktop-appletsrc`, panels) must be exported from a real working session, never hand-written.
- Keep idle RAM low; measure, don't assume (target under ~800 MB is a benchmark, not a guarantee).

## Brand and design
- Palette: Midnight Navy `#172337`, Warm Ivory `#F5F4EF`, Muted Teal `#69B7A0`.
- Fonts: Inter. Icons: Breeze-dark for now.
- Mood: calm, quiet, mountain-and-mist wallpapers; dark UI with soft teal accents.
- Window buttons: macOS-style traffic lights on the LEFT (`ButtonsOnLeft=XIA` in `kwinrc`).
- Target layout (later phases): slim left rail (This PC, Home, Documents, Photos, Settings), floating centered bottom dock, minimal top-right status (Wi-Fi, battery, clock), clean login screen with clock and Shut down visible.
- Wallpapers are auto-adaptive (day / dusk / night) in a later phase.

## Roadmap (do phases in order, one per branch)
- **1A** Touchpad tap-to-click only: `etc/X11/xorg.conf.d/90-veyra-touchpad.conf`.
- **1B** Hardware validation (Wi-Fi, audio, brightness, suspend, shutdown, restart). Testing only, minimal changes.
- **2** Visual identity: wallpaper, colour scheme, window decorations, then panel layout (exported from a real session).
- **3** Installer (Calamares, tested in a VM first) and updates (Debian apt + signed Veyra `.deb` repo).
- **4** Custom Veyra apps and adaptive wallpaper engine (needs research first).

## Testing
Every branch must produce a bootable ISO via Actions. Failures are reported with the last 50 lines of the workflow log.
