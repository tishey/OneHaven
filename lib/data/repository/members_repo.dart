import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:onehaven_assessment/data/model/member.dart';
import 'package:onehaven_assessment/service/api_service/api_service.dart';
import 'package:onehaven_assessment/service/hive_service.dart';

class MemberRepository {
  final ApiService api;

  MemberRepository({required this.api});

  Future<List<Member>> getMembers() async {
    // Check connectivity
    final connectivityResult = await Connectivity().checkConnectivity();
    final bool isOnline = connectivityResult != ConnectivityResult.none;

    if (isOnline) {
      try {
        // Try to fetch from remote API first
        final data = await api.fetchMembers();
        final members = data
            .map((e) => Member.fromJson(e as Map<String, dynamic>))
            .toList();

        // Save to local cache
        await HiveService.saveMembers(members.map((m) => m.toJson()).toList());
        return members;
      } catch (e) {
        print('Remote fetch failed: $e, trying cache...');
        // Fall back to cache if remote fails
      }
    }

    // Use cached data as fallback
    final cached = HiveService.loadMembers();
    if (cached != null && cached.isNotEmpty) {
      print('Loaded ${cached.length} members from cache');
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
    // Optimistic update: update local cache immediately
    final updatedMember = member.copyWith(screenTimeEnabled: enabled);
    await HiveService.updateMember(member.id, updatedMember.toJson());

    // Add to sync queue for background synchronization
    final queue = HiveService.loadQueue();
    queue.add({
      'id': member.id,
      'enabled': enabled,
      'timestamp': DateTime.now().toIso8601String(),
    });
    await HiveService.saveQueue(queue);

    // Try to sync immediately if online
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

        // Send update to server
        final response = await api.patchMember(id, {
          'screenTimeEnabled': enabled,
        });

        // Update local cache with server response
        await HiveService.updateMember(
          id,
          (response as Map).cast<String, dynamic>(),
        );
      } catch (e) {
        print('Failed to sync update for $item: $e');
        remaining.add(item);
      }
    }

    // Save remaining items that failed to sync
    await HiveService.saveQueue(remaining);
  }

  Future<void> syncPendingChanges() async {
    await _syncQueue();
  }
}
