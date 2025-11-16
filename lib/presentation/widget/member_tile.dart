import 'package:flutter/material.dart';

class MemberItem extends StatelessWidget {
  final String avatar;
  final String name;
  final String subtitle;
  final bool toggleValue;
  final VoidCallback onTap;
  final ValueChanged<bool> onToggle;

  const MemberItem({
    super.key,
    required this.avatar,
    required this.name,
    required this.subtitle,
    required this.toggleValue,
    required this.onTap,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(backgroundImage: NetworkImage(avatar)),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: Switch(value: toggleValue, onChanged: onToggle),
      ),
    );
  }
}
