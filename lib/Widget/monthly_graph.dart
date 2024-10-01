import 'package:ecommerceadmin/provider/store_statics_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MonthlySalesGraph extends StatefulWidget {
  @override
  _MonthlySalesGraphState createState() => _MonthlySalesGraphState();
}

class _MonthlySalesGraphState extends State<MonthlySalesGraph> {
  String _selectedRange = 'Last 12 Months'; // Default selection
  int? _pressedBarIndex; // Track the index of the pressed bar

  @override
  Widget build(BuildContext context) {
    final statsProvider = Provider.of<StoreStaticsProvider>(context);
    List<double> salesData;
    List<String> labels;

    switch (_selectedRange) {
      case 'Last 7 Days':
        salesData = statsProvider.last7DaysSales;
        labels = List.generate(7, (index) {
          final date = DateTime.now().subtract(Duration(days: 6 - index));
          return _getDateLabel(date);
        }).toList();
        break;
      case 'Last 30 Days':
        salesData = statsProvider.last30DaysSales;
        labels = List.generate(30, (index) {
          final date = DateTime.now().subtract(Duration(days: 29 - index));
          return _getDateLabel(date);
        }).toList();
        break;
      case 'Last 12 Months':
      default:
        salesData = statsProvider.last12MonthsSales;
        labels = List.generate(12, (index) {
          final monthDate =
              DateTime.now().subtract(Duration(days: 30 * (11 - index)));
          return _getMonthName(monthDate.month);
        }).toList();
        break;
    }

    if (salesData.isEmpty) {
      return Center(child: Text('No data available.'));
    }

    final double maxSales = salesData.reduce((a, b) => a > b ? a : b);

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
      Colors.pink,
    ];

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sales Data (${_selectedRange})',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: 400,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: ['Last 7 Days', 'Last 30 Days', 'Last 12 Months']
                    .map((range) {
                  return ChoiceChip(
                    label: Text(range),
                    selected: _selectedRange == range,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedRange = range;
                          _pressedBarIndex =
                              null; // Reset index on range change
                        });
                      }
                    },
                  );
                }).toList(),
              ),
            ),
          ),
          SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double barWidth = 24.0;
                final double maxBarHeight = 200.0;
                final double dateLineHeight = 20.0;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(salesData.length, (index) {
                    final sales = salesData[index];
                    final label = labels[index];

                    final barHeight =
                        maxSales > 0 ? (sales / maxSales) * maxBarHeight : 2.0;

                    final color = colors[index % colors.length];

                    return GestureDetector(
                      onLongPress: () {
                        setState(() {
                          _pressedBarIndex =
                              index; // Update the index on long press
                        });
                      },
                      onLongPressUp: () {
                        setState(() {
                          _pressedBarIndex =
                              null; // Reset index when long press is released
                        });
                      },
                      child: Container(
                        width: barWidth,
                        height: barHeight + 40,
                        margin: EdgeInsets.symmetric(horizontal: 4.0),
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.bottomCenter,
                          children: [
                            // Bar
                            Container(
                              width: barWidth,
                              height: barHeight.toDouble(),
                              decoration: BoxDecoration(
                                color: color,
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
                            // Tooltip
                            if (_pressedBarIndex == index && sales > 0)
                              Positioned(
                                bottom: barHeight + 5, // Position above the bar
                                child: Container(
                                  height: sales.toString().length + 20,
                                  width: 40 + sales.toString().length * 10,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(4.0),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '\$${sales.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            SizedBox(height: 4),
                            // Date label
                            Container(
                              width: barWidth,
                              height: dateLineHeight,
                              alignment: Alignment.center,
                              child: Text(
                                label,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getDateLabel(DateTime date) {
    return '${date.day}/${date.month}';
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
    return monthNames[month - 1];
  }
}
