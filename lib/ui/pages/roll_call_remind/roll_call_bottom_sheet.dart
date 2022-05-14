import 'package:flutter/material.dart';
import 'package:flutter_app/src/controllers/zuvio_course_controller.dart';
import 'package:flutter_app/ui/pages/roll_call_remind/new_roll_call_monitor_card_widget.dart';
import 'package:get/get.dart';

class RollCallBottomSheet extends StatelessWidget {
  const RollCallBottomSheet({super.key});

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

  Widget get _courseCardList {
    final isDarkMode = Get.isDarkMode;
    return GetBuilder<ZCourseController>(
      builder: (controller) => ListView.builder(
        itemCount: controller.courses.length,
        itemBuilder: (_, index) {
          final course = controller.courses[index];
          return NewRollCallMonitorCard(
            courseName: course.name,
            teacherName: course.teacherName,
            semesterName: course.semesterName,
            isDarkMode: isDarkMode,
            onAddMonitorPressed: (weekday, startTime, endTime) => controller.addScheduledMonitor(),
          );
        },
      ),
    );
  }

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
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: _courseCardList,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
}
