from __future__ import annotations

import contextlib
import io
import json
import tempfile
import unittest
from pathlib import Path

from helpers import load_script


class TempMailTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.tm = load_script("tempmail-waybar")

    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix="tempmail-test-")
        root = Path(self.temporary.name)
        self.saved = {
            name: getattr(self.tm, name)
            for name in ("STATE_HOME", "STATE_FILE", "LOCK_FILE", "RETRY_FILE", "API", "notify")
        }
        self.tm.STATE_HOME = root
        self.tm.STATE_FILE = root / "state.json"
        self.tm.LOCK_FILE = root / "lock"
        self.tm.RETRY_FILE = root / "retry-until"
        # Port 1 is closed: every request fails immediately.
        self.tm.API = "http://127.0.0.1:1"
        self.tm.notify = lambda *args, **kwargs: None

    def tearDown(self):
        for name, value in self.saved.items():
            setattr(self.tm, name, value)
        self.temporary.cleanup()

    def status(self) -> tuple[int, list[dict]]:
        output = io.StringIO()
        with contextlib.redirect_stdout(output):
            code = self.tm.cmd_status()
        lines = [json.loads(line) for line in output.getvalue().splitlines() if line.strip()]
        return code, lines

    def test_connection_failure_is_an_error_not_an_empty_inbox(self):
        code, lines = self.status()
        self.assertEqual(code, 0)
        self.assertEqual(len(lines), 1)
        self.assertEqual(lines[0]["class"], "error")
        self.assertIn("network unavailable", lines[0]["tooltip"])
        self.assertEqual(lines[0]["text"], "󰇮!")

    def test_connection_failure_raises_api_error(self):
        with self.assertRaises(self.tm.ApiError) as caught:
            self.tm.api("GET", "/messages", token="token")
        self.assertIsNone(caught.exception.status)

    def test_has_mail_with_escaped_tooltip(self):
        self.tm.save_state(
            {"token": "token", "email": "inbox@example.com", "seen": [], "created": 0}
        )
        self.tm.api = lambda method, path, token=None, body=None: {
            "messages": [
                {
                    "_id": "m1",
                    "from": "Evil <evil@example.com>",
                    "subject": "<b>hello</b>",
                    "bodyPreview": "plain text",
                    "receivedAt": 1700000000,
                }
            ]
        }

        code, lines = self.status()
        self.assertEqual(code, 0)
        self.assertEqual(len(lines), 1)
        payload = lines[0]
        self.assertEqual(payload["class"], "has-mail")
        self.assertEqual(payload["alt"], "inbox@example.com")
        self.assertIn("&lt;b&gt;hello&lt;/b&gt;", payload["tooltip"])
        self.assertNotIn("<b>hello</b>", payload["tooltip"])
        self.assertIn("m1", json.loads(self.tm.STATE_FILE.read_text(encoding="utf-8"))["seen"])

    def test_otp_extraction(self):
        self.assertEqual(self.tm.extract_otp("Your verification code is 482 913"), "482913")
        self.assertEqual(self.tm.extract_otp("OTP: 1234-5678"), "12345678")
        self.assertIsNone(self.tm.extract_otp("Order 2024 shipped"))

    def test_state_file_is_private(self):
        self.tm.save_state(
            {"token": "token", "email": "a@b.c", "seen": [], "created": 0}
        )
        self.assertEqual(self.tm.STATE_FILE.stat().st_mode & 0o777, 0o600)


if __name__ == "__main__":
    unittest.main()
