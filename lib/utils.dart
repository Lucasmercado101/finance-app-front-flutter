const double thousand = 1000.0;
const double million = 1000000.0;
const double billion = 1000000000.0;

String prettifyCurrency(double amount) {
  amount = amount.abs();
  if (amount >= billion) {
    return "${(amount / billion).toStringAsFixed(2)}B";
  } else if (amount >= million) {
    return "${(amount / million).toStringAsFixed(2)}M";
  } else if (amount >= thousand) {
    return "${(amount / thousand).toStringAsFixed(2)}K";
  } else {
    return amount.toStringAsFixed(2);
  }
}

String weekDayToString(int weekDay) {
  switch (weekDay) {
    case DateTime.monday:
      return 'Monday';
    case DateTime.tuesday:
      return 'Tuesday';
    case DateTime.wednesday:
      return 'Wednesday';
    case DateTime.thursday:
      return 'Thursday';
    case DateTime.friday:
      return 'Friday';
    case DateTime.saturday:
      return 'Saturday';
    case DateTime.sunday:
      return 'Sunday';
    default:
      return 'Unknown';
  }
}

String monthToString(int month) {
  switch (month) {
    case DateTime.january:
      return 'January';
    case DateTime.february:
      return 'February';
    case DateTime.march:
      return 'March';
    case DateTime.april:
      return 'April';
    case DateTime.may:
      return 'May';
    case DateTime.june:
      return 'June';
    case DateTime.july:
      return 'July';
    case DateTime.august:
      return 'August';
    case DateTime.september:
      return 'September';
    case DateTime.october:
      return 'October';
    case DateTime.november:
      return 'November';
    case DateTime.december:
      return 'December';
    default:
      return 'Unknown';
  }
}
