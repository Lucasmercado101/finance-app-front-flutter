import 'dart:convert';

import 'package:finance_app_front_flutter/api/index.dart';
import 'package:finance_app_front_flutter/api/responseExpenseDto.dart';
import 'package:http/http.dart';

class GetExpensesTotalBetweenResp {
  final double amount;
  final String currency;

  GetExpensesTotalBetweenResp({
    required this.amount,
    required this.currency,
  });

  GetExpensesTotalBetweenResp.fromJson(Map<String, dynamic> json)
      : amount = json['amount'] + .0,
        currency = json['currency'];
}

Future<List<GetExpensesTotalBetweenResp>> getExpensesTotalBetween({
  required DateTime from,
  required DateTime to,
}) async {
  final resp = await get(
    Uri.parse("${baseUrl}/expense/between").replace(
      queryParameters: {
        "from": from.toIso8601String(),
        "to": to.toIso8601String(),
      },
    ),
  );
  final parsedJson = jsonDecode(resp.body);
  final typedList = List<Map<String, dynamic>>.from(parsedJson);
  return typedList
      .map((el) => GetExpensesTotalBetweenResp.fromJson(el))
      .toList();
}
