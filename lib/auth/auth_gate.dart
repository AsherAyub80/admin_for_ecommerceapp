import 'package:ecommerceadmin/auth/loginOrRegister.dart';
import 'package:ecommerceadmin/screens/dashboard_screen.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            return DashboardScreen();
          } else {
            return const LoginOrRegister();
          }
        },
      ),
    );
  }
}

