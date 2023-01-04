import 'package:flutter/material.dart';
import 'package:flutter_app/src/r.dart';

class ScorePageAppBarActionButtons extends StatelessWidget {
  const ScorePageAppBarActionButtons({
    super.key,
    required VoidCallback onRefreshPressed,
    required VoidCallback onCalculateCreditPressed,
  })  : _onRefreshPressed = onRefreshPressed,
        _onCalculateCreditPressed = onCalculateCreditPressed;

  final VoidCallback _onRefreshPressed;
  final VoidCallback _onCalculateCreditPressed;

  Widget get _refreshButton => Tooltip(
        message: R.current.refresh,
        child: IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _onRefreshPressed,
        ),
      );

  Widget get _calculateCreditButton => Tooltip(
        message: R.current.calculationCredit,
        child: IconButton(
          icon: const Icon(Icons.calculate),
          onPressed: _onCalculateCreditPressed,
        ),
      );

  @override
  Widget build(BuildContext context) => Row(
        children: [
          _refreshButton,
          _calculateCreditButton,
        ],
      );
}
