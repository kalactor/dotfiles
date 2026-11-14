# System config copies

These files are **copies** of system-level configuration, kept here for reference and
disaster recovery. They are **not** managed by Stow and must not be symlinked into `/etc`.

To restore after a reinstall, compare and copy by hand:

```bash
sudo cp system/etc/fstab /etc/fstab
sudo cp system/etc/mkinitcpio.conf /etc/mkinitcpio.conf
sudo cp system/etc/pacman.conf /etc/pacman.conf
sudo cp system/etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist
sudo cp system/etc/locale.conf /etc/locale.conf
sudo cp system/etc/vconsole.conf /etc/vconsole.conf
sudo mkinitcpio -P
```

SDDM configuration is saved in `system/etc/sddm.conf.d/10-theme.conf`; the
theme itself is below `system/sddm/`. See that directory's README for the sudo
install/preview commands.
