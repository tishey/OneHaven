import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onehaven_assessment/data/model/member.dart';
import 'package:onehaven_assessment/presentation/view/login_screen.dart';
import 'package:onehaven_assessment/presentation/view/member_screen.dart';
import 'package:onehaven_assessment/presentation/widget/member_tile.dart';
import 'package:onehaven_assessment/presentation/widget/shimmer_loader.dart';
import 'package:onehaven_assessment/provider/provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersState = ref.watch(membersListProvider);
    final membersNotifier = ref.read(membersListProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Protected Members'),
        actions: [
          IconButton(
            icon: Text('Logout', style: TextStyle(color: Colors.red)),
            onPressed: () {
              ref.read(authStateProvider.notifier).logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: membersState.when(
        data: (members) {
          if (members.isEmpty) {
            return _buildEmptyState(membersNotifier);
          }
          return _buildMembersList(members, membersNotifier, context);
        },
        loading: () => _buildLoadingState(),
        error: (error, stackTrace) =>
            _buildErrorState(context, error, membersNotifier),
      ),
    );
  }

  Widget _buildMembersList(
    List<Member> members,
    MembersNotifier notifier,
    BuildContext context,
  ) {
    return RefreshIndicator(
      onRefresh: () => notifier.refresh(),
      child: ListView.builder(
        itemCount: members.length,
        itemBuilder: (context, index) {
          final member = members[index];
          return MemberItem(
            avatar: member.avatar,
            name: member.fullName,
            subtitle:
                '${member.relationship} • ${member.age} yrs • ${member.status}',
            toggleValue: member.screenTimeEnabled,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MemberDetailsScreen(member: member),
              ),
            ),
            onToggle: (value) => notifier.toggleScreenTime(member, value),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(MembersNotifier notifier) {
    return RefreshIndicator(
      onRefresh: () => notifier.refresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: 400,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.people_outline, size: 80, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'No protected members found',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                'Pull down to refresh',
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return ShimmerList();
  }

  Widget _buildErrorState(context, Object error, MembersNotifier notifier) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Failed to load members',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.red),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => notifier.loadMembers(),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
