#!/usr/bin/env python3
"""Skrinshotlarni Play talab qiladigan 9:16 nisbatiga keltirish.

FAQAT ishlab chiqish vositasi. `flutter drive` skrinshotlarni qurilma
ekrani o'lchamida oladi, Google Play esa do'kon sahifasi uchun qat'iy
16:9 yoki 9:16 talab qiladi.

Agar chetlarda yetarli bo'sh joy bo'lsa, ortiqcha balandlik o'shandan
kesiladi. Bo'sh joy yetmasa (maket butun ekranni to'ldirsa) kontent
qirqilmaydi: balandlik 16 ga karrali qiymatga keltirilib, eni 9 ga
karrali qiymatgacha kengaytiriladi. Qo'shilgan chet ustunlar har bir
qator uchun alohida cho'ziladi, shuning uchun ilovaning fon gradienti
uzluksiz davom etadi.

Ishlatish:
    python3 tool/crop_screenshots.py [papka]
"""

from __future__ import annotations

import sys
from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
SHOTS = ROOT / "docs/play/graphics/screenshots"

MIN_TOP = 40
CONTENT_THRESHOLD = 6.0
SNAP_RANGE = 45


def trim_height(img: Image.Image, need: int) -> Image.Image:
    """Ortiqcha balandlikni chetlardagi bo'sh joydan oladi."""
    if need <= 0:
        return img

    rows = np.asarray(img.convert("L"), dtype=np.float32)
    height = rows.shape[0]
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


def pad_width(img: Image.Image, target: int) -> Image.Image:
    width, height = img.size
    if target <= width:
        return img

    left = (target - width) // 2
    out = Image.new("RGB", (target, height))
    out.paste(img.crop((0, 0, 1, height)).resize((left, height)), (0, 0))
    out.paste(
        img.crop((width - 1, 0, width, height)).resize(
            (target - width - left, height)
        ),
        (left + width, 0),
    )
    out.paste(img, (left, 0))
    return out


def to_916(path: Path) -> Image.Image:
    img = Image.open(path).convert("RGB")
    width, height = img.size
    if width * 16 == height * 9:
        return img

    units = height // 16
    if 9 * units >= width:
        img = trim_height(img, height - 16 * units)
        return pad_width(img, 9 * units)

    return trim_height(img, height - round(width * 16 / 9))


def main() -> None:
    root = Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else SHOTS
    done: list[tuple[Path, Image.Image]] = []
    bad: list[str] = []

    for path in sorted(root.glob("*/*.png")):
        out = to_916(path)
        if out.size[0] * 16 != out.size[1] * 9:
            bad.append(f"{path.name}: {out.size[0]}x{out.size[1]}")
            continue
        done.append((path, out))

    if bad:
        raise SystemExit("9:16 ga keltirib bo'lmadi:\n  " + "\n  ".join(bad))

    for path, out in done:
        out.save(path, optimize=True)
        print(f"{path.relative_to(ROOT)}  {out.size[0]}x{out.size[1]}")


if __name__ == "__main__":
    main()
