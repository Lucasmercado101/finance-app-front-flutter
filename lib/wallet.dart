import 'package:flutter/material.dart';
import 'package:finance_app_front_flutter/api.dart';

enum DateRange {
  Today,
  ThisWeek,
  ThisMonth,
  ThisYear,
  // TODO: see all time range
}

extension Conveniences on DateRange {
  Period toPeriod() {
    switch (this) {
      case DateRange.Today:
        return Period.today;
      case DateRange.ThisWeek:
        return Period.week;
      case DateRange.ThisMonth:
        return Period.month;
      case DateRange.ThisYear:
        return Period.year;
      default:
        throw Exception("Unknown range: $this");
    }
  }
}

class Wallet with ChangeNotifier {
  Future<List<Transaction>> transactions = Future.value([]);
  Future<List<MonthlyBalance>> monthlyExpenses = Future.value([]);
  DateRange _dateRange = DateRange.ThisMonth;

  set dateRange(DateRange value) {
    _dateRange = value;
    notifyListeners();
  }

  DateRange get dateRange => _dateRange;

  Wallet() {
    update();
  }

  getTransactions(Period range) async {
    DateTime startDate;
    DateTime endDate;
    switch (range) {
      case Period.today:
        startDate = DateTime.now().subtract(Duration(days: 1));
        endDate = DateTime.now();
        break;
      case Period.week:
        startDate = DateTime.now().subtract(Duration(days: 7));
        endDate = DateTime.now();
        break;
      case Period.month:
        startDate = DateTime.now().subtract(Duration(days: 30));
        endDate = DateTime.now();
        break;
      case Period.year:
        startDate = DateTime.now().subtract(Duration(days: 365));
        endDate = DateTime.now();
        break;
      default:
        throw Exception("Unknown range: $range");
    }
    transactions =
        WalletApi.getTransactions(endDate: endDate, startDate: startDate);
    notifyListeners();
  }

  getMonthlyBalance() async {
    monthlyExpenses = WalletApi.getTotalMonthlyExpenses();
    notifyListeners();
  }

  update() async {
    getTransactions(dateRange.toPeriod());
    getMonthlyBalance();
  }
}
