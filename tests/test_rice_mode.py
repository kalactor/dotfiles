from __future__ import annotations

import argparse
import tempfile
import unittest
from datetime import datetime
from pathlib import Path
from unittest.mock import patch
from zoneinfo import ZoneInfo

from helpers import load_script


class RiceModeTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.rice = load_script("rice-mode")

    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix="rice-mode-test-")
        root = Path(self.temporary.name)
        self.rice.CACHE = root
        self.rice.MODE_FILE = root / "mode"
        self.rice.EFFECTIVE_FILE = root / "effective-mode"
        self.rice.LOCATION_FILE = root / "location"
        self.rice.LOCK_FILE = root / "mode.lock"
        self.rice.LOG_FILE = root / "mode.log"
        self.rice.WALLS = root / "walls"

    def tearDown(self):
        self.temporary.cleanup()

    def test_noaa_transitions_and_manual_override(self):
        self.rice.write_text(self.rice.LOCATION_FILE, "28.133528,76.7542707\n")
        tz = ZoneInfo("Asia/Kolkata")
        morning = datetime(2026, 11, 14, 6, 0, tzinfo=tz)
        daytime = datetime(2026, 11, 14, 12, 0, tzinfo=tz)
        evening = datetime(2026, 11, 14, 18, 0, tzinfo=tz)

        self.assertEqual(self.rice.compute_effective("auto", morning)[0], "dark")
        effective, info = self.rice.compute_effective("auto", daytime)
        self.assertEqual(effective, "light")
        self.assertEqual(info["sunrise"].strftime("%H:%M"), "06:43")
        self.assertEqual(info["sunset"].strftime("%H:%M"), "17:30")
        self.assertEqual(info["next_event"], "sunset")
        self.assertEqual(self.rice.compute_effective("auto", evening)[0], "dark")
        self.assertEqual(self.rice.compute_effective("light", evening)[0], "light")
        self.assertEqual(self.rice.compute_effective("dark", daytime)[0], "dark")

    def test_polar_day_and_night(self):
        tz = ZoneInfo("UTC")
        self.rice.write_text(self.rice.LOCATION_FILE, "78.2232,15.6267\n")
        summer = datetime(2026, 6, 21, 12, 0, tzinfo=tz)
        winter = datetime(2026, 12, 21, 12, 0, tzinfo=tz)
        self.assertEqual(self.rice.compute_effective("auto", summer)[0], "light")
        self.assertEqual(self.rice.compute_effective("auto", winter)[0], "dark")

    def test_state_round_trip_and_location_validation(self):
        self.rice.write_text(self.rice.MODE_FILE, "dark\n")
        self.assertEqual(self.rice.read_mode(), "dark")
        self.rice.write_text(self.rice.MODE_FILE, "invalid\n")
        self.assertEqual(self.rice.read_mode(), "auto")
        self.assertEqual(self.rice.parse_location("28.1, 76.7"), (28.1, 76.7))
        with self.assertRaises(ValueError):
            self.rice.parse_location("91,20")
        with self.assertRaises(ValueError):
            self.rice.parse_location("not-a-location")

    def test_tick_propagates_wall_failure(self):
        info = {"sunrise": None, "sunset": None, "polar": None}
        with (
            patch.object(self.rice, "read_mode", return_value="auto"),
            patch.object(self.rice, "compute_effective", return_value=("light", info)),
            patch.object(self.rice, "run_wall", return_value=7) as run_wall,
        ):
            result = self.rice.cmd_tick(argparse.Namespace(verbose=False))
        self.assertEqual(result, 7)
        run_wall.assert_called_once()

    def test_forced_mode_returns_apply_status(self):
        info = {"sunrise": None, "sunset": None, "polar": None}
        with (
            patch.object(self.rice, "compute_effective", return_value=("dark", info)),
            patch.object(self.rice, "run_wall", return_value=4),
        ):
            _, _, result = self.rice.set_mode("dark")
        self.assertEqual(result, 4)


if __name__ == "__main__":
    unittest.main()
