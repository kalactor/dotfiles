#!/usr/bin/env python3
"""Shared import helper for extension-less scripts in bin/.local/bin."""

from __future__ import annotations

import importlib.util
import sys
from importlib.machinery import SourceFileLoader
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SCRIPTS = ROOT / "bin" / ".local" / "bin"


def load_script(name: str):
    path = SCRIPTS / name
    module_name = f"rice_test_{name.replace('-', '_')}"
    loader = SourceFileLoader(module_name, str(path))
    spec = importlib.util.spec_from_file_location(module_name, path, loader=loader)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"cannot load {path}")
    module = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    return module
