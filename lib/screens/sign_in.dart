import 'package:ecommerceadmin/auth/auth_provider.dart';
import 'package:ecommerceadmin/screens/register_store.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminSignIn extends StatefulWidget {
  const AdminSignIn({super.key});

  @override
  State<AdminSignIn> createState() => _AdminSignInState();
}

class _AdminSignInState extends State<AdminSignIn> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    TextEditingController emailController = TextEditingController();
    TextEditingController passController = TextEditingController();

    @override
    void dispose() {
      ;
      super.dispose();
      emailController.dispose();
      passController.dispose();
    }

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
              'Admin Sign In',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 15,
            ),
            MyTextField(
              hintText: 'Email',
              controller: emailController,
            ),
            MyTextField(
              hintText: 'Password',
              controller: passController,
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
                  authProvider.signInAsAdmin(
                    emailController.text,
                    passController.text,
                  );
                },
                child: Text(
                  'Sign in As admin',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                )),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Want to Register your own store?'),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RegisterStore()));
                  },
                  child: Text('Create Now',
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

class MyTextField extends StatelessWidget {
  const MyTextField({
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
