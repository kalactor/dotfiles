# SDDM “rice” theme — handoff

The theme lives in `system/sddm/themes/rice/` and is **not** stowed into `$HOME`.
Installing it needs `sudo`, so run the commands below yourself.

The theme was previewed with:

```bash
sddm-greeter-qt6 --test-mode --theme ~/dotfiles/system/sddm/themes/rice
```

and renders correctly (wallpaper background, clock, dark copper-bordered card,
username/password/session, Login/Reboot/Shutdown).

## Install

```bash
sudo mkdir -p /usr/share/sddm/themes /etc/sddm.conf.d
sudo cp -r ~/dotfiles/system/sddm/themes/rice /usr/share/sddm/themes/
sudo cp ~/dotfiles/system/etc/sddm.conf.d/10-theme.conf /etc/sddm.conf.d/
sudo chown -R root:root /usr/share/sddm/themes/rice
sudo chmod -R a+rX /usr/share/sddm/themes/rice
```

Preview the installed copy without logging out:

```bash
sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/rice
```

Apply it (this **ends the graphical session**):

```bash
sudo systemctl restart sddm
```

or simply reboot.

## Rollback

If the greeter does not appear, switch to a TTY (`Ctrl+Alt+F3`), log in, then:

```bash
sudo rm -f /etc/sddm.conf.d/10-theme.conf
sudo systemctl restart sddm
```

The stock `maldives` theme will be used again. The theme directory can stay in
place; removing `/usr/share/sddm/themes/rice` is optional.

## Changing wallpaper / palette later

SDDM is system-level, so it does **not** follow `wall`/`theme-apply`
automatically (that would need root on every wallpaper change).

To update it by hand:

```bash
# 1. new background
sudo cp ~/Pictures/walls/<new-wallpaper>.jpg /usr/share/sddm/themes/rice/background.jpg

# 2. palette: edit the seven color properties at the top of Main.qml
#    (bg, fg, accent, accentAlt, muted, fieldBg, danger), then copy it
sudo cp ~/dotfiles/system/sddm/themes/rice/Main.qml /usr/share/sddm/themes/rice/Main.qml
```

Current theme palette (2026-11-13, teal wallpaper): `#232829`, `#D3E4E5`,
`#117C62`, `#127E86`, `#809292`, `#484E4F`, `#E06C75`.

## Why the greeter stays X11

The installed SDDM uses the X11 greeter and the theme is pure QML, so it works
there. Switching to the Wayland greeter would require `weston` (extra package)
and is not needed for this theme.
