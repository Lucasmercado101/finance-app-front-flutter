import 'package:flutter/material.dart';
import 'package:finance_app_front_flutter/api.dart';
import 'package:finance_app_front_flutter/utils.dart';

class Balance {
  final double balance;
  final String currency;
  final double lastMonthDiff;

  Balance({
    required this.balance,
    required this.currency,
    required this.lastMonthDiff,
  });
}

class TotalExpensesCard extends StatelessWidget {
  final Balance balance;

  const TotalExpensesCard(
    this.balance, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Total Expenses",
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 10),
            Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (prettifyCurrency(balance.balance) +
                          " - " +
                          balance.currency),
                      style: TextStyle(
                        fontSize:
                            Theme.of(context).textTheme.headline4!.fontSize,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      color: balance.lastMonthDiff > 0
                          ? Theme.of(context).errorColor.withGreen(100)
                          : Colors.lightGreen[600],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      (balance.lastMonthDiff > 0 ? "+" : "-") +
                          prettifyCurrency(balance.lastMonthDiff),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Text(
                    "than last month",
                    style: TextStyle(color: Colors.white),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
