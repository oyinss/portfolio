/// Shared shell for admin pages: title + back to dashboard.
library;

import 'package:flutter/material.dart';

class AdminScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final Widget? action;
  final bool showBack;
  const AdminScaffold({
    super.key,
    required this.title,
    required this.body,
    this.action,
    this.showBack = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        automaticallyImplyLeading: showBack,
        actions: action == null ? null : [Padding(padding: const EdgeInsets.only(right: 8), child: action!)],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: body,
          ),
        ),
      ),
    );
  }
}

/// Delete confirmation dialog. Returns true when confirmed.
Future<bool> confirmDelete(BuildContext context, String label) async {
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete?'),
          content: Text('Delete "$label"? This cannot be undone.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
          ],
        ),
      ) ??
      false;
}

void showAdminError(BuildContext context, Object e) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
}
