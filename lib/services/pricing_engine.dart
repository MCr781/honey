import '../core/rounding.dart';
import '../data/models.dart';

class PricingEngine {
  const PricingEngine();

  CalculationOutput calculate({
    required SettingsModel settings,
    required List<ContainerModel> containers,
    required List<DeliveryMethodModel> deliveryMethods,
    required CalculationInput input,
  }) {
    if (input.kg <= 0) {
      throw ArgumentError('kg must be > 0');
    }
    if (input.buyPricePerKg <= 0) {
      throw ArgumentError('buyPricePerKg must be > 0');
    }

    final container = containers.firstWhere(
      (c) => c.name == input.containerName,
      orElse: () => throw ArgumentError('Container not found'),
    );

    final density = settings.densityKgPerLiter <= 0 ? 1 : settings.densityKgPerLiter;
    final approxLiter = input.kg / density;

    final vol = container.volumeLiter <= 0 ? 1 : container.volumeLiter;
    final containerCount = roundUpToInt(approxLiter / vol);
    final totalContainerCapacityLiter = containerCount * vol;

    final containerCost = containerCount * container.buyPrice;
    final communicationsCost = settings.communicationsCostPerSale();
    final storageCost = settings.storageCostPerKg * input.kg;
    final packagingCost = settings.packMinutesPerKg * settings.valuePerMinute * input.kg;
    final honeyCostWithWaste = input.buyPricePerKg * input.kg * (1 + settings.wastePercent);

    final suggestedShippingCost = deliveryMethods
        .firstWhere(
          (d) => d.name == input.deliveryMethod,
          orElse: () => const DeliveryMethodModel(name: '', suggestedCost: 0),
        )
        .suggestedCost;

    final usedShippingCost =
        (input.actualShippingCost != null) ? input.actualShippingCost! : suggestedShippingCost;

    final totalCost = containerCost +
        communicationsCost +
        storageCost +
        packagingCost +
        honeyCostWithWaste +
        (usedShippingCost.isFinite ? usedShippingCost : 0);

    final suggestedSaleTotal =
        roundDownToThousand(totalCost * (1 + settings.profitPercent));
    final suggestedSalePerKg =
        roundDownToThousand(suggestedSaleTotal / input.kg);

    return CalculationOutput(
      approxLiter: approxLiter,
      containerCount: containerCount,
      totalContainerCapacityLiter: totalContainerCapacityLiter,
      containerCost: containerCost,
      communicationsCost: communicationsCost,
      storageCost: storageCost,
      packagingCost: packagingCost,
      honeyCostWithWaste: honeyCostWithWaste,
      suggestedShippingCost: suggestedShippingCost,
      usedShippingCost: usedShippingCost,
      totalCost: totalCost,
      suggestedSaleTotal: suggestedSaleTotal,
      suggestedSalePerKg: suggestedSalePerKg,
    );
  }
}
