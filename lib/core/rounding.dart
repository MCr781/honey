int roundDownToThousand(num value) {
  final v = value.toDouble();
  if (v.isNaN || v.isInfinite) return 0;
  if (v <= 0) return 0;
  return (v / 1000).floor() * 1000;
}

int roundUpToInt(num value) {
  final v = value.toDouble();
  if (v.isNaN || v.isInfinite) return 0;
  return v.ceil();
}
