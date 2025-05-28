class TemperatureUtils {
  static double celsiusToFahrenheit(double celsius) {
    return (celsius * 9 / 5) + 32;
  }

  static double fahrenheitToCelsius(double fahrenheit) {
    return (fahrenheit - 32) * 5 / 9;
  }

  static double convertTemperature(double temperature, String fromUnit, String toUnit) {
    if (fromUnit == toUnit) return temperature;
    if (fromUnit == '°C' && toUnit == '°F') return celsiusToFahrenheit(temperature);
    if (fromUnit == '°F' && toUnit == '°C') return fahrenheitToCelsius(temperature);
    return temperature;
  }

  static String formatTemperature(double temperature, String unit) {
    return '${temperature.round()}$unit';
  }
}
