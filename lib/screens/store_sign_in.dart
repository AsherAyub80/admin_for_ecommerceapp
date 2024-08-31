import 'package:ecommerceadmin/auth/auth_provider.dart';
import 'package:ecommerceadmin/screens/register_store.dart';
import 'package:ecommerceadmin/upload_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StoreSignIn extends StatelessWidget {
  StoreSignIn({super.key});

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.manage_accounts,
              size: 80,
              color: Colors.purple,
            ),
            Text(
              'Store Sign in',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 15,
            ),
            SignInTextFields(
              hintText: 'Email',
              controller: emailController,
            ),
            SignInTextFields(
              hintText: 'Password',
              controller: passwordController,
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    fixedSize: Size(width - 100, 60)),
                onPressed: () {
                  final authProvider =
                      Provider.of<AuthProviders>(context, listen: false);
                  authProvider.signInAsStoreOwner(
                    emailController.text,
                    passwordController.text,
                  );
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => UploadScreen()));
                },
                child: Text(
                  'Register Store',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                )),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Don't have a store?"),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RegisterStore()));
                  },
                  child: Text('Register Now',
                      style: TextStyle(color: Colors.deepPurple)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class SignInTextFields extends StatelessWidget {
  const SignInTextFields({
    super.key,
    this.controller,
    required this.hintText,
  });
  final controller;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          contentPadding: EdgeInsets.all(20),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey)),
        ),
      ),
    );
  }
}
