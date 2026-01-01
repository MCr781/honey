import 'package:flutter/material.dart';
import '../../core/formatters.dart';

class PersianNumberField extends StatefulWidget {
  final String label;
  final String? hint;
  final double? value;
  final void Function(double?) onChanged;
  final bool allowDecimal;
  final bool allowEmpty;
  final TextInputAction? textInputAction;

  const PersianNumberField({
    super.key,
    required this.label,
    required this.onChanged,
    this.hint,
    this.value,
    this.allowDecimal = true,
    this.allowEmpty = true,
    this.textInputAction,
  });

  @override
  State<PersianNumberField> createState() => _PersianNumberFieldState();
}

class _PersianNumberFieldState extends State<PersianNumberField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  String _valueToText(double? v) {
    if (v == null) return '';
    // نمایش ساده برای ویرایش (بدون جداکننده) تا تایپ راحت باشد
    final asInt = v == v.roundToDouble();
    return asInt ? v.round().toString() : v.toString();
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _valueToText(widget.value));
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant PersianNumberField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_focusNode.hasFocus && oldWidget.value != widget.value) {
      _controller.text = _valueToText(widget.value);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      focusNode: _focusNode,
      keyboardType: TextInputType.numberWithOptions(decimal: widget.allowDecimal),
      textInputAction: widget.textInputAction,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
      ),
      onChanged: (v) {
        if (v.trim().isEmpty && widget.allowEmpty) {
          widget.onChanged(null);
          return;
        }
        widget.onChanged(tryParseDoubleFa(v));
      },
    );
  }
}
