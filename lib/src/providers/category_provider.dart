import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_app/src/util/file_utils.dart';
import 'package:mime_type/mime_type.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoryProvider extends ChangeNotifier {
  CategoryProvider() {
    getHidden();
    getSort();
  }

  bool loading = false;
  final List<FileSystemEntity> downloads = [];
  final List<String> downloadTabs = [];

  final List<FileSystemEntity> images = [];
  final List<String> imageTabs = [];

  final List<FileSystemEntity> audio = [];
  final List<String> audioTabs = [];

  bool showHidden = false;
  int sort = 0;

  getDownloads() async {
    setLoading(true);
    downloadTabs.clear();
    downloads.clear();
    downloadTabs.add("All");
    final List<Directory> storages = await FileUtils.getStorageList();
    for (final dir in storages) {
      if (Directory("${dir.path}Download").existsSync()) {
        final List<FileSystemEntity> files = Directory("${dir.path}Download").listSync();
        for (final file in files) {
          if (FileSystemEntity.isFileSync(file.path)) {
            downloads.add(file);
            final tmpDownloadTabs = [...downloadTabs, file.path.split("/")[file.path.split("/").length - 2]]
              ..toSet().toList();
            downloadTabs
              ..clear()
              ..addAll(tmpDownloadTabs);
            notifyListeners();
          }
        }
      }
    }
    setLoading(false);
  }

  getImages(String type) async {
    setLoading(true);
    imageTabs.clear();
    images.clear();
    imageTabs.add("All");
    final List<FileSystemEntity> files = await FileUtils.getAllFiles(showHidden: showHidden);
    for (final file in files) {
      final mimeType = mime(file.path) ?? "";
      if (mimeType.split("/")[0] == type) {
        images.add(file);
        final tmpImageTabs = [...imageTabs, file.path.split("/")[file.path.split("/").length - 2]]..toSet().toList();
        imageTabs
          ..clear()
          ..addAll(tmpImageTabs);
      }
      notifyListeners();
    }
    setLoading(false);
  }

  getAudios(String type) async {
    setLoading(true);
    audioTabs.clear();
    audio.clear();
    audioTabs.add("All");
    final List<FileSystemEntity> files = await FileUtils.getAllFiles(showHidden: showHidden);
    for (final file in files) {
      final mimeType = mime(file.path);
      if (type == "text" && extension(file.path) == ".pdf") {
        audio.add(file);
      }
      if (mimeType != null) {
        if (mimeType.split("/")[0] == type) {
          audio.add(file);
          final tmpAudioTabs = [...audioTabs, file.path.split("/")[file.path.split("/").length - 2]]..toSet().toList();
          audioTabs
            ..clear()
            ..addAll(tmpAudioTabs);
        }
        notifyListeners();
      }
    }
    setLoading(false);
  }

  void setLoading(value) {
    loading = value;
    notifyListeners();
  }

  setHidden(value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("hidden", value);
    showHidden = value;
    notifyListeners();
  }

  getHidden() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool h = prefs.getBool("hidden") ?? false;
    setHidden(h);
  }

  Future setSort(value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt("sort", value);
    sort = value;
    notifyListeners();
  }

  getSort() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int h = prefs.getInt("sort") ?? 0;
    setSort(h);
  }
}
