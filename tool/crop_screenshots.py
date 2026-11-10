#!/usr/bin/env python3
"""Skrinshotlarni Play talab qiladigan 9:16 nisbatiga keltirish.

FAQAT ishlab chiqish vositasi. `flutter drive` skrinshotlarni qurilma
ekrani o'lchamida oladi (masalan 1080x2270), Google Play esa do'kon
sahifasi uchun qat'iy 16:9 yoki 9:16 talab qiladi.

Skript ortiqcha balandlikni kontentdan emas, chetlardagi bo'sh joydan
oladi; bo'sh joy yetmasa, kesim chizig'ini elementlar orasidagi eng
kam kontrastli qatorga suradi.

Ishlatish:
    python3 tool/crop_screenshots.py
"""

from __future__ import annotations

from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
SHOTS = ROOT / "docs/play/graphics/screenshots"

TARGET_H = 1920
MIN_TOP = 40
CONTENT_THRESHOLD = 6.0
SNAP_RANGE = 45


def crop_916(path: Path) -> Image.Image:
    img = Image.open(path).convert("RGB")
    rows = np.asarray(img.convert("L"), dtype=np.float32)
    height = rows.shape[0]
    need = height - TARGET_H
    if need <= 0:
        return img

    contrast = rows.std(axis=1)
    content = np.where(contrast > CONTENT_THRESHOLD)[0]
    top_free = max(0, int(content[0]) - MIN_TOP)
    bottom_free = height - 1 - int(content[-1])

    spare = top_free + bottom_free - need
    if spare >= 0:
        cut_top = round(min(top_free, max(0, top_free - spare / 2)))
        cut_bottom = need - cut_top
        if cut_bottom > bottom_free:
            cut_bottom = bottom_free
            cut_top = need - cut_bottom
    else:
        cut_top = top_free
        edge = height - (need - cut_top)
        lo = max(0, edge - SNAP_RANGE)
        hi = min(height - 1, edge + SNAP_RANGE)
        edge = int(lo + np.argmin(contrast[lo:hi + 1]))
        cut_bottom = height - edge
        cut_top = need - cut_bottom
        if not 0 <= cut_top <= top_free:
            cut_top = top_free
            cut_bottom = need - cut_top

    return img.crop((0, cut_top, img.size[0], height - cut_bottom))


def main() -> None:
    for path in sorted(SHOTS.glob("*/*.png")):
        out = crop_916(path)
        if out.size != (1080, TARGET_H):
            raise SystemExit(f"{path}: {out.size[0]}x{out.size[1]}")
        out.save(path, optimize=True)
        print(f"{path.relative_to(ROOT)}  {out.size[0]}x{out.size[1]}")


if __name__ == "__main__":
    main()
