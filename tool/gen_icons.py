#!/usr/bin/env python3
"""Ikonka va Play Store grafikalarini yaratish.

FAQAT ishlab chiqish vositasi — ilovaga kirmaydi. Natijalar repozitoriyga
yoziladi va qayta yaratish shart emas. Android 8.0+ da adaptive icon
(vektor XML) ishlatiladi; bu skript eski launcherlar uchun PNG mipmap'lar
va Play Console uchun ikonkani chiqaradi. Feature grafikasi alohida
tayyorlangan va qo'lda saqlanadi.

Ishlatish:
    python3 tool/gen_icons.py
"""

from __future__ import annotations

import math
from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
RES = ROOT / "android/app/src/main/res"
STORE = ROOT / "docs/play/graphics"

SS = 4  # supersampling

BG_OUTER = (18, 13, 8)
BG_INNER = (50, 33, 15)
GOLD = (216, 169, 67)
GOLD_DEEP = (185, 138, 44)
GOLD_BRIGHT = (230, 187, 85)
IVORY_HI = (255, 255, 255)
IVORY = (244, 234, 212)
IVORY_LO = (199, 179, 138)
SHADOW = (0, 0, 0, 90)

MIPMAPS = {
    "mipmap-mdpi": 48,
    "mipmap-hdpi": 72,
    "mipmap-xhdpi": 96,
    "mipmap-xxhdpi": 144,
    "mipmap-xxxhdpi": 192,
}


def lerp(a: tuple[int, ...], b: tuple[int, ...], t: float) -> tuple[int, ...]:
    return tuple(round(x + (y - x) * t) for x, y in zip(a, b))


def radial_background(size: int, center: tuple[float, float], radius: float,
                      inner: tuple[int, int, int],
                      outer: tuple[int, int, int]) -> Image.Image:
    """Radial gradient — kichik rasm yasab, keyin kattalashtiriladi."""
    small = 64
    img = Image.new("RGB", (small, small))
    px = img.load()
    cx = center[0] / size * small
    cy = center[1] / size * small
    r = radius / size * small
    for y in range(small):
        for x in range(small):
            d = math.hypot(x - cx, y - cy) / r
            px[x, y] = lerp(inner, outer, min(1.0, d))
    return img.resize((size, size), Image.LANCZOS)


def crown(draw: ImageDraw.ImageDraw, cx: float, cy: float, scale: float,
          fill: tuple[int, int, int], jewel: tuple[int, int, int]) -> None:
    """108x108 vektordagi toj shakli bilan bir xil nisbatlar."""

    def p(x: float, y: float) -> tuple[float, float]:
        return (cx + (x - 54) * scale, cy + (y - 54) * scale)

    draw.polygon(
        [p(38.5, 62.5), p(35.2, 43.8), p(45.4, 51.6), p(54, 39.5),
         p(62.6, 51.6), p(72.8, 43.8), p(69.5, 62.5)],
        fill=fill,
    )
    x0, y0 = p(37.6, 64.4)
    x1, y1 = p(70.4, 69.2)
    draw.rounded_rectangle([x0, y0, x1, y1], radius=2.4 * scale, fill=fill)
    for jx, jy, jr in ((35.2, 42.2, 2.6), (72.8, 42.2, 2.6), (54, 37.4, 3.1)):
        x, y = p(jx, jy)
        rr = jr * scale
        draw.ellipse([x - rr, y - rr, x + rr, y + rr], fill=jewel)


def draw_icon(size: int, *, rounded: bool) -> Image.Image:
    """Ikonkani chizadi. [rounded] — kvadrat (Play Store) yoki doira."""
    s = size * SS
    background = radial_background(s, (s * 0.28, s * 0.17), s * 1.15,
                                   BG_INNER, BG_OUTER).convert("RGBA")

    mask = Image.new("L", (s, s), 0)
    md = ImageDraw.Draw(mask)
    if rounded:
        md.rounded_rectangle([0, 0, s - 1, s - 1], radius=s * 0.22, fill=255)
    else:
        md.ellipse([0, 0, s - 1, s - 1], fill=255)
    background.putalpha(mask)

    layer = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    draw = ImageDraw.Draw(layer)
    cx = cy = s / 2
    ring = s * 0.335
    disc = s * 0.281

    draw.ellipse(
        [cx - ring, cy - ring + s * 0.022, cx + ring, cy + ring + s * 0.022],
        fill=SHADOW,
    )
    draw.ellipse([cx - ring, cy - ring, cx + ring, cy + ring], fill=GOLD)

    # Suyak tosh — radial gradient doira.
    stone = radial_background(int(disc * 2), (disc * 0.72, disc * 0.6),
                              disc * 1.55, IVORY_HI, IVORY_LO)
    stone = stone.convert("RGBA")
    stone_mask = Image.new("L", stone.size, 0)
    ImageDraw.Draw(stone_mask).ellipse([0, 0, stone.size[0] - 1,
                                        stone.size[1] - 1], fill=255)
    stone.putalpha(stone_mask)
    layer.alpha_composite(stone, (round(cx - disc), round(cy - disc)))

    inner = s * 0.2
    draw.ellipse([cx - inner, cy - inner, cx + inner, cy + inner],
                 outline=(120, 95, 55, 56), width=max(1, round(s * 0.015)))

    crown(draw, cx, cy, s / 108 * 0.60, GOLD_DEEP, GOLD_BRIGHT)

    background.alpha_composite(layer)
    return background.resize((size, size), Image.LANCZOS)


def main() -> None:
    for folder, size in MIPMAPS.items():
        target = RES / folder
        target.mkdir(parents=True, exist_ok=True)
        icon = draw_icon(size, rounded=False)
        icon.save(target / "ic_launcher.png")
        icon.save(target / "ic_launcher_round.png")
        print(f"{folder}/ic_launcher.png  {size}x{size}")

    STORE.mkdir(parents=True, exist_ok=True)
    draw_icon(512, rounded=True).save(STORE / "play_icon_512.png")
    print("docs/play/graphics/play_icon_512.png  512x512")


if __name__ == "__main__":
    main()
