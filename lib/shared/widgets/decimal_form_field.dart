import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Campo numérico decimal que:
/// - Aceita apenas dígitos e um único separador decimal (ponto ou vírgula → converte para ponto)
/// - Bloqueia separadores consecutivos e separador no início
/// - Expõe [value] como double? (null quando vazio)
class DecimalFormField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final String? suffixText;
  final String? Function(String?)? validator;
  final EdgeInsetsGeometry? contentPadding;

  const DecimalFormField({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.suffixText,
    this.validator,
    this.contentPadding,
  });

  @override
  State<DecimalFormField> createState() => _DecimalFormFieldState();
}

class _DecimalFormFieldState extends State<DecimalFormField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      decoration: InputDecoration(
        labelText: widget.labelText,
        border: const OutlineInputBorder(),
        hintText: widget.hintText,
        suffixText: widget.suffixText,
        contentPadding: widget.contentPadding,
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [_DecimalInputFormatter()],
      validator: widget.validator,
    );
  }
}

class _DecimalInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final raw = newValue.text;
    if (raw.isEmpty) return newValue;

    // Normaliza vírgula para ponto
    final normalized = raw.replaceAll(',', '.');

    // Permite apenas dígitos e um único ponto
    final buffer = StringBuffer();
    bool hasDot = false;
    for (int i = 0; i < normalized.length; i++) {
      final ch = normalized[i];
      if (ch == '.') {
        // Bloqueia ponto no início ou ponto duplicado
        if (buffer.isEmpty || hasDot) continue;
        hasDot = true;
        buffer.write(ch);
      } else if (ch.contains(RegExp(r'[0-9]'))) {
        buffer.write(ch);
      }
      // qualquer outro caractere é descartado
    }

    final result = buffer.toString();

    // Corrige a posição do cursor
    final cursorOffset = newValue.selection.end.clamp(0, result.length);
    return TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: cursorOffset),
    );
  }
}
