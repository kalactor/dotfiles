# Theme hooks

Executables in this directory are run by `theme-apply` after wallust has
regenerated every target. Each hook receives the wallpaper path as `$1`.

Example: restart a GTK app that caches its colors.

```bash
#!/usr/bin/env bash
pkill -SIGUSR1 some-app
```
