import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

/// Date and time utility functions
class DateTimeUtils {
  // Prevent instantiation
  DateTimeUtils._();

  /// Format date to short format (MMM dd, yyyy)
  static String formatShortDate(DateTime date) {
    return DateFormat(AppConstants.shortDateFormat).format(date);
  }

  /// Format date to long format (MMMM dd, yyyy)
  static String formatLongDate(DateTime date) {
    return DateFormat(AppConstants.longDateFormat).format(date);
  }

  /// Format time (HH:mm)
  static String formatTime(DateTime dateTime) {
    return DateFormat(AppConstants.timeFormat).format(dateTime);
  }

  /// Format date and time (MMM dd, yyyy HH:mm)
  static String formatDateTime(DateTime dateTime) {
    return DateFormat(AppConstants.dateTimeFormat).format(dateTime);
  }

  /// Format date with custom pattern
  static String formatCustom(DateTime date, String pattern) {
    return DateFormat(pattern).format(date);
  }

  /// Get relative time string (e.g., "2 hours ago", "in 3 days")
  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);

    if (difference.isNegative) {
      // Past
      final positiveDiff = difference.abs();

      if (positiveDiff.inSeconds < 60) {
        return 'just now';
      } else if (positiveDiff.inMinutes < 60) {
        final minutes = positiveDiff.inMinutes;
        return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
      } else if (positiveDiff.inHours < 24) {
        final hours = positiveDiff.inHours;
        return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
      } else if (positiveDiff.inDays < 7) {
        final days = positiveDiff.inDays;
        return '$days ${days == 1 ? 'day' : 'days'} ago';
      } else if (positiveDiff.inDays < 30) {
        final weeks = (positiveDiff.inDays / 7).floor();
        return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
      } else if (positiveDiff.inDays < 365) {
        final months = (positiveDiff.inDays / 30).floor();
        return '$months ${months == 1 ? 'month' : 'months'} ago';
      } else {
        final years = (positiveDiff.inDays / 365).floor();
        return '$years ${years == 1 ? 'year' : 'years'} ago';
      }
    } else {
      // Future
      if (difference.inSeconds < 60) {
        return 'in a moment';
      } else if (difference.inMinutes < 60) {
        final minutes = difference.inMinutes;
        return 'in $minutes ${minutes == 1 ? 'minute' : 'minutes'}';
      } else if (difference.inHours < 24) {
        final hours = difference.inHours;
        return 'in $hours ${hours == 1 ? 'hour' : 'hours'}';
      } else if (difference.inDays < 7) {
        final days = difference.inDays;
        return 'in $days ${days == 1 ? 'day' : 'days'}';
      } else if (difference.inDays < 30) {
        final weeks = (difference.inDays / 7).floor();
        return 'in $weeks ${weeks == 1 ? 'week' : 'weeks'}';
      } else if (difference.inDays < 365) {
        final months = (difference.inDays / 30).floor();
        return 'in $months ${months == 1 ? 'month' : 'months'}';
      } else {
        final years = (difference.inDays / 365).floor();
        return 'in $years ${years == 1 ? 'year' : 'years'}';
      }
    }
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
           date.month == now.month &&
           date.day == now.day;
  }

  /// Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
           date.month == yesterday.month &&
           date.day == yesterday.day;
  }

  /// Check if date is tomorrow
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
           date.month == tomorrow.month &&
           date.day == tomorrow.day;
  }

  /// Check if date is in the past
  static bool isPast(DateTime date) {
    return date.isBefore(DateTime.now());
  }

  /// Check if date is in the future
  static bool isFuture(DateTime date) {
    return date.isAfter(DateTime.now());
  }

  /// Get start of day
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Get end of day
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  /// Get start of week (Monday)
  static DateTime startOfWeek(DateTime date) {
    final weekday = date.weekday;
    final daysToSubtract = weekday - 1;
    return startOfDay(date.subtract(Duration(days: daysToSubtract)));
  }

  /// Get end of week (Sunday)
  static DateTime endOfWeek(DateTime date) {
    final weekday = date.weekday;
    final daysToAdd = 7 - weekday;
    return endOfDay(date.add(Duration(days: daysToAdd)));
  }

  /// Get start of month
  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// Get end of month
  static DateTime endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59, 999);
  }

  /// Get start of year
  static DateTime startOfYear(DateTime date) {
    return DateTime(date.year, 1, 1);
  }

  /// Get end of year
  static DateTime endOfYear(DateTime date) {
    return DateTime(date.year, 12, 31, 23, 59, 59, 999);
  }

  /// Get days between two dates
  static int daysBetween(DateTime start, DateTime end) {
    return end.difference(start).inDays;
  }

  /// Get months between two dates
  static int monthsBetween(DateTime start, DateTime end) {
    return (end.year - start.year) * 12 + end.month - start.month;
  }

  /// Get years between two dates
  static int yearsBetween(DateTime start, DateTime end) {
    return end.year - start.year;
  }

  /// Add business days to a date (excluding weekends)
  static DateTime addBusinessDays(DateTime date, int days) {
    var result = date;
    var daysAdded = 0;

    while (daysAdded < days) {
      result = result.add(const Duration(days: 1));
      if (result.weekday != DateTime.saturday &&
          result.weekday != DateTime.sunday) {
        daysAdded++;
      }
    }

    return result;
  }

  /// Check if date is weekend
  static bool isWeekend(DateTime date) {
    return date.weekday == DateTime.saturday ||
           date.weekday == DateTime.sunday;
  }

  /// Check if date is weekday
  static bool isWeekday(DateTime date) {
    return !isWeekend(date);
  }

  /// Get age from birthdate
  static int getAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;

    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }

    return age;
  }

  /// Format duration to readable string
  static String formatDuration(Duration duration) {
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;

    if (days > 0) {
      return '$days ${days == 1 ? 'day' : 'days'}, $hours ${hours == 1 ? 'hour' : 'hours'}';
    } else if (hours > 0) {
      return '$hours ${hours == 1 ? 'hour' : 'hours'}, $minutes ${minutes == 1 ? 'minute' : 'minutes'}';
    } else {
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'}';
    }
  }

  /// Parse date from string with multiple format attempts
  static DateTime? tryParse(String dateString) {
    // Try ISO 8601 format first
    DateTime? date = DateTime.tryParse(dateString);
    if (date != null) return date;

    // Try common formats
    final formats = [
      'yyyy-MM-dd',
      'dd/MM/yyyy',
      'MM/dd/yyyy',
      'yyyy/MM/dd',
      'dd-MM-yyyy',
      'MM-dd-yyyy',
      'MMM dd, yyyy',
      'MMMM dd, yyyy',
      'dd MMM yyyy',
      'dd MMMM yyyy',
    ];

    for (final format in formats) {
      try {
        return DateFormat(format).parse(dateString);
      } catch (_) {
        // Continue to next format
      }
    }

    return null;
  }

  /// Get greeting based on time of day
  static String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else if (hour < 21) {
      return 'Good Evening';
    } else {
      return 'Good Night';
    }
  }

  /// Check if year is leap year
  static bool isLeapYear(int year) {
    if (year % 4 != 0) return false;
    if (year % 100 != 0) return true;
    if (year % 400 != 0) return false;
    return true;
  }

  /// Get number of days in month
  static int daysInMonth(int year, int month) {
    if (month == 2 && isLeapYear(year)) {
      return 29;
    }

    const daysPerMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    return daysPerMonth[month - 1];
  }

  /// Convert DateTime to Firestore timestamp format
  static Map<String, dynamic> toTimestamp(DateTime dateTime) {
    return {
      '_seconds': dateTime.millisecondsSinceEpoch ~/ 1000,
      '_nanoseconds': (dateTime.millisecondsSinceEpoch % 1000) * 1000000,
    };
  }

  /// Convert Firestore timestamp to DateTime
  static DateTime fromTimestamp(dynamic timestamp) {
    if (timestamp == null) return DateTime.now();

    if (timestamp is DateTime) {
      return timestamp;
    }

    if (timestamp is Map) {
      final seconds = timestamp['_seconds'] ?? 0;
      final nanoseconds = timestamp['_nanoseconds'] ?? 0;
      return DateTime.fromMillisecondsSinceEpoch(
        seconds * 1000 + nanoseconds ~/ 1000000,
      );
    }

    return DateTime.now();
  }
}