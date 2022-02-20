import 'dart:convert';

import 'package:finance_app_front_flutter/api/index.dart';
import 'package:finance_app_front_flutter/api/responseIncomeDto.dart';
import 'package:http/http.dart';

Future<List<ResponseIncomeDto>> getIncomesBetween({
  required DateTime from,
  required DateTime to,
}) {
  return get(
    Uri.parse("${baseUrl}/income/between").replace(
      queryParameters: {
        "from": from.toIso8601String(),
        "to": to.toIso8601String(),
      },
    ),
  ).then((val) {
    final parsedJson = jsonDecode(val.body);
    return parsedJson.map((el) => ResponseIncomeDto.fromJson(el)).toList();
  });
}
