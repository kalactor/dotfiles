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
sudo chown -R "$USER:$USER" /usr/share/sddm/themes/rice
sudo chmod -R u+rwX,go+rX /usr/share/sddm/themes/rice
```

The theme directory is deliberately owned by your user so `wall`/`theme-apply`
can keep its wallpaper and `Colors.qml` in sync without sudo. On a single-user
home PC that is a reasonable trade-off; if you prefer root ownership, use
`root:root` and re-run the manual update steps below instead.

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

After the install above, `wall`/`theme-apply` updates SDDM automatically:
it copies the new wallpaper to `background.jpg` and writes the generated
`Colors.qml` palette into the theme directory. The greeter reads both on its
next start, so the login screen matches the desktop with no sudo.

This works because the theme directory is owned by your user. If you switch it
back to `root:root`, either restore the `chown` above or update it by hand:

```bash
sudo cp "$(readlink -f ~/.cache/rice/wallpaper)" /usr/share/sddm/themes/rice/background.jpg
sudo cp ~/.cache/rice/Colors.qml /usr/share/sddm/themes/rice/Colors.qml
```

Current default palette (2026-11-13, gothic wallpaper): `#0F1112`, `#FCF5E7`,
`#BD7E50`, `#BA97B1`, `#A9A295`, `#38393B`, `#E06C75`.

## Why the greeter stays X11

The installed SDDM uses the X11 greeter and the theme is pure QML, so it works
there. Switching to the Wayland greeter would require `weston` (extra package)
and is not needed for this theme.
