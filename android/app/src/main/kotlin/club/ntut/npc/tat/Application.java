package club.ntut.npc.tat;

import io.flutter.app.FlutterApplication;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingBackgroundService;
import io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingPlugin;

public class Application extends FlutterApplication implements PluginRegistry.PluginRegistrantCallback {
    @Override
    public void onCreate() {
        super.onCreate();
        FlutterFirebaseMessagingBackgroundService.setPluginRegistrant(this);
    }

    @Override
    public void registerWith(PluginRegistry registry) {

        //FlutterFirebaseMessagingPlugin.registerWith(registry.registrarFor("io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingPlugin"));
    }
}
