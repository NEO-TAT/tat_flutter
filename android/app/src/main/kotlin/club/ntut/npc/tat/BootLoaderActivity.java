package club.ntut.npc.tat;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.os.Environment;
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
        //尋找是否有補丁
        try {
            File downloadDir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS);
            File source = new File(downloadDir, "hotfixed.so");
            File dest = new File(dir, "hotfix.so");
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
            if(source.delete()){
                FlutterLogger.i("delete patch");
            }
            FlutterLogger.i("copy fixed file finish: " + dest.getAbsolutePath());
            FlutterManager.startInitialization(this, dest, FlutterVersion.VERSION_011400);
        } catch (Throwable error) {
            FlutterLogger.e("copy file error: " + error);
        }
        Intent intent = new Intent(this, MainActivity.class);
        BootLoaderActivity.this.startActivity(intent);
        BootLoaderActivity.this.finish();
    }


}
