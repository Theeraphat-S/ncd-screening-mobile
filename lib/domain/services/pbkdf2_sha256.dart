import 'dart:typed_data';

import 'package:crypto/crypto.dart';

/// PBKDF2-HMAC-SHA256 (RFC 8018) tuned for many iterations.
///
/// A generic `Hmac(sha256, key).convert(u)` per iteration re-hashes the
/// padded key twice and allocates on every call (4 SHA-256 compressions per
/// iteration). Here the inner and outer key states are computed once, so an
/// iteration is exactly 2 compressions with no allocation. That is what
/// makes ≥100k iterations affordable on a low-end phone. Output is identical
/// to the generic construction (checked against RFC 7914 test vectors).
List<int> pbkdf2HmacSha256(
  List<int> password,
  List<int> salt,
  int iterations,
  int length,
) {
  if (iterations < 1) throw ArgumentError.value(iterations, 'iterations');
  final key = password.length > 64 ? sha256.convert(password).bytes : password;
  final padded = Uint8List(64)..setAll(0, key);

  final inner = Uint32List.fromList(_iv);
  final outer = Uint32List.fromList(_iv);
  final w = Uint32List(64);
  for (var i = 0; i < 16; i++) {
    w[i] = _readWord(padded, i * 4) ^ 0x36363636;
  }
  _compress(inner, w);
  for (var i = 0; i < 16; i++) {
    w[i] = _readWord(padded, i * 4) ^ 0x5c5c5c5c;
  }
  _compress(outer, w);

  final hmac = Hmac(sha256, password);
  final state = Uint32List(8);
  final u = Uint32List(8);
  final t = Uint32List(8);
  final out = BytesBuilder(copy: false);
  final blocks = (length + 31) ~/ 32;

  for (var block = 1; block <= blocks; block++) {
    // U1 = HMAC(P, S || INT(block)); the message length varies, so use the
    // generic HMAC for this one step.
    final first = Uint8List.fromList(hmac.convert([
      ...salt,
      (block >> 24) & 0xff,
      (block >> 16) & 0xff,
      (block >> 8) & 0xff,
      block & 0xff,
    ]).bytes);
    for (var i = 0; i < 8; i++) {
      u[i] = _readWord(first, i * 4);
      t[i] = u[i];
    }

    for (var j = 1; j < iterations; j++) {
      // inner = SHA256(K^ipad || U): one block, 32-byte message + padding.
      state.setAll(0, inner);
      w.setRange(0, 8, u);
      _padAfter32Bytes(w);
      _compress(state, w);
      // outer = SHA256(K^opad || inner)
      w.setRange(0, 8, state);
      _padAfter32Bytes(w);
      state.setAll(0, outer);
      _compress(state, w);
      for (var i = 0; i < 8; i++) {
        u[i] = state[i];
        t[i] ^= state[i];
      }
    }

    final bytes = Uint8List(32);
    for (var i = 0; i < 8; i++) {
      bytes[i * 4] = t[i] >> 24;
      bytes[i * 4 + 1] = t[i] >> 16;
      bytes[i * 4 + 2] = t[i] >> 8;
      bytes[i * 4 + 3] = t[i];
    }
    out.add(bytes);
  }
  return out.takeBytes().sublist(0, length);
}

int _readWord(Uint8List b, int o) =>
    (b[o] << 24) | (b[o + 1] << 16) | (b[o + 2] << 8) | b[o + 3];

/// Words 8–15 of a block whose message is 64 (key block) + 32 bytes.
void _padAfter32Bytes(Uint32List w) {
  w[8] = 0x80000000;
  for (var i = 9; i < 15; i++) {
    w[i] = 0;
  }
  w[15] = (64 + 32) * 8;
}

const _mask = 0xffffffff;

int _rotr(int x, int n) => ((x >> n) | (x << (32 - n))) & _mask;

/// SHA-256 compression of the 16 words in [w] into [h]. Uses w[16..63] as
/// scratch space.
void _compress(Uint32List h, Uint32List w) {
  for (var i = 16; i < 64; i++) {
    final w15 = w[i - 15];
    final w2 = w[i - 2];
    final s0 = _rotr(w15, 7) ^ _rotr(w15, 18) ^ (w15 >> 3);
    final s1 = _rotr(w2, 17) ^ _rotr(w2, 19) ^ (w2 >> 10);
    w[i] = (w[i - 16] + s0 + w[i - 7] + s1) & _mask;
  }

  var a = h[0], b = h[1], c = h[2], d = h[3];
  var e = h[4], f = h[5], g = h[6], hh = h[7];

  for (var i = 0; i < 64; i++) {
    final s1 = _rotr(e, 6) ^ _rotr(e, 11) ^ _rotr(e, 25);
    final ch = (e & f) ^ (~e & _mask & g);
    final t1 = (hh + s1 + ch + _k[i] + w[i]) & _mask;
    final s0 = _rotr(a, 2) ^ _rotr(a, 13) ^ _rotr(a, 22);
    final maj = (a & b) ^ (a & c) ^ (b & c);
    final t2 = (s0 + maj) & _mask;
    hh = g;
    g = f;
    f = e;
    e = (d + t1) & _mask;
    d = c;
    c = b;
    b = a;
    a = (t1 + t2) & _mask;
  }

  h[0] = h[0] + a;
  h[1] = h[1] + b;
  h[2] = h[2] + c;
  h[3] = h[3] + d;
  h[4] = h[4] + e;
  h[5] = h[5] + f;
  h[6] = h[6] + g;
  h[7] = h[7] + hh;
}

const _iv = [
  0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a, //
  0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19,
];

final _k = Uint32List.fromList(const [
  0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, //
  0x923f82a4, 0xab1c5ed5, 0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3,
  0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174, 0xe49b69c1, 0xefbe4786,
  0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
  0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147,
  0x06ca6351, 0x14292967, 0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13,
  0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85, 0xa2bfe8a1, 0xa81a664b,
  0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
  0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a,
  0x5b9cca4f, 0x682e6ff3, 0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208,
  0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2,
]);
