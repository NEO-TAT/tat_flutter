package club.ntut.npc.ntpu_tat

import android.content.Intent
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.Log

class MainActivity : FlutterActivity() {
    private val CHANNEL = "tat/global"
    private val logTag = "FlutterActivity"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "update_home_screen_weight" -> {
                    Log.i(logTag, "update_weight")
                    try {
                        val intend = Intent("android.appwidget.action.APPWIDGET_UPDATE")
                        this.sendBroadcast(intend)
                        result.success(true)
                    } catch (e: Exception) {
                        result.success(false)
                        Log.e(logTag, e.toString())
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
