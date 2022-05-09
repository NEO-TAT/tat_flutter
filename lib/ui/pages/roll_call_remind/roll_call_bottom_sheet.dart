// TODO: remove sdk version selector after migrating to null-safety.
// @dart=2.16

import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// A function returns `void` and with no any parameters.
typedef VoidFunc = void Function();

class RollCallBottomSheet extends StatelessWidget {
  const RollCallBottomSheet({Key? key}) : super(key: key);

  Widget _buildCloseSheetButton(
    BuildContext context, {
    VoidFunc? onTab,
  }) =>
      GestureDetector(
        onTap: onTab,
        child: Container(
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.close,
            size: 24,
            color: Get.isDarkMode ? Theme.of(context).primaryColorLight : Theme.of(context).primaryColor,
          ),
        ),
      );

  BoxDecoration get _sheetDecoration => BoxDecoration();

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.symmetric(vertical: 24, horizontal: 12),
        child: Container(
          decoration: _sheetDecoration,
          child: Align(
            alignment: Alignment.topRight,
            child: _buildCloseSheetButton(
              context,
              onTab: () => Get.back(),
            ),
          ),
        ),
      );
}
