package club.ntut.npc.tat

import android.content.Intent
import androidx.annotation.NonNull
import io.flutter.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import java.lang.Exception

class MainActivity : FlutterActivity() {
    private val channelName = "club.ntut.npc.tat.update.weight"
    private val Tag = "FlutterActivity"
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName).setMethodCallHandler { call, result ->
            if (call.method == "update_weight") {
                Log.i(Tag, "update_weight")
                try {
                    val intend = Intent("android.appwidget.action.APPWIDGET_UPDATE") //顯示意圖
                    context.sendBroadcast(intend)
                    result.success(true)
                } catch (e: Exception) {
                    result.success(false)
                    Log.e(Tag, e.toString())
                    //result.error("UNAVAILABLE", "Battery level not available.", null)
                }
            } else if (call.method == "close_app") {
                this.finish()
            } else {
                result.notImplemented()
            }
        }
    }
}
