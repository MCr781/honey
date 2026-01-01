import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../app_providers.dart';
import '../../core/formatters.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('سوابق'),
        actions: [
          IconButton(
            tooltip: 'خروجی CSV',
            onPressed: history.isEmpty ? null : () => _exportCsv(context, ref),
            icon: const Icon(Icons.table_view),
          ),
          IconButton(
            tooltip: 'پاک کردن همه',
            onPressed: history.isEmpty
                ? null
                : () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (c) => AlertDialog(
                        title: const Text('پاک کردن همه سوابق؟'),
                        content: const Text('این عملیات قابل برگشت نیست.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(c, false),
                            child: const Text('انصراف'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(c, true),
                            child: const Text('پاک کن'),
                          ),
                        ],
                      ),
                    );
                    if (ok == true) {
                      await ref.read(historyProvider.notifier).clear();
                    }
                  },
            icon: const Icon(Icons.delete_sweep),
          ),
        ],
      ),
      body: history.isEmpty
          ? const Center(child: Text('هنوز موردی ذخیره نشده است.'))
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: history.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final r = history[i];
                return Card(
                  child: ListTile(
                    title: Text('${r.input.honeyType} — ${formatNumber(r.input.kg, fractionDigits: 2)} کیلو'),
                    subtitle: Text('کل: ${formatToman(r.output.suggestedSaleTotal)} | هر کیلو: ${formatToman(r.output.suggestedSalePerKg)}'),
                    trailing: PopupMenuButton<String>(
                      onSelected: (v) async {
                        if (v == 'copy') {
                          ref.read(calculatorProvider.notifier).setFromHistory(r.input);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('به فرم محاسبه منتقل شد')),
                          );
                        } else if (v == 'delete') {
                          await ref.read(historyProvider.notifier).delete(r.id);
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'copy', child: Text('کپی به محاسبه')),
                        PopupMenuItem(value: 'delete', child: Text('حذف')),
                      ],
                    ),
                    onTap: () => showModalBottomSheet(
                      context: context,
                      showDragHandle: true,
                      builder: (_) => _HistoryDetails(recordIndex: i),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Future<void> _exportCsv(BuildContext context, WidgetRef ref) async {
    final history = ref.read(historyProvider);
    final rows = <List<dynamic>>[
      [
        'تاریخ',
        'نوع عسل',
        'کیلو',
        'قیمت خرید/کیلو',
        'ظرف',
        'روش تحویل',
        'ارسال واقعی',
        'ارسال پیشنهادی',
        'جمع هزینه',
        'فروش کل پیشنهادی',
        'فروش پیشنهادی/کیلو',
      ],
    ];

    for (final r in history) {
      rows.add([
        r.createdAt.toIso8601String(),
        r.input.honeyType,
        r.input.kg,
        r.input.buyPricePerKg,
        r.input.containerName,
        r.input.deliveryMethod,
        r.input.actualShippingCost ?? '',
        r.output.suggestedShippingCost,
        r.output.totalCost,
        r.output.suggestedSaleTotal,
        r.output.suggestedSalePerKg,
      ]);
    }

    final csv = const ListToCsvConverter().convert(rows);

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/honey_history_${DateTime.now().millisecondsSinceEpoch}.csv');
    await file.writeAsString(csv, flush: true);

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'سوابق محاسبه قیمت عسل (CSV)',
      subject: 'سوابق محاسبه قیمت عسل',
    );
  }
}

class _HistoryDetails extends ConsumerWidget {
  final int recordIndex;
  const _HistoryDetails({required this.recordIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final record = ref.watch(historyProvider)[recordIndex];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          Text(
            'جزئیات',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          _kv('نوع عسل', record.input.honeyType),
          _kv('مقدار (کیلو)', formatNumber(record.input.kg, fractionDigits: 2)),
          _kv('قیمت خرید/کیلو', formatToman(record.input.buyPricePerKg)),
          _kv('ظرف', record.input.containerName),
          _kv('روش تحویل', record.input.deliveryMethod),
          _kv('ارسال واقعی', record.input.actualShippingCost == null ? '—' : formatToman(record.input.actualShippingCost)),
          const Divider(),
          _kv('لیتر تقریبی', formatNumber(record.output.approxLiter, fractionDigits: 2)),
          _kv('تعداد ظرف', formatNumber(record.output.containerCount, fractionDigits: 0)),
          _kv('ظرفیت کل (لیتر)', formatNumber(record.output.totalContainerCapacityLiter, fractionDigits: 2)),
          const Divider(),
          _kv('هزینه ظرف', formatToman(record.output.containerCost)),
          _kv('هزینه ارتباطات', formatToman(record.output.communicationsCost)),
          _kv('هزینه انبارداری', formatToman(record.output.storageCost)),
          _kv('هزینه بسته‌بندی', formatToman(record.output.packagingCost)),
          _kv('هزینه عسل با ضایعات', formatToman(record.output.honeyCostWithWaste)),
          _kv('ارسال پیشنهادی', formatToman(record.output.suggestedShippingCost)),
          _kv('ارسال لحاظ‌شده', formatToman(record.output.usedShippingCost)),
          const Divider(),
          _kv('جمع کل هزینه', formatToman(record.output.totalCost)),
          _kv('قیمت فروش پیشنهادی (کل)', formatToman(record.output.suggestedSaleTotal)),
          _kv('قیمت پیشنهادی/کیلو', formatToman(record.output.suggestedSalePerKg)),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {
              ref.read(calculatorProvider.notifier).setFromHistory(record.input);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('به فرم محاسبه منتقل شد')),
              );
            },
            icon: const Icon(Icons.copy),
            label: const Text('کپی به صفحه محاسبه'),
          ),
        ],
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(k)),
          const SizedBox(width: 12),
          Text(v, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
