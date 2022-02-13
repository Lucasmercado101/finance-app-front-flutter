import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';

enum Period { today, week, month, year }

class MonthlyBalance {
  final double expenses;
  final String currency;
  final double lastMonthExpensesDiff;

  MonthlyBalance(
      {required this.expenses,
      required this.currency,
      required this.lastMonthExpensesDiff});

  MonthlyBalance.fromJson(Map<String, dynamic> json)
      : expenses = json['expenses'] + .0,
        currency = json['currency'],
        lastMonthExpensesDiff = json['last_month_expenses_diff'] + .0;
}

enum TransactionType {
  income,
  expense,

  // TODO:
  // conversion,
}

class Transaction {
  final int id;
  final DateTime createdAt;
  final double amount;
  final String currency;
  final String category;
  final String? comment;
  final TransactionType type;

  Transaction({
    required this.id,
    required this.createdAt,
    required this.amount,
    required this.category,
    required this.comment,
    required this.currency,
    required this.type,
  });

  Transaction.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        createdAt = DateTime.parse(json['created_at']),
        amount = json['amount'] + .0,
        category = json['category'],
        comment = json['comment'],
        currency = json['currency'],
        type = json['type'] == "income"
            ? TransactionType.income
            : TransactionType.expense;
}

class Expense {
  final int id;
  final DateTime createdAt;
  final double amount;
  final String currency;
  final String category;
  final String? comment;

  Expense({
    required this.id,
    required this.createdAt,
    required this.amount,
    required this.category,
    required this.comment,
    required this.currency,
  });

  Expense.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        createdAt = DateTime.parse(json['created_at']),
        amount = json['amount'] + .0,
        category = json['category'],
        comment = json['comment'],
        currency = json['currency'];
}

class WalletApi {
  // --------  Endpoints  --------
  static final baseUrl = dotenv.env['BASE_URL'];

  static final Uri newIncomeEndpoint = Uri.parse("$baseUrl/new-income");
  static final Uri newExpenseEndpoint = Uri.parse("$baseUrl/new-expense");
  static final Uri totalMonthlyExpensesEndpoint =
      Uri.parse("$baseUrl/total-monthly-expenses");

  static Uri expensesBetweenEndpoint({
    DateTime? startDate,
    DateTime? endDate,
    Period? period,
  }) {
    assert(startDate != null || endDate != null || period != null);
    assert(period == null || startDate == null && endDate == null);
    var endpoint = Uri.parse("$baseUrl/expenses-between");
    if (startDate != null && endDate != null) {
      endpoint = endpoint.replace(queryParameters: {
        "startDate": startDate.toIso8601String(),
        "endDate": endDate.toIso8601String(),
      });
    } else if (period != null) {
      endpoint = endpoint.replace(queryParameters: {
        "period": period.toString().split('.')[1],
      });
    }
    return endpoint;
  }

  static Uri transactionsBetweenEndpoint({
    DateTime? startDate,
    DateTime? endDate,
    Period? period,
  }) {
    assert(startDate != null || endDate != null || period != null);
    assert(period == null || startDate == null && endDate == null);
    var endpoint = Uri.parse("$baseUrl/transactions-between");
    if (startDate != null && endDate != null) {
      endpoint = endpoint.replace(queryParameters: {
        "startDate": startDate.toIso8601String(),
        "endDate": endDate.toIso8601String(),
      });
    } else if (period != null) {
      endpoint = endpoint.replace(queryParameters: {
        "period": period.toString().split('.')[1],
      });
    }
    return endpoint;
  }

  // --------  API Calls  --------

  static Future<Response> newIncome({
    required currency,
    required amount,
    required category,
    createdAt,
    comment,
  }) async {
    return post(
      newIncomeEndpoint,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'currency': currency,
        'createdAt': (createdAt ?? DateTime.now()).toIso8601String(),
        'amount': amount,
        'category': category,
        'comment': comment,
      }),
    );
  }

  static Future<Response> newExpense({
    required currency,
    required amount,
    required category,
    createdAt,
    comment,
  }) async {
    return post(
      newExpenseEndpoint,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'currency': currency,
        'createdAt': (createdAt ?? DateTime.now()).toIso8601String(),
        'amount': amount,
        'category': category,
        'comment': comment,
      }),
    );
  }

  static Future<List<MonthlyBalance>> getTotalMonthlyExpenses() async {
    final response = await get(totalMonthlyExpensesEndpoint);
    final parsed = json.decode(response.body);
    final parsedList = List<Map<String, dynamic>>.from(parsed);

    return parsedList.map((el) => MonthlyBalance.fromJson(el)).toList();
  }

  static Future<List<Expense>> getExpenses({
    Period? range,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return get(expensesBetweenEndpoint(
      startDate: startDate,
      endDate: endDate,
      period: range,
    )).then((response) {
      final parsed = json.decode(response.body);
      final parsedList = List<Map<String, dynamic>>.from(parsed);

      return parsedList.map((el) => Expense.fromJson(el)).toList();
    });
  }

  static Future<List<Transaction>> getTransactions({
    Period? range,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return get(transactionsBetweenEndpoint(
      startDate: startDate,
      endDate: endDate,
      period: range,
    )).then((response) {
      final parsed = json.decode(response.body);
      final parsedList = List<Map<String, dynamic>>.from(parsed);

      return parsedList.map((el) => Transaction.fromJson(el)).toList();
    });
  }
}
