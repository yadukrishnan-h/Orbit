# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# flutter_secure_storage
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# local_auth
-keep class io.flutter.plugins.localauth.** { *; }

# Google Tink Cryptography (Used by Keystore / Encrypted Preferences) [REV-004]
-keep class com.google.crypto.tink.** { *; }
-dontwarn com.google.crypto.tink.**

# Google Play Core (In-App Updates) [REV-004]
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# JNI Native Methods & C/C++ bindings [REV-004]
-keepclasseswithmembernames class * {
    native <methods>;
}
