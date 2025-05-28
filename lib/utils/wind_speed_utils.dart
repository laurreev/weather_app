class WindSpeedUtils {
  static double metersPerSecondToKilometersPerHour(double mps) {
    return mps * 3.6;
  }

  static double metersPerSecondToMilesPerHour(double mps) {
    return mps * 2.237;
  }

  static double convertWindSpeed(double speed, String fromUnit, String toUnit) {
    if (fromUnit == toUnit) return speed;
    if (fromUnit == 'm/s' && toUnit == 'km/h') return metersPerSecondToKilometersPerHour(speed);
    if (fromUnit == 'm/s' && toUnit == 'mph') return metersPerSecondToMilesPerHour(speed);
    return speed;
  }

  static String formatWindSpeed(double speed, String unit) {
    return '${speed.toStringAsFixed(1)}$unit';
  }
}
