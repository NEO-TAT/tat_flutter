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
    final String Tag = "BootLoaderActivity";

    final String patch_version_key = "flutter.patch_version";
    final String patch_version_now_key = "flutter.patch_version_now";
    final String flutter_state_key = "flutter.flutter_state";
    final String app_version_key = "flutter.version";

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

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.bootloader_activity);
        //創建補丁存放資料夾
        File dir = new File(getFilesDir(), "/flutter/hotfix");
        if (!dir.exists()) {
            if (dir.mkdirs()) {
                FlutterLogger.i("mkdirs success: " + dir.getAbsolutePath());
            } else {
                FlutterLogger.i("mkdirs failure: " + dir.getAbsolutePath());
            }
        } else {
            FlutterLogger.i("dirs exists: " + dir.getAbsolutePath());
        }
        SharedPreferences pref = getSharedPreferences("FlutterSharedPreferences", MODE_PRIVATE);
        String appVersionNow = getVersionName(getApplicationContext());
        String appVersionName = pref.getString(app_version_key, appVersionNow);
        boolean app_version_update = !appVersionName.contains(appVersionNow); //版本號不同刪除補丁
        FlutterLogger.i(String.format("app_version_now:%s app_version:%s %s", appVersionNow, appVersionName, app_version_update));
        boolean launch_success = pref.contains(flutter_state_key);
        if (!launch_success || app_version_update) {  //載入失敗刪除補丁或是app版本更新
            File dest = new File(dir, "hotfix.so");
            if (dest.delete()) {
                pref.edit().putInt(patch_version_now_key, 0).apply();  //代表補丁被刪除了
            }
            if (app_version_update) {
                pref.edit().putInt(patch_version_key, 0).apply();
            }
        }
        pref.edit().remove(flutter_state_key).apply(); //每次啟動會刪除由flutter重新寫入
        //更新補丁補丁
        try {
            File downloadDir = getApplicationContext().getExternalFilesDir(null);
            File source = new File(downloadDir, "hotfixed.so");
            FlutterLogger.i(source.getAbsolutePath());
            File dest = new File(dir, "hotfix.so");
            if (source.exists()) {  //檢查是否有要更新的補丁
                //寫入前將舊的補丁刪除
                if (dest.exists() && !dest.delete()) {
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
                FlutterManager.startInitialization(this, dest, FlutterVersion.VERSION_011400);
                int patch_update_version = pref.getInt(patch_version_key, 0);
                pref.edit().putInt(patch_version_now_key, patch_update_version).apply();  //更新實際執行補丁版本
            } else if (dest.exists()) {  //檢查是否有之前更新的補丁
                FlutterLogger.i("load fixed file finish: " + dest.getAbsolutePath());
                FlutterManager.startInitialization(this, dest, FlutterVersion.VERSION_011400);
            }
        } catch (Throwable error) {
            FlutterLogger.e("copy file error: " + error);
        }
        Intent intent = new Intent(this, MainActivity.class);
        BootLoaderActivity.this.startActivity(intent);
        BootLoaderActivity.this.finish();
    }


}
