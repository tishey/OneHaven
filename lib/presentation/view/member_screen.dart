import 'package:flutter/material.dart';
import 'package:onehaven_assessment/data/model/member.dart';
import 'package:flutter/material.dart';

class MemberDetailsScreen extends StatelessWidget {
  final Member member;

  const MemberDetailsScreen({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Member Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            _buildAvatar(),
            const SizedBox(height: 24),
            _buildNameSection(),
            const SizedBox(height: 24),
            _buildDetailsCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Stack(
      alignment: Alignment.center,
      children: [
        CircleAvatar(
          radius: 60,
          backgroundImage: NetworkImage(member.avatar),
          onBackgroundImageError: (exception, stackTrace) {},
        ),
        Positioned(
          bottom: 0,
          right: 10,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2),
              color: member.status == 'active' ? Colors.green : Colors.orange,
              shape: BoxShape.circle,
            ),
            child: Icon(
              member.status == 'active' ? Icons.check : Icons.schedule,
              color: Colors.white,
              size: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNameSection() {
    return Column(
      children: [
        Text(
          member.fullName,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.black,
          ),
          child: Text(
            member.relationship,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsCard(context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).primaryColor,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildDetailRow('Birth Year', member.birthYear.toString()),
            _buildDetailRow('Age', '${member.age} years'),
            _buildDetailRow('Status', member.status),
            _buildDetailRow(
              'Screen Time',
              member.screenTimeEnabled ? 'Enabled' : 'Disabled',
              valueColor: member.screenTimeEnabled ? Colors.green : Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.lightBlueAccent,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: valueColor ?? Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
