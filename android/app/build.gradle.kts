plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.nexora.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.nexora.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

tasks.matching { it.name == "assembleDebug" || it.name == "assembleRelease" }.configureEach {
    doLast {
        val variant = name.removePrefix("assemble").lowercase()
        val builtApk = project.layout.buildDirectory
            .dir("outputs/apk/$variant")
            .get()
            .asFile
            .resolve("app-$variant.apk")
        val targetDir = project.layout.buildDirectory
            .dir("outputs/flutter-apk")
            .get()
            .asFile
        if (builtApk.exists()) {
            targetDir.mkdirs()
            builtApk.copyTo(targetDir.resolve("Nexora.apk"), overwrite = true)

            // Copia lista para pasar al teléfono desde la raíz del proyecto.
            val compiledDir = rootProject.projectDir.parentFile.resolve("Compilado")
            compiledDir.mkdirs()
            builtApk.copyTo(compiledDir.resolve("Nexora.apk"), overwrite = true)
            compiledDir.resolve("LEEME.txt").writeText(
                "Nexora - instalación en Android\n\n" +
                    "Copia Nexora.apk al teléfono y ábrelo para instalar. Si Android lo solicita, " +
                    "permite instalar aplicaciones de esta fuente.\n\n" +
                    "Por ADB: adb install -r Nexora.apk\n",
            )
        }
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
