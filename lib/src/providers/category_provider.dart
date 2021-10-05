import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:mime_type/mime_type.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tat/src/util/file_utils.dart';

class CategoryProvider extends ChangeNotifier {
  CategoryProvider() {
    getHidden();
    getSort();
  }

  bool loading = false;
  final List<FileSystemEntity> downloads = [];
  List<String> downloadTabs = [];

  final List<FileSystemEntity> images = [];
  List<String> imageTabs = [];

  final List<FileSystemEntity> audio = [];
  List<String> audioTabs = [];

  bool showHidden = false;
  int sort = 0;

  Future<void> getDownloads() async {
    setLoading(true);
    downloadTabs.clear();
    downloads.clear();
    downloadTabs.add("All");
    final storages = await FileUtils.getStorageList();

    storages.forEach((dir) {
      if (Directory(dir.path + "Download").existsSync()) {
        final files = Directory(dir.path + "Download").listSync();
        print(files);

        files.forEach((file) {
          if (FileSystemEntity.isFileSync(file.path)) {
            downloads.add(file);
            downloadTabs
                .add(file.path.split("/")[file.path.split("/").length - 2]);
            downloadTabs = downloadTabs.toSet().toList();
            notifyListeners();
          }
        });
      }
    });

    setLoading(false);
  }

  Future<void> getImages(String type) async {
    setLoading(true);
    imageTabs.clear();
    images.clear();
    imageTabs.add("All");
    final files = await FileUtils.getAllFiles(showHidden: showHidden);

    files.forEach((file) {
      final String? mimeType = mime(file.path) == null ? "" : mime(file.path);

      if (mimeType!.split("/")[0] == type) {
        images.add(file);
        imageTabs
            .add("${file.path.split("/")[file.path.split("/").length - 2]}");
        imageTabs = imageTabs.toSet().toList();
      }

      notifyListeners();
    });

    setLoading(false);
  }

  Future<void> getAudios(String type) async {
    setLoading(true);
    audioTabs.clear();
    audio.clear();
    audioTabs.add("All");
    final files = await FileUtils.getAllFiles(showHidden: showHidden);

    files.forEach((file) {
      final String? mimeType = mime(file.path);

      if (type == "text" && extension(file.path) == ".pdf") {
        audio.add(file);
      }

      if (mimeType != null) {
        if (mimeType.split("/")[0] == type) {
          audio.add(file);
          audioTabs
              .add("${file.path.split("/")[file.path.split("/").length - 2]}");
          audioTabs = audioTabs.toSet().toList();
        }

        notifyListeners();
      }
    });

    setLoading(false);
  }

  void setLoading(value) {
    loading = value;
    notifyListeners();
  }

  Future<void> setHidden(value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("hidden", value);
    showHidden = value;
    notifyListeners();
  }

  Future<void> getHidden() async {
    final prefs = await SharedPreferences.getInstance();
    final bool? h =
        prefs.getBool("hidden") == null ? false : prefs.getBool("hidden");
    setHidden(h);
  }

  Future<void> setSort(value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt("sort", value);
    sort = value;
    notifyListeners();
  }

  Future<void> getSort() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? h = prefs.getInt("sort") == null ? 0 : prefs.getInt("sort");
    setSort(h);
  }
}
