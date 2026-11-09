# ONNX Runtime — Dart FFI orqali chaqiriladi, lekin AAR ichidagi Java
# sinflar native kod tomonidan JNI bilan izlanadi. R8 ularni olib
# tashlamasligi kerak.
-keep class ai.onnxruntime.** { *; }
-dontwarn ai.onnxruntime.**

# Flutter embedding — standart saqlash qoidalari.
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**
