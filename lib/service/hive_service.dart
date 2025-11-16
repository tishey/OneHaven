import 'dart:developer';

import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const String membersBox = 'members_box';
  static const String queueBox = 'queue_box';
  static const String authBox = 'auth_box';

  static Future<void> init() async {
    await Hive.initFlutter();

    // Hive.registerAdapter(MemberAdapter());

    await Hive.openBox(membersBox);
    await Hive.openBox(queueBox);
    await Hive.openBox(authBox);

    log('Hive initialized successfully');
  }

  static List<dynamic>? loadMembers() {
    try {
      final box = Hive.box(membersBox);
      return box.get('members') as List<dynamic>?;
    } catch (e) {
      log('Error loading members from Hive: $e');
      return null;
    }
  }

  static Future<void> saveMembers(List<Map<String, dynamic>> members) async {
    try {
      final box = Hive.box(membersBox);
      await box.put('members', members);
    } catch (e) {
      log('Error saving members to Hive: $e');
      rethrow;
    }
  }

  static Future<void> updateMember(
    String id,
    Map<String, dynamic> memberJson,
  ) async {
    try {
      final box = Hive.box(membersBox);
      final list =
          (box.get('members') as List<dynamic>?)
              ?.cast<Map<String, dynamic>>() ??
          [];
      final index = list.indexWhere((m) => m['id'] == id);

      if (index >= 0) {
        list[index] = memberJson;
      } else {
        list.add(memberJson);
      }

      await box.put('members', list);
    } catch (e) {
      print('Error updating member in Hive: $e');
      rethrow;
    }
  }

  static List<dynamic> loadQueue() {
    try {
      final box = Hive.box(queueBox);
      return (box.get('queue') as List<dynamic>?) ?? [];
    } catch (e) {
      print('Error loading queue from Hive: $e');
      return [];
    }
  }

  static Future<void> saveQueue(List<dynamic> queue) async {
    try {
      final box = Hive.box(queueBox);
      await box.put('queue', queue);
    } catch (e) {
      log('Error saving queue to Hive: $e');
      rethrow;
    }
  }

  static Future<void> saveAuthToken(String token) async {
    try {
      final box = Hive.box(authBox);
      await box.put('auth_token', token);
    } catch (e) {
      log('Error saving auth token: $e');
      rethrow;
    }
  }

  static String? getAuthToken() {
    try {
      final box = Hive.box(authBox);
      return box.get('auth_token') as String?;
    } catch (e) {
      print('Error getting auth token: $e');
      return null;
    }
  }

  static Future<void> clearAuth() async {
    try {
      final box = Hive.box(authBox);
      await box.delete('auth_token');
    } catch (e) {
      log('Error clearing auth: $e');
      rethrow;
    }
  }
}
