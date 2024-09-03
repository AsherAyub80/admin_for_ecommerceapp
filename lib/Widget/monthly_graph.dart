import 'package:ecommerceadmin/provider/store_statics_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MonthlySalesGraph extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final statsProvider = Provider.of<StoreStaticsProvider>(context);
    final last12MonthsSales = statsProvider.last12MonthsSales;

    if (last12MonthsSales.isEmpty) {
      return Center(child: Text('No data available.'));
    }

    final minSales = last12MonthsSales.reduce((a, b) => a < b ? a : b);
    final maxSales = last12MonthsSales.reduce((a, b) => a > b ? a : b);

    // Define a list of fixed colors
    final List<Color> colors = [
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.cyan,
      Colors.amber,
      Colors.indigo,
      Colors.lime,
      Colors.deepOrange,
      Colors.pink
    ];

    // Generate the list of months for the last 12 months in reverse order
    final List<String> reversedMonths = List.generate(12, (index) {
      final monthDate =
          DateTime.now().subtract(Duration(days: 30 * (11 - index)));
      return _getMonthName(monthDate.month);
    });

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Monthly Sales (Last 12 Months)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final fixedBarWidth = 20.0; // Thinner width for each bar
              final maxBarHeight = 200.0; // Maximum height for a bar
              final dateLineHeight = 20.0; // Height for the date line

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(last12MonthsSales.length, (index) {
                    final sales = last12MonthsSales[index];
                    final monthName = reversedMonths[index];

                    // Calculate bar height as a percentage of the maxBarHeight
                    final barHeight = maxSales > 0
                        ? (sales / maxSales) * maxBarHeight
                        : 0; // Ensure height is 0 if maxSales is 0

                    // Get a color for the bar based on index
                    final color = colors[index % colors.length];

                    return Container(
                      width: fixedBarWidth,
                      margin: EdgeInsets.symmetric(horizontal: 4.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.bottomCenter,
                            children: [
                              Container(
                                width: fixedBarWidth,
                                height: barHeight.toDouble(),
                                decoration: BoxDecoration(
                                  color: color, // Use fixed color
                                  borderRadius: BorderRadius.circular(4.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.3),
                                      spreadRadius: 2,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                              if (sales > 0)
                                Positioned(
                                  bottom: barHeight.toDouble() +
                                      7, // Position above the bar
                                  child: Container(
                                    width: fixedBarWidth + 200,
                                    alignment: Alignment.center,
                                    child: Text(
                                      '\$${sales.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 10, // Smaller font size
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Container(
                            width: fixedBarWidth,
                            height: dateLineHeight,
                            alignment: Alignment.center,
                            child: Text(
                              monthName,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10, // Smaller font size
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return monthNames[month - 1]; // Adjust for 0-based index
  }
}
