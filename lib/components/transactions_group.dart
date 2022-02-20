import 'package:flutter/material.dart';
import 'package:finance_app_front_flutter/api.dart';
import 'package:finance_app_front_flutter/utils.dart';

class TransactionGroup extends StatelessWidget {
  final List<Transaction> transactions;

  const TransactionGroup(this.transactions, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final totalTransactions =
        transactions.fold<double>(0, (previousValue, element) {
      if (element.type == TransactionType.expense) {
        return previousValue - element.amount;
      } else {
        return previousValue + element.amount;
      }
    });

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey[400]!,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // assuming they're all the same day
              Text(
                  (weekDayToString(transactions[0].createdAt.weekday) +
                      ", " +
                      transactions[0].createdAt.day.toString()),
                  style: Theme.of(context).textTheme.headline6),
              Text(
                  (totalTransactions > 0 ? "+" : "-") +
                      '\$' +
                      prettifyCurrency(totalTransactions),
                  style: TextStyle(
                      fontSize: Theme.of(context).textTheme.headline6!.fontSize,
                      fontWeight:
                          Theme.of(context).textTheme.headline6!.fontWeight,
                      color: totalTransactions < 0
                          ? Theme.of(context).textTheme.headline6!.color
                          : Colors.green))
            ],
          ),
          const SizedBox(
            height: 16,
          ),
          Container(
            height: 1,
            color: Colors.grey[400],
          ),
          const SizedBox(
            height: 16,
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) =>
                TransactionItem(transactions[index]),
            itemCount: transactions.length,
            separatorBuilder: (context, index) => const SizedBox(
              height: 16,
            ),
          )
        ],
      ),
    );
  }
}

class TransactionItem extends StatelessWidget {
  final Transaction transaction;

  const TransactionItem(this.transaction, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (transaction.category != null)
                Text(
                  transaction.category!,
                  style: Theme.of(context).textTheme.headline6,
                ),
              const SizedBox(
                height: 10,
              ),
              if (transaction.comment != null)
                Text(transaction.comment!,
                    style: Theme.of(context).textTheme.subtitle1),
            ],
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        Text(
          (transaction.type == TransactionType.expense ? "-" : "+") +
              "\$" +
              prettifyCurrency(transaction.amount),
          style: TextStyle(
              fontSize: Theme.of(context).textTheme.headline6!.fontSize,
              fontWeight: Theme.of(context).textTheme.headline6!.fontWeight,
              color: transaction.type == TransactionType.expense
                  ? Theme.of(context).textTheme.headline6!.color
                  : Colors.green),
        ),
      ],
    );
  }
}
