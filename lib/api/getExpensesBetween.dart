import 'dart:convert';

import 'package:finance_app_front_flutter/api/index.dart';
import 'package:finance_app_front_flutter/api/responseExpenseDto.dart';
import 'package:http/http.dart';

Future<List<ResponseExpenseDto>> getExpensesBetween({
  required DateTime from,
  required DateTime to,
}) {
  return get(
    Uri.parse("${baseUrl}/expense/between").replace(
      queryParameters: {
        "from": from.toIso8601String(),
        "to": to.toIso8601String(),
      },
    ),
  ).then((val) {
    final parsedJson = jsonDecode(val.body);
    final data = List<Map<String, dynamic>>.from(parsedJson);
    return data.map((el) => ResponseExpenseDto.fromJson(el)).toList();
  });
}
