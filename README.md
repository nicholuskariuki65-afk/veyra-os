# Veyra OS

> *"A calmer way to compute."*
> **Pillars:** Elegant · Connected · Private · Yours

Veyra OS is an operating system crafted from the ground up for quiet focus, visual harmony, and responsive performance. Starting from a hardened **Debian GNU/Linux** foundation paired with **KDE Plasma**, Veyra delivers a custom-curated computing experience without unneeded telemetry or system bloat.

---

## 🎨 Design Philosophy & Specifications

Detailed design systems, color tokens, window chrome requirements, and layout geometry are documented in [DESIGN.md](file:///c:/Users/nicho/Downloads/VEYRA%20OS/DESIGN.md).

- **Midnight Navy Canvas:** `#172337`
- **Warm Ivory Typography:** `#F5F4EF`
- **Muted Teal Accents:** `#69B7A0`
- **Cool Mist Subtitles & Icons:** `#C9D1D8`
- **Window Controls:** Left-aligned macOS-style traffic lights on frosted dark acrylic.
- **Persistent Left Rail:** Slim, unobtrusive navigation strip for primary directories.
- **Floating Pill Dock:** Centered dock hosting core apps (Browser, Files, Notes, Settings, Terminal, Store, Trash) and the quick launcher.

---

## 💻 Hardware Target: HP Folio 13

Optimized specifically for the HP Folio 13 architecture and equivalent x86_64 machines:
- **RAM Footprint:** Engineered to comfortably operate within 8 GB RAM with low idle consumption (< 800 MB).
- **Safe Live USB Mode:** Built strictly as a non-destructive live image with overlay persistence. It will **never** automatically partition, format, or overwrite existing Windows partitions or data drives.

---

## 🏗️ Repository Architecture

```text
veyra-os/
├── .github/
│   └── workflows/
│       └── build-iso.yml          # GitHub Actions remote CI build pipeline
├── live-build/                    # Debian Live Build (lb) configuration tree
│   ├── auto/
│   │   ├── clean
│   │   ├── config
│   │   └── build
│   └── config/
│       ├── package-lists/         # Debian packages, KDE Plasma base & utilities
│       │   └── veyra.list.chroot
│       └── includes.chroot/       # Root filesystem overlay
│           └── etc/
│               ├── skel/          # Default user configuration skeleton
│               └── sddm.conf.d/   # SDDM display manager theme configuration
├── branding/                      # Logos, icons, typography, and wallpaper assets
│   ├── wallpapers/
│   └── icons/
├── scripts/                       # Local & remote build helpers
│   └── build.sh
├── DESIGN.md                      # UI/UX design specifications & reference analysis
└── README.md
```

---

## 🚀 Building Veyra OS

### Remote Build (Recommended)
Because live OS compilation requires loopback device privileges, debootstrap, and substantial disk workspace, Veyra OS includes a **GitHub Actions remote build workflow** (`.github/workflows/build-iso.yml`).
1. Push changes to `main` or trigger manually via `workflow_dispatch`.
2. The GitHub runner provisions a clean Debian environment, builds the hybrid ISO via `live-build`, and publishes the release artifact safely without consuming your laptop's drive space.

### Local Build (Debian/Ubuntu/WSL2 Environment)
```bash
sudo apt-get update
sudo apt-get install -y live-build debootstrap

cd live-build
sudo lb clean --purge
sudo lb config
sudo lb build
```

---

## 🔒 Safety Guarantee
Veyra OS live media boots into memory with `toram` or standard overlayfs. No installer runs automatically; disk operations remain strictly manual and explicit.
