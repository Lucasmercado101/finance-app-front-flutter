import 'dart:convert';

import 'package:finance_app_front_flutter/api/getExpensesBetween.dart';
import 'package:finance_app_front_flutter/api/getExpensesTotalBetween.dart';
import 'package:finance_app_front_flutter/api/getIncomesBetween.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';

enum Period { today, week, month, year }

class ThisAndLastMonthExpenses {
  final List<GetExpensesTotalBetweenResp> thisMonth;
  final List<GetExpensesTotalBetweenResp> lastMonth;

  ThisAndLastMonthExpenses({
    required this.thisMonth,
    required this.lastMonth,
  });
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
  final String? category;
  final String? comment;
  final TransactionType type;

  Transaction({
    required this.id,
    required this.createdAt,
    required this.amount,
    required this.currency,
    required this.type,
    this.category,
    this.comment,
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

  // static Uri expensesBetweenEndpoint({
  //   DateTime? startDate,
  //   DateTime? endDate,
  //   Period? period,
  // }) {
  //   assert(startDate != null || endDate != null || period != null);
  //   assert(period == null || startDate == null && endDate == null);
  //   var endpoint = Uri.parse("$baseUrl/expenses-between");
  //   if (startDate != null && endDate != null) {
  //     endpoint = endpoint.replace(queryParameters: {
  //       "startDate": startDate.toIso8601String(),
  //       "endDate": endDate.toIso8601String(),
  //     });
  //   } else if (period != null) {
  //     endpoint = endpoint.replace(queryParameters: {
  //       "period": period.toString().split('.')[1],
  //     });
  //   }
  //   return endpoint;
  // }

  // static Uri transactionsBetweenEndpoint({
  //   DateTime? startDate,
  //   DateTime? endDate,
  //   Period? period,
  // }) {
  //   assert(startDate != null || endDate != null || period != null);
  //   assert(period == null || startDate == null && endDate == null);
  //   var endpoint = Uri.parse("$baseUrl/transactions-between");
  //   if (startDate != null && endDate != null) {
  //     endpoint = endpoint.replace(queryParameters: {
  //       "startDate": startDate.toIso8601String(),
  //       "endDate": endDate.toIso8601String(),
  //     });
  //   } else if (period != null) {
  //     endpoint = endpoint.replace(queryParameters: {
  //       "period": period.toString().split('.')[1],
  //     });
  //   }
  //   return endpoint;
  // }

  // // --------  API Calls  --------

  // static Future<Response> newIncome({
  //   required currency,
  //   required amount,
  //   required category,
  //   createdAt,
  //   comment,
  // }) async {
  //   return post(
  //     newIncomeEndpoint,
  //     headers: {
  //       'Content-Type': 'application/json',
  //     },
  //     body: jsonEncode({
  //       'currency': currency,
  //       'createdAt': (createdAt ?? DateTime.now()).toIso8601String(),
  //       'amount': amount,
  //       'category': category,
  //       'comment': comment,
  //     }),
  //   );
  // }

  // static Future<Response> newExpense({
  //   required currency,
  //   required amount,
  //   required category,
  //   createdAt,
  //   comment,
  // }) async {
  //   return post(
  //     newExpenseEndpoint,
  //     headers: {
  //       'Content-Type': 'application/json',
  //     },
  //     body: jsonEncode({
  //       'currency': currency,
  //       'createdAt': (createdAt ?? DateTime.now()).toIso8601String(),
  //       'amount': amount,
  //       'category': category,
  //       'comment': comment,
  //     }),
  //   );
  // }

  static Future<ThisAndLastMonthExpenses> getTotalMonthlyExpenses() async {
    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month, 1);
    final lastMonth = DateTime(now.year, now.month - 1, 1);
    final expensesThisMonth = await getExpensesTotalBetween(
        from: thisMonth, to: thisMonth.add(const Duration(days: 31)));
    final expensesLastMonth =
        await getExpensesTotalBetween(from: lastMonth, to: thisMonth);

    return ThisAndLastMonthExpenses(
        lastMonth: expensesLastMonth, thisMonth: expensesThisMonth);
  }

  // static Future<List<Expense>> getExpenses({
  //   Period? range,
  //   DateTime? startDate,
  //   DateTime? endDate,
  // }) {
  //   return get(expensesBetweenEndpoint(
  //     startDate: startDate,
  //     endDate: endDate,
  //     period: range,
  //   )).then((response) {
  //     final parsed = json.decode(response.body);
  //     final parsedList = List<Map<String, dynamic>>.from(parsed);

  //     return parsedList.map((el) => Expense.fromJson(el)).toList();
  //   });
  // }

  static Future<List<Transaction>> getTransactions({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final expenses = await getExpensesBetween(from: startDate, to: endDate);
      final incomes = await getIncomesBetween(from: startDate, to: endDate);
      final transactions = expenses
          .map((e) => Transaction(
                id: e.id,
                createdAt: e.createdAt,
                amount: e.amount,
                category: e.category,
                comment: e.comment,
                currency: e.currency,
                type: TransactionType.expense,
              ))
          .toList();
      transactions.addAll(
        incomes
            .map((i) => Transaction(
                  id: i.id,
                  createdAt: i.createdAt,
                  amount: i.amount,
                  category: i.category,
                  comment: i.comment,
                  currency: i.currency,
                  type: TransactionType.income,
                ))
            .toList(),
      );
      return transactions;
    } catch (e) {
      return Future.error(e);
    }
  }
}
