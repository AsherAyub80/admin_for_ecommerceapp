import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;
  final String initialStatus;
  final String username;
  final String email;
  final List<dynamic> items;

  OrderDetailScreen({
    required this.orderId,
    required this.initialStatus,
    required this.username,
    required this.email,
    required this.items,
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

      // Update only the status of the order document
      await orderRef.update({
        'status': _selectedStatus,
      });

      Navigator.pop(context);
    } catch (e) {
      print('Failed to update order status: $e');
      // Handle the error
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Card(
              child: ListTile(
                title: Text('Customer Name: ${widget.username}'),
                subtitle: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Customer Email: ${widget.email}'),
                    Text('Order ID: ${widget.orderId}'),
                    Text(
                        'Order Status: $_selectedStatus'), // Display status here
                  ],
                ),
              ),
            ),
            DropdownButton<String>(
              value: _selectedStatus,
              onChanged: (newValue) {
                setState(() {
                  _selectedStatus = newValue!;
                });
              },
              items: ['Pending', 'In Progress', 'Delivered']
                  .map<DropdownMenuItem<String>>((status) {
                return DropdownMenuItem<String>(
                  value: status,
                  child: Text(status),
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            Text('Order Items:', style: TextStyle(fontWeight: FontWeight.bold)),
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
                      'Status: ${_selectedStatus.toString()}',
                      style: TextStyle(fontSize: 15),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple, fixedSize: Size(180, 55)),
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
