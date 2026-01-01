import 'package:intl/intl.dart';

/// تبدیل اعداد به قالب فارسی با جداکننده هزارگان.
final _faInt = NumberFormat.decimalPattern('fa');

String formatToman(num? value) {
  if (value == null) return '—';
  final intVal = value.round();
  return '${_faInt.format(intVal)} تومان';
}

String formatNumber(num? value, {int fractionDigits = 2}) {
  if (value == null) return '—';
  final nf = NumberFormat.decimalPattern('fa')
    ..minimumFractionDigits = fractionDigits
    ..maximumFractionDigits = fractionDigits;
  return nf.format(value);
}

/// تبدیل ارقام فارسی/عربی به لاتین برای پارس کردن ورودی‌ها.
String normalizeDigits(String input) {
  const fa = '۰۱۲۳۴۵۶۷۸۹';
  const ar = '٠١٢٣٤٥٦٧٨٩';
  final sb = StringBuffer();
  for (final ch in input.trim().split('')) {
    final faIndex = fa.indexOf(ch);
    if (faIndex != -1) {
      sb.write(faIndex);
      continue;
    }
    final arIndex = ar.indexOf(ch);
    if (arIndex != -1) {
      sb.write(arIndex);
      continue;
    }
    sb.write(ch);
  }
  return sb.toString();
}

double? tryParseDoubleFa(String? text) {
  if (text == null) return null;
  final t = normalizeDigits(text).replaceAll(',', '').replaceAll('٬', '');
  if (t.isEmpty) return null;
  return double.tryParse(t);
}
