import 'package:flutter/material.dart';

class ValueTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData? icon;

  const ValueTile({
    super.key,
    required this.title,
    required this.value,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: icon == null ? null : Icon(icon),
      title: Text(title),
      trailing: Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}
