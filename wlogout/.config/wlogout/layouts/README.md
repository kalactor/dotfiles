# Power-menu layouts

Each directory is a complete wlogout layout:

- `layout` — wlogout JSON actions, in wlogout's column-major order
- `style.css` — GTK3 stylesheet, importing the generated `colors.css`
- `layout.conf` — picker metadata and grid geometry (`buttons`, `inset_x`,
  `inset_y`, `col_gap`, `row_gap`, `order`)

`rice-logout` reads the geometry, sizes the block from the focused monitor,
stages the stylesheet and icons in `~/.cache/rice/wlogout`, and remembers the
last choice in `~/.cache/rice/wlogout-layout`.

## Presets

| Directory | Idea | Upstream |
|---|---|---|
| `attached` | 2×2 attached tiles, outer-corner rounding | [HyDE](https://github.com/prasanthrangan/hyprdots) (GPL-3.0) |
| `grid` | 3×2 tiles with soft gaps | [HyDE](https://github.com/prasanthrangan/hyprdots) (GPL-3.0) |
| `pills` | 3×2 translucent pills, wide rounding | [JaKooLit](https://github.com/JaKooLit/Hyprland-Dots) (GPL-3.0) |
| `cards` | single row of floating cards | [HyprNova](https://github.com/zDyant/HyprNova) (MIT) |
| `capsule` | 3×2 grid with capsule ends | [BlackNode](https://github.com/zhaleff/BlackNode) (MIT) |
| `glass` | 3×2 frosted tiles over a dimmed backdrop | [ML4W](https://github.com/mylinuxforwork/dotfiles) (GPL-3.0) |
| `modern` | 3×2 accent-edged cards | [ML4W](https://github.com/mylinuxforwork/dotfiles) (GPL-3.0) |
| `minimal` | icon-only row with a soft halo | [Vieg](https://github.com/ViegPhunt/Dotfiles) (MIT) |
| `mosaic` | 2×2 quadrants with colour-edged rules | [LierB](https://github.com/LierB/dotfiles) (no licence file) |
| `compact` | small 2×2 block with tight gaps | [Hyprstellar](https://github.com/xeji01/hyprstellar) (no licence file) |

The stylesheets are original implementations written for this rice. They use
the palette roles from `colors.css` instead of copying upstream colour values,
so every preset follows the active static theme or wallpaper palette. The
upstream projects are credited as visual references; consult each repository
for its full licence text.

Catppuccin's wlogout theme was reviewed but is a colour skin of the stock 2×3
grid rather than a distinct layout, so it is not shipped as a separate preset.
