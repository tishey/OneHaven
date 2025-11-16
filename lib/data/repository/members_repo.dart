import 'dart:async';
import 'dart:developer';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:onehaven_assessment/data/model/member.dart';
import 'package:onehaven_assessment/service/api_service/api_service.dart';
import 'package:onehaven_assessment/service/hive_service.dart';

class MemberRepository {
  final ApiService api;

  MemberRepository({required this.api});

  Future<List<Member>> getMembers() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    final bool isOnline = connectivityResult != ConnectivityResult.none;

    if (isOnline) {
      try {
        final data = await api.fetchMembers();
        final members = data
            .map((e) => Member.fromJson(e as Map<String, dynamic>))
            .toList();

        await HiveService.saveMembers(members.map((m) => m.toJson()).toList());
        return members;
      } catch (e) {
        log('Remote fetch failed: $e, trying cache...');
      }
    }

    final cached = HiveService.loadMembers();
    if (cached != null && cached.isNotEmpty) {
      log('Loaded ${cached.length} members from cache');
      return cached
          .map((e) => Member.fromJson((e as Map).cast<String, dynamic>()))
          .toList();
    }

    throw Exception(
      isOnline
          ? 'Failed to fetch members and no cache available'
          : 'No internet connection and no cache available',
    );
  }

  Future<void> toggleScreenTime(Member member, bool enabled) async {
    final updatedMember = member.copyWith(screenTimeEnabled: enabled);
    await HiveService.updateMember(member.id, updatedMember.toJson());

    final queue = HiveService.loadQueue();
    queue.add({
      'id': member.id,
      'enabled': enabled,
      'timestamp': DateTime.now().toIso8601String(),
    });
    await HiveService.saveQueue(queue);

    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult != ConnectivityResult.none) {
      await _syncQueue();
    }
  }

  Future<void> _syncQueue() async {
    final queue = HiveService.loadQueue();
    if (queue.isEmpty) return;

    final remaining = <dynamic>[];
    for (final item in queue) {
      try {
        final id = (item as Map)['id'] as String;
        final enabled = item['enabled'] as bool;

        final response = await api.patchMember(id, {
          'screenTimeEnabled': enabled,
        });

        await HiveService.updateMember(
          id,
          (response as Map).cast<String, dynamic>(),
        );
      } catch (e) {
        print('Failed to sync update for $item: $e');
        remaining.add(item);
      }
    }

    await HiveService.saveQueue(remaining);
  }

  Future<void> syncPendingChanges() async {
    await _syncQueue();
  }
}
