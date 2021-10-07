import 'dart:io';
import 'dart:math';

import 'package:intl/intl.dart';
import 'package:mime_type/mime_type.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class FileUtils {
  static const String waPath = "/storage/emulated/0/WhatsApp/Media/.Statuses";

  /// Convert Byte to KB, MB, .......
  static String formatBytes(bytes, decimals) {
    if (bytes == 0) return "0.0 KB";
    final k = 1024,
        dm = decimals <= 0 ? 0 : decimals,
        sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'],
        i = (log(bytes) / log(k)).floor();
    return (((bytes / pow(k, i)).toStringAsFixed(dm)) + ' ' + sizes[i]);
  }

  /// Get mime information of a file
  static String? getMime(String path) {
    final file = File(path);
    final mimeType = mime(file.path);
    return mimeType;
  }

  /// Return all available Storage path
  static Future<List<Directory>> getStorageList() async {
    final List<Directory>? paths = await getExternalStorageDirectories();
    final List<Directory> filteredPaths = [];

    for (final dir in paths!) {
      filteredPaths.add(removeDataDirectory(dir.path));
    }

    return filteredPaths;
  }

  static Directory removeDataDirectory(String path) {
    return Directory(path.split("Android")[0]);
  }

  static Future<List<FileSystemEntity>> getFilesInPath(String path) async {
    final dir = Directory(path);
    return dir.listSync();
  }

  static Future<List<FileSystemEntity>> getAllFiles(
      {bool showHidden = false}) async {
    final List<Directory> storages = await getStorageList();
    final List<FileSystemEntity> files = [];

    for (final dir in storages) {
      files.addAll(await getAllFilesInPath(dir.path, showHidden: showHidden));
    }

    return files;
  }

  static Future<List<FileSystemEntity>> getRecentFiles(
      {bool showHidden = false}) async {
    final List<FileSystemEntity> files =
        await getAllFiles(showHidden: showHidden);

    files.sort((a, b) => File(a.path)
        .lastAccessedSync()
        .compareTo(File(b.path).lastAccessedSync()));
    return files.reversed.toList();
  }

  static Future<List<FileSystemEntity>> searchFiles(String query,
      {bool showHidden = false}) async {
    final List<Directory> storage = await getStorageList();
    final List<FileSystemEntity> files = [];

    for (final dir in storage) {
      final List<FileSystemEntity> fs =
          await getAllFilesInPath(dir.path, showHidden: showHidden);

      for (final fs in fs) {
        if (basename(fs.path).toLowerCase().contains(query.toLowerCase())) {
          files.add(fs);
        }
      }
    }
    return files;
  }

  /// Get all files
  static Future<List<FileSystemEntity>> getAllFilesInPath(String path,
      {bool showHidden = false}) async {
    final List<FileSystemEntity> files = [];
    final Directory d = Directory(path);
    final List<FileSystemEntity> l = d.listSync();

    for (final file in l) {
      if (FileSystemEntity.isFileSync(file.path)) {
        if (!showHidden) {
          if (!basename(file.path).startsWith(".")) {
            files.add(file);
          }
        } else {
          files.add(file);
        }
      } else {
        if (!file.path.contains("/storage/emulated/0/Android")) {
          if (!showHidden) {
            if (!basename(file.path).startsWith(".")) {
              files.addAll(
                await getAllFilesInPath(file.path, showHidden: showHidden),
              );
            }
          } else {
            files.addAll(
              await getAllFilesInPath(file.path, showHidden: showHidden),
            );
          }
        }
      }
    }

    return files;
  }

  static String formatTime(String iso) {
    final date = DateTime.parse(iso);
    final now = DateTime.now();
    final yDay = DateTime.now().subtract(Duration(days: 1));
    final dateFormat = DateTime.parse(
        "${date.year}-${date.month.toString().padLeft(2, "0")}-${date.day.toString().padLeft(2, "0")}T00:00:00.000Z");
    final today = DateTime.parse(
        "${now.year}-${now.month.toString().padLeft(2, "0")}-${now.day.toString().padLeft(2, "0")}T00:00:00.000Z");
    final yesterday = DateTime.parse(
        "${yDay.year}-${yDay.month.toString().padLeft(2, "0")}-${yDay.day.toString().padLeft(2, "0")}T00:00:00.000Z");

    if (dateFormat == today) {
      return "Today ${DateFormat("HH:mm").format(DateTime.parse(iso))}";
    } else if (dateFormat == yesterday) {
      return "Yesterday ${DateFormat("HH:mm").format(DateTime.parse(iso))}";
    } else {
      return "${DateFormat("MMM dd, HH:mm").format(DateTime.parse(iso))}";
    }
  }

  static List<FileSystemEntity> sortList(
    List<FileSystemEntity> list,
    int sort,
  ) {
    switch (sort) {
      case 0:
        if (list.toString().contains("Directory")) {
          list
            ..sort((f1, f2) => basename(f1.path)
                .toLowerCase()
                .compareTo(basename(f2.path).toLowerCase()));
          return list
            ..sort((f1, f2) => f1
                .toString()
                .split(":")[0]
                .toLowerCase()
                .compareTo(f2.toString().split(":")[0].toLowerCase()));
        } else {
          return list
            ..sort((f1, f2) => basename(f1.path)
                .toLowerCase()
                .compareTo(basename(f2.path).toLowerCase()));
        }

      case 1:
        list.sort((f1, f2) => basename(f1.path)
            .toLowerCase()
            .compareTo(basename(f2.path).toLowerCase()));
        if (list.toString().contains("Directory")) {
          list
            ..sort((f1, f2) => f1
                .toString()
                .split(":")[0]
                .toLowerCase()
                .compareTo(f2.toString().split(":")[0].toLowerCase()));
        }
        return list.reversed.toList();

      case 2:
        return list
          ..sort((f1, f2) => FileSystemEntity.isFileSync(f1.path) &&
                  FileSystemEntity.isFileSync(f2.path)
              ? File(f1.path)
                  .lastModifiedSync()
                  .compareTo(File(f2.path).lastModifiedSync())
              : 1);

      case 3:
        list
          ..sort((f1, f2) => FileSystemEntity.isFileSync(f1.path) &&
                  FileSystemEntity.isFileSync(f2.path)
              ? File(f1.path)
                  .lastModifiedSync()
                  .compareTo(File(f2.path).lastModifiedSync())
              : 1);
        return list.reversed.toList();

      case 4:
        list
          ..sort((f1, f2) => FileSystemEntity.isFileSync(f1.path) &&
                  FileSystemEntity.isFileSync(f2.path)
              ? File(f1.path).lengthSync().compareTo(File(f2.path).lengthSync())
              : 0);
        return list.reversed.toList();

      case 5:
        return list
          ..sort((f1, f2) => FileSystemEntity.isFileSync(f1.path) &&
                  FileSystemEntity.isFileSync(f2.path)
              ? File(f1.path).lengthSync().compareTo(File(f2.path).lengthSync())
              : 0);

      default:
        return list..sort();
    }
  }
}
