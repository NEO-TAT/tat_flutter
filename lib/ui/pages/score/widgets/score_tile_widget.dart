// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

typedef OnCategoryChanged = void Function(int? category);

class ScoreTile extends StatelessWidget {
  const ScoreTile({
    super.key,
    required String courseName,
    required String category,
    required String scoreValue
  })  : _courseName = courseName,
        _category = category,
        _scoreValue = scoreValue;

  /// The score value of a course.
  /// Note that we should make the score's type to be a [String] instead of [int] since the score can be a string like "Q".
  final String _scoreValue;
  final String _category;
  final String _courseName;

  Widget get _courseNameText => AutoSizeText(
        _courseName,
        style: const TextStyle(fontSize: 16.0),
      );

  Widget get _scoreValueText => SizedBox(
        width: 40,
        child: Text(
          _scoreValue,
          style: const TextStyle(fontSize: 16.0),
          textAlign: TextAlign.end,
        ),
      );

  Widget get _categoryValueText => SizedBox(
    width: 40,
    child: Text(
      _category,
      style: const TextStyle(fontSize: 16.0),
      textAlign: TextAlign.center,
    ),
  );

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: _courseNameText),
          _categoryValueText,
          _scoreValueText,
        ],
      );
}
