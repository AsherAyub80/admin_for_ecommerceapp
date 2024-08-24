import 'package:ecommerceadmin/upload_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  @override
  Widget build(BuildContext context) {
    FirebaseAuth auth = FirebaseAuth.instance;
    final width = MediaQuery.of(context).size.width;
    TextEditingController emailController = TextEditingController();
    TextEditingController passController = TextEditingController();

    bool isLoading = false;
    @override
    void dispose() {
      ;
      super.dispose();
      emailController.dispose();
      passController.dispose();
    }

    void signIn() async {
      final email = emailController.text.trim();
      final password = passController.text.trim();

      if (email.isEmpty || password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please enter both email and password')));
        return;
      }

      setState(() {
        isLoading = true;
      });

      try {
        await auth.signInWithEmailAndPassword(email: email, password: password);
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => UploadScreen()));
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('User not found for this email')));
        } else if (e.code == 'wrong-password') {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Wrong password')));
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Error ${e.message}')));
          print('error $e');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('An unexpected error occurred')));
        print('Unexpected error: $e');
      } finally {
        setState(() {
          isLoading = false;
        });
      }
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
                  signIn();
                },
                child: isLoading
                    ? CircularProgressIndicator()
                    : Text(
                        'Sign in',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ))
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
