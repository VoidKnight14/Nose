class CalendarUtils {
  /// Devuelve el lunes correspondiente al inicio de la semana para la fecha dada.
  static DateTime getStartOfWeek(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    // Calendar arithmetic, not Duration: a DST change can shift the hour.
    return DateTime(
      normalized.year,
      normalized.month,
      normalized.day - (normalized.weekday - 1),
    );
  }

  /// Genera los 7 días reales de la semana a partir de la fecha de referencia,
  /// manejando correctamente los límites de mes y año.
  static List<DateTime> getDaysOfWeek(DateTime date) {
    final start = getStartOfWeek(date);
    return List.generate(7, (i) {
      return DateTime(start.year, start.month, start.day + i);
    });
  }

  /// Compara si dos fechas corresponden al mismo día del calendario.
  static bool isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Navega al primer día del mes anterior (seguro entre años).
  static DateTime previousMonth(DateTime date) {
    return DateTime(date.year, date.month - 1, 1);
  }

  /// Navega al primer día del mes siguiente (seguro entre años).
  static DateTime nextMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 1);
  }

  /// Navega 7 días hacia atrás.
  static DateTime previousWeek(DateTime date) {
    return DateTime(date.year, date.month, date.day - 7);
  }

  /// Navega 7 días hacia adelante.
  static DateTime nextWeek(DateTime date) {
    return DateTime(date.year, date.month, date.day + 7);
  }
}
