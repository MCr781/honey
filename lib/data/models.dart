import 'dart:convert';

class SettingsModel {
  final double callCostPerMinute;
  final double avgCallMinutes;
  final double smsCost;
  final double smsCountPerSale;

  final double packMinutesPerKg;
  final double hourlyWage;

  final double monthlyStorageCost;
  final double monthlySalesForecastKg;

  /// مثلا 0.01 یعنی 1%
  final double wastePercent;

  /// مثلا 0.1 یعنی 10%
  final double profitPercent;

  /// کیلوگرم بر لیتر
  final double densityKgPerLiter;

  const SettingsModel({
    required this.callCostPerMinute,
    required this.avgCallMinutes,
    required this.smsCost,
    required this.smsCountPerSale,
    required this.packMinutesPerKg,
    required this.hourlyWage,
    required this.monthlyStorageCost,
    required this.monthlySalesForecastKg,
    required this.wastePercent,
    required this.profitPercent,
    required this.densityKgPerLiter,
  });

  double get valuePerMinute => hourlyWage / 60.0;

  double get storageCostPerKg {
    if (monthlySalesForecastKg <= 0) return 0;
    return monthlyStorageCost / monthlySalesForecastKg;
  }

  double communicationsCostPerSale() {
    return (callCostPerMinute * avgCallMinutes) + (smsCost * smsCountPerSale);
  }

  Map<String, dynamic> toMap() => {
        'callCostPerMinute': callCostPerMinute,
        'avgCallMinutes': avgCallMinutes,
        'smsCost': smsCost,
        'smsCountPerSale': smsCountPerSale,
        'packMinutesPerKg': packMinutesPerKg,
        'hourlyWage': hourlyWage,
        'monthlyStorageCost': monthlyStorageCost,
        'monthlySalesForecastKg': monthlySalesForecastKg,
        'wastePercent': wastePercent,
        'profitPercent': profitPercent,
        'densityKgPerLiter': densityKgPerLiter,
      };

  String toJson() => jsonEncode(toMap());

  static SettingsModel fromMap(Map<String, dynamic> map) => SettingsModel(
        callCostPerMinute: (map['callCostPerMinute'] ?? 0).toDouble(),
        avgCallMinutes: (map['avgCallMinutes'] ?? 0).toDouble(),
        smsCost: (map['smsCost'] ?? 0).toDouble(),
        smsCountPerSale: (map['smsCountPerSale'] ?? 0).toDouble(),
        packMinutesPerKg: (map['packMinutesPerKg'] ?? 0).toDouble(),
        hourlyWage: (map['hourlyWage'] ?? 0).toDouble(),
        monthlyStorageCost: (map['monthlyStorageCost'] ?? 0).toDouble(),
        monthlySalesForecastKg: (map['monthlySalesForecastKg'] ?? 0).toDouble(),
        wastePercent: (map['wastePercent'] ?? 0).toDouble(),
        profitPercent: (map['profitPercent'] ?? 0).toDouble(),
        densityKgPerLiter: (map['densityKgPerLiter'] ?? 1).toDouble(),
      );

  static SettingsModel fromJson(String s) =>
      fromMap((jsonDecode(s) as Map).cast<String, dynamic>());

  SettingsModel copyWith({
    double? callCostPerMinute,
    double? avgCallMinutes,
    double? smsCost,
    double? smsCountPerSale,
    double? packMinutesPerKg,
    double? hourlyWage,
    double? monthlyStorageCost,
    double? monthlySalesForecastKg,
    double? wastePercent,
    double? profitPercent,
    double? densityKgPerLiter,
  }) =>
      SettingsModel(
        callCostPerMinute: callCostPerMinute ?? this.callCostPerMinute,
        avgCallMinutes: avgCallMinutes ?? this.avgCallMinutes,
        smsCost: smsCost ?? this.smsCost,
        smsCountPerSale: smsCountPerSale ?? this.smsCountPerSale,
        packMinutesPerKg: packMinutesPerKg ?? this.packMinutesPerKg,
        hourlyWage: hourlyWage ?? this.hourlyWage,
        monthlyStorageCost: monthlyStorageCost ?? this.monthlyStorageCost,
        monthlySalesForecastKg:
            monthlySalesForecastKg ?? this.monthlySalesForecastKg,
        wastePercent: wastePercent ?? this.wastePercent,
        profitPercent: profitPercent ?? this.profitPercent,
        densityKgPerLiter: densityKgPerLiter ?? this.densityKgPerLiter,
      );
}

class ContainerModel {
  final String name;
  final double volumeLiter;
  final double buyPrice;

  const ContainerModel({
    required this.name,
    required this.volumeLiter,
    required this.buyPrice,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'volumeLiter': volumeLiter,
        'buyPrice': buyPrice,
      };

  static ContainerModel fromMap(Map<String, dynamic> map) => ContainerModel(
        name: (map['name'] ?? '').toString(),
        volumeLiter: (map['volumeLiter'] ?? 0).toDouble(),
        buyPrice: (map['buyPrice'] ?? 0).toDouble(),
      );
}

class DeliveryMethodModel {
  final String name;
  final double suggestedCost;

  const DeliveryMethodModel({required this.name, required this.suggestedCost});

  Map<String, dynamic> toMap() => {
        'name': name,
        'suggestedCost': suggestedCost,
      };

