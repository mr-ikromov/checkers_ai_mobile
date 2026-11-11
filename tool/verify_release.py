#!/usr/bin/env python3
"""Release AAB ni yetkazishdan oldin tekshirish.

FAQAT ishlab chiqish vositasi. Qo'lda tekshirishga tayanmaslik uchun
barcha shartlar shu yerda yig'ilgan: imzo, versiya, ruxsatlar, 16 KB
sahifa tekisligi, modelning shifrlanganligi va obfuskatsiya.

Obfuskatsiya alohida muhim: `flutter build` ni `--obfuscate` siz
ishga tushirish oson, bunda esa shifr nomi va sinf nomlari binaryda
ochiq qoladi. Skript aynan shu holatni ushlaydi.

Ishlatish:
    python3 tool/verify_release.py [aab]
"""

from __future__ import annotations

import re
import subprocess
import sys
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_AAB = ROOT / "build/app/outputs/bundle/release/app-release.aab"

EXPECTED_OWNER = "CN=Shashka AI"
MODEL_ASSET = "base/assets/flutter_assets/assets/models/model.bin"
MODEL_MAGIC = b"SHK1"

# Binaryda uchramasligi kerak bo'lgan satrlar: shifr nomi va ilova
# sinflari. Bulardan biri chiqsa, demak obfuskatsiya qo'llanmagan.
FORBIDDEN = [
    b"chacha20",
    b"expand 32-byte k",
    b"SHK1",
    b"modelKey",
    b"modelNonce",
    b"decryptModel",
    b"GameController",
    b"OnnxEvaluator",
    b"SettingsStore",
]

ALLOWED_ALIGN = {"0x4000", "0x10000"}


class Report:
    def __init__(self) -> None:
        self.failures: list[str] = []

    def check(self, name: str, ok: bool, detail: str = "") -> None:
        mark = "OK  " if ok else "XATO"
        print(f"  [{mark}] {name}{' — ' + detail if detail else ''}")
        if not ok:
            self.failures.append(name)


def manifest_value(blob: bytes, name: str) -> str:
    i = blob.find(name.encode())
    if i < 0:
        return ""
    tail = blob[i + len(name):]
    return tail[2:2 + tail[1]].decode(errors="replace")


def key_material() -> list[bytes]:
    src = (ROOT / "lib/core/ai/model_key.dart").read_text(encoding="utf-8")
    out = []
    for field in ("modelKey", "modelNonce"):
        body = src.split(field)[1].split("]")[0]
        out.append(bytes(int(x) for x in re.findall(r"\b(\d{1,3})\b", body)))
    return out


def key_found(blob: bytes, secret: bytes) -> bool:
    if secret in blob:
        return True
    for step, shift in ((8, 1), (8, 0), (4, 1), (4, 0)):
        packed = b"".join((b << shift).to_bytes(step, "little") for b in secret)
        if packed in blob:
            return True
    return False


def main() -> int:
    aab = Path(sys.argv[1]) if len(sys.argv) > 1 else DEFAULT_AAB
    if not aab.exists():
        raise SystemExit(f"AAB topilmadi: {aab}")

    print(f"\n{aab.name}  ({aab.stat().st_size / 1048576:.1f} MB)\n")
    r = Report()
    zf = zipfile.ZipFile(aab)

    cert = subprocess.run(
        ["keytool", "-printcert"],
        input=zf.read("META-INF/UPLOAD.RSA"),
        capture_output=True,
    ).stdout.decode(errors="replace")
    r.check("imzo upload-kalit bilan", EXPECTED_OWNER in cert,
            cert.split("\n")[0].replace("Owner: ", "")[:48])

    manifest = zf.read("base/manifest/AndroidManifest.xml")
    r.check("paket nomi", b"uz.deepcontrol.shashka" in manifest)
    r.check("minSdkVersion 24", manifest_value(manifest, "minSdkVersion") == "24")
    r.check("targetSdkVersion 36",
            manifest_value(manifest, "targetSdkVersion") == "36")

    perms = {p.decode() for p in re.findall(rb"android\.permission\.[A-Z_]+", manifest)}
    requested = {p for p in perms if b'name\x1a' + p.encode() in manifest}
    r.check("tizim ruxsati so'ralmaydi", not requested,
            ", ".join(sorted(requested)) or "yo'q")

    model = zf.read(MODEL_ASSET)
    r.check("model shifrlangan", model[:4] == MODEL_MAGIC,
            model[:4].decode(errors="replace"))
    r.check("modelda ONNX izi yo'q", b"onnx" not in model[:4096].lower())

    libs = [n for n in zf.namelist() if n.endswith(".so")]
    r.check("kutubxonalar topildi", bool(libs), f"{len(libs)} ta")

    secrets = key_material()
    for abi in ("arm64-v8a", "armeabi-v7a", "x86_64"):
        name = f"base/lib/{abi}/libapp.so"
        if name not in zf.namelist():
            continue
        blob = zf.read(name)
        leaked = [f.decode() for f in FORBIDDEN if f in blob]
        r.check(f"{abi}: obfuskatsiya", not leaked, ", ".join(leaked) or "toza")
        r.check(f"{abi}: kalit binaryda topilmaydi",
                not any(key_found(blob, s) for s in secrets))

    tmp = ROOT / "build/_verify_so"
    subprocess.run(["rm", "-rf", str(tmp)], check=False)
    tmp.mkdir(parents=True, exist_ok=True)
    bad_align = []
    for name in libs:
        if "/arm64-v8a/" not in name:
            continue
        path = tmp / Path(name).name
        path.write_bytes(zf.read(name))
        out = subprocess.run(["readelf", "-lW", str(path)],
                             capture_output=True).stdout.decode()
        aligns = {line.split()[-1] for line in out.splitlines()
                  if line.strip().startswith("LOAD")}
        if not aligns <= ALLOWED_ALIGN:
            bad_align.append(f"{path.name}={sorted(aligns)}")
    subprocess.run(["rm", "-rf", str(tmp)], check=False)
    r.check("16 KB sahifa tekisligi", not bad_align, ", ".join(bad_align) or "arm64 toza")

    print()
    if r.failures:
        print(f"NUQSON: {len(r.failures)} ta — {', '.join(r.failures)}\n")
        return 1
    print("TAYYOR — barcha shartlar bajarildi\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
