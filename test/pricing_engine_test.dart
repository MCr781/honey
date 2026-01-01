import 'package:flutter_test/flutter_test.dart';

import 'package:honey_pricer/data/defaults.dart';
import 'package:honey_pricer/data/models.dart';
import 'package:honey_pricer/services/pricing_engine.dart';

void main() {
  test('PricingEngine matches sample row from Excel', () {
    const engine = PricingEngine();

    const input = CalculationInput(
      honeyType: 'عسل گون',
      kg: 21.3,
      buyPricePerKg: 200000,
      containerName: 'دبه 20 لیتری',
      deliveryMethod: 'تحویل حضوری از خانه (بدون ارسال)',
      actualShippingCost: null,
    );

    final out = engine.calculate(
      settings: defaultSettings,
      containers: defaultContainers,
      deliveryMethods: defaultDeliveryMethods,
      input: input,
    );

    expect(out.approxLiter, closeTo(15.0, 1e-9));
    expect(out.containerCount, 1);
    expect(out.totalContainerCapacityLiter, 20);

    expect(out.containerCost, 500000);
    expect(out.communicationsCost, 418);
    expect(out.storageCost, 10650);
    expect(out.packagingCost, 53250);
    expect(out.honeyCostWithWaste, 4302600);

    expect(out.suggestedShippingCost, 0);
    expect(out.usedShippingCost, 0);

    expect(out.totalCost, 4866918);
    expect(out.suggestedSaleTotal, 5353000);
    expect(out.suggestedSalePerKg, 251000);
  });
}
