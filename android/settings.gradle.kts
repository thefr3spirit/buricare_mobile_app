pluginManagement {
    // Locate the Flutter SDK and include its Gradle build logic
    val flutterSdkPath = run {
        val props = java.util.Properties().apply {
            file("local.properties").inputStream().use { load(it) }
        }
        props.getProperty("flutter.sdk")
            ?: error("flutter.sdk not set in local.properties")
    }
    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    // Where to look for plugins
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }

    // Bump Kotlin Gradle plugin to 1.9.10 so it can consume Firebase AARs compiled
    // with newer metadata (2.1.0)
    plugins {
        id("com.android.application")          version "8.7.0"  apply false
        id("org.jetbrains.kotlin.android")     version "1.10.0" apply false
        id("com.google.gms.google-services")   version "4.4.2"  apply false
        id("dev.flutter.flutter-gradle-plugin") version "1.0.0"  apply false
    }
}

rootProject.name = "buricare"
include(":app")
