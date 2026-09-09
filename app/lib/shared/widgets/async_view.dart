/// Async page wrapper: loading spinner, error + retry, then content.
library;

import 'package:flutter/material.dart';

import '../../core/api/api_client.dart';

class AsyncView<T> extends StatefulWidget {
  final Future<T> Function() load;
  final Widget Function(BuildContext context, T data) builder;
  const AsyncView({super.key, required this.load, required this.builder});

  @override
  State<AsyncView<T>> createState() => _AsyncViewState<T>();
}

class _AsyncViewState<T> extends State<AsyncView<T>> {
  late Future<T> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.load();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const _Skeleton();
        }
        if (snap.hasError) {
          final message = snap.error is ApiException
              ? (snap.error as ApiException).message
              : 'Something went wrong.';
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off_outlined, size: 40),
                  const SizedBox(height: 12),
                  Text(message, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => setState(() => _future = widget.load()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }
        return widget.builder(context, snap.data as T);
      },
    );
  }
}

/// Gray placeholder blocks shown while content loads.
class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.6);
    Widget bar(double width, double height) => Container(
          width: width,
          height: height,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(color: base, borderRadius: BorderRadius.circular(8)),
        );
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          bar(160, 16),
          bar(280, 36),
          bar(220, 24),
          const SizedBox(height: 8),
          bar(double.infinity, 80),
          bar(double.infinity, 80),
          bar(double.infinity, 80),
        ],
      ),
    );
  }
}
