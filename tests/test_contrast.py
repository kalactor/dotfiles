from __future__ import annotations

import tempfile
import unittest
from pathlib import Path

from helpers import ROOT, load_script


BASE_LIGHT = {
    "background": "#C7B9B9",
    "foreground": "#6B6E33",
    "cursor": "#867F2A",
    "color0": "#AB9E9E",
    "color1": "#767184",
    "color2": "#A08F20",
    "color3": "#0AA2D3",
    "color4": "#8FB8A2",
    "color5": "#FA9871",
    "color6": "#EEF572",
    "color7": "#6B6E33",
    "color8": "#230001",
    "color9": "#767184",
    "color10": "#A08F20",
    "color11": "#0AA2D3",
    "color12": "#8FB8A2",
    "color13": "#FA9871",
    "color14": "#EEF572",
    "color15": "#242511",
}

ANSI_LIGHT = {
    "color0": "#2e3936",
    "color1": "#b7393e",
    "color2": "#00733b",
    "color3": "#989b00",
    "color4": "#0058bf",
    "color5": "#bf0071",
    "color6": "#00b7bf",
    "color7": "#fff7db",
    "color8": "#505a57",
    "color9": "#f44d53",
    "color10": "#00994f",
    "color11": "#cbcf00",
    "color12": "#0075ff",
    "color13": "#ff0096",
    "color14": "#00f4ff",
    "color15": "#fff7db",
}

BASE_DARK = {
    "background": "#161110",
    "foreground": "#FFF5E0",
    "cursor": "#BC9F79",
    "color0": "#3E3938",
    "color1": "#021658",
    "color2": "#794A12",
    "color3": "#676879",
    "color4": "#F14B7F",
    "color5": "#D57B4A",
    "color6": "#FFE2A5",
    "color7": "#F6E8CA",
    "color8": "#ADA28D",
    "color9": "#021658",
    "color10": "#794A12",
    "color11": "#676879",
    "color12": "#F14B7F",
    "color13": "#D57B4A",
    "color14": "#FFE2A5",
    "color15": "#F6E8CA",
}

ANSI_DARK = {
    "color0": "#331a1a",
    "color1": "#730000",
    "color2": "#00733b",
    "color3": "#989b00",
    "color4": "#0058bf",
    "color5": "#bf0071",
    "color6": "#00b7bf",
    "color7": "#f7f8ff",
    "color8": "#554040",
    "color9": "#990000",
    "color10": "#00994f",
    "color11": "#cbcf00",
    "color12": "#0075ff",
    "color13": "#ff0096",
    "color14": "#00f4ff",
    "color15": "#f7f8ff",
}


class ColorMathTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.rc = load_script("rice-contrast")

    def test_contrast_extremes(self):
        self.assertAlmostEqual(self.rc.contrast("#000000", "#ffffff"), 21.0, places=2)
        self.assertEqual(self.rc.contrast("#123456", "#123456"), 1.0)
        self.assertEqual(
            self.rc.contrast("#000000", "#ffffff"),
            self.rc.contrast("#ffffff", "#000000"),
        )

    def test_oklch_round_trip(self):
        for color in (
            "#000000",
            "#ffffff",
            "#C7B9B9",
            "#004962",
            "#7f8192",
            "#ff0000",
            "#00ff00",
            "#0000ff",
            "#123456",
        ):
            self.assertEqual(self.rc.oklch_to_hex(self.rc.hex_to_oklch(color)), color.lower())

    def test_adjust_reaches_target_and_keeps_hue(self):
        background = "#baadaa"
        original = "#0aa2d3"
        adjusted = self.rc.adjust(original, background, 4.5)
        self.assertGreaterEqual(self.rc.contrast(adjusted, background), 4.49)
        before = self.rc.hex_to_oklch(original)[2]
        after = self.rc.hex_to_oklch(adjusted)[2]
        delta = abs(before - after) % 360
        self.assertLess(min(delta, 360 - delta), 2.0)

    def test_adjust_leaves_compliant_colour_alone(self):
        self.assertEqual(self.rc.adjust("#000000", "#ffffff", 4.5), "#000000")

    def test_mix_and_force_lightness(self):
        self.assertEqual(self.rc.mix("#000000", "#ffffff", 0.0), "#000000")
        self.assertEqual(self.rc.mix("#000000", "#ffffff", 1.0), "#ffffff")
        dark = self.rc.force_lightness("#ffffff", 0.10, 0.06)
        self.assertLess(self.rc.rel_lum(dark), 0.05)

    def test_effective_background_uses_opacity(self):
        self.assertEqual(
            self.rc.effective_background("#000000", "#646464", 0.5),
            "#323232",
        )
        self.assertEqual(
            self.rc.effective_background("#000000", None, 0.5),
            "#000000",
        )


class PaletteTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.rc = load_script("rice-contrast")

    def test_light_palette_passes_policy(self):
        palette = self.rc.compute_palette(BASE_LIGHT, ANSI_LIGHT, "#baadaa")
        self.assertEqual(self.rc.check_palette(palette, "#baadaa"), [])
        self.assertGreaterEqual(self.rc.contrast(palette["foreground"], "#baadaa"), 6.95)
        self.assertGreaterEqual(
            self.rc.contrast(palette["color0"], palette["color7"]), 6.95
        )
        self.assertGreaterEqual(
            self.rc.contrast(palette["surface_fg"], palette["surface"]), 4.49
        )
        self.assertGreaterEqual(
            self.rc.contrast(palette["accent_fg"], palette["accent"]), 4.49
        )

    def test_dark_palette_passes_policy(self):
        palette = self.rc.compute_palette(BASE_DARK, ANSI_DARK, "#211719")
        self.assertEqual(self.rc.check_palette(palette, "#211719"), [])
        self.assertGreaterEqual(self.rc.contrast(palette["foreground"], "#211719"), 6.95)

    def test_semantic_keys_are_derived_from_the_wallpaper_palette(self):
        palette = self.rc.compute_palette(BASE_LIGHT, ANSI_LIGHT, "#baadaa")
        for key in (
            "surface",
            "surface_alt",
            "surface_fg",
            "bar_bg",
            "bar_fg",
            "muted",
            "border",
            "accent",
            "accent_alt",
            "accent_fg",
            "accent_alt_fg",
            "accent_source",
            "accent_alt_source",
            "danger",
            "danger_fg",
            "success",
            "success_fg",
            "warning",
            "warning_fg",
            "info",
            "link",
            "selection_bg",
            "selection_fg",
            "effective_background",
        ):
            self.assertIn(key, palette)
        # UI accents keep the salience hue; ANSI yellow keeps the warning role.
        self.assertNotEqual(palette["accent"], palette["color3"])
        self.assertEqual(palette["warning"], palette["color3"])

    def test_check_reports_a_broken_palette(self):
        palette = self.rc.compute_palette(BASE_LIGHT, ANSI_LIGHT, "#baadaa")
        broken = dict(palette)
        broken["foreground"] = palette["background"]
        failures = self.rc.check_palette(broken, "#baadaa")
        self.assertTrue(any("foreground" in failure for failure in failures))

    def test_bar_tint_follows_the_wallpaper_sample(self):
        palette = self.rc.compute_palette(
            BASE_LIGHT,
            ANSI_LIGHT,
            "#baadaa",
            wallpaper_sample="#44593e",
            mode="light",
        )
        self.assertNotEqual(palette["bar_bg"], palette["background"])
        self.assertNotEqual(palette["bar_bg"], palette["surface"])
        self.assertGreaterEqual(
            self.rc.contrast(palette["bar_fg"], palette["bar_bg"]), 4.49
        )

    def test_reprocessing_preserves_the_wallpaper_accent(self):
        palette = self.rc.compute_palette(BASE_LIGHT, ANSI_LIGHT, "#baadaa")
        again = self.rc.compute_palette(palette, ANSI_LIGHT, "#baadaa")
        self.assertEqual(again["accent"], palette["accent"])
        self.assertEqual(again["accent_alt"], palette["accent_alt"])
        self.assertEqual(again["accent_source"], palette["accent_source"])
        self.assertNotEqual(again["accent"], again["color3"])

    def test_palette_text_round_trips(self):
        palette = self.rc.compute_palette(BASE_LIGHT, ANSI_LIGHT, "#baadaa")
        with tempfile.TemporaryDirectory(prefix="rice-contrast-test-") as directory:
            path = Path(directory) / "colors.env"
            path.write_text(self.rc.palette_text(palette), encoding="utf-8")
            self.assertEqual(self.rc.read_palette(path), palette)

    def test_every_template_renders_with_the_semantic_palette(self):
        palette = self.rc.compute_palette(BASE_LIGHT, ANSI_LIGHT, "#baadaa")
        templates = ROOT / "wallust/.config/wallust/templates"
        for path in sorted(templates.iterdir()):
            if not path.is_file():
                continue
            rendered = self.rc.render_text(path.read_text(), palette, path.name)
            self.assertNotIn("{{", rendered, path.name)
            self.assertNotIn("}}", rendered, path.name)


class RendererTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.rc = load_script("rice-contrast")

    def test_simple_variables_and_hash_stripping(self):
        context = {"background": "#abcdef", "color3": "#123456"}
        self.assertEqual(
            self.rc.render_text(
                "a={{ background }} b={{ color3[1:] }}", context
            ),
            "a=#abcdef b=123456",
        )

    def test_unknown_variable_is_an_error(self):
        with self.assertRaises(KeyError):
            self.rc.render_text("{{ nope }}", {})

    def test_unsupported_expression_is_an_error(self):
        with self.assertRaises(ValueError):
            self.rc.render_text("{{ background|upper }}", {"background": "#abcdef"})
        with self.assertRaises(ValueError):
            self.rc.render_text("{{ color3[2:] }}", {"color3": "#123456"})
        with self.assertRaises(ValueError):
            self.rc.render_text("{{ color3[1:] }}", {"color3": "not-a-colour"})

    def test_parse_ansi_scheme(self):
        with tempfile.TemporaryDirectory(prefix="rice-contrast-test-") as directory:
            path = Path(directory) / "ansi"
            path.write_text("\n".join(ANSI_LIGHT[f"color{i}"] for i in range(16)))
            self.assertEqual(self.rc.parse_ansi_scheme(path), ANSI_LIGHT)
            path.write_text("\n".join(ANSI_LIGHT[f"color{i}"] for i in range(15)))
            with self.assertRaises(ValueError):
                self.rc.parse_ansi_scheme(path)


class TemplateConfigTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.rc = load_script("rice-contrast")

    def test_parses_dotted_and_inline_entries(self):
        with tempfile.TemporaryDirectory(prefix="rice-contrast-test-") as directory:
            root = Path(directory)
            template = root / "template"
            template.write_text("{{ background }}")
            target = root / "target"
            config = root / "wallust.toml"
            config.write_text(
                "[templates]\n"
                "dotted.template = 'template'\n"
                f"dotted.target = '{target}'\n"
                f"inline = {{ src = 'template', dst = '{target}' }}\n",
                encoding="utf-8",
            )
            entries = self.rc.parse_wallust_templates(config)
            self.assertEqual([name for name, _, _ in entries], ["dotted", "inline"])
            self.assertEqual(entries[0][1], template)
            self.assertEqual(entries[0][2], target)

    def test_resolves_templates_under_the_templates_directory(self):
        with tempfile.TemporaryDirectory(prefix="rice-contrast-test-") as directory:
            root = Path(directory)
            templates = root / "templates"
            templates.mkdir()
            (templates / "template").write_text("{{ background }}")
            config = root / "wallust.toml"
            config.write_text(
                "[templates]\n"
                "nested = { template = 'template', target = 'target' }\n",
                encoding="utf-8",
            )
            entries = self.rc.parse_wallust_templates(config)
            self.assertEqual(entries[0][1], templates / "template")

    def test_rejects_pywal_templates(self):
        with tempfile.TemporaryDirectory(prefix="rice-contrast-test-") as directory:
            root = Path(directory)
            (root / "template").write_text("{{ background }}")
            config = root / "wallust.toml"
            config.write_text(
                "[templates]\n"
                "bad = { template = 'template', target = 'target', pywal = true }\n",
                encoding="utf-8",
            )
            with self.assertRaises(ValueError):
                self.rc.parse_wallust_templates(config)


class OpacityTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.rc = load_script("rice-contrast")

    def test_kitty_and_hyprland_opacity(self):
        with tempfile.TemporaryDirectory(prefix="rice-contrast-test-") as directory:
            root = Path(directory)
            kitty = root / "kitty.conf"
            kitty.write_text("background_opacity 0.75\n")
            self.assertEqual(self.rc.kitty_opacity(kitty), 0.75)
            hypr = root / "look.lua"
            hypr.write_text(
                "active_opacity = 0.90\ninactive_opacity = 0.80\n"
            )
            self.assertEqual(self.rc.hypr_opacity(hypr), 0.80)


if __name__ == "__main__":
    unittest.main()
