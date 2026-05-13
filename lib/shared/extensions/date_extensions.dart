import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  String get formattedTime => DateFormat('HH:mm').format(this);
  String get formattedDate => DateFormat('dd/MM').format(this);
  String get formattedDateTime => DateFormat('dd/MM • HH:mm').format(this);
  String get formattedWeekday => DateFormat('EEE, dd/MM', 'pt_BR').format(this);

  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }
}
