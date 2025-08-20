import 'package:flutter/material.dart';
import '../../domain/entities/danish_holidays.dart';
import '../../domain/services/holiday_surcharge_calculator.dart';
import '../../../core/constants/spacing.dart';

class SurchargeNoticeWidget extends StatelessWidget {
  final DateTime date;
  final SurchargeNotice notice;
  final bool showDismissButton;
  final VoidCallback? onDismiss;
  final VoidCallback? onLearnMore;

  const SurchargeNoticeWidget({
    Key? key,
    required this.date,
    required this.notice,
    this.showDismissButton = true,
    this.onDismiss,
    this.onLearnMore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: Spacing.medium,
        vertical: Spacing.small,
      ),
      child: Container(
        padding: const EdgeInsets.all(Spacing.medium),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getBorderColor(notice.type, theme),
            width: 1.5,
          ),
          gradient: LinearGradient(
            colors: [
              _getBackgroundColor(notice.type, theme).withOpacity(0.1),
              _getBackgroundColor(notice.type, theme).withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getIconBackgroundColor(notice.type, theme),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getNoticeIcon(notice.type),
                    color: _getIconColor(notice.type, theme),
                    size: 24,
                  ),
                ),
                
                const SizedBox(width: Spacing.medium),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getNoticeTitle(notice),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _getTextColor(notice.type, theme),
                        ),
                      ),
                      if (notice.holiday != null)
                        Text(
                          notice.holiday!.name,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: _getTextColor(notice.type, theme).withOpacity(0.8),
                          ),
                        ),
                    ],
                  ),
                ),
                
                if (showDismissButton)
                  IconButton(
                    onPressed: onDismiss,
                    icon: Icon(
                      Icons.close,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: Spacing.medium),
            
            // Main message
            Text(
              notice.message,
              style: theme.textTheme.bodyMedium,
            ),
            
            // Surcharge details
            if (notice.hasSurcharge) ...[
              const SizedBox(height: Spacing.medium),
              Container(
                padding: const EdgeInsets.all(Spacing.small),
                decoration: BoxDecoration(
                  color: _getAccentColor(notice.type, theme).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _getAccentColor(notice.type, theme).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.attach_money,
                      color: _getAccentColor(notice.type, theme),
                      size: 20,
                    ),
                    const SizedBox(width: Spacing.small),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: theme.textTheme.bodyMedium,
                          children: [
                            const TextSpan(text: 'Holiday surcharge: '),
                            TextSpan(
                              text: '${notice.surchargePercentage}%',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const TextSpan(text: ' additional'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            // Additional info
            if (notice.additionalInfo != null) ...[
              const SizedBox(height: Spacing.medium),
              Container(
                padding: const EdgeInsets.all(Spacing.small),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: Spacing.small),
                    Expanded(
                      child: Text(
                        notice.additionalInfo!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            // Holiday details
            if (notice.holiday != null) ...[
              const SizedBox(height: Spacing.medium),
              _buildHolidayDetails(theme, notice.holiday!),
            ],
            
            // Action buttons
            const SizedBox(height: Spacing.medium),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: onLearnMore,
                  icon: const Icon(Icons.help_outline, size: 16),
                  label: const Text('Learn More'),
                  style: TextButton.styleFrom(
                    foregroundColor: _getAccentColor(notice.type, theme),
                  ),
                ),
                
                if (notice.hasSurcharge)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getAccentColor(notice.type, theme),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getSurchargeIcon(notice.surchargePercentage),
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '+${notice.surchargePercentage}%',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHolidayDetails(ThemeData theme, DanishHoliday holiday) {
    return Container(
      padding: const EdgeInsets.all(Spacing.small),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getHolidayIcon(holiday),
                color: theme.colorScheme.tertiary,
                size: 18,
              ),
              const SizedBox(width: Spacing.small),
              Text(
                'Holiday Information',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.tertiary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: Spacing.small),
          
          _buildDetailRow(
            icon: Icons.event,
            label: 'Date',
            value: _formatHolidayDate(holiday.date),
            theme: theme,
          ),
          
          const SizedBox(height: 4),
          
          _buildDetailRow(
            icon: Icons.info_outline,
            label: 'Type',
            value: holiday.isPublicHoliday ? 'Public Holiday' : 'Special Day',
            theme: theme,
          ),
          
          if (holiday.description.isNotEmpty) ...[
            const SizedBox(height: 4),
            _buildDetailRow(
              icon: Icons.description,
              label: 'About',
              value: holiday.description,
              theme: theme,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 14,
          color: theme.colorScheme.onTertiaryContainer.withOpacity(0.7),
        ),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onTertiaryContainer.withOpacity(0.8),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onTertiaryContainer,
            ),
          ),
        ),
      ],
    );
  }

  // Color and styling helpers

  Color _getBorderColor(SurchargeNoticeType type, ThemeData theme) {
    switch (type) {
      case SurchargeNoticeType.info:
        return theme.colorScheme.primary;
      case SurchargeNoticeType.warning:
        return Colors.orange;
      case SurchargeNoticeType.critical:
        return theme.colorScheme.error;
    }
  }

  Color _getBackgroundColor(SurchargeNoticeType type, ThemeData theme) {
    switch (type) {
      case SurchargeNoticeType.info:
        return theme.colorScheme.primary;
      case SurchargeNoticeType.warning:
        return Colors.orange;
      case SurchargeNoticeType.critical:
        return theme.colorScheme.error;
    }
  }

  Color _getIconBackgroundColor(SurchargeNoticeType type, ThemeData theme) {
    return _getBackgroundColor(type, theme).withOpacity(0.1);
  }

  Color _getIconColor(SurchargeNoticeType type, ThemeData theme) {
    return _getBackgroundColor(type, theme);
  }

  Color _getTextColor(SurchargeNoticeType type, ThemeData theme) {
    return _getBackgroundColor(type, theme);
  }

  Color _getAccentColor(SurchargeNoticeType type, ThemeData theme) {
    return _getBackgroundColor(type, theme);
  }

  IconData _getNoticeIcon(SurchargeNoticeType type) {
    switch (type) {
      case SurchargeNoticeType.info:
        return Icons.info;
      case SurchargeNoticeType.warning:
        return Icons.warning;
      case SurchargeNoticeType.critical:
        return Icons.error;
    }
  }

  IconData _getSurchargeIcon(int percentage) {
    if (percentage >= 30) return Icons.trending_up;
    if (percentage >= 15) return Icons.add_circle;
    return Icons.add;
  }

  IconData _getHolidayIcon(DanishHoliday holiday) {
    final name = holiday.name.toLowerCase();
    
    if (name.contains('christmas') || name.contains('jul')) {
      return Icons.celebration;
    } else if (name.contains('new year')) {
      return Icons.celebration;
    } else if (name.contains('easter') || name.contains('påske')) {
      return Icons.egg;
    } else if (name.contains('constitution')) {
      return Icons.flag;
    } else {
      return Icons.event;
    }
  }

  String _getNoticeTitle(SurchargeNotice notice) {
    if (!notice.hasSurcharge) {
      return 'No Holiday Surcharge';
    }

    switch (notice.type) {
      case SurchargeNoticeType.info:
        return 'Holiday Pricing';
      case SurchargeNoticeType.warning:
        return 'Increased Holiday Rates';
      case SurchargeNoticeType.critical:
        return 'Premium Holiday Pricing';
    }
  }

  String _formatHolidayDate(DateTime date) {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    
    return '${weekdays[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

// Helper widget for showing multiple surcharge notices
class SurchargeNoticeList extends StatefulWidget {
  final List<SurchargeNotice> notices;
  final Function(SurchargeNotice)? onDismiss;
  final Function(SurchargeNotice)? onLearnMore;

  const SurchargeNoticeList({
    Key? key,
    required this.notices,
    this.onDismiss,
    this.onLearnMore,
  }) : super(key: key);

  @override
  State<SurchargeNoticeList> createState() => _SurchargeNoticeListState();
}

class _SurchargeNoticeListState extends State<SurchargeNoticeList> {
  final List<SurchargeNotice> _dismissedNotices = [];

  @override
  Widget build(BuildContext context) {
    final visibleNotices = widget.notices
        .where((notice) => !_dismissedNotices.contains(notice))
        .toList();

    if (visibleNotices.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: visibleNotices
          .map((notice) => SurchargeNoticeWidget(
                date: notice.date,
                notice: notice,
                onDismiss: widget.onDismiss != null
                    ? () {
                        setState(() {
                          _dismissedNotices.add(notice);
                        });
                        widget.onDismiss!(notice);
                      }
                    : null,
                onLearnMore: widget.onLearnMore != null
                    ? () => widget.onLearnMore!(notice)
                    : null,
              ))
          .toList(),
    );
  }
}

// Compact version for booking forms
class CompactSurchargeNotice extends StatelessWidget {
  final SurchargeNotice notice;
  final VoidCallback? onTap;

  const CompactSurchargeNotice({
    Key? key,
    required this.notice,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!notice.hasSurcharge) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.small,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: _getNoticeColor(theme),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.add_circle,
              size: 16,
              color: Colors.white,
            ),
            const SizedBox(width: 4),
            Text(
              '+${notice.surchargePercentage}% Holiday',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.info_outline,
                size: 14,
                color: Colors.white.withOpacity(0.8),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getNoticeColor(ThemeData theme) {
    if (notice.surchargePercentage >= 30) {
      return theme.colorScheme.error;
    } else if (notice.surchargePercentage >= 15) {
      return Colors.orange;
    } else {
      return theme.colorScheme.primary;
    }
  }
}