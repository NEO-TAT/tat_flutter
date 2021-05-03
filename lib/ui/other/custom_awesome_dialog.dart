library awesome_dialog;

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:awesome_dialog/src/vertical_stack_header_dialog.dart';
import 'package:flutter/material.dart';

class CustomAwesomeDialog {
  /// [@required]
  final BuildContext context;

  /// Dialog Type can be INFO, WARNING, ERROR, SUCCES, NO_HEADER
  final DialogType dialogType;

  /// Widget with priority over DialogType, for a custom header widget
  final Widget customHeader;

  /// Dialog Title
  final String title;

  /// Set the description text of the dialog.
  final String desc;

  /// Create your own Widget for body, if this property is set title and description will be ignored.
  final Widget body;

  /// Btn OK props
  final String btnOkText;
  final IconData btnOkIcon;
  final Function btnOkOnPress;
  final Color btnOkColor;

  /// Btn Cancel props
  final String btnCancelText;
  final IconData btnCancelIcon;
  final Function btnCancelOnPress;
  final Color btnCancelColor;

  /// Custom Btn OK
  final Widget btnOk;

  /// Custom Btn Cancel
  final Widget btnCancel;

  /// Barrier Dissmisable
  final bool dismissOnTouchOutside;

  /// Callback to execute after dialog get dissmised
  final Function onDissmissCallback;

  /// Anim Type can be { SCALE, LEFTSLIDE, RIGHSLIDE, BOTTOMSLIDE, TOPSLIDE }
  final AnimType animType;

  /// Aligment of the Dialog
  final AlignmentGeometry aligment;

  /// Padding off inner content of Dialog
  final EdgeInsetsGeometry padding;

  /// This Prop is usefull to Take advantage of screen dimensions
  final bool isDense;

  /// Whenever the animation Header loops or not.
  final bool headerAnimationLoop;

  /// To use the Rootnavigator
  final bool useRootNavigator;

  /// For Autho Hide Dialog after some Duration.
  final Duration autoHide;

  ///Control if add or not the Padding EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom).
  final bool keyboardAware;

  ///Control if Dialog is dissmis by back key.
  final bool dismissOnBackKeyPress;

  ///Max with of entire Dialog.
  final double width;

  ///Border Radius for built in buttons.
  final BorderRadiusGeometry buttonsBorderRadius;

  /// Control if close icon is appear.
  final bool showCloseIcon;

  /// Custom closeIcon.
  final Widget closeIcon;

  /// Custom background color for dialog + header
  final Color dialogBackgroundColor;

  /// Set BorderSide of DialogShape
  final BorderSide borderSide;

  CustomAwesomeDialog({
    @required this.context,
    this.dialogType = DialogType.INFO,
    this.customHeader,
    this.title,
    this.desc,
    this.body,
    this.btnOk,
    this.btnCancel,
    this.btnOkText,
    this.btnOkIcon,
    this.btnOkOnPress,
    this.btnOkColor,
    this.btnCancelText,
    this.btnCancelIcon,
    this.btnCancelOnPress,
    this.btnCancelColor,
    this.onDissmissCallback,
    this.isDense = false,
    this.dismissOnTouchOutside = true,
    this.headerAnimationLoop = true,
    this.aligment = Alignment.center,
    this.animType = AnimType.SCALE,
    this.padding,
    this.useRootNavigator = false,
    this.autoHide,
    this.keyboardAware = true,
    this.dismissOnBackKeyPress = true,
    this.width,
    this.buttonsBorderRadius,
    this.showCloseIcon = false,
    this.closeIcon,
    this.dialogBackgroundColor,
    this.borderSide,
  }) : assert(
          context != null,
        );

  Widget get child {
    switch (animType) {
      case AnimType.SCALE:
        return ScaleFade(
            scale: 0.1,
            fade: true,
            curve: Curves.fastLinearToSlowEaseIn,
            child: _buildDialog);
        break;
      case AnimType.LEFTSLIDE:
        return FadeIn(from: SlideFrom.LEFT, child: _buildDialog);
        break;
      case AnimType.RIGHSLIDE:
        return FadeIn(from: SlideFrom.RIGHT, child: _buildDialog);
        break;
      case AnimType.BOTTOMSLIDE:
        return FadeIn(from: SlideFrom.BOTTOM, child: _buildDialog);
        break;
      case AnimType.TOPSLIDE:
        return FadeIn(from: SlideFrom.TOP, child: _buildDialog);
        break;
      default:
        return _buildDialog;
    }
  }

  Widget get _buildHeader {
    if (customHeader != null) return customHeader;
    if (dialogType == DialogType.NO_HEADER) return null;
    return FlareHeader(
      loop: headerAnimationLoop,
      dialogType: this.dialogType,
    );
  }

  Widget get _buildDialog => WillPopScope(
        onWillPop: _onWillPop,
        child: VerticalStackDialog(
          dialogBackgroundColor: dialogBackgroundColor,
          borderSide: borderSide,
          header: _buildHeader,
          title: this.title,
          desc: this.desc,
          body: this.body,
          isDense: isDense,
          alignment: aligment,
          keyboardAware: keyboardAware,
          width: width,
          padding: padding ?? EdgeInsets.only(left: 5, right: 5),
          btnOk: btnOk ?? (btnOkOnPress != null ? _buildFancyButtonOk : null),
          btnCancel: btnCancel ??
              (btnCancelOnPress != null ? _buildFancyButtonCancel : null),
          showCloseIcon: this.showCloseIcon,
          closeIcon: closeIcon,
          onClose: () {},
        ),
      );

  Widget get _buildFancyButtonOk => AnimatedButton(
        isFixedHeight: false,
        pressEvent: () {
          btnOkOnPress?.call();
        },
        text: btnOkText ?? 'Ok',
        color: btnOkColor ?? Color(0xFF00CA71),
        icon: btnOkIcon,
        borderRadius: buttonsBorderRadius,
      );

  Widget get _buildFancyButtonCancel => AnimatedButton(
        isFixedHeight: false,
        pressEvent: () {
          btnCancelOnPress?.call();
        },
        text: btnCancelText ?? 'Cancel',
        color: btnCancelColor ?? Colors.red,
        icon: btnCancelIcon,
        borderRadius: buttonsBorderRadius,
      );

  Future<bool> _onWillPop() async => dismissOnBackKeyPress;
}
