library;

int bit(int sq) => 1 << sq;

const int _deBruijn32 = 0x077CB531;

final List<int> _ctzTable = _buildCtzTable();

List<int> _buildCtzTable() {
  final table = List<int>.filled(32, 0);
  for (var i = 0; i < 32; i++) {
    final hash = ((1 << i) * _deBruijn32 & 0xFFFFFFFF) >>> 27;
    table[hash] = i;
  }
  return table;
}

int lowestBit(int x) {
  assert(x != 0, 'lowestBit(0) aniqlanmagan');
  final isolated = x & -x;
  return _ctzTable[(isolated * _deBruijn32 & 0xFFFFFFFF) >>> 27];
}


class SplitMix64 {
  SplitMix64(this._state);

  int _state;

  int next() {
    _state += 0x9E3779B97F4A7C15;
    var z = _state;
    z = (z ^ (z >>> 30)) * 0xBF58476D1CE4E5B9;
    z = (z ^ (z >>> 27)) * 0x94D049BB133111EB;
    return z ^ (z >>> 31);
  }
}
