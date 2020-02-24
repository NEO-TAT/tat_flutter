import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/generated/i18n.dart';
import 'package:flutter_app/src/costants/app_colors.dart';
import 'package:flutter_app/ui/other/MyToast.dart';

import '../../../src/store/Model.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _accountControl = new TextEditingController();
  final TextEditingController _passwordControl = new TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final FocusNode _passwordFocus = new FocusNode();
  final FocusNode _accountFocus = new FocusNode();
  String _accountErrorMessage = '';
  String _passwordErrorMessage = '';

  @override
  void initState() {
    super.initState();
    _accountControl.text = Model.instance.getAccount();
    _passwordControl.text = Model.instance.getPassword();
  }

  void _loginPress(BuildContext context) async {
    if (_formKey.currentState.validate()) {
      _passwordFocus.unfocus();
      _accountFocus.unfocus();
      Model.instance.setAccount(_accountControl.text.toString());
      Model.instance.setPassword(_passwordControl.text.toString());
      await Model.instance.saveUserData();
      MyToast.show(S.current.loginSave);
      Navigator.of(context).pop(true);
    }
  }

  String _validatorAccount(String value) {
    if (value.isNotEmpty) {
      _accountErrorMessage = '';
    } else {
      setState(() {
        _accountErrorMessage = S.current.accountNull;
      });
    }
    return _accountErrorMessage.isNotEmpty ? _accountErrorMessage : null;
  }

  String _validatorPassword(String value) {
    if (value.isNotEmpty) {
      _passwordErrorMessage = '';
    } else {
      setState(() {
        _passwordErrorMessage = S.current.passwordNull;
      });
    }
    return _passwordErrorMessage.isNotEmpty ? _passwordErrorMessage : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Stack(
            children: <Widget>[
              ClipPath(
                clipper: WaveClipper1(),
                child: Container(
                  width: double.infinity,
                  height: 350,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue,
                        Colors.lightBlue,
                      ],
                    ),
                  ),
                ),
              ),
              ClipPath(
                clipper: WaveClipper2(),
                child: Container(
                  child: Column(),
                  width: double.infinity,
                  height: 350,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0x442196f3),
                        Color(0x4403a9f4),
                      ],
                    ),
                  ),
                ),
              ),
              ClipPath(
                clipper: WaveClipper3(),
                child: Container(
                  child: Column(),
                  width: double.infinity,
                  height: 350,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Color(0x222196f3), Color(0x2203a9f4)]),
                  ),
                ),
              ),
              Container(
                height: 320,
                alignment: Alignment.center,
                child: Icon(
                  Icons.account_circle,
                  color: Colors.white,
                  size: 120,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 30,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Material(
                    elevation: 2,
                    borderRadius: BorderRadius.all(Radius.circular(32)),
                    child: TextFormField(
                      controller: _accountControl,
                      cursorColor: Colors.blue[800],
                      textInputAction: TextInputAction.done,
                      focusNode: _accountFocus,
                      onEditingComplete: () {
                        _accountFocus.unfocus();
                        FocusScope.of(context).requestFocus(_passwordFocus);
                      },
                      validator: (value) => _validatorAccount(value),
                      decoration: InputDecoration(
                        hintText: S.current.account,
                        errorStyle: TextStyle(
                          height: 0,
                          fontSize: 0,
                        ),
                        prefixIcon: Icon(
                          Icons.account_circle,
                          color: Colors.grey,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  if (_accountErrorMessage.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(left: 16),
                      child: Text(
                        _accountErrorMessage,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  SizedBox(
                    height: 20,
                  ),
                  Material(
                    elevation: 2,
                    borderRadius: BorderRadius.all(Radius.circular(32)),
                    child: TextFormField(
                      controller: _passwordControl,
                      cursorColor: Colors.blue[800],
                      obscureText: true,
                      focusNode: _passwordFocus,
                      onEditingComplete: () {
                        _passwordFocus.unfocus();
                      },
                      validator: (value) => _validatorPassword(value),
                      decoration: InputDecoration(
                        hintText: S.current.password,
                        errorStyle: TextStyle(
                          height: 0,
                          fontSize: 0,
                        ),
                        prefixIcon: Icon(
                          Icons.lock,
                          color: Colors.grey,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 13,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  if (_passwordErrorMessage.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(left: 16),
                      child: Text(
                        _passwordErrorMessage,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  SizedBox(
                    height: 25,
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: FlatButton(
                      child: Text(
                        S.current.login,
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(32.0),
                      ),
                      color: AppColors.mainColor,
                      textColor: AppColors.lightFontColor,
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      onPressed: () => _loginPress(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WaveClipper1 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0.0, size.height - 50);

    var firstEndPoint = Offset(size.width * 0.6, size.height - 29 - 50);
    var firstControlPoint = Offset(size.width * .25, size.height - 60 - 50);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondEndPoint = Offset(size.width, size.height - 60);
    var secondControlPoint = Offset(size.width * 0.84, size.height - 50);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

class WaveClipper2 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0.0, size.height - 50);

    var firstEndPoint = Offset(size.width * 0.6, size.height - 15 - 50);
    var firstControlPoint = Offset(size.width * .25, size.height - 60 - 50);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondEndPoint = Offset(size.width, size.height - 40);
    var secondControlPoint = Offset(size.width * 0.84, size.height - 30);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

class WaveClipper3 extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0.0, size.height - 50);

    var firstEndPoint = Offset(size.width * .7, size.height - 40);
    var firstControlPoint = Offset(size.width * .25, size.height);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondEndPoint = Offset(size.width, size.height - 45);
    var secondControlPoint = Offset(size.width * 0.84, size.height - 50);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
