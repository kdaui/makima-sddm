# Makima-SilentSDDM

A Makima (Chainsaw Man) themed configuration for [SilentSDDM](https://github.com/uiriansan/SilentSDDM) - a highly customizable SDDM login manager theme.

![Preview](makima.png)

## Features

- **Makima-inspired color scheme** with dark rose accents
- **Custom background** featuring Makima from Chainsaw Man
- **Right-aligned login form** with clock in center-right
- **Partial blur** on lock screen for depth
- **Minimalist design** with hidden avatar and virtual keyboard disabled

## Color Palette (Option C)

| Element | Color |
|---------|-------|
| Accent | `#8B3A3A` (dark rose) |
| Highlight | `#C4626D` (coral pink) |
| Text | `#C4626D` (accent color) |
| Background | `#000000` (pure black) |

## Prerequisites

- [SilentSDDM](https://github.com/uiriansan/SilentSDDM) installed
- SDDM as your display manager
- Qt6 with graphical effects support

### Required Packages (Fedora)

```bash
sudo dnf install qt5-qtgraphicaleffects qt5-qtquickcontrols2 google-noto-cjk-fonts
```

### Required Packages (Arch Linux)

```bash
sudo pacman -S sddm noto-fonts-cjk
yay -S otf-ipafont qt5-graphicaleffects qt5-quickcontrols2
```

## Installation

### Option 1: Manual Installation

1. **Download the theme files:**
   ```bash
   git clone https://github.com/YOUR_USERNAME/makima-sddm.git
   cd makima-sddm
   ```

2. **Copy the configuration file to SilentSDDM:**
   ```bash
   sudo cp makima.conf /usr/share/sddm/themes/silent/configs/
   ```

3. **Copy the background image to SilentSDDM:**
   ```bash
   sudo cp makima.png /usr/share/sddm/themes/silent/backgrounds/
   ```

4. **Update SilentSDDM to use this configuration:**
   
   Edit `/usr/share/sddm/themes/silent/metadata.desktop` and change:
   ```
   ConfigFile=configs/default.conf
   ```
   to:
   ```
   ConfigFile=configs/makima.conf
   ```

5. **Restart SDDM:**
   ```bash
   systemctl restart sddm
   ```

### Option 2: Test Before Installing

```bash
cd /usr/share/sddm/themes/silent
./test.sh
```

This opens a preview window. Press `Ctrl+C` to exit.

## Customization

You can edit `makima.conf` to customize:

- **Background**: Change `background = "makima.png"` to any image in `backgrounds/`
- **Login position**: Change `position = "right"` to `"left"`, `"center"`, or `"right"`
- **Clock position**: Change `position = "center-right"` (options: `top-left`, `top-center`, `top-right`, `center-left`, `center`, `center-right`, `bottom-left`, `bottom-center`, `bottom-right`)
- **Blur intensity**: Change `blur = 32` (0 = no blur, higher = more blur)
- **Colors**: All colors are defined as hex values (e.g., `#C4626D`)

For full customization options, see the [SilentSDDM Wiki](https://github.com/uiriansan/SilentSDDM/wiki).

## System Color Scheme

To apply the Makima colors to your entire desktop (KDE, GTK, Qt), see the companion repositories:

- **KDE Plasma**: Copy `makima.colors` to `~/.local/share/color-schemes/`
- **GTK 3/4**: Copy `colors.css` to `~/.config/gtk-3.0/` and `~/.config/gtk-4.0/`
- **Qt5/6**: Copy `Makima.conf` to `~/.config/qt5ct/colors/` and `~/.config/qt6ct/colors/`

Then restart your session or log out and back in.

## Credits

- **SilentSDDM**: [uiriansan/SilentSDDM](https://github.com/uiriansan/SilentSDDM) - The customizable SDDM theme framework this configuration is built upon
- **Makima-SDDM**: [Arnau029/Makima-SDDM](https://github.com/Arnau029/Makima-SDDM) - The original Makima-themed SDDM theme that inspired this configuration (used for background image and aesthetic)
- **Makima**: Character design by Tatsuki Fujimoto for Chainsaw Man

## License

This configuration is released under the same license as SilentSDDM (GPL-3.0-or-later).

The background image is property of its respective owners and is used here for personal customization purposes.

## Troubleshooting

### Virtual keyboard keeps appearing
Make sure `display = false` is set in `[LoginScreen.MenuArea.Keyboard]` section.

### SDDM doesn't start
Check SDDM status:
```bash
systemctl status sddm
journalctl -u sddm -e
```

### Colors not applying
Make sure you're using the correct config file in `metadata.desktop`:
```
ConfigFile=configs/makima.conf
```

## Contributing

Feel free to fork and customize this theme for your own setup. If you make improvements, submit a pull request!
