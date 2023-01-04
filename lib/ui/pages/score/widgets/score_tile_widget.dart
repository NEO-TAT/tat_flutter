// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/src/model/course/course_score_json.dart';

typedef OnCategoryChanged = void Function(int? category);

class ScoreTile extends StatelessWidget {
  ScoreTile({
    super.key,
    required String courseName,
    required String category,
    required String scoreValue,
    OnCategoryChanged? onCategoryChanged,
  })  : _courseName = courseName,
        _category = category,
        _scoreValue = scoreValue,
        _onCategoryChanged = onCategoryChanged;

  /// The score value of a course.
  /// Note that we should make the score's type to be a [String] instead of [int] since the score can be a string like "Q".
  final String _scoreValue;
  final String _category;
  final String _courseName;
  final OnCategoryChanged? _onCategoryChanged;

  final ValueNotifier<int?> _selectedCategory = ValueNotifier(null);

  int? _getInitialCategoryIndex() {
    final index = constCourseType.indexOf(_category);
    return index == -1 ? null : index;
  }

  Widget get _courseNameText => AutoSizeText(
        _courseName,
        style: const TextStyle(fontSize: 16.0),
      );

  Widget get _categoryMenu => ValueListenableBuilder(
        valueListenable: _selectedCategory,
        builder: (_, value, __) => DropdownButton(
          underline: const SizedBox.shrink(),
          value: value ?? _getInitialCategoryIndex(),
          items: constCourseType
              .asMap()
              .entries
              .map((category) => _buildCategoryMenuItem(category.value, category.key))
              .toList(),
          onChanged: (newCategory) {
            _selectedCategory.value = newCategory;
            _onCategoryChanged?.call(newCategory);
          },
        ),
      );

  Widget get _scoreValueText => SizedBox(
        width: 40,
        child: Text(
          _scoreValue,
          style: const TextStyle(fontSize: 16.0),
          textAlign: TextAlign.end,
        ),
      );

  DropdownMenuItem<int> _buildCategoryMenuItem(String category, int index) => DropdownMenuItem(
        value: index,
        child: Text(
          category,
          style: const TextStyle(fontSize: 16.0),
        ),
      );

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: _courseNameText),
          if (_category.isNotEmpty) _categoryMenu,
          _scoreValueText,
        ],
      );
}
