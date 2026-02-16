# Flutter specific rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep Google Fonts
-keep class com.google.android.gms.** { *; }

# Keep Supabase
-keep class io.supabase.** { *; }

# Prevent R8 from stripping interface information
-keepattributes Signature
-keepattributes *Annotation*
