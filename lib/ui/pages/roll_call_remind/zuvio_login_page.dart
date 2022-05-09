// TODO: remove sdk version selector after migrating to null-safety.
// @dart=2.16

import 'dart:math';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/controllers/zuvio_auth_controller.dart';
import 'package:get/get.dart';

/// A function to be invoked after logged in successfully.
typedef LoginSuccessAction = void Function();

/// A function to be invoked after login canceled.
typedef CancelLoginAction = void Function();

/// A function to called when content of a [TextFormField] or [TextField] changed.
typedef TextFieldValidator = String? Function(String?);

class ZuvioLoginPage extends StatefulWidget {
  const ZuvioLoginPage({
    Key? key,
    LoginSuccessAction? onLoginSuccess,
    CancelLoginAction? onPageClose,
  })  : _onPageClose = onPageClose,
        _onLoginSuccess = onLoginSuccess,
        super(key: key);

  final LoginSuccessAction? _onLoginSuccess;
  final CancelLoginAction? _onPageClose;

  @override
  State<ZuvioLoginPage> createState() => _ZuvioLoginPageState();
}

class _ZuvioLoginPageState extends State<ZuvioLoginPage> {
  late final TextEditingController _userNameInputBoxController;
  late final TextEditingController _passwordInputBoxController;

