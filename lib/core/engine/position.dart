library;

import 'dart:typed_data';

import 'bitboard.dart';

const int white = 1;

const int black = -1;

const int numSquares = 32;

const int actionSize = numSquares * numSquares;

const int inputSize = numSquares * 6 + 2;

const int noProgressLimit = 60;

const int maxPlies = 300;

const List<List<int>> _dirs = [
  [-1, -1],
  [-1, 1],
  [1, -1],
  [1, 1],
];

class _Geometry {
  _Geometry() {
    var n = 0;
    for (var r = 0; r < 8; r++) {
      for (var c = 0; c < 8; c++) {
        if ((r + c) % 2 == 1) {
          rcSq[r * 8 + c] = n;
          sqRow[n] = r;
          sqCol[n] = c;
          n++;
        }
      }
    }
    rays = List<List<Int8List>>.generate(numSquares, (sq) {
      final r0 = sqRow[sq];
      final c0 = sqCol[sq];
      return List<Int8List>.generate(4, (d) {
        final dr = _dirs[d][0];
        final dc = _dirs[d][1];
        final out = <int>[];
        var r = r0 + dr;
        var c = c0 + dc;
        while (r >= 0 && r < 8 && c >= 0 && c < 8) {
          out.add(rcSq[r * 8 + c]);
          r += dr;
          c += dc;
        }
        return Int8List.fromList(out);
      }, growable: false);
    }, growable: false);
  }

  final Int8List sqRow = Int8List(numSquares);
  final Int8List sqCol = Int8List(numSquares);
  final Int8List rcSq = Int8List(64)..fillRange(0, 64, -1);
  late final List<List<Int8List>> rays;
}

final _Geometry _geo = _Geometry();

final Int8List sqRow = _geo.sqRow;

final Int8List sqCol = _geo.sqCol;

final Int8List rcSq = _geo.rcSq;

final List<List<Int8List>> rays = _geo.rays;

final _ZobristTables _zobrist = _ZobristTables();

class _ZobristTables {
  _ZobristTables() {
    final rng = SplitMix64(0x5A5A20260610);
    for (var cls = 0; cls < 4; cls++) {
      for (var sq = 0; sq < numSquares; sq++) {
        pieces[cls * numSquares + sq] = rng.next();
      }
    }
    side = rng.next();
  }

  final Int64List pieces = Int64List(4 * numSquares);
  late final int side;
}

int actionEncode(int from, int to) => from * 32 + to;

int actionFrom(int action) => action >> 5;

int actionTo(int action) => action & 31;

String squareName(int sq) =>
    '${'abcdefgh'[sqCol[sq]]}${8 - sqRow[sq]}';

String actionName(int action) =>
    '${squareName(actionFrom(action))}-${squareName(actionTo(action))}';

int _segment(int to, int captured) => to | (captured << 8);
int _segTo(int seg) => seg & 0xFF;
int _segCap(int seg) => seg >> 8;

typedef GameStatus = ({int? winner, List<int> moves});

class Position {
  Position._({
    required this.whitePieces,
    required this.blackPieces,
    required this.kings,
    required this.player,
    required this.chainSq,
    required this.captured,
    required this.halfmove,
    required this.ply,
  });

  factory Position.initial() {
    var w = 0;
    var b = 0;
    for (var sq = 0; sq < numSquares; sq++) {
      if (sqRow[sq] < 3) {
        b |= bit(sq);
      } else if (sqRow[sq] > 4) {
        w |= bit(sq);
      }
    }
    final pos = Position._(
      whitePieces: w,
      blackPieces: b,
      kings: 0,
      player: white,
      chainSq: -1,
      captured: 0,
      halfmove: 0,
      ply: 0,
    );
    pos._window.add(pos.hash());
    return pos;
  }

  int whitePieces;

  int blackPieces;

  int kings;

  int player;

  int chainSq;

  int captured;

  int halfmove;

  int ply;

  final List<int> _window = <int>[];

  Position clone() {
    final copy = Position._(
      whitePieces: whitePieces,
      blackPieces: blackPieces,
      kings: kings,
      player: player,
      chainSq: chainSq,
      captured: captured,
      halfmove: halfmove,
      ply: ply,
    );
    copy._window.addAll(_window);
    return copy;
  }

