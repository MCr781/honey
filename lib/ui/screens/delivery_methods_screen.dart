import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_providers.dart';
import '../../core/formatters.dart';
import '../../data/models.dart';
import '../widgets/persian_number_field.dart';

class DeliveryMethodsScreen extends ConsumerWidget {
  const DeliveryMethodsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(deliveryMethodsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('روش‌های تحویل'),
        actions: [
          IconButton(
            tooltip: 'افزودن',
            onPressed: () => _openEditor(context, ref),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: list.isEmpty
          ? const Center(child: Text('هنوز روشی ثبت نشده است.'))
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final d = list[i];
                return Card(
                  child: ListTile(
                    title: Text(d.name),
                    subtitle: Text('هزینه پیشنهادی: ${formatToman(d.suggestedCost)}'),
                    trailing: PopupMenuButton<String>(
                      onSelected: (v) async {
                        if (v == 'edit') {
                          _openEditor(context, ref, existing: d);
                        } else if (v == 'delete') {
                          final next = [...list]..removeAt(i);
                          await ref.read(deliveryMethodsProvider.notifier).setAll(next);
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

  Future<void> _openEditor(
    BuildContext context,
    WidgetRef ref, {
    DeliveryMethodModel? existing,
  }) async {
    String name = existing?.name ?? '';
    double? cost = existing?.suggestedCost;

    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(existing == null ? 'افزودن روش تحویل' : 'ویرایش روش تحویل'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: name,
                decoration: const InputDecoration(labelText: 'نام روش'),
                onChanged: (v) => name = v,
              ),
              const SizedBox(height: 12),
              PersianNumberField(
                label: 'هزینه ارسال پیشنهادی (تومان)',
                value: cost,
                allowDecimal: false,
                onChanged: (v) => cost = v,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('انصراف')),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('ذخیره')),
        ],
      ),
    );

    if (ok != true) return;

    if (name.trim().isEmpty || (cost ?? 0) < 0) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ورودی‌ها معتبر نیستند')),
        );
      }
      return;
    }

    final list = ref.read(deliveryMethodsProvider);
    final edited = DeliveryMethodModel(name: name.trim(), suggestedCost: cost ?? 0);

    final next = [...list];
    if (existing == null) {
      next.add(edited);
    } else {
      final idx = next.indexWhere((x) => x.name == existing.name);
      if (idx == -1) {
        next.add(edited);
      } else {
        next[idx] = edited;
      }
    }
    await ref.read(deliveryMethodsProvider.notifier).setAll(next);
  }
}
