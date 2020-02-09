/**
 * 通過自定義transitionsBuilder實現路由過渡動畫
 *
 * 請切換不同注釋分別查看
 */
import 'package:flutter/material.dart';

class CustomRoute extends PageRouteBuilder {
  final Widget widget;
  CustomRoute(this.widget)
      : super(
    transitionDuration: const Duration(seconds: 1),
    pageBuilder: (BuildContext context, Animation<double> animation,
        Animation<double> secondaryAnimation) {
      return widget;
    },
    transitionsBuilder: (BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget child) {
      //淡出過渡路由
      return FadeTransition(
        opacity: Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: animation, curve: Curves.fastOutSlowIn)),
        child: child,
      );

      //比例轉換路由
//          return ScaleTransition(
//            scale: Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
//                parent: animation, curve: Curves.fastOutSlowIn)),
//            child: child,
//            );

      //旋轉+比例轉換路由
//            return RotationTransition(
//              turns: Tween(begin: -1.0, end: 1.0).animate(CurvedAnimation(
//                  parent: animation, curve: Curves.fastOutSlowIn)),
//              child: ScaleTransition(
//                scale: Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
//                    parent: animation, curve: Curves.fastOutSlowIn)),
//                child: child,
//              ),
//            );

      //幻燈片路由
//            return SlideTransition(
//              position:
//                  Tween<Offset>(begin: Offset(0.0, -1.0), end: Offset(0.0, 0.0))
//                      .animate(CurvedAnimation(
//                          parent: animation, curve: Curves.fastOutSlowIn)),
//              child: child,
//            );
    },
  );
}