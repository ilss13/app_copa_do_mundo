import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/models/match.dart';
import '../../../../shared/models/match_event.dart';

class EventsListWidget extends StatelessWidget {
  const EventsListWidget({super.key, required this.events, required this.match});

  final List<MatchEvent> events;
  final Match match;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return Center(
        child: Text(
          'Sem eventos',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: events.length,
      separatorBuilder: (_, _) => Divider(color: AppColors.divider, height: 1),
      itemBuilder: (_, i) => _EventTile(event: events[i], match: match),
    );
  }
}

class _EventTile extends StatelessWidget {
  const _EventTile({required this.event, required this.match});

  final MatchEvent event;
  final Match match;

  bool get _isHome => event.teamId == match.homeTeam.id;

  @override
  Widget build(BuildContext context) {
    final icon = _iconFor(event.type);
    final color = _colorFor(event.type);
    final timeStr = event.extraTime != null
        ? "${event.elapsed}+${event.extraTime}'"
        : "${event.elapsed}'";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          if (_isHome) ...[
            _PlayerInfo(name: event.playerName, assist: event.assistName, align: TextAlign.left),
            const SizedBox(width: 8),
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(timeStr, style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary)),
            const Spacer(),
          ] else ...[
            const Spacer(),
            Text(timeStr, style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary)),
            const SizedBox(width: 8),
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            _PlayerInfo(name: event.playerName, assist: event.assistName, align: TextAlign.right),
          ],
        ],
      ),
    );
  }

  IconData _iconFor(MatchEventType type) => switch (type) {
        MatchEventType.goal => Icons.sports_soccer,
        MatchEventType.ownGoal => Icons.sports_soccer,
        MatchEventType.penalty => Icons.sports_soccer,
        MatchEventType.missedPenalty => Icons.close,
        MatchEventType.yellowCard => Icons.square,
        MatchEventType.redCard => Icons.square,
        MatchEventType.yellowRedCard => Icons.square,
        MatchEventType.substitution => Icons.swap_horiz,
        MatchEventType.var_ => Icons.monitor,
        MatchEventType.unknown => Icons.circle_outlined,
      };

  Color _colorFor(MatchEventType type) => switch (type) {
        MatchEventType.goal || MatchEventType.penalty => AppColors.success,
        MatchEventType.ownGoal || MatchEventType.missedPenalty => AppColors.error,
        MatchEventType.yellowCard => AppColors.warning,
        MatchEventType.redCard || MatchEventType.yellowRedCard => AppColors.error,
        _ => AppColors.textSecondary,
      };
}

class _PlayerInfo extends StatelessWidget {
  const _PlayerInfo({required this.name, this.assist, required this.align});

  final String name;
  final String? assist;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Column(
        crossAxisAlignment: align == TextAlign.left ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Text(name, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary), textAlign: align),
          if (assist != null)
            Text(
              assist!,
              style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary),
              textAlign: align,
            ),
        ],
      ),
    );
  }
}
