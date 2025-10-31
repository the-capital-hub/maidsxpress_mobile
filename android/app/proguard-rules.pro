# =============================================================================
# Flutter App Optimization - ProGuard Rules
# =============================================================================

# 🔹 Flutter Core Rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.Log { *; }
-keep class io.flutter.embedding.engine.systemchannels.** { *; }

# 🔹 Flutter Platform Channels
-keep class * extends io.flutter.plugin.common.MethodChannel
-keep class * extends io.flutter.plugin.common.EventChannel
-keep class * extends io.flutter.plugin.common.BasicMessageChannel

# 🔹 Dart VM and Flutter Engine
-keep class io.flutter.embedding.engine.dart.** { *; }
-keep class io.flutter.embedding.engine.FlutterEngine { *; }
-keep class io.flutter.embedding.engine.FlutterJNI { *; }

# 🔹 Aggressive Optimization Settings
-optimizations !code/simplification/arithmetic,!code/simplification/cast,!field/*,!class/merging/*
-optimizationpasses 5
-allowaccessmodification
-dontpreverify
-dontusemixedcaseclassnames
-dontskipnonpubliclibraryclasses
-verbose

# 🔹 Remove Debug Information
-assumenosideeffects class android.util.Log {
    public static boolean isLoggable(java.lang.String, int);
    public static int v(...);
    public static int i(...);
    public static int w(...);
    public static int d(...);
    public static int e(...);
}

# 🔹 Remove Unused Resources Aggressively
-dontwarn **
-ignorewarnings

# 🔹 Android Core Classes
-keep public class * extends android.app.Activity
-keep public class * extends android.app.Application
-keep public class * extends android.app.Service
-keep public class * extends android.content.BroadcastReceiver
-keep public class * extends android.content.ContentProvider
-keep public class * extends android.app.backup.BackupAgentHelper
-keep public class * extends android.preference.Preference

# 🔹 Keep Native Methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# 🔹 Keep Serializable Classes
-keepnames class * implements java.io.Serializable
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# 🔹 Keep Parcelable Classes
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# 🔹 Keep Enums
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# 🔹 Keep Annotations
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# 🔹 Firebase (if using)
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# 🔹 OkHttp/Retrofit (if using)
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn javax.annotation.**
-dontwarn org.conscrypt.**
-keepnames class okhttp3.internal.publicsuffix.PublicSuffixDatabase

# 🔹 Gson (if using)
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }
-keep class * extends com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# 🔹 Remove Unused Kotlin Metadata
-dontwarn kotlin.**
-dontwarn kotlinx.**
-assumenosideeffects class kotlin.jvm.internal.Intrinsics {
    static void checkParameterIsNotNull(java.lang.Object, java.lang.String);
}

# 🔹 Aggressive Resource Removal
-assumenosideeffects class java.io.PrintStream {
    public void println(%);
    public void println(**);
}

# 🔹 Remove Assertions
-assumenosideeffects class * {
    void assert*(...);
}

# 🔹 WebView (if not using, remove this section)
# -keep class android.webkit.WebView { *; }
# -keep class android.webkit.WebViewClient { *; }
# -keep class android.webkit.WebChromeClient { *; }

# 🔹 Custom Model Classes (ADD YOUR MODEL CLASSES HERE)
# Example:
# -keep class com.example.maidxpress.models.** { *; }
# -keep class com.example.maidxpress.data.** { *; }

# 🔹 Keep MainActivity and other Activities
-keep class com.maidsxpressservices.app.MainActivity { *; }

# 🔹 Crash Prevention Rules
-keep class * extends java.lang.Exception
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# 🔹 Network Security (if using network calls)
-keep class javax.net.ssl.** { *; }
-keep class org.apache.http.** { *; }

# 🔹 Final Cleanup Rules
-dontnote **
-dontwarn javax.annotation.**
-dontwarn javax.inject.**
-dontwarn sun.misc.Unsafe