import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;
  final String initialStatus;
  final String username;
  final String email;
  final List<dynamic> items;
  final String orderAddress;
  final String paymentMethod;

  OrderDetailScreen({
    required this.orderId,
    required this.initialStatus,
    required this.username,
    required this.email,
    required this.items,
    required this.orderAddress,
    required this.paymentMethod,
  });

  @override
  _OrderDetailScreenState createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late String _selectedStatus;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.initialStatus;
  }

  Future<void> _updateOrderStatus() async {
    try {
      final orderRef =
          FirebaseFirestore.instance.collection('orders').doc(widget.orderId);
      await orderRef.update({'status': _selectedStatus});
      Navigator.pop(context);
    } catch (e) {
      print('Failed to update order status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Customer Name: ${widget.username}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Customer Email: ${widget.email}',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Order ID: ${widget.orderId}',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Order Status: $_selectedStatus',
                      style: TextStyle(fontSize: 16, color: Colors.blueAccent),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Address:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(widget.orderAddress),
                    SizedBox(height: 8),
                    Text(
                      'Payment Method:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(widget.paymentMethod),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            DropdownButton<String>(
              value: _selectedStatus,
              onChanged: (newValue) {
                setState(() {
                  _selectedStatus = newValue!;
                });
              },
              items: [
                'Pending',
                'Preparing',
                'On the way',
                'Delivered',
              ].map<DropdownMenuItem<String>>((status) {
                return DropdownMenuItem<String>(
                  value: status,
                  child: Text(status),
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            Text('Order Items:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Expanded(
              child: ListView.builder(
                itemCount: widget.items.length,
                itemBuilder: (context, index) {
                  final item = widget.items[index] as Map<String, dynamic>;
                  return ListTile(
                    title: Text(item['title']),
                    subtitle: Text(
                        'Quantity: ${item['quantity']} - Price: \$${item['price']}'),
                    trailing: Text(
                      'Status: $_selectedStatus',
                      style: TextStyle(fontSize: 15),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                fixedSize: Size(180, 55),
              ),
              onPressed: _updateOrderStatus,
              child: Text(
                'Update Status',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
