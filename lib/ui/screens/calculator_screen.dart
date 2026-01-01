import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_providers.dart';
import '../../core/formatters.dart';
import '../../data/models.dart';
import '../widgets/persian_number_field.dart';
import '../widgets/value_tile.dart';

class CalculatorScreen extends ConsumerWidget {
  const CalculatorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final honeyTypes = ref.watch(honeyTypesProvider);
    final containers = ref.watch(containersProvider);
    final deliveryMethods = ref.watch(deliveryMethodsProvider);
    final calc = ref.watch(calculatorProvider);
    final out = ref.watch(calculationOutputProvider);

    final containerNames = containers.map((c) => c.name).toList();
    final deliveryNames = deliveryMethods.map((d) => d.name).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('محاسبه قیمت'),
        actions: [
          IconButton(
            tooltip: 'ریست',
            onPressed: () => ref.read(calculatorProvider.notifier).reset(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _SectionTitle('ورودی‌ها'),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: calc.honeyType,
            decoration: const InputDecoration(labelText: 'نوع عسل'),
            items: honeyTypes
                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                .toList(),
            onChanged: ref.read(calculatorProvider.notifier).setHoneyType,
          ),
          const SizedBox(height: 12),
          PersianNumberField(
            label: 'مقدار فروش (کیلوگرم)',
            hint: 'مثلاً ۲۱.۳',
            value: calc.kg,
            onChanged: ref.read(calculatorProvider.notifier).setKg,
          ),
          const SizedBox(height: 12),
          PersianNumberField(
            label: 'قیمت خرید عسل (تومان/کیلو)',
            hint: 'مثلاً ۲۰۰٬۰۰۰',
            value: calc.buyPricePerKg,
            allowDecimal: false,
            onChanged: ref.read(calculatorProvider.notifier).setBuyPrice,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: calc.containerName,
            decoration: const InputDecoration(labelText: 'نوع ظرف'),
            items: containerNames
                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                .toList(),
            onChanged: ref.read(calculatorProvider.notifier).setContainer,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: calc.deliveryMethod,
            decoration: const InputDecoration(labelText: 'روش تحویل'),
            items: deliveryNames
                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                .toList(),
            onChanged: ref.read(calculatorProvider.notifier).setDelivery,
          ),
          const SizedBox(height: 12),
          PersianNumberField(
            label: 'هزینه ارسال واقعی (اختیاری)',
            hint: 'اگر خالی باشد، هزینه پیشنهادی استفاده می‌شود',
            value: calc.actualShippingCost,
            allowDecimal: false,
            onChanged: ref.read(calculatorProvider.notifier).setActualShipping,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: out == null
                ? null
                : () async {
                    final record = _toRecord(calc.toInput(), out);
                    await ref.read(historyProvider.notifier).add(record);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('در سوابق ذخیره شد')),
                      );
                    }
                  },
            icon: const Icon(Icons.save),
            label: const Text('ذخیره در سوابق'),
          ),
          const SizedBox(height: 20),
          _SectionTitle('خروجی‌ها'),
          const SizedBox(height: 8),
          if (out == null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('برای دیدن خروجی‌ها، همه ورودی‌های لازم را پر کنید.'),
            )
          else
            _OutputPanel(output: out),
          const SizedBox(height: 24),
          _SectionTitle('یادآوری'),
          const SizedBox(height: 8),
          const Text(
            'اگر «هزینه ارسال واقعی» را وارد کنید، همان ملاک است؛ وگرنه هزینه پیشنهادی روش تحویل استفاده می‌شود.',
          ),
        ],
      ),
    );
  }

  CalculationRecord _toRecord(CalculationInput input, CalculationOutput out) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    return CalculationRecord(
      id: id,
      createdAt: DateTime.now(),
      input: input,
      output: out,
    );
  }
}

class _OutputPanel extends StatelessWidget {
  final CalculationOutput output;

  const _OutputPanel({required this.output});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ValueTile(
            title: 'معادل تقریبی (لیتر)',
            value: formatNumber(output.approxLiter, fractionDigits: 2),
            icon: Icons.local_drink,
          ),
          ValueTile(
            title: 'تعداد ظرف لازم',
            value: formatNumber(output.containerCount, fractionDigits: 0),
            icon: Icons.inventory_2,
          ),
          ValueTile(
            title: 'ظرفیت کل ظرف‌ها (لیتر)',
            value: formatNumber(output.totalContainerCapacityLiter, fractionDigits: 2),
            icon: Icons.water_drop,
          ),
          const Divider(height: 1),
          ValueTile(title: 'هزینه ظرف', value: formatToman(output.containerCost), icon: Icons.shopping_bag),
          ValueTile(title: 'هزینه ارتباطات', value: formatToman(output.communicationsCost), icon: Icons.phone),
          ValueTile(title: 'هزینه انبارداری', value: formatToman(output.storageCost), icon: Icons.home),
          ValueTile(title: 'هزینه بسته‌بندی', value: formatToman(output.packagingCost), icon: Icons.handyman),
          ValueTile(title: 'هزینه عسل (با ضایعات)', value: formatToman(output.honeyCostWithWaste), icon: Icons.hive),
          ValueTile(
            title: 'هزینه ارسال پیشنهادی',
            value: formatToman(output.suggestedShippingCost),
            icon: Icons.local_shipping,
          ),
          ValueTile(
            title: 'هزینه ارسال لحاظ‌شده',
            value: formatToman(output.usedShippingCost),
            icon: Icons.local_shipping_outlined,
          ),
          const Divider(height: 1),
          ValueTile(
            title: 'جمع کل هزینه',
            value: formatToman(output.totalCost),
            icon: Icons.summarize,
          ),
          ValueTile(
            title: 'قیمت فروش پیشنهادی (کل)',
            value: formatToman(output.suggestedSaleTotal),
            icon: Icons.price_check,
          ),
          ValueTile(
            title: 'قیمت پیشنهادی به ازای هر کیلو',
            value: formatToman(output.suggestedSalePerKg),
            icon: Icons.scale,
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
    );
  }
}
