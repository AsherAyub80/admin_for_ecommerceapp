import 'package:ecommerceadmin/auth/auth_provider.dart';
import 'package:ecommerceadmin/screens/settings/settingServices/profile_provider.dart';
import 'package:ecommerceadmin/screens/settings/settingServices/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // Import Cupertino package
import 'package:provider/provider.dart';
import 'package:ecommerceadmin/Widget/custom_drawer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SettingScreen extends StatefulWidget {
  final String email;

  SettingScreen({super.key, required this.email});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final _storeNameController = TextEditingController();

  String? _storeName;

  Future<void> _fetchStoreName() async {
    try {
      final authProviders = Provider.of<AuthProviders>(context, listen: false);
      await authProviders.fetchUserDetails();
      setState(() {
        _storeName = authProviders.storeName;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch store details: $e')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchStoreName();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<AuthProviders, ProfileProvider, ThemeProvider>(
      builder: (context, authProvider, profileProvider, themeProvider, child) {
        _storeNameController.text = _storeName ?? '';

        return Scaffold(
          key: _scaffoldKey,
          drawer: CustomDrawer(
            storeName: _storeName ?? '',
            email: widget.email,
          ),
          appBar: AppBar(
            title: Text(
              'Settings',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            leading: IconButton(
              onPressed: () {
                _scaffoldKey.currentState!.openDrawer();
              },
              icon: FaIcon(FontAwesomeIcons.barsStaggered),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Info Card
                Card(
                  elevation: 4,
                  margin: EdgeInsets.only(bottom: 16.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Profile Information',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: 16.0),
                        Text(
                          'Store Name: ${_storeName ?? 'Not Set'}',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          'Email: ${widget.email}',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 16.0),
                        TextField(
                          controller: _storeNameController,
                          decoration: InputDecoration(
                            labelText: 'Update Store Name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 16.0),
                        ElevatedButton(
                          onPressed: () {
                            profileProvider
                                .updateProfile(_storeNameController.text);
                          },
                          child: Text('Update Profile'),
                        ),
                      ],
                    ),
                  ),
                ),
                // Theme Card
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Theme',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: 16.0),
                        Text(
                          'Current Theme: ${themeProvider.isDarkMode ? "Dark" : "Light"}',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 16.0),
                        CupertinoSwitch(
                          key: ValueKey<bool>(themeProvider.isDarkMode),
                          value: themeProvider.isDarkMode,
                          onChanged: (value) {
                            themeProvider.toggleTheme();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
