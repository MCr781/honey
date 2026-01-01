import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

import '../defaults.dart';
import '../models.dart';

class StorageService {
  static final StorageService instance = StorageService._();
  StorageService._();

  static const _settingsBoxName = 'settings_box';
  static const _listsBoxName = 'lists_box';
  static const _historyBoxName = 'history_box';

  late Box _settingsBox;
  late Box _listsBox;
  late Box _historyBox;

  Future<void> init() async {
    await Hive.initFlutter();
    _settingsBox = await Hive.openBox(_settingsBoxName);
    _listsBox = await Hive.openBox(_listsBoxName);
    _historyBox = await Hive.openBox(_historyBoxName);

    // Seed defaults if first run
    if (_settingsBox.get('settings') == null) {
      await _settingsBox.put('settings', defaultSettings.toJson());
    }
    if (_listsBox.get('honeyTypes') == null) {
      await _listsBox.put('honeyTypes', defaultHoneyTypes);
    }
    if (_listsBox.get('containers') == null) {
      final list = defaultContainers.map((c) => jsonEncode(c.toMap())).toList();
      await _listsBox.put('containers', list);
    }
    if (_listsBox.get('deliveryMethods') == null) {
      final list =
          defaultDeliveryMethods.map((d) => jsonEncode(d.toMap())).toList();
      await _listsBox.put('deliveryMethods', list);
    }
    if (_historyBox.get('records') == null) {
      await _historyBox.put('records', <String>[]);
    }
  }

  // Settings
  SettingsModel getSettings() {
    final s = _settingsBox.get('settings') as String;
    return SettingsModel.fromJson(s);
  }

  Future<void> saveSettings(SettingsModel settings) =>
      _settingsBox.put('settings', settings.toJson());

  // Honey types
  List<String> getHoneyTypes() =>
      List<String>.from(_listsBox.get('honeyTypes') as List);

  Future<void> saveHoneyTypes(List<String> list) =>
      _listsBox.put('honeyTypes', list);

  // Containers
  List<ContainerModel> getContainers() {
    final list = List<String>.from(_listsBox.get('containers') as List);
    return list.map((s) => ContainerModel.fromMap((jsonDecode(s) as Map).cast<String, dynamic>())).toList();
  }

  Future<void> saveContainers(List<ContainerModel> containers) {
    final list = containers.map((c) => jsonEncode(c.toMap())).toList();
    return _listsBox.put('containers', list);
  }

  // Delivery methods
  List<DeliveryMethodModel> getDeliveryMethods() {
    final list = List<String>.from(_listsBox.get('deliveryMethods') as List);
    return list
        .map((s) => DeliveryMethodModel.fromMap((jsonDecode(s) as Map).cast<String, dynamic>()))
        .toList();
  }

  Future<void> saveDeliveryMethods(List<DeliveryMethodModel> list) {
    final encoded = list.map((d) => jsonEncode(d.toMap())).toList();
    return _listsBox.put('deliveryMethods', encoded);
  }

  // History
  List<CalculationRecord> getHistory() {
    final list = List<String>.from(_historyBox.get('records') as List);
    return list.map(CalculationRecord.fromJson).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> addHistory(CalculationRecord record) async {
    final list = List<String>.from(_historyBox.get('records') as List);
    list.add(record.toJson());
    await _historyBox.put('records', list);
  }

  Future<void> deleteHistory(String id) async {
    final list = List<String>.from(_historyBox.get('records') as List);
    list.removeWhere((s) => CalculationRecord.fromJson(s).id == id);
    await _historyBox.put('records', list);
  }

  Future<void> clearHistory() => _historyBox.put('records', <String>[]);
}
