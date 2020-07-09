library directory_picker;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/util/PermissionsUtil.dart';
import 'package:permission_handler/permission_handler.dart';

import 'directory_list.dart';

class DirectoryPicker {
  /// Opens a dialog to allow user to pick a directory.
  ///
  /// If [message] is non null then it is rendered when user denies to give
  /// external storage permission. A default message will be used if [message]
  /// is not specified. [rootDirectory] is the initial directory whose
  /// sub directories are shown for picking
  ///
  /// If [allowFolderCreation] is true then user will be allowed to create
  /// new folders directly from the picker. Make sure that you add write
  /// permission to manifest if you want to support folder creationa
  static Future<Directory> pick(
      {bool allowFolderCreation = false,
      @required BuildContext context,
      bool barrierDismissible = true,
      Color backgroundColor,
      @required Directory rootDirectory,
      String message,
      ShapeBorder shape}) async {
    assert(context != null, 'A non null context is required');

    if (Platform.isAndroid) {
      Directory directory = await showDialog<Directory>(
          context: context,
          useRootNavigator: false,
          barrierDismissible: barrierDismissible,
          builder: (BuildContext context) {
            return DirectoryPickerData(
                allowFolderCreation: allowFolderCreation,
                backgroundColor: backgroundColor,
                child: _DirectoryPickerDialog(),
                message: message,
                rootDirectory: rootDirectory,
                shape: shape);
          });

      return directory;
    } else {
      throw UnsupportedError('DirectoryPicker is only supported on android!');
    }
  }
}

class DirectoryPickerData extends InheritedWidget {
  final bool allowFolderCreation;
  final Color backgroundColor;
  final String message;
  final Directory rootDirectory;
  final ShapeBorder shape;

  DirectoryPickerData(
      {Widget child,
      this.allowFolderCreation,
      this.backgroundColor,
      this.message,
      this.rootDirectory,
      this.shape})
      : super(child: child);

  static DirectoryPickerData of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DirectoryPickerData>();
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return false;
  }
}

class _DirectoryPickerDialog extends StatefulWidget {
  @override
  _DirectoryPickerDialogState createState() => _DirectoryPickerDialogState();
}

class _DirectoryPickerDialogState extends State<_DirectoryPickerDialog>
    with WidgetsBindingObserver {
  static final double spacing = 8;
  static final Permission requiredPermission = Permission.storage;

  bool checkingForPermission;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    Future.delayed(Duration.zero).then((_) => _requestPermission());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  Future<void> _requestPermission() async {
    checkingForPermission = await PermissionsUtil.check(context);
    setState(() {});
  }

  Widget _buildBody(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    if (checkingForPermission == null) {
      return Padding(
          padding: EdgeInsets.all(spacing * 2),
          child: Column(
            children: <Widget>[
              CircularProgressIndicator(),
              SizedBox(height: spacing),
              Text(R.current.checkingPermission, textAlign: TextAlign.center)
            ],
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
          ));
    } else if (checkingForPermission) {
      return DirectoryList();
    } else {
      return Padding(
          padding: EdgeInsets.all(spacing * 2),
          child: Column(
            children: <Widget>[
              Text(message, textAlign: TextAlign.center),
              SizedBox(height: spacing),
              RaisedButton(
                  child: Text(R.current.grantPermission),
                  color: theme.primaryColor,
                  onPressed: _requestPermission)
            ],
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: data.backgroundColor,
      child: _buildBody(context),
      shape: data.shape,
    );
  }

  DirectoryPickerData get data => DirectoryPickerData.of(context);

  String get message {
    if (data.message == null) {
      return 'App needs read access to your device storage to load directories';
    } else {
      return data.message;
    }
  }
}
