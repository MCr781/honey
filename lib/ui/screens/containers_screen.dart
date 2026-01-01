import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_providers.dart';
import '../../core/formatters.dart';
import '../../data/models.dart';
import '../widgets/persian_number_field.dart';

class ContainersScreen extends ConsumerWidget {
  const ContainersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(containersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ظرف‌ها'),
        actions: [
          IconButton(
            tooltip: 'افزودن',
            onPressed: () => _openEditor(context, ref),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: list.isEmpty
          ? const Center(child: Text('هیچ ظرفی ثبت نشده است.'))
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final c = list[i];
                return Card(
                  child: ListTile(
                    title: Text(c.name),
                    subtitle: Text('حجم: ${formatNumber(c.volumeLiter, fractionDigits: 2)} لیتر | قیمت: ${formatToman(c.buyPrice)}'),
                    trailing: PopupMenuButton<String>(
                      onSelected: (v) async {
                        if (v == 'edit') {
                          _openEditor(context, ref, existing: c);
                        } else if (v == 'delete') {
                          final next = [...list]..removeAt(i);
                          await ref.read(containersProvider.notifier).setAll(next);
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
    ContainerModel? existing,
  }) async {
    String name = existing?.name ?? '';
    double? volume = existing?.volumeLiter;
    double? price = existing?.buyPrice;

    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(existing == null ? 'افزودن ظرف' : 'ویرایش ظرف'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: name,
                decoration: const InputDecoration(labelText: 'نام ظرف'),
                onChanged: (v) => name = v,
              ),
              const SizedBox(height: 12),
              PersianNumberField(
                label: 'حجم (لیتر)',
                value: volume,
                onChanged: (v) => volume = v,
              ),
              const SizedBox(height: 12),
              PersianNumberField(
                label: 'قیمت خرید ظرف (تومان)',
                value: price,
                allowDecimal: false,
                onChanged: (v) => price = v,
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

    if (name.trim().isEmpty || (volume ?? 0) <= 0 || (price ?? 0) < 0) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ورودی‌ها معتبر نیستند')),
        );
      }
      return;
    }

    final list = ref.read(containersProvider);
    final edited = ContainerModel(name: name.trim(), volumeLiter: volume!, buyPrice: price ?? 0);

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
    await ref.read(containersProvider.notifier).setAll(next);
  }
}
