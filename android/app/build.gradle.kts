plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")      // version pulled from settings.gradle.kts
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.thefr3spirit.buricare"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        // Force both Java & Kotlin to target 1.8
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
        // Enable Java 8+ API desugaring for flutter_local_notifications, etc.
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        // Must match Java version above
        jvmTarget = JavaVersion.VERSION_1_8.toString()
    }

    defaultConfig {
        applicationId = "com.fr3spirit.buricare"
        minSdk     = 23
        targetSdk  = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Using debug signing for now
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:33.12.0"))
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-auth-ktx")
    implementation("com.google.firebase:firebase-firestore-ktx")
    // …other implementation(…) lines…

    // Must be at least 2.1.4 to satisfy flutter_local_notifications
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

// Process your google‑services.json
apply(plugin = "com.google.gms.google-services")
