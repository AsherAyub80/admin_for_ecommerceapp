import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerceadmin/Widget/custom_drawer.dart';
import 'package:ecommerceadmin/auth/auth_provider.dart';
import 'package:ecommerceadmin/screens/OrdersScreen/order_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DeliveredOrdered extends StatelessWidget {
  final String storeName;
  final String storeEmail;
  const DeliveredOrdered(
      {super.key, required this.storeName, required this.storeEmail});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AuthProviders>(context);
    final user = provider.storeId;

    return Scaffold(
      drawer: CustomDrawer(
        storeName: storeName,
        email: storeEmail,
      ),
      appBar: AppBar(
        title: Text('Pending Orders'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('storeId', isEqualTo: user)
            .where('status', isEqualTo: 'Delivered')
            .snapshots(), // Ensure real-time

        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return Center(child: const CircularProgressIndicator());
          }

          final orders = snapshot.data!.docs;
          print('Fetched orders: ${orders.map((doc) => doc.data()).toList()}');

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index].data() as Map<String, dynamic>;
              final paymentMethod = order['paymentMethod'];
              final address = order['address'];
              final orderId = orders[index].id;
              final items = order['items'] as List<dynamic>;
              final userDetail = items.isNotEmpty
                  ? items[0]
                  : {'username': 'Unknown', 'email': 'Unknown'};

              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 5.0, horizontal: 12),
                child: Card(
                  child: ListTile(
                    title: Text(order['receipt']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: items.map((item) {
                        return Text(
                            'Item: ${item['title']}\nCustomer: ${item['username']}');
                      }).toList(),
                    ),
                    trailing: Text('Total: \$${order['totalPrice']}'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderDetailScreen(
                            orderId: orderId,
                            initialStatus:
                                order['status'], // Use status from the document
                            username: userDetail['username'],
                            email: userDetail['email'],
                            items: items, orderAddress: address, paymentMethod: paymentMethod,
                          ),
                        ),
                      );
                    },
                    onLongPress: () {
                      _confirmDelete(context, orderId);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _backupOrder(String orderId) async {
    try {
      final orderDoc = await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .get();

      if (orderDoc.exists) {
        await FirebaseFirestore.instance
            .collection('order_backups')
            .doc(orderId)
            .set(orderDoc.data()!);
        print('Order backed up successfully');
      } else {
        print('Order does not exist');
      }
    } catch (e) {
      print('Failed to back up order: $e');
    }
  }

  void _confirmDelete(BuildContext context, String orderId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Order'),
          content: Text('Are you sure you want to delete this order?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await _backupOrder(orderId); // Backup before deleting
                  await FirebaseFirestore.instance
                      .collection('orders')
                      .doc(orderId)
                      .delete();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Order deleted successfully')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete order: $e')),
                  );
                }
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
