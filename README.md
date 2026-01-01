# Honey Pricer (اپ محاسبه قیمت عسل)

این پروژه یک اپ آفلاین و RTL (فارسی) برای محاسبه قیمت فروش عسل است که منطق آن از فایل اکسل `honey_pricing_rtl_dropdown_final.xlsx` پیاده‌سازی شده.

## امکانات
- محاسبه قیمت فروش پیشنهادی (کل و به ازای هر کیلو) با گردکردن رو به پایین به هزار تومان
- مدیریت تنظیمات (سود، ضایعات، چگالی، هزینه تماس/پیامک، هزینه انبارداری، بسته‌بندی و…)
- مدیریت ظروف (حجم/قیمت ظرف)
- مدیریت انواع عسل (Dropdown)
- مدیریت روش‌های تحویل و هزینه ارسال پیشنهادی
- سوابق محاسبات + خروجی CSV (Share)

## پیش‌نیاز
- Flutter SDK نصب باشد.

## راه‌اندازی سریع
1) یک پروژه Flutter بسازید:
```bash
flutter create honey_pricer
cd honey_pricer
```

2) محتویات این ریپو/فایل‌ها را روی پروژه تازه ساخته شده کپی کنید:
- `pubspec.yaml` را جایگزین کنید
- پوشه‌های `lib/`, `test/`, `assets/` را جایگزین کنید

3) پکیج‌ها:
```bash
flutter pub get
```

4) فونت (اختیاری ولی پیشنهاد می‌شود)
- فایل‌های فونت **Vazirmatn** را در مسیر `assets/fonts/` قرار دهید:
  - `Vazirmatn-Regular.ttf`
  - `Vazirmatn-Bold.ttf`
- اگر فونت را قرار ندهید، اپ با فونت پیش‌فرض اجرا می‌شود (ممکن است در کنسول هشدار asset ببینید).

5) اجرا:
```bash
flutter run
```

## Build گرفتن APK (Release)
```bash
flutter build apk --release
```

خروجی در مسیر:
`build/app/outputs/flutter-apk/app-release.apk`

## Build گرفتن AAB (برای Play Store)
```bash
flutter build appbundle --release
```

