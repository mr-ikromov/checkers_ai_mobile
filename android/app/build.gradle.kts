import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Релиз имзоси uchun kalitlar `android/key.properties` da (git'ga kirmaydi).
// Fayl bo'lmasa, release debug kalit bilan imzolanadi — shunda
// `flutter run --release` sinov uchun baribir ishlaydi, lekin bunday
// APK/AAB ni Play Console qabul qilmaydi.
val keystoreProperties = Properties().apply {
    val file = rootProject.file("key.properties")
    if (file.exists()) {
        file.inputStream().use { load(it) }
    }
}
val hasReleaseKeystore = keystoreProperties.getProperty("storeFile") != null

android {
    namespace = "uz.deepcontrol.shashka"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "uz.deepcontrol.shashka"
        // ONNX Runtime 1.28 Android AAR minSdk 24 talab qiladi.
        minSdk = 24
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        resourceConfigurations += listOf("en", "ru", "uz")
    }

    signingConfigs {
        if (hasReleaseKeystore) {
            create("release") {
                storeFile = rootProject.file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseKeystore) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }

    packaging {
        jniLibs {
            // ONNX Runtime Dart'dan FFI orqali chaqiriladi, uning Java/JNI
            // ko'prigi ishlatilmaydi — har ABI uchun ~1 MB tejaladi.
            excludes += "**/libonnxruntime4j_jni.so"
            // Android 15+ 16 KB sahifa hajmi talabi: kutubxonalar APK ichida
            // siqilmagan va tekislangan holda turishi kerak.
            useLegacyPackaging = false
        }
        resources {
            excludes += listOf(
                "META-INF/*.kotlin_module",
                "META-INF/DEPENDENCIES",
                "META-INF/LICENSE*",
                "META-INF/NOTICE*",
            )
        }
    }

    bundle {
        // Play har qurilmaga faqat kerakli ABI va tilni yuboradi.
        abi { enableSplit = true }
        language { enableSplit = true }
        density { enableSplit = true }
    }

    androidResources {
        // ONNX modeli asset'dan fayl tizimiga nusxalanadi; siqib qo'yilsa
        // nusxalash sekinlashadi va hech qanday foyda bermaydi.
        noCompress += listOf("onnx", "data")
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
