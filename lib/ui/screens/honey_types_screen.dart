import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_providers.dart';

class HoneyTypesScreen extends ConsumerWidget {
  const HoneyTypesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(honeyTypesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('انواع عسل'),
        actions: [
          IconButton(
            tooltip: 'افزودن',
            onPressed: () => _addOrEdit(context, ref),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: list.isEmpty
          ? const Center(child: Text('هنوز نوعی ثبت نشده است.'))
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final t = list[i];
                return Card(
                  child: ListTile(
                    title: Text(t),
                    trailing: PopupMenuButton<String>(
                      onSelected: (v) async {
                        if (v == 'edit') {
                          _addOrEdit(context, ref, existing: t);
                        } else if (v == 'delete') {
                          final next = [...list]..removeAt(i);
                          await ref.read(honeyTypesProvider.notifier).setAll(next);
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'edit', child: Text('ویرایش')),
                        PopupMenuItem(value: 'delete', child: Text('حذف')),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Future<void> _addOrEdit(BuildContext context, WidgetRef ref,
      {String? existing}) async {
    String value = existing ?? '';
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(existing == null ? 'افزودن نوع عسل' : 'ویرایش نوع عسل'),
        content: TextFormField(
          initialValue: value,
          decoration: const InputDecoration(labelText: 'نام'),
          onChanged: (v) => value = v,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('انصراف')),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('ذخیره')),
        ],
      ),
    );

    if (ok != true) return;

    value = value.trim();
    if (value.isEmpty) return;

    final list = ref.read(honeyTypesProvider);
    final next = [...list];
    if (existing == null) {
      next.add(value);
    } else {
      final idx = next.indexOf(existing);
      if (idx >= 0) next[idx] = value;
    }
    await ref.read(honeyTypesProvider.notifier).setAll(next);
  }
}
