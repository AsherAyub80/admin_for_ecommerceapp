// import 'package:ecommerceadmin/Widget/monthly_graph.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:ecommerceadmin/provider/store_statics_provider.dart';

// class SalesGraphScreen extends StatefulWidget {
//   @override
//   _SalesGraphScreenState createState() => _SalesGraphScreenState();
// }

// class _SalesGraphScreenState extends State<SalesGraphScreen> {
//   String selectedTimeRange = 'Last 12 Months';

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Sales Graph'),
//         actions: [
//           PopupMenuButton<String>(
//             onSelected: (value) {
//               setState(() {
//                 selectedTimeRange = value;
//               });
//             },
//             itemBuilder: (BuildContext context) {
//               return [
//                 PopupMenuItem(
//                   value: 'Last 7 Days',
//                   child: Text('Last 7 Days'),
//                 ),
//                 PopupMenuItem(
//                   value: 'Last 30 Days',
//                   child: Text('Last 30 Days'),
//                 ),
//                 PopupMenuItem(
//                   value: 'Last 12 Months',
//                   child: Text('Last 12 Months'),
//                 ),
//               ];
//             },
//           ),
//         ],
//       ),
//       body: Consumer<StoreStaticsProvider>(
//         builder: (context, statsProvider, child) {
//           List<double> salesData;
//           switch (selectedTimeRange) {
//             case 'Last 7 Days':
//               salesData = List.generate(7, (index) {
//                 final date = DateTime.now().subtract(Duration(days: 6 - index));
//                 return statsProvider.last7DaysSales; // Assume this provides daily data
//               });
//               break;
//             case 'Last 30 Days':
//               salesData = List.generate(30, (index) {
//                 final date = DateTime.now().subtract(Duration(days: 29 - index));
//                 return statsProvider.last30DaysSales; // Assume this provides daily data
//               });
//               break;
//             case 'Last 12 Months':
//             default:
//               salesData = statsProvider.last12MonthsSales;
//               break;
//           }

//           return MonthlySalesGraph(
//             salesData: salesData,
//             timeRange: selectedTimeRange,
//           );
//         },
//       ),
//     );
//   }
// }
