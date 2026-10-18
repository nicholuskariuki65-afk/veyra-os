# Veyra OS — Design Specification & System Blueprint
*Derived from visual reference designs and user architectural specifications.*

---

## 1. Vision & Core Identity

> **"A calmer way to compute."**
> **Pillars:** Elegant · Connected · Private · Yours

Veyra OS is a quiet, distraction-free desktop operating system crafted for clarity, intentionality, and seamless workflow. Starting from a hardened Debian Linux + KDE Plasma foundation, Veyra progresses into a dedicated desktop shell with cohesive native applications.

---

## 2. Brand Identity & Visual Language

### 2.1 Logo & Logotype
- **Symbol:** A sculpted, continuous ribbon forming a stylized "V". The folded, 3D ribbon cascades smoothly downward.
- **Gradient:** Flows from **Warm Ivory (`#F5F4EF`)** across the upper sweeps into **Muted Teal (`#69B7A0`)** at the base.
- **Wordmark:** `VEYRA` in wide-tracked geometric sans-serif (Inter Display / Inter uppercase).
- **Subtitle:** `— OS —` flanked by subtle horizontal rules in Cool Mist (`#C9D1D8`).
- **Tagline:** *"A calmer way to compute."* in sentence case, light weight.

### 2.2 Color Palette
| Token | Role | Hex Value | Usage |
|---|---|---|---|
| `veyra-bg-dark` | Primary Canvas | `#172337` | Desktop background, base terminal, deep window frames |
| `veyra-surface` | Elevated Panels | `rgba(23, 35, 55, 0.82)` | Dock, Control Center, sidebars, floating search |
| `veyra-surface-card` | Cards / Lists | `rgba(30, 45, 66, 0.70)` | Setting cards, notification tiles, quick toggles |
| `veyra-accent` | Interactive Highlight | `#69B7A0` | Active toggles, sliders, focus rings, badges, PIN submit |
| `veyra-text-primary` | High Contrast Text | `#F5F4EF` | Headings, active labels, clock, primary icons |
| `veyra-text-secondary`| Muted / Metadata | `#C9D1D8` | Breadcrumbs, subtitles, timestamps, inactive icons |
| `veyra-border` | Delicate Outlines | `rgba(255, 255, 255, 0.08)` | Window borders, floating panel boundaries (1px) |

---

## 3. Desktop Shell & Spatial Architecture

### 3.1 Window Chrome & Decorations
- **Window Controls (Traffic Lights):** Positioned strictly on the **Left side** (macOS-style layout) to establish a distinct, uncluttered identity.
- **Geometry:** Corner radius of **14px** with 1px delicate outline (`rgba(255, 255, 255, 0.08)`).
- **Surface:** Frosted glass effect via KWin background blur + deep semi-transparent navy titlebars.
- **Title Alignment:** Centered title text with subtle subtitle metadata where relevant.

### 3.2 Left Sidebar Rail
- **Format:** Slim, unobtrusive vertical dock/rail docked to the left edge of the desktop.
- **Behavior:** Always visible on the desktop canvas, providing persistent fast navigation without crowding window space.
- **Default Shortcuts:**
  1. *This PC / Devices*
  2. *Home / User*
  3. *Documents*
  4. *Photos*
  5. *Settings*
- **Visual Style:** Minimalist monochrome outline glyphs (`#C9D1D8` at 70% resting opacity, 100% on hover).

### 3.3 Floating Bottom Dock
- **Format:** Floating pill detached from the bottom edge (~16px margin).
- **Background:** `rgba(23, 35, 55, 0.85)` with 24px blur and rounded pill caps.
- **Default Pinned Apps:**
  1. **Browser** (Firefox candidate)
  2. **Files** (Veyra Files / Dolphin tailored)
  3. **Notes** (Veyra Notes)
  4. **Settings** (Veyra System Configuration)
  5. **Terminal** (Konsole configured to Veyra palette)
  6. **Store** (Software center)
  7. **Trash**
  8. **App Launcher** (Grid trigger at the far right)
- **Indicators:** Subtle teal pip below running applications.

### 3.4 Snap Layouts
- Accessible via hover on the window maximize button or `Super + Z`.
- **Options Provided:**
  - **2-split** (50/50 and 65/35 golden ratio)
  - **3-zone** (Focus center with twin wings or 3-column split)
  - **4-zone** (Balanced quadrants)
  - Plus fluid manual drag-to-edge snapping.

### 3.5 Auto-Adaptive Landscapes & Night Mode
- Dynamic wallpapers shifting seamlessly through **Day**, **Dusk**, and **Night Mode**.
- Imagery features layered Nordic mist and mountain ridges rendering quiet warmth and serenity.

---

## 4. System Implementation & Distribution Target

### 4.1 Target Platform
- **Device:** HP Folio 13 (Intel Core i5 / HD Graphics, 8 GB RAM, Synaptics Touchpad, UEFI/BIOS).
- **Base OS:** Debian GNU/Linux 12 (Bookworm) 64-bit (`amd64`).
- **Desktop Environment:** KDE Plasma 5.27 LTS / Plasma 6 with custom KWin / Plasma theme overlays.
- **Delivery Format:** Non-destructive bootable Live USB (`hybrid-iso`) with persistence support and safe readonly live boot (no automatic disk formatting or Windows interference).
