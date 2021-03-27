//  listview_animator.dart
//  北科課程助手
//  用於顯示動畫
//  Created by morris13579 on 2020/02/12.
//  Copyright © 2020 morris13579 All rights reserved.
//

import 'dart:async';

import 'package:flutter/cupertino.dart';

class Animator extends StatefulWidget {
  final Widget child;
  final Duration time;

  Animator(this.child, this.time);

  @override
  _AnimatorState createState() => _AnimatorState();
}

class _AnimatorState extends State<Animator>
    with SingleTickerProviderStateMixin {
  Timer timer;
  AnimationController animationController;
  Animation animation;

  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(duration: Duration(milliseconds: 290), vsync: this);
    animation =
        CurvedAnimation(parent: animationController, curve: Curves.easeInOut);
    timer = Timer(widget.time, animationController.forward);
  }

  @override
  void dispose() {
    timer.cancel();
    animationController.dispose();
    super.dispose(); //需要先dispose上面兩個才不會出錯
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      child: widget.child,
      builder: (BuildContext context, Widget child) {
        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(0.0, (1 - animation.value) * 20),
            child: child,
          ),
        );
      },
    );
  }
}

Timer timer;
Duration duration = Duration();

wait() {
  if (timer == null || !timer.isActive) {
    timer = Timer(Duration(microseconds: 120), () {
      duration = Duration();
    });
  }
  duration += Duration(milliseconds: 100);
  return duration;
}

class WidgetAnimator extends StatelessWidget {
  final Widget child;

  WidgetAnimator(this.child);

  @override
  Widget build(BuildContext context) {
    return Animator(child, wait());
  }
}
