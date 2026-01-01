import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_providers.dart';
import '../../core/formatters.dart';
import '../../data/models.dart';
import '../widgets/persian_number_field.dart';
import 'containers_screen.dart';
import 'delivery_methods_screen.dart';
import 'honey_types_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late SettingsModel _draft;

  @override
  void initState() {
    super.initState();
    _draft = ref.read(settingsProvider);
  }

  double _asFraction(double? v) {
    if (v == null) return 0;
    if (v > 1) return v / 100.0;
    return v;
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    // اگر بیرون از این صفحه تنظیمات تغییر کرد (کم احتمال)، در draft هم sync شود
    if (settings.toJson() != _draft.toJson()) {
      // فقط وقتی draft هنوز همسان است، تغییرات خارجی را اعمال کن
      // (برای سادگی: اگر کاربر در حال تایپ نباشد، معمولاً این اتفاق نمی‌افتد)
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('تنظیمات'),
        actions: [
          FilledButton(
            onPressed: () async {
              await ref.read(settingsProvider.notifier).update(_draft);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تنظیمات ذخیره شد')),
                );
              }
            },
            child: const Text('ذخیره'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _GroupTitle('ارتباط با مشتری'),
          const SizedBox(height: 8),
          PersianNumberField(
            label: 'هزینه هر دقیقه تماس (تومان)',
            value: _draft.callCostPerMinute,
            allowDecimal: true,
            onChanged: (v) => setState(() => _draft = _draft.copyWith(callCostPerMinute: v ?? 0)),
          ),
          const SizedBox(height: 12),
          PersianNumberField(
            label: 'میانگین زمان مکالمه (دقیقه)',
            value: _draft.avgCallMinutes,
            allowDecimal: true,
            onChanged: (v) => setState(() => _draft = _draft.copyWith(avgCallMinutes: v ?? 0)),
          ),
          const SizedBox(height: 12),
          PersianNumberField(
            label: 'هزینه هر پیامک (تومان)',
            value: _draft.smsCost,
            allowDecimal: true,
            onChanged: (v) => setState(() => _draft = _draft.copyWith(smsCost: v ?? 0)),
          ),
          const SizedBox(height: 12),
          PersianNumberField(
            label: 'تعداد پیامک در هر فروش',
            value: _draft.smsCountPerSale,
            allowDecimal: false,
            onChanged: (v) => setState(() => _draft = _draft.copyWith(smsCountPerSale: (v ?? 0))),
          ),

          const SizedBox(height: 20),
          _GroupTitle('نیروی کار (بسته‌بندی)'),
          const SizedBox(height: 8),
          PersianNumberField(
            label: 'زمان لازم برای هر کیلو (دقیقه)',
            value: _draft.packMinutesPerKg,
            allowDecimal: true,
            onChanged: (v) => setState(() => _draft = _draft.copyWith(packMinutesPerKg: v ?? 0)),
          ),
          const SizedBox(height: 12),
          PersianNumberField(
            label: 'دستمزد یک ساعت کارگر (تومان)',
            value: _draft.hourlyWage,
            allowDecimal: false,
            onChanged: (v) => setState(() => _draft = _draft.copyWith(hourlyWage: v ?? 0)),
          ),
          const SizedBox(height: 8),
          _ReadOnlyRow(
            title: 'ارزش هر دقیقه (اتوماتیک)',
            value: formatToman(_draft.valuePerMinute),
          ),

          const SizedBox(height: 20),
          _GroupTitle('انبارداری (خانه)'),
          const SizedBox(height: 8),
          PersianNumberField(
            label: 'کل هزینه ماهانه فضای نگهداری (تومان)',
            value: _draft.monthlyStorageCost,
            allowDecimal: false,
            onChanged: (v) => setState(() => _draft = _draft.copyWith(monthlyStorageCost: v ?? 0)),
          ),
          const SizedBox(height: 12),
          PersianNumberField(
            label: 'پیش‌بینی فروش ماهانه (کیلو)',
            value: _draft.monthlySalesForecastKg,
            allowDecimal: true,
            onChanged: (v) => setState(() => _draft = _draft.copyWith(monthlySalesForecastKg: v ?? 0)),
          ),
          const SizedBox(height: 8),
          _ReadOnlyRow(
            title: 'هزینه انبار هر کیلو (اتوماتیک)',
            value: formatToman(_draft.storageCostPerKg),
          ),

          const SizedBox(height: 20),
          _GroupTitle('سیاست مالی'),
          const SizedBox(height: 8),
          PersianNumberField(
            label: 'درصد ضایعات (مثلاً ۱ یا ۰.۰۱)',
            value: _draft.wastePercent * 100.0,
            allowDecimal: true,
            onChanged: (v) => setState(() => _draft = _draft.copyWith(wastePercent: _asFraction(v))),
          ),
          const SizedBox(height: 12),
          PersianNumberField(
            label: 'درصد سود مورد انتظار (مثلاً ۱۰ یا ۰.۱)',
            value: _draft.profitPercent * 100.0,
            allowDecimal: true,
            onChanged: (v) => setState(() => _draft = _draft.copyWith(profitPercent: _asFraction(v))),
          ),

          const SizedBox(height: 20),
          _GroupTitle('تبدیل کیلو ↔ لیتر'),
          const SizedBox(height: 8),
          PersianNumberField(
            label: 'چگالی عسل (کیلوگرم بر لیتر)',
            value: _draft.densityKgPerLiter,
            allowDecimal: true,
            onChanged: (v) => setState(() => _draft = _draft.copyWith(densityKgPerLiter: v ?? 1)),
          ),

          const SizedBox(height: 24),
          _GroupTitle('مدیریت لیست‌ها'),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.inventory_2),
            title: const Text('ظرف‌ها'),
            subtitle: const Text('اضافه/حذف/ویرایش ظرف‌ها'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ContainersScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.hive),
            title: const Text('انواع عسل'),
            subtitle: const Text('مدیریت لیست دراپ‌داون'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HoneyTypesScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.local_shipping),
            title: const Text('روش‌های تحویل'),
            subtitle: const Text('هزینه ارسال پیشنهادی هر روش'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DeliveryMethodsScreen()),
            ),
          ),

          const SizedBox(height: 24),
          const Text(
            'نکته: اگر فونت Vazirmatn را در assets قرار ندهید، اپ با فونت پیش‌فرض اجرا می‌شود.',
          ),
        ],
      ),
    );
  }
}

class _GroupTitle extends StatelessWidget {
  final String text;
  const _GroupTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
    );
  }
}

class _ReadOnlyRow extends StatelessWidget {
  final String title;
  final String value;
  const _ReadOnlyRow({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(child: Text(title)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
