import 'package:ecommerceadmin/auth/auth_gate.dart';
import 'package:ecommerceadmin/auth/auth_provider.dart';
import 'package:ecommerceadmin/firebase_options.dart';
import 'package:ecommerceadmin/provider/store_statics_provider.dart';
import 'package:ecommerceadmin/screens/settings/settingServices/profile_provider.dart';
import 'package:ecommerceadmin/screens/settings/settingServices/theme_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProviders()),
        ChangeNotifierProvider(create: (_) => StoreStaticsProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,

          theme: ThemeData(
            brightness:
                themeProvider.isDarkMode ? Brightness.dark : Brightness.light,
          ),

          home: AuthGate(), // Replace with your actual home screen
        );
      },
    );
  }
}
