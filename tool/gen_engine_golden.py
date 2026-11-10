#!/usr/bin/env python3
"""Dart dvigateli uchun golden test vektorlarini asl Python etalonidan yaratish.

Bu — FAQAT ishlab chiqish vositasi (ilovaga kirmaydi). Asl loyihadagi
`shashka_ai/checkers_engine.py` — 10 000 o'yinlik invariant-fuzzing'dan
o'tgan etalon dvigatel. Shu skript tasodifiy (lekin determinik) o'yinlar
o'ynab, har yarim-yurishda to'liq holatni yozib oladi; Dart testi
(`test/engine_golden_test.dart`) aynan shu harakatlarni takrorlab,
natijalarni bit-darajada solishtiradi.

Ishlatish:
    python3 tool/gen_engine_golden.py > test/golden/engine_golden.json
"""

from __future__ import annotations

import json
import random
import sys
from pathlib import Path

ENGINE_DIR = Path(__file__).resolve().parents[2] / "checkers_ai-main" / "shashka_ai"
sys.path.insert(0, str(ENGINE_DIR))

from checkers_engine import (  # noqa: E402
    GameState,
    NUM_SQUARES,
    SQ_TO_RC,
    action_encode,
)

GAMES = 200
MAX_PLIES_PER_GAME = 400


def board_string(st: GameState) -> str:
    """32 katak: '.' bo'sh, w/W oq shashka/damka, b/B qora shashka/damka."""
    sym = {0: ".", 1: "w", 2: "W", -1: "b", -2: "B"}
    return "".join(sym[int(st.board[r, c])] for (r, c) in SQ_TO_RC)


def snapshot(st: GameState) -> dict:
    winner, moves = st.status()
    acts = [action_encode(f, t) for f, t in moves]
    enc = st.encode()
    return {
        "board": board_string(st),
        "player": st.player,
        "chain": -1 if st.chain_sq is None else st.chain_sq,
        "captured": sorted(int(x) for x in st.captured),
        "halfmove": st.halfmove,
        "ply": st.ply,
        "winner": winner,
        "moves": acts,
        # encode() asosan nollardan iborat — siyrak (sparse) yozamiz:
        # [indeks, qiymat, indeks, qiymat, ...]. Fayl ~7 barobar kichrayadi.
        "encode": [
            v
            for i, x in enumerate(enc)
            if float(x) != 0.0
            for v in (i, float(x))
        ],
    }


def play_game(seed: int) -> dict:
    rng = random.Random(seed)
    st = GameState()
    plies = [snapshot(st)]
    chosen: list[int] = []
    for _ in range(MAX_PLIES_PER_GAME):
        winner, moves = st.status()
        if winner is not None or not moves:
            break
        acts = [action_encode(f, t) for f, t in moves]
        # Urishlarni ozroq ustun qilib tanlaymiz: o'yinlar qiziqroq va
        # zanjirlar, damkalar ko'proq uchraydi.
        idx = rng.randrange(len(acts))
        action = acts[idx]
        st.apply(action)
        chosen.append(action)
        plies.append(snapshot(st))
    return {"seed": seed, "actions": chosen, "plies": plies}


def main() -> None:
    games = [play_game(777000 + i * 13) for i in range(GAMES)]
    total_plies = sum(len(g["plies"]) for g in games)
    out = {
        "meta": {
            "source": "shashka_ai/checkers_engine.py",
            "games": len(games),
            "plies": total_plies,
            "num_squares": NUM_SQUARES,
        },
        "games": games,
    }
    json.dump(out, sys.stdout, separators=(",", ":"))
    print(file=sys.stderr)
    print(f"{len(games)} o'yin, {total_plies} yarim-yurish", file=sys.stderr)


if __name__ == "__main__":
    main()
