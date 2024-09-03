import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StoreStaticsProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  double totalSales = 0.0;
  double todaySales = 0.0;
  double monthlySales = 0.0;
  double weeklySales = 0.0;

  double prevDaySales = 0.0;
  double prevWeekSales = 0.0;
  double prevMonthSales = 0.0;
  double prevMonthTotalSales = 0.0;

  int positiveReviews = 0;
  int negativeReviews = 0;
  int totalReviews = 0;

  List<double> last12MonthsSales = List.filled(12, 0.0);

  Future<void> fetchStatistics(String storeId) async {
    final DateTime now = DateTime.now();
    final DateTime startOfDay = DateTime(now.year, now.month, now.day);
    final DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final DateTime startOfMonth = DateTime(now.year, now.month, 1);

    final DateTime startOfPreviousDay = startOfDay.subtract(Duration(days: 1));
    final DateTime startOfPreviousWeek =
        startOfWeek.subtract(Duration(days: 7));
    final DateTime startOfPreviousMonth = startOfMonth
        .subtract(Duration(days: 30)); // Approximation for simplicity

    try {
      // Fetch and calculate sales data
      final salesQuery = await _firestore
          .collection('orders')
          .where('storeId', isEqualTo: storeId)
          .where('date', isGreaterThanOrEqualTo: startOfDay)
          .get();

      final totalSale = await _firestore
          .collection('orders')
          .where('storeId', isEqualTo: storeId)
          .get();

      final prevDaySalesQuery = await _firestore
          .collection('orders')
          .where('storeId', isEqualTo: storeId)
          .where('date', isGreaterThanOrEqualTo: startOfPreviousDay)
          .where('date', isLessThan: startOfDay)
          .get();

      final weeklySalesQuery = await _firestore
          .collection('orders')
          .where('storeId', isEqualTo: storeId)
          .where('date', isGreaterThanOrEqualTo: startOfWeek)
          .get();

      final prevWeekSalesQuery = await _firestore
          .collection('orders')
          .where('storeId', isEqualTo: storeId)
          .where('date', isGreaterThanOrEqualTo: startOfPreviousWeek)
          .where('date', isLessThan: startOfWeek)
          .get();

      final monthlySalesQuery = await _firestore
          .collection('orders')
          .where('storeId', isEqualTo: storeId)
          .where('date', isGreaterThanOrEqualTo: startOfMonth)
          .get();

      final prevMonthSalesQuery = await _firestore
          .collection('orders')
          .where('storeId', isEqualTo: storeId)
          .where('date', isGreaterThanOrEqualTo: startOfPreviousMonth)
          .where('date', isLessThan: startOfMonth)
          .get();

      // Query for products
      final productsQuery = await _firestore
          .collection('products')
          .where('storeId', isEqualTo: storeId)
          .get();

      // Calculate sales
      todaySales = _calculateSales(salesQuery.docs);
      prevDaySales = _calculateSales(prevDaySalesQuery.docs);
      weeklySales = _calculateSales(weeklySalesQuery.docs);
      prevWeekSales = _calculateSales(prevWeekSalesQuery.docs);
      monthlySales = _calculateSales(monthlySalesQuery.docs);
      prevMonthSales = _calculateSales(prevMonthSalesQuery.docs);
      totalSales = _calculateSales(totalSale.docs);
      prevMonthTotalSales = prevMonthSales;

      // Fetch and calculate sales data for the last 12 months
      await _fetchLast12MonthsSales(storeId);

      // Calculate reviews
      positiveReviews = 0;
      negativeReviews = 0;
      totalReviews = 0;

      for (var productDoc in productsQuery.docs) {
        final reviews = productDoc.get('reviews') as List<dynamic>?;

        if (reviews == null) {
          print('No reviews found for product ${productDoc.id}');
          continue;
        }

        for (var review in reviews) {
          if (review is Map<String, dynamic>) {
            final rating = review['rating'];
            if (rating is int) {
              final ratingAsDouble = rating.toDouble();
              totalReviews++;
              if (ratingAsDouble >= 4) {
                positiveReviews++;
              } else if (ratingAsDouble <= 2) {
                negativeReviews++;
              }
            } else if (rating is double) {
              totalReviews++;
              if (rating >= 4) {
                positiveReviews++;
              } else if (rating <= 2) {
                negativeReviews++;
              }
            } else {
              print('Unexpected rating type: ${rating.runtimeType}');
            }
          } else {
            print('Unexpected review format: ${review.runtimeType}');
          }
        }
      }

      notifyListeners();
    } catch (e) {
      print('Error fetching statistics: $e');
    }
  }

  Future<void> _fetchLast12MonthsSales(String storeId) async {
    final DateTime now = DateTime.now();
    final DateTime startOfMonth = DateTime(now.year, now.month, 1);

    for (int i = 0; i < 12; i++) {
      final DateTime startOfMonthForQuery =
          DateTime(now.year, now.month - i, 1);
      final DateTime endOfMonthForQuery = (i == 0)
          ? DateTime(now.year, now.month + 1, 1)
          : DateTime(now.year, now.month - i + 1, 1);

      final salesQuery = await _firestore
          .collection('orders')
          .where('storeId', isEqualTo: storeId)
          .where('date', isGreaterThanOrEqualTo: startOfMonthForQuery)
          .where('date', isLessThan: endOfMonthForQuery)
          .get();

      last12MonthsSales[11 - i] = _calculateSales(salesQuery.docs);
    }
  }

  double getSalesChangePercentage(double currentSales, double previousSales) {
    if (previousSales == 0) return currentSales > 0 ? 100.0 : 0.0;
    return ((currentSales - previousSales) / previousSales) * 100.0;
  }

  double _calculateSales(List<QueryDocumentSnapshot> docs) {
    return docs.fold(0.0, (sum, doc) {
      final totalPrice = doc['totalPrice'];

      // Check if 'totalPrice' exists and is not null
      if (totalPrice != null) {
        if (totalPrice is int) {
          return sum + totalPrice.toDouble();
        } else if (totalPrice is double) {
          return sum + totalPrice;
        } else {
          print('Unexpected totalPrice type: ${totalPrice.runtimeType}');
        }
      } else {
        print('totalPrice is null or missing in document: ${doc.id}');
      }

      return sum;
    });
  }

  double getTodaySalesChange() =>
      getSalesChangePercentage(todaySales, prevDaySales);
  double getWeeklySalesChange() =>
      getSalesChangePercentage(weeklySales, prevWeekSales);
  double getMonthlySalesChange() =>
      getSalesChangePercentage(monthlySales, prevMonthSales);
  double getTotalRevenuePercentage() {
    if (totalSales == 0) return 0.0; // Avoid division by zero
    return (monthlySales / totalSales) * 100.0;
  }

  double getTotalRevenuePercentageChange() {
    if (prevMonthTotalSales == 0)
      return getTotalRevenuePercentage(); // Return current percentage if previous month’s sales are zero
    double currentPercentage = getTotalRevenuePercentage();
    double prevMonthPercentage = (prevMonthSales / totalSales) * 100.0;
    return getSalesChangePercentage(currentPercentage, prevMonthPercentage);
  }

  List<double> getLast12MonthsSales() => last12MonthsSales;
}
