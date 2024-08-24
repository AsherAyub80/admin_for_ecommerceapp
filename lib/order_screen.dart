import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerceadmin/order_detail_screen.dart';
import 'package:flutter/material.dart';

class AdminOrderScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Orders'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('orders').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index].data() as Map<String, dynamic>;
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
                            'Item: ${item['title']}\nStatus: ${item['status']}\nCustomer: ${item['username']}');
                      }).toList(),
                    ),
                    trailing: Text('Total: \$${order['totalPrice']}'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderDetailScreen(
                            orderId: orderId,
                            initialStatus: items.isNotEmpty
                                ? items[0]['status']
                                : 'Pending',
                            username: userDetail['username'],
                            email: userDetail['email'],
                            items: items, // Pass the entire list of items
                          ),
                        ),
                      );
                    },
                    // Add delete button
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
