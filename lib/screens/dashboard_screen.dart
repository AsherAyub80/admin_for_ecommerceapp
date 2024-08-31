import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:ecommerceadmin/auth/auth_provider.dart';
import 'package:ecommerceadmin/provider/store_statics_provider.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final storeId = Provider.of<AuthProviders>(context).storeId;
    final statsProvider = Provider.of<StoreStaticsProvider>(context);

    // Fetch statistics when the screen is loaded
    if (storeId != null) {
      statsProvider.fetchStatistics(storeId);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Store Statistics'),
      ),
      body: Consumer<StoreStaticsProvider>(
        builder: (context, provider, child) {
          final salesData = [
            SalesData('Today', provider.todaySales),
            SalesData('This Week', provider.weeklySales),
            SalesData('This Month', provider.monthlySales),
          ];

          final totalReviews = provider.totalReviews;
          final positivePercentage = totalReviews > 0
              ? (provider.positiveReviews / totalReviews) * 100
              : 0;
          final negativePercentage = totalReviews > 0
              ? (provider.negativeReviews / totalReviews) * 100
              : 0;

          final reviewData = [
            ReviewData('Positive', positivePercentage.toDouble()),
            ReviewData('Negative', negativePercentage.toDouble()),
          ];

          String formatChange(double value) {
            return value > 0
                ? '+${value.toStringAsFixed(2)}%'
                : '${value.toStringAsFixed(2)}%';
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Today\'s Sales: \$${provider.todaySales.toStringAsFixed(2)}',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Change from Yesterday: ${formatChange(provider.getTodaySalesChange())}',
                        style: TextStyle(
                          fontSize: 16,
                          color: provider.getTodaySalesChange() >= 0
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'This Week\'s Sales: \$${provider.weeklySales.toStringAsFixed(2)}',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Change from Last Week: ${formatChange(provider.getWeeklySalesChange())}',
                        style: TextStyle(
                          fontSize: 16,
                          color: provider.getWeeklySalesChange() >= 0
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'This Month\'s Sales: \$${provider.monthlySales.toStringAsFixed(2)}',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Change from Last Month: ${formatChange(provider.getMonthlySalesChange())}',
                        style: TextStyle(
                          fontSize: 16,
                          color: provider.getMonthlySalesChange() >= 0
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                      SizedBox(height: 32),
                    ],
                  ),
                ),

                // Sales Chart
                if (salesData.isNotEmpty)

                  Column(
                    children: [
                      Text(
                        'Sales Chart',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        height: 300,
                        child: BarChart(
                          BarChartData(
                            gridData: FlGridData(
                              show: true,
                              drawHorizontalLine: true,
                              horizontalInterval: 10,
                              drawVerticalLine: false,
                            ),
                            borderData: FlBorderData(
                              show: true,
                              border: Border.all(
                                color: Colors.grey,
                                width: 1,
                              ),
                            ),
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 40,
                                  getTitlesWidget: (value, meta) {
                                    final index = value.toInt();
                                    return SideTitleWidget(
                                      axisSide: meta.axisSide,
                                      child: Text(
                                        salesData[index].label,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: true),
                              ),
                            ),
                            barGroups: salesData.asMap().entries.map((entry) {
                              final index = entry.key;
                              final data = entry.value;
                              return BarChartGroupData(
                                x: index,
                                barRods: [
                                  BarChartRodData(
                                    toY: data.value,
                                    color: Colors.blue,
                                    width: 20,
                                    backDrawRodData: BackgroundBarChartRodData(
                                      toY: 0,
                                      color: Colors.grey[200],
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'No sales data available.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),

                Text(
                  'Reviews Chart',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                // Reviews Chart
                if (reviewData.isNotEmpty && totalReviews > 0)
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    height: 300,
                    child: PieChart(
                      PieChartData(
                        sections: reviewData.map((data) {
                          return PieChartSectionData(
                            value: data.value,
                            title:
                                '${data.label}\n${data.value.toStringAsFixed(1)}%',
                            titleStyle: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                            color: data.label == 'Positive'
                                ? Colors.green
                                : Colors.red,
                            radius: 50,
                          );
                        }).toList(),
                        borderData: FlBorderData(
                          show: false,
                        ),
                        sectionsSpace: 0,
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'No review data available.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class SalesData {
  final String label;
  final double value;

  SalesData(this.label, this.value);
}

class ReviewData {
  final String label;
  final double value;

  ReviewData(this.label, this.value);
}
