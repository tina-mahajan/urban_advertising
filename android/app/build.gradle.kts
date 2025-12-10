// APP-LEVEL build.gradle.kts

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")

    // Flutter plugin
    id("dev.flutter.flutter-gradle-plugin")

    // Firebase Google Services plugin
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.urban_application"
    compileSdk = 36

    defaultConfig {
        applicationId = "com.example.urban_application"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false    // keep code shrinking off
            isShrinkResources = false  // <- ADD THIS LINE
        }
    }

}

flutter {
    source = "../.."
}

dependencies {
    // Firebase BoM (manages versions automatically)
    implementation(platform("com.google.firebase:firebase-bom:33.5.1"))
    // Add this (along with your other firebase libs)
    implementation("com.google.firebase:firebase-appcheck-playintegrity")

    // Firebase libraries
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.firebase:firebase-firestore")
    implementation("com.google.firebase:firebase-analytics")

    // Optional Firebase services:
    implementation("com.google.firebase:firebase-storage")
    implementation("com.google.firebase:firebase-messaging")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")

}
apply(plugin = "com.google.gms.google-services")
