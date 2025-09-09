## Flutter/OkHttp/Gson/Retrofit common keep rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.embedding.**

# Keep models annotated for json_serializable
-keep class **$$JsonAdapter { *; }
-keep class **_JsonSerializable { *; }
-keep class com.google.gson.stream.** { *; }
-dontwarn sun.misc.**

# Retrofit/OkHttp (if used indirectly by packages)
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn javax.annotation.**
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }

# Keep Firebase Analytics (if present)
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Support for 16 KB memory page sizes (required for Android 15+)
-keep class com.masokotips.app.** { *; }
-keep class com.masokotips.app.MainActivity { *; }
-keep class com.masokotips.app.MainActivity$* { *; }

# Keep native methods for 16 KB page size support
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep JNI methods
-keepclasseswithmembernames class * {
    @android.webkit.JavascriptInterface <methods>;
}


