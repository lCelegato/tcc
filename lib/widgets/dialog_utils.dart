/// Widgets reutilizáveis para diálogos comuns
///
/// Centraliza a criação de diálogos padronizados
/// para manter consistência visual
library;

import 'package:flutter/material.dart';

class DialogUtils {
  /// Dialog para confirmar ação perigosa
  static Future<bool> showConfirmDialog({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirmar',
    String cancelText = 'Cancelar',
    Color? confirmColor,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: confirmColor != null
                ? ElevatedButton.styleFrom(backgroundColor: confirmColor)
                : null,
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Dialog para entrada de texto
  static Future<String?> showTextInputDialog({
    required BuildContext context,
    required String title,
    String? message,
    String? hintText,
    String? initialValue,
    bool obscureText = false,
    String confirmText = 'OK',
    String cancelText = 'Cancelar',
    String? Function(String?)? validator,
  }) async {
    return await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _TextInputDialog(
        title: title,
        message: message,
        hintText: hintText,
        initialValue: initialValue,
        obscureText: obscureText,
        confirmText: confirmText,
        cancelText: cancelText,
        validator: validator,
      ),
    );
  }

  /// Dialog de informação simples
  static Future<void> showInfoDialog({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'OK',
  }) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  /// Dialog de erro
  static Future<void> showErrorDialog({
    required BuildContext context,
    required String message,
    String title = 'Erro',
  }) async {
    await showInfoDialog(
      context: context,
      title: title,
      message: message,
    );
  }

  /// Dialog de sucesso
  static Future<void> showSuccessDialog({
    required BuildContext context,
    required String message,
    String title = 'Sucesso',
  }) async {
    await showInfoDialog(
      context: context,
      title: title,
      message: message,
    );
  }

  /// Dialog de carregamento
  static void showLoadingDialog({
    required BuildContext context,
    String message = 'Aguarde...',
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 16),
              Text(message),
            ],
          ),
        ),
      ),
    );
  }

  /// Fecha dialog de carregamento
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }
}

class _TextInputDialog extends StatefulWidget {
  final String title;
  final String? message;
  final String? hintText;
  final String? initialValue;
  final bool obscureText;
  final String confirmText;
  final String cancelText;
  final String? Function(String?)? validator;

  const _TextInputDialog({
    required this.title,
    this.message,
    this.hintText,
    this.initialValue,
    this.obscureText = false,
    this.confirmText = 'OK',
    this.cancelText = 'Cancelar',
    this.validator,
  });

  @override
  State<_TextInputDialog> createState() => _TextInputDialogState();
}

class _TextInputDialogState extends State<_TextInputDialog> {
  late final TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.message != null) ...[
              Text(widget.message!),
              const SizedBox(height: 16),
            ],
            TextFormField(
              controller: _controller,
              obscureText: widget.obscureText,
              decoration: InputDecoration(
                hintText: widget.hintText,
                border: const OutlineInputBorder(),
                prefixIcon: widget.obscureText
                    ? const Icon(Icons.lock)
                    : const Icon(Icons.text_fields),
              ),
              validator: widget.validator,
              autofocus: true,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: Text(widget.cancelText),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              Navigator.of(context).pop(_controller.text.trim());
            }
          },
          child: Text(widget.confirmText),
        ),
      ],
    );
  }
}
