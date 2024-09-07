import 'package:ecommerceadmin/screens/OrdersScreen/deliveredordered.dart';
import 'package:ecommerceadmin/screens/OrdersScreen/inprogressscreen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ecommerceadmin/auth/auth_gate.dart';
import 'package:ecommerceadmin/auth/auth_provider.dart';
import 'package:ecommerceadmin/screens/OrdersScreen/order_screen.dart';
import 'package:ecommerceadmin/upload_screen.dart';
import 'package:ecommerceadmin/screens/dashboard_screen.dart';

class CustomDrawer extends StatefulWidget {
  final String storeName;
  final String email;

  CustomDrawer({super.key, this.storeName = '', this.email = ''});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  bool isExpand = false;

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
                      widget.storeName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      widget.email,
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
                    MaterialPageRoute(
                        builder: (context) => UploadScreen(
                              storeName: widget.storeName,
                              storeEmail: widget.email,
                            )),
                  ),
                ),
                _buildExpandableOrderSection(context),
                Divider(),
                _buildDrawerItem(
                  Icons.settings,
                  'Settings',
                  context,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DashboardScreen()),
                  ),
                ),
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

  Widget _buildExpandableOrderSection(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              isExpand = !isExpand;
            });
          },
          child: ListTile(
            leading: Icon(Icons.shopping_cart, color: Colors.blueGrey[900]),
            title: Text(
              'Orders',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: Icon(
              isExpand ? Icons.expand_less : Icons.expand_more,
              color: Colors.blueGrey[900],
            ),
          ),
        ),
        AnimatedContainer(
          duration: Duration(milliseconds: 300),
          height: isExpand ? 160 : 0,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _pendingOrder(
                Icons.pending,
                'Pending',
                () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PendingOrders(
                                storeName: widget.storeName,
                                storeEmail: widget.email,
                              )));
                },
              ),
              _progressOrder(
                FontAwesomeIcons.listCheck,
                'In Progress',
                () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => InProgressScreen(
                                storeName: widget.storeName,
                                storeEmail: widget.email,
                              )));
                },
              ),
              _doneOrders(
                FontAwesomeIcons.solidCircleCheck,
                'Done',
                () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DeliveredOrdered(
                                storeName: widget.storeName,
                                storeEmail: widget.email,
                              )));
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  ListTile _doneOrders(IconData icon, String title, VoidCallback onTap) {
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

  ListTile _progressOrder(IconData icon, String title, VoidCallback onTap) {
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

  ListTile _pendingOrder(IconData icon, String title, VoidCallback onTap) {
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
