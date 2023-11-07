import 'package:intl/intl.dart';

extension DateTimeExt on DateTime {
  String format() {
    return DateFormat('yyyy-MM-dd kk:mm').format(this);
  }
}
