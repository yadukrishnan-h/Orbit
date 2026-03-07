import 'dart:math';

/// Formats a double as a percentage string with 2 decimal places.
/// Example: 0.1234 -> "12.34%"
String formatPercent(double value) {
  // If value is 0-1, multiply by 100?
  // User request said: 'Your CPU will show `0.94%` instead of `0%`.'
  // Our parser returns 0-100 values already (e.g. 45.2).
  // So we just format it.
  return "${value.toStringAsFixed(2)}%";
}

/// Formats bytes into human-readable string (KB, MB, GB).
/// maxDecimals: default 2
String formatBytes(num bytes, [int decimals = 2]) {
  if (bytes <= 0) return "0 B";
  const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
  var i = (log(bytes) / log(1024)).floor();
  return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
}
