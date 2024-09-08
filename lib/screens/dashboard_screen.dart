import 'package:ecommerceadmin/Widget/custom_drawer.dart';
import 'package:ecommerceadmin/Widget/monthly_graph.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:ecommerceadmin/auth/auth_provider.dart';
import 'package:ecommerceadmin/provider/store_statics_provider.dart';

class DashboardScreen extends StatefulWidget {
  DashboardScreen({
    super.key,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? _storeName;

  Future<void> _fetchStoreName() async {
    try {
      final authProviders = Provider.of<AuthProviders>(context, listen: false);
      await authProviders.fetchUserDetails();
      setState(() {
        _storeName = authProviders.storeName;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch store details: $e')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchStoreName();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final isWideScreen = width > 800; // Define what constitutes a "wide" screen

    final storeId = Provider.of<AuthProviders>(context).storeId;
    final storeName = Provider.of<AuthProviders>(context).storeName;
    final storeEmail = Provider.of<AuthProviders>(context);
    final email = storeEmail.user?.email ?? 'unknown';

    final statsProvider = Provider.of<StoreStaticsProvider>(context);

    // Fetch statistics when the screen is loaded

    if (storeId != null) {
      statsProvider.fetchStatistics(storeId);
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            _scaffoldKey.currentState!.openDrawer();
          },
          icon: FaIcon(FontAwesomeIcons.barsStaggered),
        ),
      ),
      drawer: CustomDrawer(
          storeName: storeName.toString(), email: email.toString()),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Consumer<StoreStaticsProvider>(
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

                return SingleChildScrollView(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Sales Summary Row

                      SizedBox(height: 32),
                      LayoutBuilder(builder: (context, constraints) {
                        final itemWidth = isWideScreen
                            ? (constraints.maxWidth - 40) / 3
                            : constraints.maxWidth - 32;
                        return isWideScreen
                            ? Row(
                                children: [
                                  buildRevenueContainer(
                                      provider, height, width, isWideScreen),
                                  SizedBox(width: 16),
                                  buildTotalReview(
                                      provider, height, width, isWideScreen)
                                ],
                              )
                            : Column(
                                children: [
                                  buildRevenueContainer(
                                      provider, height, width, isWideScreen),
                                  SizedBox(height: 16),
                                  buildTotalReview(
                                      provider, height, width, isWideScreen)
                                ],
                              );
                      }),
                      SizedBox(height: 32),

                      LayoutBuilder(
                        builder: (context, constraints) {
                          final itemWidth = isWideScreen
                              ? (constraints.maxWidth - 40) / 3
                              : constraints.maxWidth -
                                  32; // Responsive width for smaller screens

                          return isWideScreen
                              ? Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    buildSalesSummaryItem(
                                        'Today\'s Sales',
                                        provider.todaySales,
                                        provider.getTodaySalesChange(),
                                        height,
                                        itemWidth),
                                    buildSalesSummaryItem(
                                        'This Week\'s Sales',
                                        provider.weeklySales,
                                        provider.getWeeklySalesChange(),
                                        height,
                                        itemWidth),
                                    buildSalesSummaryItem(
                                        'This Month\'s Sales',
                                        provider.monthlySales,
                                        provider.getMonthlySalesChange(),
                                        height,
                                        itemWidth),
                                  ],
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    buildSalesSummaryItem(
                                        'Today\'s Sales',
                                        provider.todaySales,
                                        provider.getTodaySalesChange(),
                                        height,
                                        itemWidth),
                                    SizedBox(height: 16),
                                    buildSalesSummaryItem(
                                        'This Week\'s Sales',
                                        provider.weeklySales,
                                        provider.getWeeklySalesChange(),
                                        height,
                                        itemWidth),
                                    SizedBox(height: 16),
                                    buildSalesSummaryItem(
                                        'This Month\'s Sales',
                                        provider.monthlySales,
                                        provider.getMonthlySalesChange(),
                                        height,
                                        itemWidth),
                                  ],
                                );
                        },
                      ),

                      SizedBox(height: 32),
                      if (isWideScreen)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: MonthlySalesGraph()),
                            Expanded(
                                child: buildReviewsAnalysis(
                                    reviewData, totalReviews)),
                          ],
                        )
                      else
                        Column(
                          children: [
                            MonthlySalesGraph(),
                            SizedBox(height: 32),
                            buildReviewsAnalysis(reviewData, totalReviews),
                          ],
                        ),

                      SizedBox(height: 32),

                      buildSalesChart(salesData, isWideScreen),
                      SizedBox(height: 32),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

Widget buildSalesSummaryItem(
    String title, double sales, double change, double height, double width) {
  return Container(
    width: width,
    padding: EdgeInsets.all(16.0),
    decoration: BoxDecoration(
      color: Colors.deepPurple.shade200,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.3),
          spreadRadius: 2,
          blurRadius: 4,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style:
              TextStyle(fontSize: height * 0.022, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          'Sales: \$${sales.toStringAsFixed(2)}',
          style: TextStyle(fontSize: height * 0.02),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            formatChange(change),
            SizedBox(width: 4),
            Text(
              "${change.toStringAsFixed(2)}%",
              style: TextStyle(
                fontSize: height * 0.02,
                color: change >= 0
                    ? const Color.fromARGB(255, 7, 105, 11)
                    : Colors.red,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget buildTotalReview(StoreStaticsProvider provider, double height,
    double width, bool isWideScreen) {
  return Center(
    child: Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade200,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      width: isWideScreen ? width * 0.4 : width * 0.6,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Total Reviews',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: height * 0.024,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "\$${provider.totalReviews}",
            style: TextStyle(
              color: Colors.black,
              fontSize: height * 0.04,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    ),
  );
}

Widget buildRevenueContainer(StoreStaticsProvider provider, double height,
    double width, bool isWideScreen) {
  return Center(
    child: Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade200,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      width: isWideScreen ? width * 0.4 : width * 0.6,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Total Revenue',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: height * 0.024,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "\$${provider.totalSales.toStringAsFixed(2)}",
            style: TextStyle(
              color: Colors.black,
              fontSize: height * 0.04,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Total Revenue :${provider.getTotalRevenuePercentageChange() >= 0 ? '+' : "-"} ${provider.getTotalRevenuePercentageChange().toStringAsFixed(2)}%',
            style: TextStyle(
              color: provider.getTotalRevenuePercentageChange() >= 0
                  ? Color.fromARGB(255, 7, 105, 11)
                  : Colors.red,
              fontSize: height * 0.02,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget buildSalesChart(List<SalesData> salesData, isWide) {
  return salesData.isNotEmpty
      ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sales Analysis',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Container(
              padding: EdgeInsets.all(isWide ? 30 : 16.0),
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
      : Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'No sales data available.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        );
}

Widget buildReviewsAnalysis(List<ReviewData> reviewData, int totalReviews) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Reviews Analysis',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      if (reviewData.isNotEmpty && totalReviews > 0)
        Container(
          height: 300,
          child: PieChart(
            PieChartData(
              sections: reviewData.map((data) {
                return PieChartSectionData(
                  value: data.value,
                  title: '${data.label}\n${data.value.toStringAsFixed(1)}%',
                  titleStyle: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                  color: data.label == 'Positive' ? Colors.green : Colors.red,
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
  );
}

Widget formatChange(double value) {
  return Icon(
    value >= 0 ? Icons.arrow_upward_outlined : Icons.arrow_downward_outlined,
    color: value >= 0 ? Color.fromARGB(255, 7, 105, 11) : Colors.red,
  );
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
