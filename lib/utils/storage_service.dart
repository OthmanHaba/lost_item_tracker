import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/item.dart';

class StorageService {
  static const String _itemsKey = 'lost_found_items';
  static const String _pinKey = 'app_pin';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  // Items CRUD operations
  Future<List<Item>> getItems() async {
    final String? itemsJson = _prefs.getString(_itemsKey);
    if (itemsJson == null) return [];

    final List<dynamic> itemsList = json.decode(itemsJson);
    return itemsList.map((item) => Item.fromJson(item)).toList();
  }

  Future<void> saveItems(List<Item> items) async {
    final String itemsJson = json.encode(items.map((item) => item.toJson()).toList());
    await _prefs.setString(_itemsKey, itemsJson);
  }

  Future<void> addItem(Item item) async {
    final items = await getItems();
    items.add(item);
    await saveItems(items);
  }

  Future<void> updateItem(Item updatedItem) async {
    final items = await getItems();
    final index = items.indexWhere((item) => item.id == updatedItem.id);
    if (index != -1) {
      items[index] = updatedItem;
      await saveItems(items);
    }
  }

  Future<void> deleteItem(String id) async {
    final items = await getItems();
    items.removeWhere((item) => item.id == id);
    await saveItems(items);
  }

  // PIN operations
  Future<void> setPin(String pin) async {
    await _prefs.setString(_pinKey, pin);
  }

  String? getPin() {
    return _prefs.getString(_pinKey);
  }

  Future<void> removePin() async {
    await _prefs.remove(_pinKey);
  }

  // Clear all data
  Future<void> clearAllData() async {
    await _prefs.remove(_itemsKey);
  }
} 