  int get occupied => whitePieces | blackPieces;

  int pieceAt(int sq) {
    final m = bit(sq);
    if (whitePieces & m != 0) return kings & m != 0 ? 2 : 1;
    if (blackPieces & m != 0) return kings & m != 0 ? -2 : -1;
    return 0;
  }

  int hash() {
    var h = 0;
    var occ = occupied;
    while (occ != 0) {
      final sq = lowestBit(occ);
      occ &= occ - 1;
      final m = bit(sq);
      final isWhite = whitePieces & m != 0;
      final isKing = kings & m != 0;
      final cls = isWhite ? (isKing ? 1 : 0) : (isKing ? 3 : 2);
      h ^= _zobrist.pieces[cls * numSquares + sq];
    }
    if (player == black) h ^= _zobrist.side;
    return h;
  }

  void _rawCaptures(
    int sq,
    bool myWhite,
    bool king,
    int alreadyCaptured,
    List<int> out,
  ) {
    final occ = occupied;
    final enemy = myWhite ? blackPieces : whitePieces;
    final sqRays = rays[sq];
    if (!king) {
      for (var d = 0; d < 4; d++) {
        final ray = sqRays[d];
        if (ray.length >= 2) {
          final mid = ray[0];
          final to = ray[1];
          if (occ & bit(to) == 0 &&
              enemy & bit(mid) != 0 &&
              alreadyCaptured & bit(mid) == 0) {
            out.add(_segment(to, mid));
          }
        }
      }
    } else {
      for (var d = 0; d < 4; d++) {
        final ray = sqRays[d];
        var i = 0;
        while (i < ray.length && occ & bit(ray[i]) == 0) {
          i++;
        }
        if (i >= ray.length) continue;
        final mid = ray[i];
        if (enemy & bit(mid) == 0 || alreadyCaptured & bit(mid) != 0) continue;
        var j = i + 1;
        while (j < ray.length && occ & bit(ray[j]) == 0) {
          out.add(_segment(ray[j], mid));
          j++;
        }
      }
    }
  }

  static bool _hasCapture(
    int whiteBb,
    int blackBb,
    int sq,
    bool myWhite,
    bool king,
    int alreadyCaptured,
  ) {
    final occ = whiteBb | blackBb;
    final enemy = myWhite ? blackBb : whiteBb;
    final sqRays = rays[sq];
    if (!king) {
      for (var d = 0; d < 4; d++) {
        final ray = sqRays[d];
        if (ray.length >= 2) {
          final mid = ray[0];
          final to = ray[1];
          if (occ & bit(to) == 0 &&
              enemy & bit(mid) != 0 &&
              alreadyCaptured & bit(mid) == 0) {
            return true;
          }
        }
      }
    } else {
      for (var d = 0; d < 4; d++) {
        final ray = sqRays[d];
        var i = 0;
        while (i < ray.length && occ & bit(ray[i]) == 0) {
          i++;
        }
        if (i >= ray.length) continue;
        final mid = ray[i];
        if (enemy & bit(mid) != 0 &&
            alreadyCaptured & bit(mid) == 0 &&
            i + 1 < ray.length &&
            occ & bit(ray[i + 1]) == 0) {
          return true;
        }
      }
    }
    return false;
  }

  List<int> capturesFrom(int sq, bool king, bool myWhite, int alreadyCaptured) {
    final segs = <int>[];
    _rawCaptures(sq, myWhite, king, alreadyCaptured, segs);
    if (segs.isEmpty || !king) return segs;

    final capsOrder = <int>[];
    for (final seg in segs) {
      final cap = _segCap(seg);
      if (!capsOrder.contains(cap)) capsOrder.add(cap);
    }
    var w0 = whitePieces;
    var b0 = blackPieces;
    if (myWhite) {
      w0 &= ~bit(sq);
    } else {
      b0 &= ~bit(sq);
    }
    final out = <int>[];
    for (final cap in capsOrder) {
      final lands = <int>[];
      for (final seg in segs) {
        if (_segCap(seg) == cap) lands.add(_segTo(seg));
      }
      final newCap = alreadyCaptured | bit(cap);
      final cont = <int>[];
      for (final to in lands) {
        var w2 = w0;
        var b2 = b0;
        if (myWhite) {
          w2 |= bit(to);
        } else {
          b2 |= bit(to);
        }
        if (_hasCapture(w2, b2, to, myWhite, true, newCap)) cont.add(to);
      }
      for (final to in cont.isEmpty ? lands : cont) {
        out.add(_segment(to, cap));
      }
    }
    return out;
  }

