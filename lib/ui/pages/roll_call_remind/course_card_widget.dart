// TODO: remove sdk version selector after migrating to null-safety.
// @dart=2.17

import 'package:flutter/material.dart';

class CourseCard extends StatelessWidget {
  const CourseCard({
    Key? key,
    required bool isDarkMode,
    required String courseName,
    required String teacherName,
    required String semesterName,
  })  : _isDarkMode = isDarkMode,
        _courseName = courseName,
        _teacherName = teacherName,
        _semesterName = semesterName,
        super(key: key);

  final bool _isDarkMode;
  final String _courseName;
  final String _teacherName;
  final String _semesterName;

  Widget _buildCourseInfoSection() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            child: Text(
              _courseName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),
          FittedBox(
            child: Row(
              children: [
                const Icon(
                  Icons.account_circle_outlined,
                  color: Colors.white,
                ),
                Text(
                  _teacherName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(width: 20),
                const Icon(
                  Icons.schedule,
                  color: Colors.white,
                ),
                Text(
                  _semesterName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      );

  Widget _buildHorizontalSideContainer({
    required Size size,
    required double ratio,
    required Color color,
    Radius leftRadius = Radius.zero,
    Radius rightRadius = Radius.zero,
    EdgeInsetsGeometry? padding,
    Widget? content,
  }) {
    final borderRadius = BorderRadius.horizontal(
      left: leftRadius,
      right: rightRadius,
    );
    return Material(
      borderRadius: borderRadius,
      elevation: 6,
      color: Colors.transparent,
      child: Container(
        width: size.width * ratio,
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          color: color,
        ),
        child: content,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return FittedBox(
      child: SizedBox(
        height: size.height * 0.25,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildHorizontalSideContainer(
                size: size,
                ratio: 0.7,
                color: _isDarkMode ? const Color(0xFF205375) : const Color(0xFF2155CD),
                leftRadius: const Radius.circular(15),
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                content: _buildCourseInfoSection(),
              ),
              _buildHorizontalSideContainer(
                size: size,
                ratio: 0.3,
                color: _isDarkMode ? const Color(0xFF112B3C) : const Color(0xFFE8F9FD),
                rightRadius: const Radius.circular(15),
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
