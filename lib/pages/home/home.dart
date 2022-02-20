import 'package:flutter/material.dart';
import 'package:finance_app_front_flutter/api.dart';
import 'package:finance_app_front_flutter/components/simple_empty_state.dart';
import 'package:finance_app_front_flutter/components/transactions_group.dart';
import 'package:finance_app_front_flutter/pages/add_expense.dart';
import 'package:finance_app_front_flutter/pages/add_income.dart';
import 'package:finance_app_front_flutter/pages/home/total_expenses_card.dart';
import 'package:finance_app_front_flutter/providers/preferences.dart';
import 'package:finance_app_front_flutter/utils.dart';
import 'package:finance_app_front_flutter/wallet.dart';
import 'package:provider/provider.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final wallet = context.watch<Wallet>();
    final dateRange = wallet.dateRange;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
      ),
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.

        child: SafeArea(
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: [
              ListTile(
                title: const Text('Dark Theme'),
                onTap: () {
                  final ctx = context.read<Preferences>();
                  ctx.setDarkMode(!ctx.darkMode);
                },
                trailing: Switch(
                  value: context.watch<Preferences>().darkMode,
                  onChanged: (_) {
                    final ctx = context.read<Preferences>();
                    ctx.setDarkMode(!ctx.darkMode);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          FutureBuilder<ThisAndLastMonthExpenses>(
            future: wallet.monthlyExpenses,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final ThisAndLastMonthExpenses expenses = snapshot.data!;

                if (expenses.lastMonth.isEmpty && expenses.thisMonth.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: SizedBox(height: 16),
                  );
                }

                List<Balance> balances = [];

                for (var i; i < expenses.thisMonth.length; i++) {
                  double lastMonthExpenses = 0;
                  int? lastMonthExpensesIndex = expenses.lastMonth.indexWhere(
                      (e) => e.currency == expenses.thisMonth[i].currency);

                  if (lastMonthExpensesIndex > -1) {
                    lastMonthExpenses =
                        expenses.lastMonth[lastMonthExpensesIndex].amount;
                  }

                  balances.add(Balance(
                    balance: expenses.thisMonth[i].amount,
                    currency: expenses.thisMonth[i].currency,
                    lastMonthDiff:
                        expenses.thisMonth[i].amount - lastMonthExpenses,
                  ));
                }

                return SliverToBoxAdapter(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: balances.map((balance) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          width: balances.length > 1
                              ? mq.size.width / 1.1
                              : mq.size.width,
                          child: TotalExpensesCard(balance),
                        );
                      }).toList(),
                    ),
                  ),
                );
              } else {
                return const SliverToBoxAdapter(
                  child:
                      Text("Loading...", style: TextStyle(color: Colors.white)),
                );
              }
            },
          ),
          SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Column(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AddExpensePage(),
                              ),
                            );
                          },
                          child: const Icon(Icons.add, color: Colors.white),
                          style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(20),
                            primary:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.black
                                    : Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Expense",
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(width: 32),
                    Column(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AddIncomePage(),
                              ),
                            );
                          },
                          child: const Icon(Icons.attach_money,
                              color: Colors.white),
                          style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(20),
                            primary:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.black
                                    : Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Income",
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              )),
          SliverAppBar(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Transactions List",
                  style: Theme.of(context).textTheme.headline5,
                ),
                DropdownButton<String>(
                  items: <String>[
                    'Today',
                    'This week',
                    'This month',
                    'This year',
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                      onTap: () {
                        final wallet = context.read<Wallet>();
                        switch (value) {
                          case 'Today':
                            setState(() {
                              wallet.dateRange = DateRange.Today;
                            });
                            wallet.getTransactions(DateRange.Today.toPeriod());
                            break;
                          case 'This week':
                            setState(() {
                              wallet.dateRange = DateRange.ThisWeek;
                            });
                            wallet
                                .getTransactions(DateRange.ThisWeek.toPeriod());
                            break;
                          case 'This month':
                            setState(() {
                              wallet.dateRange = DateRange.ThisMonth;
                            });
                            wallet.getTransactions(
                                DateRange.ThisMonth.toPeriod());
                            break;
                          case 'This year':
                            setState(() {
                              wallet.dateRange = DateRange.ThisYear;
                            });
                            wallet
                                .getTransactions(DateRange.ThisYear.toPeriod());
                            break;
                          default:
                            throw Exception("Unknown date range");
                        }
                      },
                    );
                  }).toList(),
                  value: (() {
                    switch (wallet.dateRange) {
                      case DateRange.Today:
                        return 'Today';
                      case DateRange.ThisWeek:
                        return 'This week';
                      case DateRange.ThisMonth:
                        return 'This month';
                      case DateRange.ThisYear:
                        return 'This year';
                      default:
                        throw Exception("Unknown date range");
                    }
                  })(),
                  onChanged: (_) {},
                )
              ],
            ),
            snap: true,
            floating: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            automaticallyImplyLeading: false,
          ),
          FutureBuilder(
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final transactions = snapshot.data! as List<Transaction>;

                  if (transactions.isEmpty) {
                    String period;
                    switch (wallet.dateRange) {
                      case DateRange.Today:
                        period = 'Today';
                        break;
                      case DateRange.ThisWeek:
                        period = 'This week';
                        break;
                      case DateRange.ThisMonth:
                        period = 'This month';
                        break;
                      case DateRange.ThisYear:
                        period = 'This year';
                        break;
                      default:
                        throw Exception("Unknown date range");
                    }
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
                        child: SimpleEmptyState(
                          title: "No transactions",
                          message: ("There are no transactions " +
                              period.toLowerCase()),
                        ),
                      ),
                    );
                  }

                  if (dateRange == DateRange.Today) {
                    return SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (index == 0) {
                              return Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text("Total",
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline6),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        "-\$" +
                                            prettifyCurrency(
                                                transactions.fold<double>(
                                                    0,
                                                    (previousValue, element) =>
                                                        element.amount +
                                                        previousValue)),
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline6,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Container(
                                    height: 1,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  TransactionItem(transactions[index]),
                                ],
                              );
                            }
                            if (index.isOdd) {
                              return Column(
                                children: [
                                  const SizedBox(height: 16),
                                  TransactionItem(transactions[index]),
                                  const SizedBox(height: 16),
                                ],
                              );
                            }
                            return TransactionItem(transactions[index]);
                          },
                          childCount: transactions.length,
                        ),
                      ),
                    );
                  } else {
                    // group transactions by .createdAt date
                    final Map<DateTime, List<Transaction>> groupedTransactions =
                        transactions.fold(<DateTime, List<Transaction>>{},
                            (Map<DateTime, List<Transaction>> map,
                                Transaction transaction) {
                      // compare year, month, day
                      final DateTime date = transaction.createdAt.toLocal();
                      final DateTime key =
                          DateTime(date.year, date.month, date.day);
                      if (map.containsKey(key)) {
                        map[key]!.add(transaction);
                      } else {
                        map[key] = [transaction];
                      }
                      return map;
                    });

                    final List<List<Transaction>> transactionsList =
                        groupedTransactions.values.toList();

                    return SliverPadding(
                      padding: const EdgeInsets.all(16.0),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            // return with a sized box in
                            // between each transaction
                            if (index.isOdd) {
                              return Column(
                                children: [
                                  const SizedBox(height: 16),
                                  TransactionGroup(transactionsList[index]),
                                  const SizedBox(height: 16),
                                ],
                              );
                            }
                            return TransactionGroup(transactionsList[index]);
                          },
                          childCount: transactionsList.length,
                        ),
                      ),
                    );
                  }
                } else {
                  return const SliverToBoxAdapter(
                    child: Center(
                      widthFactor: 1.1,
                      heightFactor: 1.3,
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
              },
              future: context.watch<Wallet>().transactions),
        ],
      ),
    );
  }
}
