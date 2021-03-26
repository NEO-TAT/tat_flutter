package club.ntut.npc.tat

import android.app.Activity
import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import androidx.annotation.NonNull
import com.anggrayudi.storage.file.DocumentFileCompat
import com.anggrayudi.storage.file.absolutePath
import io.flutter.Log
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import kotlin.system.exitProcess

class MainActivity : FlutterFragmentActivity() {
    private val methodChannelWidgetName = "club.ntut.npc.tat.widget"
    private val methodChannelSaveName = "club.ntut.npc.tat.save"
    private val DIRECTORY_CHOOSE_REQ_CODE = 42
    var pendingPickResult: MethodChannel.Result? = null
    private val logTag = "FlutterActivity"
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        //flutterEngine.plugins.remove(FlutterLocalNotificationsPlugin().javaClass)
        //flutterEngine.plugins.add(MyFlutterLocalNotificationsPlugin())
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, methodChannelWidgetName).setMethodCallHandler { call, result ->
            when (call.method) {
                "update_weight" -> {
                    Log.i(logTag, "update_weight")
                    try {
                        val intend = Intent("android.appwidget.action.APPWIDGET_UPDATE") //顯示意圖
                        this.sendBroadcast(intend)
                        result.success(true)
                    } catch (e: Exception) {
                        result.success(false)
                        Log.e(logTag, e.toString())
                        //result.error("UNAVAILABLE", "Battery level not available.", null)
                    }
                }
                "restart_app" -> {
                    doRestart(this)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, methodChannelSaveName).setMethodCallHandler { call, result ->
            when (call.method) {
                "choice_folder" -> {
                    Log.i(logTag, "choice_folder")
                    val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE)
                    startActivityForResult(intent, DIRECTORY_CHOOSE_REQ_CODE);
                    pendingPickResult = result
                }
                "get_path" -> {
                    val list = contentResolver.persistedUriPermissions.takeWhile { it.isReadPermission && it.isWritePermission }
                    if (list.isEmpty()) {
                        result.success(null)
                    }
                    val file = DocumentFileCompat.fromUri(this, list.first().uri);
                    Log.i(logTag, file?.absolutePath.toString())
                    result.success(file?.absolutePath.toString())
                    //result.success(list.first().uri.toString())
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    override fun onActivityResult(
            requestCode: Int, resultCode: Int,
            data: Intent?
    ) {
        super.onActivityResult(requestCode, resultCode, data)
        when (requestCode) {
            DIRECTORY_CHOOSE_REQ_CODE ->
                if (resultCode == Activity.RESULT_OK) {
                    data?.data?.also { uri ->
                        Log.d("flutter.store_path", uri.toString())
                        /*
                        if (uri.toString().toLowerCase(Locale.ROOT).contains("download")) {
                            pendingPickResult?.success(false)
                            return
                        }
                        */
                        val contentResolver = applicationContext.contentResolver
                        val takeFlags: Int = Intent.FLAG_GRANT_READ_URI_PERMISSION or
                                Intent.FLAG_GRANT_WRITE_URI_PERMISSION
                        contentResolver.takePersistableUriPermission(uri, takeFlags)
                        for (i in contentResolver.persistedUriPermissions) {
                            if (i.isReadPermission && i.isWritePermission && i.uri != uri) {
                                contentResolver.releasePersistableUriPermission(i.uri, takeFlags)
                            }
                        }
                        pendingPickResult?.success(true)
                        pendingPickResult = null
                    }
                } else {
                    pendingPickResult?.success(false)
                    pendingPickResult = null
                }
        }
    }


    private fun doRestart(c: Context?) {
        try {
            //check if the context is given
            if (c != null) {
                //fetch the packageManager so we can get the default launch activity
                // (you can replace this intent with any other activity if you want
                val pm: PackageManager = c.packageManager
                //check if we got the PackageManager
                //create the intent with the default start activity for your application
                val mStartActivity: Intent? = pm.getLaunchIntentForPackage(
                        c.packageName
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
                    exitProcess(0)
                } else {
                    Log.e(logTag, "Was not able to restart application, mStartActivity null")
                }
            } else {
                Log.e(logTag, "Was not able to restart application, Context null")
            }
        } catch (ex: java.lang.Exception) {
            Log.e(logTag, "Was not able to restart application")
        }
    }

}
