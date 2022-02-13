import 'package:flutter/material.dart';

class SimpleEmptyState extends StatelessWidget {
  final String title;
  final String message;
  final IconData? icon;
  final Widget? button;

  const SimpleEmptyState({
    Key? key,
    required this.title,
    required this.message,
    this.icon,
    this.button,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null)
            Icon(
              icon,
              size: 48,
              color: Theme.of(context)
                  .textTheme
                  .bodyText1!
                  .color!
                  .withOpacity(0.6),
            ),
          if (icon != null) const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.headline6,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: Theme.of(context).textTheme.subtitle1!.fontSize,
              color: Theme.of(context)
                  .textTheme
                  .bodyText1!
                  .color!
                  .withOpacity(0.6),
              fontWeight: Theme.of(context).textTheme.bodyText1!.fontWeight,
            ),
          ),
          if (button != null) const SizedBox(height: 8),
          if (button != null) button!
        ],
      ),
    );
  }
}
