import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:onehaven_assessment/data/model/member.dart';
import 'package:onehaven_assessment/data/repository/members_repo.dart';
import 'package:onehaven_assessment/service/api_service/api_service.dart';
import 'package:onehaven_assessment/service/hive_service.dart';

final baseUrlProvider = Provider<String>((ref) => 'http://10.0.2.2:3000');

final apiServiceProvider = Provider<ApiService>((ref) {
  final baseUrl = ref.watch(baseUrlProvider);
  return ApiService(baseUrl);
});

final memberRepositoryProvider = Provider<MemberRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return MemberRepository(api: apiService);
});

final membersListProvider =
    StateNotifierProvider<MembersNotifier, AsyncValue<List<Member>>>((ref) {
      final repository = ref.watch(memberRepositoryProvider);
      return MembersNotifier(repository);
    });

class MembersNotifier extends StateNotifier<AsyncValue<List<Member>>> {
  final MemberRepository _repository;

  MembersNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadMembers();
  }

  Future<void> loadMembers() async {
    state = const AsyncValue.loading();
    try {
      final members = await _repository.getMembers();
      state = AsyncValue.data(members);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    await loadMembers();
  }

  Future<void> toggleScreenTime(Member member, bool enabled) async {
    final currentState = state;

    if (currentState case AsyncData<List<Member>>(:final value)) {
      final updatedMembers = value.map((m) {
        return m.id == member.id ? m.copyWith(screenTimeEnabled: enabled) : m;
      }).toList();
      state = AsyncValue.data(updatedMembers);
    }

    try {
      await _repository.toggleScreenTime(member, enabled);

      // await loadMembers();
    } catch (e) {
      state = currentState;
      rethrow;
    }
  }

  Future<void> syncChanges() async {
    await _repository.syncPendingChanges();
    await loadMembers();
  }
}

final authStateProvider = StateNotifierProvider<AuthNotifier, AsyncValue<bool>>(
  (ref) {
    return AuthNotifier();
  },
);

class AuthNotifier extends StateNotifier<AsyncValue<bool>> {
  AuthNotifier() : super(const AsyncValue.data(false)) {
    checkAuthStatus();
  }

  void checkAuthStatus() {
    final token = HiveService.getAuthToken();
    state = AsyncValue.data(token != null);
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await Future.delayed(const Duration(milliseconds: 1000));

      if (!email.contains('@') || password.isEmpty) {
        throw Exception('Invalid email or password');
      }

      await HiveService.saveAuthToken(
        'mock_jwt_token_${DateTime.now().millisecondsSinceEpoch}',
      );
      state = const AsyncValue.data(true);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> logout() async {
    await HiveService.clearAuth();
    state = const AsyncValue.data(false);
  }

  bool get isAuthenticated {
    return state.when(
      data: (isAuth) => isAuth,
      loading: () => false,
      error: (_, __) => false,
    );
  }
}

final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (isAuth) => isAuth,
    loading: () => false,
    error: (_, __) => false,
  );
});
