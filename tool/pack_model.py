#!/usr/bin/env python3
"""Modelni bitta shifrlangan asset qilib qadoqlash.

FAQAT ishlab chiqish vositasi — ilovaga kirmaydi.

Nima qiladi:
  1. `best.onnx` + `best.onnx.data` (tashqi og'irliklar) bitta ONNX faylga
     birlashtiriladi. Shundan keyin modelni fayl yo'lisiz, to'g'ridan-to'g'ri
     xotiradan yuklash mumkin bo'ladi.
  2. Natija ChaCha20 bilan shifrlanadi va `assets/models/model.bin` ga
     yoziladi.

Nega kerak:
  * Birlashtirilgan model `OrtSession.fromBuffer` bilan yuklanadi — model
    fayl tizimiga UMUMAN tushmaydi, faqat jarayon xotirasida bo'ladi.
  * Shifrlangan asset APK'ni oddiy `unzip` qilgan odamga ishlaydigan
    `.onnx` bermaydi.

Cheklov: qurilmadagi modelni butunlay himoyalab bo'lmaydi — ilova uni
ocha olsa, qurilmani to'liq nazorat qilgan odam ham ocha oladi. Maqsad —
to'siqni jiddiy ko'tarish, mutlaq kafolat emas.

Ishlatish:
    python3 tool/pack_model.py            # mavjud kalit bilan
    python3 tool/pack_model.py --new-key  # yangi kalit yaratish
"""

from __future__ import annotations

import argparse
import hashlib
import os
import re
import struct
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT.parents[0] / "checkers_ai-main" / "checkpoints" / "best.onnx"
ASSET = ROOT / "assets" / "models" / "model.bin"
KEY_DART = ROOT / "lib" / "core" / "ai" / "model_key.dart"

MAGIC = b"SHK1"


def rotl32(v: int, n: int) -> int:
    return ((v << n) | (v >> (32 - n))) & 0xFFFFFFFF


def chacha20_block(key: bytes, counter: int, nonce: bytes) -> bytes:
    """RFC 8439 ChaCha20 blok funksiyasi."""
    constants = (0x61707865, 0x3320646E, 0x79622D32, 0x6B206574)
    state = list(constants)
    state += list(struct.unpack("<8I", key))
    state.append(counter)
    state += list(struct.unpack("<3I", nonce))
    working = list(state)

    def quarter(a: int, b: int, c: int, d: int) -> None:
        working[a] = (working[a] + working[b]) & 0xFFFFFFFF
        working[d] = rotl32(working[d] ^ working[a], 16)
        working[c] = (working[c] + working[d]) & 0xFFFFFFFF
        working[b] = rotl32(working[b] ^ working[c], 12)
        working[a] = (working[a] + working[b]) & 0xFFFFFFFF
        working[d] = rotl32(working[d] ^ working[a], 8)
        working[c] = (working[c] + working[d]) & 0xFFFFFFFF
        working[b] = rotl32(working[b] ^ working[c], 7)

    for _ in range(10):
        quarter(0, 4, 8, 12)
        quarter(1, 5, 9, 13)
        quarter(2, 6, 10, 14)
        quarter(3, 7, 11, 15)
        quarter(0, 5, 10, 15)
        quarter(1, 6, 11, 12)
        quarter(2, 7, 8, 13)
        quarter(3, 4, 9, 14)

    out = [(working[i] + state[i]) & 0xFFFFFFFF for i in range(16)]
    return struct.pack("<16I", *out)


def chacha20(key: bytes, nonce: bytes, data: bytes) -> bytes:
    out = bytearray(len(data))
    for offset in range(0, len(data), 64):
        stream = chacha20_block(key, 1 + offset // 64, nonce)
        chunk = data[offset:offset + 64]
        for i, byte in enumerate(chunk):
            out[offset + i] = byte ^ stream[i]
    return bytes(out)


def merge_external_data(path: Path) -> bytes:
    """Tashqi og'irliklarni model ichiga kiritib, baytlarni qaytaradi."""
    import onnx

    model = onnx.load(str(path), load_external_data=True)
    onnx.checker.check_model(model)
    with tempfile.TemporaryDirectory() as tmp:
        merged = Path(tmp) / "merged.onnx"
        onnx.save_model(model, str(merged), save_as_external_data=False)
        blob = merged.read_bytes()
    if b"best.onnx.data" in blob:
        raise SystemExit("birlashtirish ishlamadi: tashqi havola qoldi")
    return blob


def write_key_file(key: bytes, nonce: bytes) -> None:
    """Kalitni Dart konstantasi sifatida yozadi."""
    def as_dart(values: bytes) -> str:
        body = ", ".join(str(b) for b in values)
        wrapped: list[str] = []
        line = "  "
        for part in body.split(", "):
            if len(line) + len(part) + 2 > 74:
                wrapped.append(line.rstrip())
                line = "  "
            line += part + ", "
        wrapped.append(line.rstrip())
        return "\n".join(wrapped)

    KEY_DART.write_text(
        "// tool/pack_model.py tomonidan yaratilgan — qo'lda tahrirlanmaydi.\n"
        "library;\n"
        "\n"
        "import 'dart:typed_data';\n"
        "\n"
        "final Uint8List modelKey = Uint8List.fromList(const [\n"
        f"{as_dart(key)}\n"
        "]);\n"
        "\n"
        "final Uint8List modelNonce = Uint8List.fromList(const [\n"
        f"{as_dart(nonce)}\n"
        "]);\n"
    )


def read_existing_key() -> tuple[bytes, bytes] | None:
    if not KEY_DART.exists():
        return None
    text = KEY_DART.read_text()
    blocks = re.findall(r"const \[(.*?)\]", text, re.S)
    if len(blocks) != 2:
        return None
    key = bytes(int(x) for x in blocks[0].replace("\n", "").split(",") if x.strip())
    nonce = bytes(int(x) for x in blocks[1].replace("\n", "").split(",") if x.strip())
    if len(key) != 32 or len(nonce) != 12:
        return None
    return key, nonce


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--new-key", action="store_true")
    args = parser.parse_args()

    if not SOURCE.exists():
        raise SystemExit(f"model topilmadi: {SOURCE}")

    print(f"manba: {SOURCE}", file=sys.stderr)
    blob = merge_external_data(SOURCE)
    digest = hashlib.sha256(blob).digest()
    print(f"birlashtirildi: {len(blob) / 1e6:.1f} MB", file=sys.stderr)

    existing = None if args.new_key else read_existing_key()
    if existing is None:
        key, nonce = os.urandom(32), os.urandom(12)
        write_key_file(key, nonce)
        print("yangi kalit yozildi: lib/core/ai/model_key.dart", file=sys.stderr)
    else:
        key, nonce = existing
        print("mavjud kalit ishlatildi", file=sys.stderr)

    payload = chacha20(key, nonce, blob)
    ASSET.parent.mkdir(parents=True, exist_ok=True)
    # Sarlavha: sehrli so'z, ochilgan hajm, SHA-256 (yaxlitlikni tekshirish).
    ASSET.write_bytes(MAGIC + struct.pack("<I", len(blob)) + digest + payload)
    print(f"yozildi: {ASSET} ({ASSET.stat().st_size / 1e6:.1f} MB)", file=sys.stderr)


if __name__ == "__main__":
    main()
