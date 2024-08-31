import 'package:ecommerceadmin/auth/auth_provider.dart';
import 'package:ecommerceadmin/screens/store_sign_in.dart';
import 'package:ecommerceadmin/upload_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegisterStore extends StatelessWidget {
  RegisterStore({super.key});

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController storeNameController = TextEditingController();
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
              'Store Register',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 15,
            ),
            MyTextFields(
              hintText: 'Name of store',
              controller: storeNameController,
            ),
            MyTextFields(
              hintText: 'Email',
              controller: emailController,
            ),
            MyTextFields(
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
                  try {
                    final authProvider =
                        Provider.of<AuthProviders>(context, listen: false);
                    authProvider.signUpAsStoreOwner(
                      emailController.text,
                      passwordController.text,
                      storeNameController.text,
                    );
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UploadScreen()));
                  } catch (e) {
                    print(e);
                  }
                },
                child: Text(
                  'Register Store',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                )),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Already have an store?'),
                TextButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => StoreSignIn()));
                  },
                  child: Text('Sign in now',
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

class MyTextFields extends StatelessWidget {
  const MyTextFields({
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
