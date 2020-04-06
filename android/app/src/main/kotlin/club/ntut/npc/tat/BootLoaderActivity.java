package club.ntut.npc.tat;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.os.Environment;
import android.view.FocusFinder;
import android.view.View;
import android.widget.Toast;

import androidx.annotation.Nullable;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.FileWriter;
import java.nio.channels.FileChannel;

import io.flutter.Log;
import io.flutter.embedding.engine.hotfix.FlutterLogger;
import io.flutter.embedding.engine.hotfix.FlutterManager;
import io.flutter.embedding.engine.hotfix.FlutterVersion;

import static android.os.Environment.getExternalStorageDirectory;

public class BootLoaderActivity extends Activity {
    final String Tag = "BootLoaderActivity";

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
        boolean launch_success = pref.contains("flutter_state");
        int version = pref.getInt("patch_version", 0);  //目前更新版本
        if (!launch_success) {  //載入失敗刪除補丁
            File dest = new File(dir, "hotfix.so");
            if (dest.delete()) {
                pref.edit().putInt("patch_version_now", 0).apply();  //代表補丁被刪除了
            }
        }
        pref.edit().remove("flutter_state").apply(); //每次啟動會刪除由flutter重新寫入
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
                pref.edit().putInt("patch_version_now", pref.getInt("patch_version", 0)).apply();  //更新實際執行補丁版本
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
