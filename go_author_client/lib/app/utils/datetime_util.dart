import 'package:intl/intl.dart' as intl;

class DateTimeUtil {
  static DateTime from(String gmt) {
    return DateTime.parse(gmt);
  }

  static String format(DateTime dateTime, {String format = 'yyyy-MM-dd HH:mm:ss'}) {
    intl.DateFormat formatter = intl.DateFormat(format);
    return formatter.format(dateTime);
  }

  static DateTime parse(String dateTimeString, {String format = 'yyyy-MM-dd HH:mm:ss'}) {
    intl.DateFormat parser = intl.DateFormat(format);
    return parser.parse(dateTimeString);
  }
}
