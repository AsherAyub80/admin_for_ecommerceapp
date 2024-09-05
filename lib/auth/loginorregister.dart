import 'package:ecommerceadmin/screens/register_store.dart';
import 'package:ecommerceadmin/screens/store_sign_in.dart';
import 'package:flutter/material.dart';

class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({super.key});

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister> {
  //initialy show login page
  bool showloginpage = true;

  //toggle between login and register page
  void togglePages() {
    setState(() {
      showloginpage = !showloginpage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showloginpage) {
      return StoreSignIn(
        onTap: togglePages,
      );
    } else {
      return RegisterStore(
        onTap: togglePages,
      );
    }
  }
}
