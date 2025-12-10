plugins {
    id("com.android.application")
    id("com.google.gms.google-services")       // Firebase
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.shark.alshark"
    compileSdk = 36   // Use stable API, 36 is preview

    defaultConfig {
        applicationId = "com.shark.alshark"
        minSdk = 25
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Java & Desugaring support
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true      // IMPORTANT
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    buildTypes {
        getByName("debug") {
            isMinifyEnabled = false
            isShrinkResources = false
        }
        getByName("release") {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }


    // Required for flutter_local_notifications
    packaging {
        resources.excludes.add("/META-INF/{AL2.0,LGPL2.1}")
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Required for Java 8 APIs (flutter_local_notifications)
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")

    // Firebase BOM (manages all Firebase versions)
    implementation(platform("com.google.firebase:firebase-bom:33.6.0"))

    // Firebase services
    implementation("com.google.firebase:firebase-messaging")
    implementation("com.google.firebase:firebase-analytics")

    // Notification plugin (if using local notifications)
    // implementation("com.dexterous:flutter_local_notifications")  // Only if you need manual dependency — usually NOT required in Flutter
}
