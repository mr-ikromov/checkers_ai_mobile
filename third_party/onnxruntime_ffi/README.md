# onnxruntime_ffi

Dart FFI bindings for ONNX Runtime, vendored into this repository.

The Dart code comes from [`onnxruntime`](https://pub.dev/packages/onnxruntime)
(gtbluesky, MIT). Two changes were necessary, both measured on a real device:

1. **Model IR version.** The published package ships ONNX Runtime 1.15, which
   refuses IR v10 models with `Unsupported model IR version: 10, max supported
   version: 9`. The network used here is exported at IR v10.
2. **16 KB page size.** Its bundled `libonnxruntime.so` is 4 KB aligned
   (`2**12`). Google Play requires 16 KB alignment for apps targeting
   Android 15 and newer, so that binary cannot ship.

The native library is therefore taken from Microsoft's official
`com.microsoft.onnxruntime:onnxruntime-android:1.28.0` AAR, declared in
`android/build.gradle`. It supports IR v10 and is 16 KB aligned.

Everything the app does not use has been removed. What remains:

| File | Purpose |
|---|---|
| `src/bindings/` | ffigen-generated C API bindings |
| `src/ort_env.dart` | environment, allocator, API version |
| `src/ort_session.dart` | session from a memory buffer, session/run options |
| `src/ort_status.dart` | error handling |
| `src/ort_float_runner.dart` | **added here** — float32 fast path |

`ort_float_runner.dart` exists because the original tensor API allocates a
nested `List<double>` on every call. The search evaluates many positions per
move, so native buffers are allocated once and reused, with no boxing in
between.

Licence: MIT, see [LICENSE](LICENSE).
