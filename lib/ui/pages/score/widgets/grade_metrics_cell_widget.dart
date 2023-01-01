import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class GradeMetricsCell extends StatelessWidget {
  const GradeMetricsCell({
    super.key,
    required String name,
    required String value,
  })  : _name = name,
        _value = value;

  final String _name;
  final String _value;

  // TODO: improve the UI of this widget.
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(4.0),
        child: Center(
          child: AutoSizeText(
            '$_name: $_value',
            style: const TextStyle(fontSize: 16),
            maxLines: 1,
            textAlign: TextAlign.center,
          ),
        ),
      );
}
