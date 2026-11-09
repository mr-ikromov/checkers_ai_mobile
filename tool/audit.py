#!/usr/bin/env python3
"""Loyihani tozalikka tekshiradi.

FAQAT ishlab chiqish vositasi.

Nimani qidiradi:
  * izohlar (lib va third_party ichida bo'lmasligi kerak);
  * hech qayerdan chaqirilmaydigan e'lonlar (sinf, funksiya, maydon);
  * import qilinmagan Dart fayllari;
  * ishlatilmaydigan l10n kalitlari;
  * ishlatilmaydigan pubspec bog'liqliklari va assetlar.

Ishlatish:
    python3 tool/audit.py
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CODE_DIRS = ["lib", "third_party/onnxruntime_ffi/lib"]
USAGE_DIRS = CODE_DIRS + ["test", "integration_test", "test_driver"]
SKIP = ("app_localizations", "onnxruntime_bindings_generated")

DECL = re.compile(
    r"^\s*(?:"
    r"(?:abstract\s+|final\s+|base\s+|sealed\s+|mixin\s+)*class\s+(\w+)"
    r"|enum\s+(\w+)"
    r"|typedef\s+(\w+)"
    r"|extension\s+(\w+)"
    r"|(?:static\s+)?(?:const|final)\s+[\w<>,\s\?]+\s+(\w+)\s*="
    r"|(?:static\s+)?[\w<>,\s\?]+\s+(\w+)\s*\([^)]*\)\s*(?:\{|=>|async)"
    r")"
)


def dart_files(dirs: list[str]) -> list[Path]:
    out: list[Path] = []
    for d in dirs:
        base = ROOT / d
        if not base.exists():
            continue
        out += [
            p for p in sorted(base.rglob("*.dart"))
            if not any(s in p.name for s in SKIP)
        ]
    return out


def main() -> int:
    problems = 0
    code = dart_files(CODE_DIRS)
    usage = dart_files(USAGE_DIRS)
    corpus = {p: p.read_text() for p in usage}
    everything = "\n".join(corpus.values())

    comments = []
    for path, text in corpus.items():
        for n, line in enumerate(text.split("\n"), 1):
            stripped = line.strip()
            if stripped.startswith("//") or stripped.startswith("/*"):
                comments.append(f"{path.relative_to(ROOT)}:{n}")
    print(f"izohlar: {len(comments)}")
    for c in comments[:10]:
        print(f"  {c}")
    problems += len(comments)

    unused_decls = []
    for path in code:
        text = corpus[path]
        others = everything.replace(text, "", 1)
        for line in text.split("\n"):
            if line.lstrip().startswith("extension "):
                continue
            m = DECL.match(line)
            if not m:
                continue
            name = next(g for g in m.groups() if g)
            if name.startswith("_") or name in {
                "main", "build", "toString", "lerp", "copyWith",
            }:
                continue
            inside = len(re.findall(rf"\b{re.escape(name)}\b", text)) - 1
            outside = len(re.findall(rf"\b{re.escape(name)}\b", others))
            if inside == 0 and outside == 0:
                unused_decls.append(f"{path.relative_to(ROOT)}  {name}")
    print(f"\nchaqirilmaydigan e'lonlar: {len(unused_decls)}")
    for d in unused_decls:
        print(f"  {d}")
    problems += len(unused_decls)

    orphans = []
    for path in code:
        if path.name in {"main.dart", "onnxruntime_ffi.dart"}:
            continue
        needle = path.name
        hits = sum(
            1 for other, text in corpus.items()
            if other != path and needle in text
        )
        if hits == 0:
            orphans.append(str(path.relative_to(ROOT)))
    print(f"\nimport qilinmagan fayllar: {len(orphans)}")
    for o in orphans:
        print(f"  {o}")
    problems += len(orphans)

    arb = json.loads((ROOT / "lib/l10n/app_en.arb").read_text())
    keys = [k for k in arb if not k.startswith("@")]
    used = set(re.findall(r"l10n\.(\w+)", everything))
    dead_keys = [k for k in keys if k not in used]
    print(f"\nl10n: {len(keys)} kalit, ishlatilmagan: {len(dead_keys)}")
    for k in dead_keys:
        print(f"  {k}")
    problems += len(dead_keys)

    pubspec = (ROOT / "pubspec.yaml").read_text()
    deps = re.findall(r"^  ([a-z_0-9]+):", pubspec, re.M)
    ignore = {
        "flutter", "flutter_test", "flutter_localizations", "sdk",
        "flutter_lints", "integration_test", "assets", "path",
        "generate", "intl",
    }
    dead_deps = [
        d for d in deps
        if d not in ignore and f"package:{d}/" not in everything
    ]
    print(f"\nishlatilmaydigan bog'liqliklar: {len(dead_deps)}")
    for d in dead_deps:
        print(f"  {d}")
    problems += len(dead_deps)

    assets = [
        p for p in (ROOT / "assets").rglob("*") if p.is_file()
    ] if (ROOT / "assets").exists() else []
    dead_assets = [
        str(p.relative_to(ROOT)) for p in assets
        if p.name not in everything
    ]
    print(f"\nishlatilmaydigan assetlar: {len(dead_assets)}")
    for a in dead_assets:
        print(f"  {a}")
    problems += len(dead_assets)

    print(f"\n{'TOZA' if problems == 0 else f'{problems} ta muammo'}")
    return 0 if problems == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
