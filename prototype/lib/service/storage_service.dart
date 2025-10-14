import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

/// A service class to handle secure data storage using [FlutterSecureStorage].
///
/// Supports:
/// - Writing data
/// - Reading data
/// - Deleting specific key
/// - Clearing all stored data
/// - Checking key existence
///
/// Works for tokens, user info, app settings, etc.
class StorageService {
  // Create a singleton instance
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;

  // Flutter secure storage instance
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  StorageService._internal();

  /// Save a value to secure storage
  Future<void> writeData(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
      debugPrint("🔐 Saved key [$key] successfully");
    } catch (e) {
      debugPrint("❌ Failed to write key [$key]: $e");
    }
  }

  /// Read a value from secure storage
  Future<String?> readData(String key) async {
    try {
      final value = await _storage.read(key: key);
      debugPrint("📖 Read key [$key]: $value");
      return value;
    } catch (e) {
      debugPrint("❌ Failed to read key [$key]: $e");
      return null;
    }
  }

  /// Delete a specific key
  Future<void> deleteData(String key) async {
    try {
      await _storage.delete(key: key);
      debugPrint("🗑️ Deleted key [$key]");
    } catch (e) {
      debugPrint("❌ Failed to delete key [$key]: $e");
    }
  }

  /// Clear all data in secure storage
  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
      debugPrint("🚮 Cleared all stored data");
    } catch (e) {
      debugPrint("❌ Failed to clear storage: $e");
    }
  }

  /// Check if a key exists
  Future<bool> hasKey(String key) async {
    try {
      final allKeys = await _storage.readAll();
      final exists = allKeys.containsKey(key);
      debugPrint("🔍 Key [$key] exists: $exists");
      return exists;
    } catch (e) {
      debugPrint("❌ Failed to check key [$key]: $e");
      return false;
    }
  }
}
