import 'package:flutter/material.dart';
import 'package:flutter_app/src/r.dart';

class ScoreCalculationWarning extends StatelessWidget {
  const ScoreCalculationWarning({super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(5),
        child: Row(
          children: [
            Expanded(
              child: Text(
                R.current.scoreCalculationWarning,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
}
