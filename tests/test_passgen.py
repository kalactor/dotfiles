from __future__ import annotations

import contextlib
import io
import json
import tempfile
import unittest
from pathlib import Path

from helpers import load_script


class PasswordTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.pg = load_script("passgen-waybar")

    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix="passgen-test-")
        root = Path(self.temporary.name)
        self.saved = {
            name: getattr(self.pg, name)
            for name in ("STATE_HOME", "STATE_FILE", "notify", "clip", "clipboard_tool")
        }
        self.pg.STATE_HOME = root
        self.pg.STATE_FILE = root / "options.json"
        self.pg.notify = lambda *args, **kwargs: None
        self.pg.clip = lambda text: True
        self.pg.clipboard_tool = lambda: "wl-copy"

    def tearDown(self):
        for name, value in self.saved.items():
            setattr(self.pg, name, value)
        self.temporary.cleanup()

    def test_default_options_are_all_sets_at_twelve(self):
        options = self.pg.default_options()
        self.assertEqual(options["length"], 12)
        for name in self.pg.CLASSES:
            self.assertTrue(options[name])

    def test_password_length_and_every_enabled_set(self):
        options = self.pg.default_options()
        for _ in range(50):
            password = self.pg.generate_password(options)
            self.assertEqual(len(password), 12)
            for name in self.pg.CLASSES:
                self.assertTrue(
                    any(character in self.pg.SETS[name] for character in password),
                    f"{name} missing from {password!r}",
                )

    def test_disabled_sets_are_absent(self):
        options = self.pg.default_options()
        options.update({"lower": False, "upper": False, "symbols": False})
        password = self.pg.generate_password(options)
        self.assertEqual(len(password), 12)
        self.assertTrue(password.isdigit())

    def test_short_length_is_bumped_to_fit_enabled_sets(self):
        options = self.pg.normalise({"length": 2})
        self.assertEqual(options["length"], 4)
        self.assertEqual(len(self.pg.generate_password(options)), 4)

    def test_bad_values_fall_back_to_defaults(self):
        options = self.pg.normalise({"length": "nonsense", "lower": "yes"})
        self.assertEqual(options, self.pg.default_options())
        self.assertEqual(
            self.pg.normalise({"length": 500, "lower": False, "upper": False,
                               "digits": False, "symbols": False}),
            self.pg.default_options(),
        )
        self.assertEqual(self.pg.normalise({"length": 500})["length"], self.pg.MAX_LENGTH)

    def test_options_round_trip_and_stay_private(self):
        options = self.pg.default_options()
        options.update({"length": 20, "symbols": False})
        self.pg.save_options(options)
        self.assertEqual(self.pg.load_options(), options)
        self.assertEqual(self.pg.STATE_FILE.stat().st_mode & 0o777, 0o600)

    def test_corrupt_state_file_uses_defaults(self):
        self.pg.STATE_FILE.write_text("{not json", encoding="utf-8")
        self.assertEqual(self.pg.load_options(), self.pg.default_options())

    def test_status_is_one_json_line(self):
        output = io.StringIO()
        with contextlib.redirect_stdout(output):
            self.assertEqual(self.pg.cmd_status(), 0)
        lines = output.getvalue().splitlines()
        self.assertEqual(len(lines), 1)
        payload = json.loads(lines[0])
        self.assertEqual(payload["text"], "󰌾")
        self.assertIn("Length: 12", payload["tooltip"])
        self.assertIn("Left: generate &amp; copy", payload["tooltip"])

    def test_new_copies_without_leaking_password_into_notification(self):
        copied: list[str] = []
        notified: list[tuple[str, str, str]] = []
        self.pg.clip = lambda text: copied.append(text) or True
        self.pg.notify = lambda title, body, urgency="normal": notified.append(
            (title, body, urgency)
        )

        self.assertEqual(self.pg.cmd_new(), 0)
        self.assertEqual(len(copied), 1)
        self.assertEqual(len(copied[0]), 12)
        self.assertEqual(notified[0][0], "Password copied")
        self.assertNotIn(copied[0], notified[0][1])

    def test_print_command(self):
        output = io.StringIO()
        with contextlib.redirect_stdout(output):
            self.assertEqual(self.pg.main(["passgen-waybar", "print"]), 0)
        password = output.getvalue().strip()
        self.assertEqual(len(password), 12)


if __name__ == "__main__":
    unittest.main()
