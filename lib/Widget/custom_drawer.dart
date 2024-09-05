import 'package:ecommerceadmin/auth/auth_gate.dart';
import 'package:ecommerceadmin/auth/auth_provider.dart';
import 'package:ecommerceadmin/upload_screen.dart';
import 'package:flutter/material.dart';
import 'package:ecommerceadmin/screens/dashboard_screen.dart';
import 'package:provider/provider.dart';

class CustomDrawer extends StatelessWidget {
  String storeName;
  String email;

  CustomDrawer({super.key, this.storeName = '', this.email = ''});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Header Section
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.deepPurple,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.blue,
                ),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      storeName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      email,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Drawer Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  Icons.dashboard,
                  'Dashboard',
                  context,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DashboardScreen()),
                  ),
                ),
                _buildDrawerItem(
                  Icons.upload,
                  'Upload Products',
                  context,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UploadScreen()),
                  ),
                ),
                _buildDrawerItem(
                  Icons.shopping_cart,
                  'Orders',
                  context,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DashboardScreen()),
                  ),
                ),
                _buildDrawerItem(
                  Icons.settings,
                  'Settings',
                  context,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DashboardScreen()),
                  ),
                ),
                Divider(),
                _buildDrawerItem(
                  Icons.logout,
                  'Logout',
                  context,
                  () async {
                    final provider =
                        Provider.of<AuthProviders>(context, listen: false);

                    try {
                      await provider.signOut();
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) => AuthGate()));
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Sign out failed: $e')),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    IconData icon,
    String title,
    BuildContext context,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueGrey[900]),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}