  final _closeButtonSize = 24.0;
  final _loginFormKey = GlobalKey<FormState>();
  final _showPassword = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _userNameInputBoxController = TextEditingController();
    _passwordInputBoxController = TextEditingController();
  }

  @override
  void dispose() {
    _userNameInputBoxController.dispose();
    _passwordInputBoxController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    final isValidate = _loginFormKey.currentState?.validate() ?? false;
    if (!isValidate) {
      return;
    }

    final username = _userNameInputBoxController.text.trim();
    final password = _passwordInputBoxController.text;

    ZAuthController.to.login(username, password);
  }

  void _handleLoginCallBack() {
    if (ZAuthController.to.isLoggedIntoZuvio()) {
      widget._onLoginSuccess?.call();
    }
  }

  String? _emailValidator(String? rawData) {
    if (rawData == null || rawData.isEmpty) {
      return R.current.accountNull;
    }

    final isValid = EmailValidator.validate(rawData.trim());
    return isValid ? null : R.current.error;
  }

  String? _passwordValidator(String? rawData) => (rawData == null || rawData.isEmpty) ? R.current.passwordNull : null;

  Widget _buildLoginButton({required bool enabled}) => Padding(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 0),
        child: ElevatedButton.icon(
          onPressed: enabled ? _onLoginPressed : null,
          style: ElevatedButton.styleFrom(
            primary: Color(0xFFFF6363),
            onSurface: Colors.black12,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0),
            ),
          ),
          icon: Icon(Icons.login),
          label: Text(R.current.login),
        ),
      );

  Widget get _boxTitle => Padding(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 0),
        child: Text(
          R.current.login + ' Zuvio',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black54,
          ),
        ),
      );

  BoxDecoration get _boxDecoration => BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        color: Color(0xFFFAF5E4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      );

  Widget _buildEmailTextField({required bool enabled}) => _InputBox(
        controller: _userNameInputBoxController,
        keyboardType: TextInputType.emailAddress,
        icon: Icons.account_circle_rounded,
        hintText: R.current.account,
        enabled: enabled,
        validator: _emailValidator,
      );

  Widget _buildPasswordTextField({required bool enabled}) => ValueListenableBuilder<bool>(
        valueListenable: _showPassword,
        builder: (context, value, child) => _InputBox(
          controller: _passwordInputBoxController,
          keyboardType: TextInputType.visiblePassword,
          icon: Icons.lock,
          hintText: R.current.password,
          obscure: !_showPassword.value,
          enabled: enabled,
          validator: _passwordValidator,
          suffixIcon: IconButton(
            icon: Icon(
              _showPassword.value ? Icons.visibility : Icons.visibility_off,
              color: Theme.of(context).primaryColorDark,
            ),
            onPressed: () => _showPassword.value = !_showPassword.value,
          ),
        ),
      );

  Widget get _loginBox => Padding(
        padding: const EdgeInsets.all(18),
        child: Container(
          decoration: _boxDecoration,
          child: Padding(
            padding: EdgeInsets.all(20),
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(textScaleFactor: 1),
                  child: ConstrainedBox(
                    constraints: BoxConstraints.tightForFinite(
                      /// To avoid overlapping with the close button,
                      /// we have to set the height not to exceed the height of the full screen minus the height of the close button,
                      /// since the close button is placed at the top left.
                      /// The size of the close button is its icon size (`_closeButtonSize`) plus the size of the inner edge of the button,
                      /// and the default size of the inner edge is 12 per side.
                      /// Please refer to [IconButton] for more details.
                      /// And we also have to plus the edge size of the first padding widget of the _loginBox,
                      /// So the final height of the _loginBox should be `max - (_closeButtonSize + closeButtonTotalHeight + first Padding height)`.
                      height: min(330, constraints.maxHeight - (_closeButtonSize + 24 + 18)),
                    ),
                    child: GetBuilder<ZAuthController>(
                      builder: (controller) {
                        // Since the [didChangeDependencies] of the [GetBuilderState] won't be called,
                        // we need to put the logics needs to be done after [build] finished here.
                        WidgetsBinding.instance?.addPostFrameCallback((_) => _handleLoginCallBack());

                        return Wrap(
                          runAlignment: WrapAlignment.center,
                          children: [
                            Form(
                              key: _loginFormKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _boxTitle,
                                  _buildEmailTextField(enabled: controller.isInputBoxesEnabled),
                                  _buildPasswordTextField(enabled: controller.isInputBoxesEnabled),
                                  _buildLoginButton(enabled: controller.isLoginBtnEnabled),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

  Widget get _closePageButton => IconButton(
        icon: Icon(Icons.clear, size: _closeButtonSize),
        iconSize: _closeButtonSize,
        onPressed: () => widget._onPageClose?.call(),
      );

  Color get _bgColor => Color(0xFF125B50);

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Container(
          decoration: BoxDecoration(
            color: _bgColor,
          ),
          child: SafeArea(
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: _closePageButton,
                ),
                Align(
                  alignment: Alignment.center,
                  child: _loginBox,
                )
              ],
            ),
          ),
        ),
      );
}

class _InputBox extends StatelessWidget {
  const _InputBox({
    Key? key,
    required TextEditingController controller,
    required TextInputType keyboardType,
    required IconData icon,
    required String hintText,
    bool obscure = false,
    bool enabled = true,
    TextFieldValidator? validator,
    Widget? suffixIcon,
  })  : _controller = controller,
        _keyboardType = keyboardType,
        _icon = icon,
        _hintText = hintText,
        _obscure = obscure,
        _enabled = enabled,
        _validator = validator,
        _suffixIcon = suffixIcon,
        super(key: key);

  final TextEditingController _controller;
  final TextInputType _keyboardType;
  final IconData _icon;
  final String _hintText;
  final bool _obscure;
  final bool _enabled;
  final TextFieldValidator? _validator;
  final Widget? _suffixIcon;

  OutlineInputBorder _buildBorder({
    required Color color,
  }) =>
      OutlineInputBorder(
        borderSide: BorderSide(width: 3, color: color),
        borderRadius: BorderRadius.circular(15),
      );

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 0),
        child: TextFormField(
          controller: _controller,
          keyboardType: _keyboardType,
          obscureText: _obscure,
          enabled: _enabled,
          validator: _validator,
          decoration: InputDecoration(
            fillColor: Color(0xFFEAE5D2),
            filled: true,
            icon: Icon(_icon, color: Colors.black54),
            hintText: _hintText,
            hintStyle: TextStyle(color: Colors.black26),
            border: _buildBorder(color: Colors.transparent),
            focusedBorder: _buildBorder(color: Colors.black54),
            suffixIcon: _suffixIcon,
          ),
          style: TextStyle(color: Colors.black87),
        ),
      );
}