  List<int> legalMoves() {
    final myWhite = player == white;
    final mine = myWhite ? whitePieces : blackPieces;

    if (chainSq >= 0) {
      final sq = chainSq;
      final king = kings & bit(sq) != 0;
      final segs = capturesFrom(sq, king, myWhite, captured);
      final out = List<int>.filled(segs.length, 0);
      for (var i = 0; i < segs.length; i++) {
        out[i] = actionEncode(sq, _segTo(segs[i]));
      }
      return out;
    }

    final caps = <int>[];
    var bbs = mine;
    while (bbs != 0) {
      final sq = lowestBit(bbs);
      bbs &= bbs - 1;
      final king = kings & bit(sq) != 0;
      for (final seg in capturesFrom(sq, king, myWhite, 0)) {
        caps.add(actionEncode(sq, _segTo(seg)));
      }
    }
    if (caps.isNotEmpty) return caps;

    final occ = occupied;
    final quiets = <int>[];
    bbs = mine;
    while (bbs != 0) {
      final sq = lowestBit(bbs);
      bbs &= bbs - 1;
      final king = kings & bit(sq) != 0;
      final sqRays = rays[sq];
      if (!king) {

        final d0 = myWhite ? 0 : 2;
        for (var d = d0; d < d0 + 2; d++) {
          final ray = sqRays[d];
          if (ray.isNotEmpty && occ & bit(ray[0]) == 0) {
            quiets.add(actionEncode(sq, ray[0]));
          }
        }
      } else {
        for (var d = 0; d < 4; d++) {
          final ray = sqRays[d];
          for (var i = 0; i < ray.length; i++) {
            final to = ray[i];
            if (occ & bit(to) != 0) break;
            quiets.add(actionEncode(sq, to));
          }
        }
      }
    }
    return quiets;
  }

  void apply(int action) {
    assert(action >= 0 && action < actionSize, 'action chegaradan tashqari');
    final f = actionFrom(action);
    final t = actionTo(action);
    final fr = sqRow[f];
    final fc = sqCol[f];
    final tr = sqRow[t];
    final tc = sqCol[t];
    final myWhite = player == white;
    var king = kings & bit(f) != 0;
    final wasMan = !king;

    final dr = tr.compareTo(fr);
    final dc = tc.compareTo(fc);
    final d = (dr > 0 ? 2 : 0) + (dc > 0 ? 1 : 0);

    var cap = -1;
    final ray = rays[f][d];
    for (var i = 0; i < ray.length; i++) {
      final s = ray[i];
      if (s == t) break;
      if (occupied & bit(s) != 0) cap = s;
    }

    if (myWhite) {
      whitePieces = (whitePieces & ~bit(f)) | bit(t);
    } else {
      blackPieces = (blackPieces & ~bit(f)) | bit(t);
    }
    if (king) kings &= ~bit(f);
    if (wasMan && ((myWhite && tr == 0) || (!myWhite && tr == 7))) {
      king = true;
    }
    if (king) kings |= bit(t);
    ply++;

    if (cap >= 0) {
      final newCap = captured | bit(cap);
      if (_hasCapture(whitePieces, blackPieces, t, myWhite, king, newCap)) {
        chainSq = t;
        captured = newCap;
        return;
      }
      whitePieces &= ~newCap;
      blackPieces &= ~newCap;
      kings &= ~newCap;
      captured = 0;
      chainSq = -1;
      halfmove = 0;
      player = -player;
      _window.clear();
    } else {
      if (wasMan) {
        halfmove = 0;
        player = -player;
        _window.clear();
      } else {
        halfmove++;
        player = -player;
      }
    }
    _window.add(hash());
  }

