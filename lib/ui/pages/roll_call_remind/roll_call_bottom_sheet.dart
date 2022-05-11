// TODO: remove sdk version selector after migrating to null-safety.
// @dart=2.16

import 'package:flutter/material.dart';
import 'package:flutter_app/ui/pages/roll_call_remind/course_card_widget.dart';
import 'package:get/get.dart';

class RollCallBottomSheet extends StatelessWidget {
  const RollCallBottomSheet({Key? key}) : super(key: key);

  Widget _buildCloseSheetButton(
    BuildContext context, {
    VoidCallback? onTab,
  }) =>
      GestureDetector(
        onTap: onTab,
        child: Container(
          padding: const EdgeInsets.all(4),
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

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          Positioned(
            right: 12,
            top: 12,
            child: _buildCloseSheetButton(
              context,
              onTab: () => Get.back(),
            ),
          ),
          Container(
            alignment: Alignment.bottomCenter,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 0,
                  height: 32,
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
                    child: ListView.builder(
                      itemCount: 12,
                      itemBuilder: (context, index) {
                        return CourseCard(
                          courseName: "TEST",
                          teacherName: "Daniel",
                          semesterName: "110-2",
                          isDarkMode: Get.isDarkMode,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
}
