import 'package:ecommerceadmin/order_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminOrderIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('orders').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return IconButton(
            onPressed: () {},
            icon: Icon(Icons.warehouse_outlined),
          );
        }

        if (snapshot.hasError) {
          return IconButton(
            onPressed: () {},
            icon: Icon(Icons.error),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return IconButton(
            onPressed: () {},
            icon: Icon(Icons.warehouse_outlined),
          );
        }

        final orders = snapshot.data!.docs;
        final orderCount = orders.length;

        return IconButton(
          onPressed: () {
            print(orderCount);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AdminOrderScreen(),
              ),
            );
          },
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(Icons.warehouse_outlined),
              Positioned(
                right: -5,
                top: -5,
                child: Container(
                  height: 20,
                  width: 20,
                  child: Center(
                    child: Text(
                      orderCount.toString(),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  decoration:
                      BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