  GameStatus status() {
    final moves = legalMoves();
    if (moves.isEmpty) return (winner: -player, moves: moves);
    if (chainSq < 0) {
      final h = hash();
      var repeats = 0;
      for (final x in _window) {
        if (x == h) repeats++;
      }
      if (repeats >= 3) return (winner: 0, moves: moves);
      if (halfmove >= noProgressLimit || ply >= maxPlies) {
        return (winner: 0, moves: moves);
      }
    }
    return (winner: null, moves: moves);
  }

  void encode(Float32List out, [int offset = 0]) {
    out.fillRange(offset, offset + inputSize, 0);
    final rot = player == black;
    final iAmWhite = player == white;
    var occ = occupied;
    while (occ != 0) {
      final sq = lowestBit(occ);
      occ &= occ - 1;
      final m = bit(sq);
      final csq = rot ? 31 - sq : sq;
      final isWhite = whitePieces & m != 0;
      final isKing = kings & m != 0;
      final mine = isWhite == iAmWhite;
      final cls = mine ? (isKing ? 1 : 0) : (isKing ? 3 : 2);
      out[offset + csq * 6 + cls] = 1;
      if (captured & m != 0) out[offset + csq * 6 + 5] = 1;
    }
    if (chainSq >= 0) {
      final cs = rot ? 31 - chainSq : chainSq;
      out[offset + cs * 6 + 4] = 1;
    }
    final hm = halfmove < noProgressLimit ? halfmove : noProgressLimit;
    out[offset + 192] = hm / noProgressLimit;
    out[offset + 193] = chainSq >= 0 ? 1 : 0;
  }

  int canonAction(int action) {
    if (player == white) return action;
    return actionEncode(31 - actionFrom(action), 31 - actionTo(action));
  }

  Int64List toSnapshot() {
    final out = Int64List(9 + _window.length);
    out[0] = whitePieces;
    out[1] = blackPieces;
    out[2] = kings;
    out[3] = player;
    out[4] = chainSq;
    out[5] = captured;
    out[6] = halfmove;
    out[7] = ply;
    out[8] = _window.length;
    for (var i = 0; i < _window.length; i++) {
      out[9 + i] = _window[i];
    }
    return out;
  }

  static Position fromSnapshot(Int64List s) {
    final pos = Position._(
      whitePieces: s[0],
      blackPieces: s[1],
      kings: s[2],
      player: s[3],
      chainSq: s[4],
      captured: s[5],
      halfmove: s[6],
      ply: s[7],
    );
    final n = s[8];
    for (var i = 0; i < n; i++) {
      pos._window.add(s[9 + i]);
    }
    return pos;
  }

  static Position fromBoard(List<int> pieces, int sidToMove) {
    var w = 0;
    var b = 0;
    var k = 0;
    for (var sq = 0; sq < numSquares; sq++) {
      switch (pieces[sq]) {
        case 1:
          w |= bit(sq);
        case 2:
          w |= bit(sq);
          k |= bit(sq);
        case -1:
          b |= bit(sq);
        case -2:
          b |= bit(sq);
          k |= bit(sq);
      }
    }
    final pos = Position._(
      whitePieces: w,
      blackPieces: b,
      kings: k,
      player: sidToMove,
      chainSq: -1,
      captured: 0,
      halfmove: 0,
      ply: 0,
    );
    pos._window.add(pos.hash());
    return pos;
  }

  @override
  String toString() {
    const sym = {1: 'w', 2: 'W', -1: 'b', -2: 'B', 0: '.'};
    final lines = <String>[];
    for (var r = 0; r < 8; r++) {
      final row = <String>[];
      for (var c = 0; c < 8; c++) {
        if ((r + c) % 2 == 1) {
          row.add(sym[pieceAt(rcSq[r * 8 + c])]!);
        } else {
          row.add(' ');
        }
      }
      lines.add('${8 - r} ${row.join(' ')}');
    }
    lines.add('  a b c d e f g h');
    lines.add('Navbat: ${player == white ? 'OQ' : 'QORA'}  ply=$ply  '
        'halfmove=$halfmove'
        '${chainSq >= 0 ? '  zanjir=${squareName(chainSq)}' : ''}');
    return lines.join('\n');
  }
}
