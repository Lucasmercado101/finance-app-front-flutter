import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:finance_app_front_flutter/api.dart';
import 'package:finance_app_front_flutter/wallet.dart';

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({Key? key}) : super(key: key);

  @override
  _AddExpenseState createState() => _AddExpenseState();
}

class _AddExpenseState extends State<AddExpensePage> {
  final _formKey = GlobalKey<FormState>();

  // amount, currency, category, comment
  final TextEditingController _currencyController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  DateTime? _date;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Expense'),
      ),
      body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Expense",
                      style: Theme.of(context).textTheme.headline6)),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Currency *'),
                validator: (value) {
                  if (value == null) {
                    return 'Please enter a currency';
                  } else if (value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
                controller: _currencyController,
                keyboardType: TextInputType.text,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Amount *',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null) {
                    return 'Please enter an amount';
                  } else if (value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
                controller: _amountController,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Category *'),
                validator: (value) {
                  if (value == null) {
                    return 'Please enter a category';
                  } else if (value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
                keyboardType: TextInputType.text,
                controller: _categoryController,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Comment'),
                controller: _commentController,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                  onPressed: () {
                    showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1970),
                            lastDate: DateTime.now())
                        .then((value) {
                      if (value != null) {
                        setState(() {
                          _date = value;
                        });
                      }
                    });
                  },
                  child: _date == null
                      ? const Text("Select Date")
                      : Text(
                          "Date: ${_date?.day}/${_date?.month}/${_date?.year} selected")),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final wallet = context.read<Wallet>();
                    DateTime? date;
                    if (_date != null) {
                      date = _date!;
                      // if date today...
                      if (date.year == DateTime.now().year &&
                          date.month == DateTime.now().month &&
                          date.day == DateTime.now().day) {
                        final today = DateTime.now();
                        date.add(
                          Duration(
                              hours: today.hour,
                              minutes: today.minute,
                              seconds: today.second,
                              milliseconds: today.millisecond),
                        );
                      }
                    }
                    WalletApi.newExpense(
                            currency: _currencyController.text,
                            amount: _amountController.text,
                            category: _categoryController.text,
                            createdAt: date ?? _date,
                            comment: _commentController.text)
                        .then((value) {
                      wallet.update();
                    });
                    Navigator.pop(context);
                  }
                },
                child: const Text("Create"),
              ),
            ],
          )),
    );
  }
}
