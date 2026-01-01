import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/models.dart';
import 'data/storage/storage_service.dart';
import 'services/pricing_engine.dart';

// Singleton storage service provider
final storageProvider = Provider<StorageService>((ref) {
  return StorageService.instance;
});

// Settings
class SettingsController extends StateNotifier<SettingsModel> {
  final StorageService _storage;
  SettingsController(this._storage) : super(_storage.getSettings());

  Future<void> update(SettingsModel next) async {
    state = next;
    await _storage.saveSettings(next);
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsController, SettingsModel>((ref) {
  return SettingsController(ref.read(storageProvider));
});

// Honey Types
class HoneyTypesController extends StateNotifier<List<String>> {
  final StorageService _storage;
  HoneyTypesController(this._storage) : super(_storage.getHoneyTypes());

  Future<void> setAll(List<String> next) async {
    state = next;
    await _storage.saveHoneyTypes(next);
  }
}

final honeyTypesProvider =
    StateNotifierProvider<HoneyTypesController, List<String>>((ref) {
  return HoneyTypesController(ref.read(storageProvider));
});

// Containers
class ContainersController extends StateNotifier<List<ContainerModel>> {
  final StorageService _storage;
  ContainersController(this._storage) : super(_storage.getContainers());

  Future<void> setAll(List<ContainerModel> next) async {
    state = next;
    await _storage.saveContainers(next);
  }
}

final containersProvider =
    StateNotifierProvider<ContainersController, List<ContainerModel>>((ref) {
  return ContainersController(ref.read(storageProvider));
});

// Delivery methods
class DeliveryMethodsController extends StateNotifier<List<DeliveryMethodModel>> {
  final StorageService _storage;
  DeliveryMethodsController(this._storage) : super(_storage.getDeliveryMethods());

  Future<void> setAll(List<DeliveryMethodModel> next) async {
    state = next;
    await _storage.saveDeliveryMethods(next);
  }
}

final deliveryMethodsProvider =
    StateNotifierProvider<DeliveryMethodsController, List<DeliveryMethodModel>>((ref) {
  return DeliveryMethodsController(ref.read(storageProvider));
});

// History
class HistoryController extends StateNotifier<List<CalculationRecord>> {
  final StorageService _storage;
  HistoryController(this._storage) : super(_storage.getHistory());

  Future<void> refresh() async {
    state = _storage.getHistory();
  }

  Future<void> add(CalculationRecord record) async {
    await _storage.addHistory(record);
    await refresh();
  }

  Future<void> delete(String id) async {
    await _storage.deleteHistory(id);
    await refresh();
  }

  Future<void> clear() async {
    await _storage.clearHistory();
    await refresh();
  }
}

final historyProvider =
    StateNotifierProvider<HistoryController, List<CalculationRecord>>((ref) {
  return HistoryController(ref.read(storageProvider));
});

// Calculator state
class CalculatorState {
  final String? honeyType;
  final double? kg;
  final double? buyPricePerKg;
  final String? containerName;
  final String? deliveryMethod;
  final double? actualShippingCost;

  const CalculatorState({
    this.honeyType,
    this.kg,
    this.buyPricePerKg,
    this.containerName,
    this.deliveryMethod,
    this.actualShippingCost,
  });

  bool get isValid =>
      (honeyType != null && honeyType!.isNotEmpty) &&
      (kg != null && kg! > 0) &&
      (buyPricePerKg != null && buyPricePerKg! > 0) &&
      (containerName != null && containerName!.isNotEmpty) &&
      (deliveryMethod != null && deliveryMethod!.isNotEmpty);

  CalculationInput toInput() => CalculationInput(
        honeyType: honeyType ?? '',
        kg: kg ?? 0,
        buyPricePerKg: buyPricePerKg ?? 0,
        containerName: containerName ?? '',
        deliveryMethod: deliveryMethod ?? '',
        actualShippingCost: (actualShippingCost != null && actualShippingCost! >= 0)
            ? actualShippingCost
            : null,
      );

  CalculatorState copyWith({
    String? honeyType,
    double? kg,
    double? buyPricePerKg,
    String? containerName,
    String? deliveryMethod,
    double? actualShippingCost,
    bool clearActualShipping = false,
  }) =>
      CalculatorState(
        honeyType: honeyType ?? this.honeyType,
        kg: kg ?? this.kg,
        buyPricePerKg: buyPricePerKg ?? this.buyPricePerKg,
        containerName: containerName ?? this.containerName,
        deliveryMethod: deliveryMethod ?? this.deliveryMethod,
        actualShippingCost: clearActualShipping ? null : (actualShippingCost ?? this.actualShippingCost),
      );
}

class CalculatorController extends StateNotifier<CalculatorState> {
  CalculatorController() : super(const CalculatorState());

  void setHoneyType(String? v) => state = state.copyWith(honeyType: v);
  void setKg(double? v) => state = state.copyWith(kg: v);
  void setBuyPrice(double? v) => state = state.copyWith(buyPricePerKg: v);
  void setContainer(String? v) => state = state.copyWith(containerName: v);
  void setDelivery(String? v) => state = state.copyWith(deliveryMethod: v);
  void setActualShipping(double? v) => state = state.copyWith(actualShippingCost: v);
  void clearActualShipping() => state = state.copyWith(clearActualShipping: true);

  void setFromHistory(CalculationInput input) {
    state = CalculatorState(
      honeyType: input.honeyType,
      kg: input.kg,
      buyPricePerKg: input.buyPricePerKg,
      containerName: input.containerName,
      deliveryMethod: input.deliveryMethod,
      actualShippingCost: input.actualShippingCost,
    );
  }

  void reset() => state = const CalculatorState();
}

final calculatorProvider =
    StateNotifierProvider<CalculatorController, CalculatorState>((ref) {
  return CalculatorController();
});

// Pricing engine provider
final pricingEngineProvider = Provider<PricingEngine>((ref) => const PricingEngine());

// Computed output (null when invalid)
final calculationOutputProvider = Provider<CalculationOutput?>((ref) {
  final calc = ref.watch(calculatorProvider);
  if (!calc.isValid) return null;

  final settings = ref.watch(settingsProvider);
  final containers = ref.watch(containersProvider);
  final delivery = ref.watch(deliveryMethodsProvider);

  try {
    return ref.watch(pricingEngineProvider).calculate(
          settings: settings,
          containers: containers,
          deliveryMethods: delivery,
          input: calc.toInput(),
        );
  } catch (_) {
    return null;
  }
});
