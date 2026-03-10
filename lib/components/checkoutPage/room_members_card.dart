import 'package:flutter/material.dart';
import 'package:seefood/rooms/room_models.dart';
import 'package:seefood/themes/app_colors.dart';

class RoomMembersCard extends StatelessWidget {
  const RoomMembersCard({
    super.key,
    required this.members,
    required this.onKick,
  });

  final List<RoomMember> members;
  final ValueChanged<RoomMember> onKick;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.foreground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Room Members',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          if (members.isEmpty)
            const Text(
              'No members yet',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
            )
          else
            ...members.map((member) => _MemberRow(
                  member: member,
                  onKick: () => onKick(member),
                )),
        ],
      ),
    );
  }
}

class _MemberRow extends StatelessWidget {
  const _MemberRow({
    required this.member,
    required this.onKick,
  });

  final RoomMember member;
  final VoidCallback onKick;

  @override
  Widget build(BuildContext context) {
    final status = member.status.toUpperCase();
    final statusColor = status == 'PAID' ? Colors.green : Colors.orange;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                member.name.characters.first.toUpperCase(),
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              member.name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            status,
            style: TextStyle(
              color: statusColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: onKick,
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            ),
            child: const Text(
              'Kick',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
