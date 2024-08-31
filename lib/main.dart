import 'package:ecommerceadmin/auth/auth_provider.dart';
import 'package:ecommerceadmin/firebase_options.dart';
import 'package:ecommerceadmin/provider/store_statics_provider.dart';
import 'package:ecommerceadmin/screens/sign_in.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final provider = StoreStaticsProvider();
  await provider.fetchStatistics('your-store-id');
  print('Today Sales: ${provider.todaySales}');
  print('Weekly Sales: ${provider.weeklySales}');
  print('Monthly Sales: ${provider.monthlySales}');
  print('Positive Reviews: ${provider.positiveReviews}');
  print('Negative Reviews: ${provider.negativeReviews}');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProviders()),
        ChangeNotifierProvider(create: (_) => StoreStaticsProvider())
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: AdminSignIn(),
      ),
    );
  }
}
