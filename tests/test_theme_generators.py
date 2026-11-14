from __future__ import annotations

import io
import os
import tempfile
import unittest
import zipfile
from pathlib import Path

from helpers import ROOT, load_script


PALETTE = {
    "background": "#E0D4D5",
    "foreground": "#655943",
    "cursor": "#454630",
    "color0": "#C4B8B9",
    "color1": "#2A0106",
    "color2": "#24321D",
    "color3": "#6B4B24",
    "color4": "#8C8520",
    "color5": "#D37523",
    "color6": "#E1C695",
    "color7": "#655943",
    "color8": "#301216",
    "color9": "#2A0106",
    "color10": "#24321D",
    "color11": "#6B4B24",
    "color12": "#8C8520",
    "color13": "#D37523",
    "color14": "#E1C695",
    "color15": "#221E16",
}


class KdeThemeTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.kde = load_script("kde-theme")

    def test_ini_merge_preserves_unknown_settings_and_is_idempotent(self):
        existing = """# user comment
[General]
ColorScheme=UserTheme
TerminalApplication=xterm
CustomSetting=keep

[Unmanaged]
KeepThis=yes

[Icons]
Theme=OldIcons
Theme=DuplicateOwnedKey
OtherIconSetting=keep
"""
        owned = {
            "General": {"ColorScheme": "Wallust", "TerminalApplication": "kitty"},
            "Icons": {"Theme": "Papirus"},
        }
        merged = self.kde.merge_ini_sections(existing, owned)
        self.assertIn("# user comment", merged)
        self.assertIn("CustomSetting=keep", merged)
        self.assertIn("[Unmanaged]\nKeepThis=yes", merged)
        self.assertIn("OtherIconSetting=keep", merged)
        self.assertIn("TerminalApplication=kitty", merged)
        self.assertEqual(merged.count("ColorScheme=Wallust"), 1)
        self.assertEqual(merged.count("Theme=Papirus"), 1)
        self.assertEqual(self.kde.merge_ini_sections(merged, owned), merged)

    def test_combined_kde_headers_collapse_without_losing_user_keys(self):
        existing = (
            "[Colors:Header][Inactive]\n"
            "BackgroundNormal=old\n"
            "UserKey=keep\n"
            "\n"
            "[Colors:Header][Inactive]\n"
            "BackgroundNormal=old-again\n"
            "UserKey2=keep-too\n"
        )
        owned = {"Colors:Header][Inactive": {"BackgroundNormal": "new"}}
        merged = self.kde.merge_ini_sections(existing, owned)
        self.assertEqual(merged.count("[Colors:Header][Inactive]"), 1)
        self.assertIn("BackgroundNormal=new", merged)
        self.assertIn("UserKey=keep", merged)
        self.assertIn("UserKey2=keep-too", merged)
        self.assertEqual(self.kde.merge_ini_sections(merged, owned), merged)

    def test_full_kdeglobals_write_keeps_user_sections(self):
        with tempfile.TemporaryDirectory(prefix="kde-theme-test-") as directory:
            self.kde.HOME = Path(directory)
            target = self.kde.HOME / ".config" / "kdeglobals"
            target.parent.mkdir(parents=True)
            target.write_text("[UserOwned]\nDoNotDelete=true\n", encoding="utf-8")
            self.kde.write_kdeglobals(PALETTE, "dark")
            self.kde.write_kdeglobals(PALETTE, "light")
            text = target.read_text(encoding="utf-8")
            self.assertIn("[UserOwned]\nDoNotDelete=true", text)
            self.assertIn("[Icons]\nTheme=Papirus", text)
            self.assertEqual(text.count("[General]"), 1)
            self.assertEqual(text.count("[Colors:Header][Inactive]"), 1)
            self.assertNotIn("Theme=Papirus-Dark", text)


class TelegramThemeTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.telegram = load_script("telegram-theme")

    def test_light_secondary_text_has_useful_contrast(self):
        colors = self.telegram.semantic_colors(PALETTE, "light")
        background_ratio = self.telegram.contrast_ratio(
            colors["dark_foreground"], colors["background"]
        )
        sidebar_ratio = self.telegram.contrast_ratio(
            colors["dark_foreground"], colors["dark_background"]
        )
        self.assertGreaterEqual(background_ratio, 3.5)
        self.assertGreaterEqual(sidebar_ratio, 3.0)

    def test_palette_and_wallpaper_package(self):
        colors = self.telegram.semantic_colors(PALETTE, "light")
        base = (ROOT / "telegram/.local/share/rice/telegram-base.tdesktop-palette").read_text()
        text = self.telegram.render_palette(base, colors, "light")
        package = self.telegram.build_theme_package(text, colors["background"], b"jpeg-fixture")
        with zipfile.ZipFile(io.BytesIO(package)) as archive:
            self.assertEqual(
                set(archive.namelist()),
                {"colors.tdesktop-theme", "background.png", "background.jpg"},
            )
            self.assertEqual(archive.read("background.jpg"), b"jpeg-fixture")
            self.assertEqual(archive.read("colors.tdesktop-theme").decode(), text)
            self.assertGreaterEqual(len(text.splitlines()), 500)

    def test_local_encryption_round_trip(self):
        key = self.telegram.derive_key(b"rice-test-salt")
        plaintext = b"telegram theme fixture\x00\x01\x02"
        encrypted = self.telegram.encrypt_local(plaintext, key)
        self.assertNotEqual(encrypted, plaintext)
        self.assertEqual(self.telegram.decrypt_local(encrypted, key), plaintext)


class DolphinDefaultsTests(unittest.TestCase):
    def test_seeds_once_and_preserves_user_choice(self):
        dolphin = load_script("dolphin-view-defaults")
        with tempfile.TemporaryDirectory(prefix="dolphin-test-") as directory:
            dolphin.BASE = Path(directory)
            dolphin.DOT_DIR = dolphin.BASE / ".directory"
            self.assertEqual(dolphin.main(), 0)
            value = os.getxattr(dolphin.BASE, dolphin.XATTR).decode()
            self.assertIn("ViewMode=1", value)
            changed = value.replace("ViewMode=1", "ViewMode=0")
            os.setxattr(dolphin.BASE, dolphin.XATTR, changed.encode())
            self.assertEqual(dolphin.main(), 0)
            self.assertEqual(os.getxattr(dolphin.BASE, dolphin.XATTR).decode(), changed)


class RofiToolsTests(unittest.TestCase):
    def test_key_labels(self):
        keybinds = load_script("rice-keybinds")
        self.assertEqual(keybinds.key_label({"modmask": 68, "key": "C"}), "Super+Ctrl+C")
        self.assertEqual(keybinds.key_label({"modmask": 64, "key": "mouse:272"}), "Super+LMB")

    def test_calculator(self):
        calculator = load_script("rice-calculator")
        self.assertEqual(calculator.evaluate("sqrt(81) + 5"), "14")
        self.assertEqual(calculator.evaluate("0.18 * 2400"), "432")

    def test_emoji_catalog_is_well_formed(self):
        emoji = load_script("rice-emoji")
        emoji.CATALOG = ROOT / "rofi/.config/rofi/emoji.tsv"
        rows = emoji.entries()
        self.assertGreaterEqual(len(rows), 150)
        self.assertEqual(len(rows), len({row[1] for row in rows}))
        self.assertIn("grinning face", emoji.render_entries(rows))


if __name__ == "__main__":
    unittest.main()
