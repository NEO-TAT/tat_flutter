import 'package:flutter/material.dart';

class MetricsTitle extends StatelessWidget {
  const MetricsTitle({
    super.key,
    required String title,
  }) : _title = title;

  final String _title;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              _title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Divider(
            color: Theme.of(context).dividerColor,
          ),
        ],
      );
}
