#!/usr/bin/env python3
"""Asl Python modelidan AI yurishlari uchun golden vektorlar.

FAQAT ishlab chiqish vositasi.

Nima qiladi: `checkpoints/best.onnx` ni onnxruntime bilan yuklab, asl
`shashka_ai/checkers_engine.py` dvigateli ustida tasodifiy pozitsiyalar
yaratadi va har birida model tanlaydigan yurishni yozadi. Mantiq
`shashka_desktop/src-tauri/src/ai.rs` dagi `sims == 0` yo'lining aynan
o'zi: kanonik legal harakatlar ustida softmax, eng kattasi tanlanadi.

Dart testi (`integration_test/ai_parity_test.dart`) shu pozitsiyalarni
telefonda takrorlab, ilova ayni shu yurishlarni tanlashini tekshiradi.

Natija to'g'ridan-to'g'ri Dart fayliga yoziladi: integration_test
qurilmada ishlaydi va host fayl tizimini ko'rmaydi. Fayl `integration_test/`
ichida — ilovaga (lib/) kirmaydi va APK'ga tushmaydi.

Ishlatish:
    python3 tool/gen_ai_golden.py
"""

from __future__ import annotations

import json
import random
import sys
from pathlib import Path

import numpy as np
import onnxruntime as ort

ROOT = Path(__file__).resolve().parents[1]
ENGINE_DIR = ROOT.parents[0] / "checkers_ai-main" / "shashka_ai"
MODEL = ROOT.parents[0] / "checkers_ai-main" / "checkpoints" / "best.onnx"
OUT = ROOT / "integration_test" / "ai_golden_data.dart"
sys.path.insert(0, str(ENGINE_DIR))

from checkers_engine import GameState, action_encode  # noqa: E402

CASES = 120
MAX_SETUP_PLIES = 60


def pick_move(session: ort.InferenceSession, state: GameState) -> dict:
    """ai.rs dagi sims==0 yo'li: policy boshidan to'g'ridan-to'g'ri yurish."""
    winner, moves = state.status()
    if winner is not None or not moves:
        raise ValueError("terminal pozitsiya")

    x = state.encode().astype(np.float32)[None, :]
    policy, wdl = session.run(["policy_logits", "wdl_logits"], {"x": x})

    acts = [action_encode(f, t) for f, t in moves]
    canon = [state.canon_action(a) for a in acts]
    logits = np.array([policy[0][c] for c in canon], dtype=np.float64)
    shifted = np.exp(logits - logits.max())
    total = float(shifted.sum())
    best = int(shifted.argmax())

    z = wdl[0].astype(np.float64)
    p = np.exp(z - z.max())
    p /= p.sum()

    ordered = np.sort(shifted)[::-1]
    margin = float(ordered[0] - ordered[1]) / total if len(ordered) > 1 else 1.0

    return {
        "action": int(acts[best]),
        "confidence": float(shifted[best] / total) if total > 0 else 0.0,
        "value": float(p[0] - p[2]),
        "margin": margin,
        "legal": len(acts),
    }


def main() -> None:
    if not MODEL.exists():
        raise SystemExit(f"model topilmadi: {MODEL}")
    session = ort.InferenceSession(str(MODEL), providers=["CPUExecutionProvider"])

    rng = random.Random(20260610)
    cases = []

    while len(cases) < CASES:
        state = GameState()
        history: list[int] = []
        depth = rng.randrange(0, MAX_SETUP_PLIES)

        ok = True
        for _ in range(depth):
            winner, moves = state.status()
            if winner is not None or not moves:
                ok = False
                break
            action = action_encode(*moves[rng.randrange(len(moves))])
            state.apply(action)
            history.append(action)
        if not ok:
            continue

        winner, moves = state.status()
        if winner is not None or not moves:
            continue

        expected = pick_move(session, state)
        expected["actions"] = history
        expected["player"] = state.player
        expected["chain"] = -1 if state.chain_sq is None else int(state.chain_sq)
        cases.append(expected)

    chained = sum(1 for c in cases if c["chain"] >= 0)
    tight = sum(1 for c in cases if c["margin"] < 0.01)
    payload = json.dumps(
        {
            "meta": {
                "source": "checkpoints/best.onnx + shashka_ai/checkers_engine.py",
                "onnxruntime": ort.__version__,
                "cases": len(cases),
                "chained": chained,
                "tight_margin": tight,
            },
            "cases": cases,
        },
        separators=(",", ":"),
    )
    assert "\'\'\'" not in payload
    OUT.write_text(
        "library;\n\nconst String aiGoldenJson = r\'\'\'\n"
        + payload
        + "\n\'\'\';\n"
    )
    print(
        f"{len(cases)} holat · zanjirli={chained} · "
        f"juda yaqin tanlov={tight} -> {OUT}",
        file=sys.stderr,
    )


if __name__ == "__main__":
    main()
