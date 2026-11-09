#!/usr/bin/env python3
"""Dart fayllaridan izohlarni olib tashlaydi.

FAQAT ishlab chiqish vositasi. Satr literallari ichidagi `//` va `/*`
buzilmasligi uchun oddiy holat mashinasi ishlatiladi: xom (`r'...'`),
uch tirnoqli va interpolyatsiyali satrlar hisobga olinadi.

Generatsiya qilingan (`lib/l10n/app_localizations*.dart`) va ko'chirilgan
(`third_party/`) fayllarga tegilmaydi.

Ishlatish:
    python3 tool/strip_comments.py lib
"""

from __future__ import annotations

import sys
from pathlib import Path

SKIP_NAMES = ("app_localizations",)


def strip(source: str) -> str:
    out: list[str] = []
    i = 0
    n = len(source)
    while i < n:
        ch = source[i]

        # Satr literali boshlanishi (xom bo'lishi ham mumkin).
        if ch in "'\"" or (ch == "r" and i + 1 < n and source[i + 1] in "'\""):
            raw = ch == "r"
            if raw:
                out.append(ch)
                i += 1
                ch = source[i]
            quote = ch
            triple = source.startswith(quote * 3, i)
            marker = quote * 3 if triple else quote
            out.append(marker)
            i += len(marker)
            while i < n:
                if not raw and source[i] == "\\":
                    out.append(source[i:i + 2])
                    i += 2
                    continue
                if source.startswith(marker, i):
                    out.append(marker)
                    i += len(marker)
                    break
                out.append(source[i])
                i += 1
            continue

        if source.startswith("//", i):
            while i < n and source[i] != "\n":
                i += 1
            continue

        if source.startswith("/*", i):
            depth = 1
            i += 2
            while i < n and depth:
                if source.startswith("/*", i):
                    depth += 1
                    i += 2
                elif source.startswith("*/", i):
                    depth -= 1
                    i += 2
                else:
                    i += 1
            continue

        out.append(ch)
        i += 1
    return "".join(out)


def tidy(text: str) -> str:
    lines = [line.rstrip() for line in text.split("\n")]
    result: list[str] = []
    blank = 0
    for line in lines:
        if line:
            blank = 0
            result.append(line)
        else:
            blank += 1
            if blank == 1:
                result.append("")
    while result and not result[0]:
        result.pop(0)
    while result and not result[-1]:
        result.pop()
    return "\n".join(result) + "\n"


def main() -> None:
    roots = sys.argv[1:] or ["lib"]
    changed = 0
    for root in roots:
        for path in sorted(Path(root).rglob("*.dart")):
            if any(name in path.name for name in SKIP_NAMES):
                continue
            original = path.read_text()
            cleaned = tidy(strip(original))
            if cleaned != original:
                path.write_text(cleaned)
                changed += 1
                saved = len(original) - len(cleaned)
                print(f"{path}  -{saved} bayt")
    print(f"\n{changed} fayl tozalandi")


if __name__ == "__main__":
    main()
