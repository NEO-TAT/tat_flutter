package io.flutter.embedding.engine.hotfix;

import android.util.Log;

public class FlutterLogger {

    public static boolean logEnabled = true;

    public static String logTag = FlutterLogger.class.getSimpleName();


    public static void setLogEnabled(boolean enabled) {
        logEnabled = enabled;
    }

    public static void i(String msg) {
        i(logTag, msg);
    }

    public static void i(String tag, String msg) {
        if (logEnabled) {
            Log.i(tag, msg);
        }
    }

    public static void w(String msg) {
        w(logTag, msg);
    }

    public static void w(String tag, String msg) {
        if (logEnabled) {
            Log.w(tag, msg);
        }
    }

    public static void e(String msg) {
        e(logTag, msg);
    }

    public static void e(String tag, String msg) {
        if (logEnabled) {
            Log.e(tag, msg);
        }
    }
}