  static DeliveryMethodModel fromMap(Map<String, dynamic> map) =>
      DeliveryMethodModel(
        name: (map['name'] ?? '').toString(),
        suggestedCost: (map['suggestedCost'] ?? 0).toDouble(),
      );
}

class CalculationInput {
  final String honeyType;
  final double kg;
  final double buyPricePerKg;
  final String containerName;
  final String deliveryMethod;
  final double? actualShippingCost;

  const CalculationInput({
    required this.honeyType,
    required this.kg,
    required this.buyPricePerKg,
    required this.containerName,
    required this.deliveryMethod,
    this.actualShippingCost,
  });

  Map<String, dynamic> toMap() => {
        'honeyType': honeyType,
        'kg': kg,
        'buyPricePerKg': buyPricePerKg,
        'containerName': containerName,
        'deliveryMethod': deliveryMethod,
        'actualShippingCost': actualShippingCost,
      };

  static CalculationInput fromMap(Map<String, dynamic> map) => CalculationInput(
        honeyType: (map['honeyType'] ?? '').toString(),
        kg: (map['kg'] ?? 0).toDouble(),
        buyPricePerKg: (map['buyPricePerKg'] ?? 0).toDouble(),
        containerName: (map['containerName'] ?? '').toString(),
        deliveryMethod: (map['deliveryMethod'] ?? '').toString(),
        actualShippingCost: map['actualShippingCost'] == null
            ? null
            : (map['actualShippingCost']).toDouble(),
      );
}

class CalculationOutput {
  final double approxLiter;
  final int containerCount;
  final double totalContainerCapacityLiter;

  final double containerCost;
  final double communicationsCost;
  final double storageCost;
  final double packagingCost;
  final double honeyCostWithWaste;

  final double suggestedShippingCost;
  final double usedShippingCost;

  final double totalCost;
  final int suggestedSaleTotal;
  final int suggestedSalePerKg;

  const CalculationOutput({
    required this.approxLiter,
    required this.containerCount,
    required this.totalContainerCapacityLiter,
    required this.containerCost,
    required this.communicationsCost,
    required this.storageCost,
    required this.packagingCost,
    required this.honeyCostWithWaste,
    required this.suggestedShippingCost,
    required this.usedShippingCost,
    required this.totalCost,
    required this.suggestedSaleTotal,
    required this.suggestedSalePerKg,
  });

  Map<String, dynamic> toMap() => {
        'approxLiter': approxLiter,
        'containerCount': containerCount,
        'totalContainerCapacityLiter': totalContainerCapacityLiter,
        'containerCost': containerCost,
        'communicationsCost': communicationsCost,
        'storageCost': storageCost,
        'packagingCost': packagingCost,
        'honeyCostWithWaste': honeyCostWithWaste,
        'suggestedShippingCost': suggestedShippingCost,
        'usedShippingCost': usedShippingCost,
        'totalCost': totalCost,
        'suggestedSaleTotal': suggestedSaleTotal,
        'suggestedSalePerKg': suggestedSalePerKg,
      };

  static CalculationOutput fromMap(Map<String, dynamic> map) => CalculationOutput(
        approxLiter: (map['approxLiter'] ?? 0).toDouble(),
        containerCount: (map['containerCount'] ?? 0).toInt(),
        totalContainerCapacityLiter:
            (map['totalContainerCapacityLiter'] ?? 0).toDouble(),
        containerCost: (map['containerCost'] ?? 0).toDouble(),
        communicationsCost: (map['communicationsCost'] ?? 0).toDouble(),
        storageCost: (map['storageCost'] ?? 0).toDouble(),
        packagingCost: (map['packagingCost'] ?? 0).toDouble(),
        honeyCostWithWaste: (map['honeyCostWithWaste'] ?? 0).toDouble(),
        suggestedShippingCost: (map['suggestedShippingCost'] ?? 0).toDouble(),
        usedShippingCost: (map['usedShippingCost'] ?? 0).toDouble(),
        totalCost: (map['totalCost'] ?? 0).toDouble(),
        suggestedSaleTotal: (map['suggestedSaleTotal'] ?? 0).toInt(),
        suggestedSalePerKg: (map['suggestedSalePerKg'] ?? 0).toInt(),
      );
}

class CalculationRecord {
  final String id;
  final DateTime createdAt;
  final CalculationInput input;
  final CalculationOutput output;

  const CalculationRecord({
    required this.id,
    required this.createdAt,
    required this.input,
    required this.output,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'createdAt': createdAt.toIso8601String(),
        'input': input.toMap(),
        'output': output.toMap(),
      };

  static CalculationRecord fromMap(Map<String, dynamic> map) => CalculationRecord(
        id: (map['id'] ?? '').toString(),
        createdAt: DateTime.tryParse((map['createdAt'] ?? '').toString()) ??
            DateTime.fromMillisecondsSinceEpoch(0),
        input: CalculationInput.fromMap((map['input'] as Map).cast<String, dynamic>()),
        output:
            CalculationOutput.fromMap((map['output'] as Map).cast<String, dynamic>()),
      );

  String toJson() => jsonEncode(toMap());

  static CalculationRecord fromJson(String s) =>
      fromMap((jsonDecode(s) as Map).cast<String, dynamic>());
}
