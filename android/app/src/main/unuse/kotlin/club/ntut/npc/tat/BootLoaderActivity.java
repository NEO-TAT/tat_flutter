package club.ntut.npc.tat;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.os.Bundle;
import androidx.annotation.Nullable;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.FileWriter;
import java.nio.channels.FileChannel;

import io.flutter.embedding.engine.hotfix.FlutterLogger;
import io.flutter.embedding.engine.hotfix.FlutterManager;
import io.flutter.embedding.engine.hotfix.FlutterVersion;

public class BootLoaderActivity extends Activity {
    //final String Tag = "BootLoaderActivity";

    final String flutter_state_key = "flutter.flutter_state";  //會刪除由flutter app寫入如果檢查到沒寫入代表app crash，會清除補丁
    final String app_version_key = "flutter.version";  //取得之前執行APP版本
    final String app_patch_version = "flutter.patch_version";
    final String hotfixFileName = "hotfix.so";

    SharedPreferences pref;
    File dir;

    public String getVersionName(Context context) {
        PackageManager packageManager = context.getPackageManager();
        PackageInfo packageInfo;
        String versionName = "";
        try {
            packageInfo = packageManager.getPackageInfo(context.getPackageName(), 0);
            versionName = packageInfo.versionName;
        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
        }
        return versionName;
    }

    void checkPatchDir() {
        if (!dir.exists()) {
            if (dir.mkdirs()) {
                FlutterLogger.i("mkdirs success: " + dir.getAbsolutePath());
            } else {
                FlutterLogger.i("mkdirs failure: " + dir.getAbsolutePath());
            }
        } else {
            FlutterLogger.i("dirs exists: " + dir.getAbsolutePath());
        }
    }

    void handleAppVersionUpdate() {
        String appVersionNow = getVersionName(getApplicationContext());
        String appVersionName = pref.getString(app_version_key, appVersionNow);
        boolean app_version_update = !appVersionName.contains(appVersionNow); //版本號不同刪除補丁
        if (app_version_update) {  //app版本更新
            File dest = new File(dir, hotfixFileName);
            try {
                if (dest.exists() && !dest.delete()) {  //刪除舊的補釘
                    FileWriter writer = new FileWriter(dest, false);
                    writer.write("");
                    writer.flush();
                    writer.close();
                }
                pref.edit().remove(app_patch_version).apply();
            } catch (Exception e) {
                FlutterLogger.i("delete fail");
            }
        }
    }

    void handleAppCrash() {
        boolean launch_success = pref.contains(flutter_state_key);  //如果flutter沒有正常啟動就不會寫入
        if (!launch_success) {  //載入失敗刪除補丁
            File dest = new File(dir, hotfixFileName);
            try {
                if (dest.exists() && !dest.delete()) {  //刪除舊的補釘
                    FileWriter writer = new FileWriter(dest, false);
                    writer.write("");
                    writer.flush();
                    writer.close();
                }
            } catch (Exception e) {
                FlutterLogger.i("delete fail");
            }
        }
        pref.edit().remove(flutter_state_key).apply(); //每次啟動會刪除由flutter重新寫入
    }


    void handlePatchUpdate() {
        try {
            File downloadDir = getApplicationContext().getExternalFilesDir(null);
            File source = new File(downloadDir, hotfixFileName);
            File dest = new File(dir, hotfixFileName);
            if (source.exists()) {  //檢查是否有要更新的補丁
                //寫入前將舊的補丁刪除
                if (dest.exists() && !dest.delete()) {  //刪除舊的補釘
                    FileWriter writer = new FileWriter(dest, false);
                    writer.write("");
                    writer.flush();
                    writer.close();
                }
                FileChannel inputChannel = new FileInputStream(source).getChannel();
                FileChannel outputChannel = new FileOutputStream(dest).getChannel();
                outputChannel.transferFrom(inputChannel, 0, inputChannel.size());
                inputChannel.close();
                outputChannel.close();
                if (source.delete()) {
                    FlutterLogger.i("delete patch");
                }
                FlutterLogger.i("copy fixed file finish: " + dest.getAbsolutePath());
            }
        } catch (Throwable error) {
            FlutterLogger.e("copy file error: " + error);
        }
    }


    void loadPatch() {
        File dest = new File(dir, hotfixFileName);
        if (dest.exists()) {  //檢查如果補釘存在就載入
            FlutterManager.startInitialization(this, dest, FlutterVersion.VERSION_012000);
        }
    }


    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        pref = getSharedPreferences("FlutterSharedPreferences", MODE_PRIVATE);
        dir = new File(getFilesDir(), "/flutter/hotfix");  //更新目錄
        setContentView(R.layout.bootloader_activity);
        //創建補丁存放資料夾
        checkPatchDir();
        //app版本更新刪除patch
        handleAppVersionUpdate();
        //處理更新補釘後app無法開啟
        handleAppCrash();
        //檢查補釘是否要更新
        handlePatchUpdate();
        //載入補釘
        loadPatch();
        //啟動flutter
        Intent intent = new Intent(this, MainActivity.class);
        BootLoaderActivity.this.startActivity(intent);
        BootLoaderActivity.this.finish();
    }


}
