package weight;
import android.annotation.SuppressLint;
import android.app.PendingIntent;
import android.appwidget.AppWidgetManager;
import android.appwidget.AppWidgetProvider;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Bundle;
import android.os.Environment;
import android.widget.RemoteViews;
import android.widget.Toast;
import java.util.Arrays;
import club.ntut.npc.tat.MainActivity;
import club.ntut.npc.tat.R;
import io.flutter.Log;


public class CourseWidgetProvider extends AppWidgetProvider {
    public static final  String TAG = "CourseWidgetProvider";
    public static final String ACTION_ONCLICK = "club.ntut.npc.tat.weight.onclick";

    @SuppressLint("UnsafeProtectedBroadcastReceiver")
    @Override
    public void onReceive(Context context, Intent intent) {
        super.onReceive(context, intent);
        Log.i(TAG, "【onReceive，其他所有回調方法都是由它調用的】");
        //這裡判斷是自己的action，做自己的事情，比如小工具被點擊了要幹啥
        if (ACTION_ONCLICK.equals(intent.getAction())) {
            //Toast.makeText(context, "開啟app", Toast.LENGTH_LONG).show();
            Intent actIntent = new Intent(context, MainActivity.class);
            actIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK | Intent.FLAG_ACTIVITY_TASK_ON_HOME);
            context.startActivity(actIntent);
        }
    }

    @Override
    public void onUpdate(Context context, AppWidgetManager appWidgetManager, int[] appWidgetIds) {
        super.onUpdate(context,appWidgetManager,appWidgetIds);
        //根據 updatePeriodMillis 定義的時間定期調用該函數，此外當用戶添加 Widget 時也會調用該函數，可以在這裡進行必要的初始化操作。
        Log.i(TAG, "【onUpdate，當插件內容更新函數時調用，最重要的方法】" + Arrays.toString(appWidgetIds));
        for (int appWidgetId : appWidgetIds) {
            RemoteViews remoteViews = new RemoteViews(context.getPackageName(), R.layout.course_widget);
            Intent actionIntent = new Intent(context, CourseWidgetProvider.class);//顯示意圖
            actionIntent.setAction(CourseWidgetProvider.ACTION_ONCLICK);
            //actionIntent.setPackage(context.getPackageName());//隱式意圖必須設置Package，實際測試發現，如果使用隱式意圖，在應用被殺掉時不響應廣播
            PendingIntent pIntent = PendingIntent.getBroadcast(context, 0, actionIntent, PendingIntent.FLAG_UPDATE_CURRENT);
            remoteViews.setOnClickPendingIntent(R.id.course_widget_table, pIntent);
            String path = context.getFilesDir().getPath() + "/course_weight.png";
            Log.i(TAG, path);
            BitmapFactory.Options options = new BitmapFactory.Options();
            options.inPreferredConfig = Bitmap.Config.RGB_565;
            Bitmap bitmap = BitmapFactory.decodeFile( path , options);
            remoteViews.setImageViewBitmap(R.id.course_table_image, bitmap);//时间
            appWidgetManager.updateAppWidget(appWidgetId, remoteViews);
        }
    }

    @Override
    public void onEnabled(Context context) {
        super.onEnabled(context);
        Log.i(TAG, "【onEnabled，當 Widget 第一次被添加時調用】");
        //例如用戶添加了兩個你的 Widget，那麼只有在添加第一個 Widget 時該方法會被調用，該方法適合執行你所有 Widgets 只需進行一次的操作
    }

    @Override
    public void onDisabled(Context context) {
        super.onDisabled(context);
        Log.i(TAG, "【onDisabled，當你的最後一個 Widget 被刪除時調用】");//該方法適合用來清理之前在 onEnabled() 中進行的操作
    }

    @Override
    public void onDeleted(Context context, int[] appWidgetIds) {
        super.onDeleted(context, appWidgetIds);
        Log.i(TAG, "【onDeleted，當 Widget 被刪除時調用】" + Arrays.toString(appWidgetIds));
    }

    @Override
    public void onRestored(Context context, int[] oldWidgetIds, int[] newWidgetIds) {
        super.onRestored(context, oldWidgetIds, newWidgetIds);
        Log.i(TAG, "【onRestored，被還原是調用】舊" + Arrays.toString(oldWidgetIds) + "，新" + Arrays.toString(newWidgetIds));
    }

    @Override
    public void onAppWidgetOptionsChanged(Context context, AppWidgetManager appWidgetManager, int appWidgetId, Bundle newOptions) {
        super.onAppWidgetOptionsChanged(context, appWidgetManager, appWidgetId, newOptions);
        RemoteViews remoteViews = new RemoteViews(context.getPackageName(), R.layout.course_widget);
        Log.i(TAG, "【onAppWidgetOptionsChanged，當 Widget 第一次被添加或者大小發生變化時調用】");
    }
}
