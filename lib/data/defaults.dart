import '../data/models.dart';

const defaultSettings = SettingsModel(
  callCostPerMinute: 79.0,
  avgCallMinutes: 5.0,
  smsCost: 11.5,
  smsCountPerSale: 2.0,
  packMinutesPerKg: 3.0,
  hourlyWage: 50000.0,
  monthlyStorageCost: 100000.0,
  monthlySalesForecastKg: 200.0,
  wastePercent: 0.01,
  profitPercent: 0.1,
  densityKgPerLiter: 1.42,
);

const defaultHoneyTypes = <String>[
  'عسل گون',
  'عسل چندگیاه',
  'عسل آویشن',
  'عسل کنار',
  'عسل مرکبات',
  'عسل گشنیز',
  'عسل اقاقیا',
  'عسل کوهی',
];

const defaultContainers = <ContainerModel>[
  ContainerModel(name: 'دبه 20 لیتری', volumeLiter: 20, buyPrice: 500000),
  ContainerModel(name: 'حلب 20 لیتری', volumeLiter: 20, buyPrice: 400000),
  ContainerModel(name: 'بطری 2 لیتری', volumeLiter: 2, buyPrice: 45000),
  ContainerModel(name: 'بطری 1 لیتری', volumeLiter: 1, buyPrice: 40000),
];

const defaultDeliveryMethods = <DeliveryMethodModel>[
  DeliveryMethodModel(name: 'تحویل حضوری از خانه (بدون ارسال)', suggestedCost: 0.0),
  DeliveryMethodModel(name: 'تولیدکننده ← خانه ما', suggestedCost: 0.0),
  DeliveryMethodModel(name: 'خانه ما ← مشتری', suggestedCost: 0.0),
  DeliveryMethodModel(name: 'تولیدکننده ← مشتری (مستقیم)', suggestedCost: 0.0),
];
