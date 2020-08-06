package io.flutter.embedding.engine.hotfix;

import android.content.Context;
import android.os.Looper;

import java.io.File;

import io.flutter.embedding.engine.loader.FlutterLoader;
import io.flutter.embedding.engine.loader.FlutterLoaderV012000;
import io.flutter.view.FlutterMain;

public class FlutterManager {

    private static final String TAG = "FlutterManager";

    public static void startInitialization(Context context) {
        startInitialization(context, null);
    }

    public static void startInitialization(Context context, File aotFile) {
        startInitialization(context, aotFile, FlutterVersion.VERSION_012000);
    }

    public static void startInitialization(Context context, File aotFile, FlutterVersion version) {
        startInitialization(context, aotFile, version, new FlutterMain.Settings());
    }

    public static void startInitialization(Context context, File aotFile, FlutterVersion version, FlutterMain.Settings settings) {
        ensureInitializeOnMainThread();
        FlutterCallback flutterCallback = generateFlutterCallback(version);
        if (null != flutterCallback) {
            flutterCallback.startInitialization(context, aotFile, getFlutterLoaderSettings(settings));
        } else {
            FlutterLogger.w(TAG, "Flutter Version not supported: " + version);
            FlutterMain.startInitialization(context);
        }
    }

    private static void ensureInitializeOnMainThread() {
        if (Looper.myLooper() != Looper.getMainLooper()) {
            throw new IllegalStateException("startInitialization must be called on the main thread");
        }
    }

    private static FlutterLoader.Settings getFlutterLoaderSettings(FlutterMain.Settings settings) {
        FlutterLoader.Settings setting = new FlutterLoader.Settings();
        if (null != settings) {
            setting.setLogTag(settings.getLogTag());
        }
        return setting;
    }

    private static FlutterCallback generateFlutterCallback(FlutterVersion version) {
        if (FlutterVersion.VERSION_012000 == version) {
            return FlutterLoaderV012000.getInstance();
        }
        return null;
    }

    public interface FlutterCallback {
        void startInitialization(Context context, File aotFile, FlutterLoader.Settings settings);
    }
}
