import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

String formatIsoDate(String isoDate) {
  try {
    final date = DateTime.parse(isoDate);
    return DateFormat.yMMMd().format(date);
  } catch (_) {
    return isoDate;
  }
}

String formatIsoDateAsTimeAgo(String isoDate, String languageCode) {
  try {
    final date = DateTime.parse(isoDate).toLocal();
    return timeago.format(date, locale: languageCode);
  } catch (_) {
    return isoDate;
  }
}

extension DateTimeExtension on DateTime? {
  String toHumanReadableDate() {
    if (this == null) {
      return '';
    }
    return DateFormat('dd MMM yyyy').format(this!.toLocal());
  }

  String formatBookingUpdatedAt() {
    if (this == null) {
      return '';
    }
    return DateFormat('dd MMM yyyy').format(this!.toLocal());
  }

  String getFirstLetterOfWeekday() {
    if (this == null) {
      return '';
    }
    const days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return days[
        this!.weekday % 7]; // because DateTime.weekday is 1=Mon ... 7=Sun
  }

  bool isSameDay(DateTime other) {
    return this?.year == other.year &&
        this?.month == other.month &&
        this?.day == other.day;
  }

  String toHumanReadableDateWithDayOfWeek() {
    if (this == null) {
      return '';
    }
    // Tue, Oct 8
    return DateFormat('EEE, dd MMM').format(this!.toLocal());
  }

  bool isPastDate() {
    if (this == null) {
      return false;
    }
    final now = DateTime.now();
    final nowDate = DateTime(now.year, now.month, now.day);
    final thisDate = DateTime(this!.year, this!.month, this!.day);
    return thisDate.isBefore(nowDate);
  }

  String toSlashDate() {
    if (this == null) {
      return '';
    }
    return DateFormat('dd/MM/yyyy').format(this!.toLocal());
  }
}
