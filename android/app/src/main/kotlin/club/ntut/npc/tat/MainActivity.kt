package club.ntut.npc.tat

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import androidx.annotation.NonNull
import io.flutter.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

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
            } else if (call.method == "restart_app") {
                //啟動flutter
                doRestart(context);
            } else {
                result.notImplemented()
            }
        }
    }

    fun doRestart(c: Context?) {
        try {
            //check if the context is given
            if (c != null) {
                //fetch the packagemanager so we can get the default launch activity
                // (you can replace this intent with any other activity if you want
                val pm: PackageManager = c.getPackageManager()
                //check if we got the PackageManager
                if (pm != null) {
                    //create the intent with the default start activity for your application
                    val mStartActivity: Intent? = pm.getLaunchIntentForPackage(
                            c.getPackageName()
                    )
                    if (mStartActivity != null) {
                        mStartActivity.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
                        //create a pending intent so the application is restarted after System.exit(0) was called.
                        // We use an AlarmManager to call this intent in 100ms
                        val mPendingIntentId = 223344
                        val mPendingIntent: PendingIntent = PendingIntent
                                .getActivity(c, mPendingIntentId, mStartActivity,
                                        PendingIntent.FLAG_CANCEL_CURRENT)
                        val mgr: AlarmManager = c.getSystemService(Context.ALARM_SERVICE) as AlarmManager
                        mgr.set(AlarmManager.RTC, System.currentTimeMillis() + 100, mPendingIntent)
                        //kill the application
                        System.exit(0)
                    } else {
                        Log.e(Tag, "Was not able to restart application, mStartActivity null")
                    }
                } else {
                    Log.e(Tag, "Was not able to restart application, PM null")
                }
            } else {
                Log.e(Tag, "Was not able to restart application, Context null")
            }
        } catch (ex: java.lang.Exception) {
            Log.e(Tag, "Was not able to restart application")
        }
    }

}
