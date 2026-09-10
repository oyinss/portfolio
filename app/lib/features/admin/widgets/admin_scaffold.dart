/// Shared shell for admin pages: title + working back button.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final Widget? action;
  final bool showBack;

  /// Where the back button goes when there is no navigation stack
  /// (admin routes are top-level, so `pop()` alone is usually a no-op).
  final String backTo;
  const AdminScaffold({
    super.key,
    required this.title,
    required this.body,
    this.action,
    this.showBack = true,
    this.backTo = '/admin',
  });

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(backTo);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: showBack ? BackButton(onPressed: () => _goBack(context)) : null,
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

/// Returns to where the user came from after a successful save.
/// Admin routes are top-level, so `pop()` alone is usually a no-op.
void goBackAfterSave(BuildContext context, String fallback) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go(fallback);
  }
}

void showAdminError(BuildContext context, Object e) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
}
