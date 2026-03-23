import 'package:flutter/material.dart';

/// Displays the AI-generated workout suggestion with the reasoning behind it.
/// The AI is rule-based (local), analyzing recent workout intensity patterns.
class AiSuggestionCard extends StatelessWidget {
  final String suggestion;
  final String reason;
  final VoidCallback? onHelpful;
  final VoidCallback? onNotHelpful;
  final int helpfulCount;
  final int notHelpfulCount;

  const AiSuggestionCard({
    super.key,
    required this.suggestion,
    required this.reason,
    this.onHelpful,
    this.onNotHelpful,
    this.helpfulCount = 0,
    this.notHelpfulCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 3,
      color: theme.colorScheme.primaryContainer,
      child: Semantics(
        label: 'AI trainer suggestion. $suggestion. Reason: $reason',
        readOnly: true,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.psychology,
                    color: theme.colorScheme.onPrimaryContainer,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'AI Trainer Suggestion',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                suggestion,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onPrimaryContainer.withValues(
                    alpha: 0.08,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: theme.colorScheme.onPrimaryContainer.withValues(
                        alpha: 0.7,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        reason,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer
                              .withValues(alpha: 0.85),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    'Was this helpful?',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer.withValues(
                        alpha: 0.8,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Helpful',
                    visualDensity: VisualDensity.compact,
                    onPressed: onHelpful,
                    icon: const Icon(Icons.thumb_up_alt_outlined, size: 18),
                  ),
                  Text('$helpfulCount'),
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: 'Not Helpful',
                    visualDensity: VisualDensity.compact,
                    onPressed: onNotHelpful,
                    icon: const Icon(Icons.thumb_down_alt_outlined, size: 18),
                  ),
                  Text('$notHelpfulCount'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
