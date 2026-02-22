import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:kidsero_parent/core/theme/app_colors.dart';
import 'package:kidsero_parent/features/notes/data/models/note_model.dart';
import 'package:kidsero_parent/features/notes/logic/cubit/upcoming_notes_cubit.dart';
import 'package:kidsero_parent/features/notes/logic/cubit/upcoming_notes_state.dart';
import 'package:kidsero_parent/l10n/app_localizations.dart';

class UpcomingNoticesSection extends StatelessWidget {
  final EdgeInsetsGeometry padding;

  const UpcomingNoticesSection({
    super.key,
    this.padding = const EdgeInsets.fromLTRB(20, 32, 20, 0),
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: padding,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, l10n),
              const SizedBox(height: 20),
              BlocBuilder<UpcomingNotesCubit, UpcomingNotesState>(
                builder: (context, state) {
                  if (state is UpcomingNotesLoading ||
                      state is UpcomingNotesInitial) {
                    return _buildLoadingState();
                  }

                  if (state is UpcomingNotesError) {
                    return _buildErrorState(context, l10n, state.message);
                  }

                  if (state is UpcomingNotesEmpty) {
                    return _buildEmptyState(l10n);
                  }

                  if (state is UpcomingNotesLoaded) {
                    return _buildNotesList(context, l10n, state);
                  }

                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.upcomingNotices,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.upcomingNoticesSubtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: l10n.retry,
          onPressed: () =>
              context.read<UpcomingNotesCubit>().refresh(),
          icon: const Icon(Icons.refresh_rounded),
          color: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: List.generate(
        2,
        (index) => Padding(
          padding: EdgeInsets.only(top: index == 0 ? 0 : 12),
          child: _SkeletonCard(),
        ),
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    AppLocalizations l10n,
    String message,
  ) {
    return Column(
      children: [
        Icon(
          Icons.error_outline,
          color: AppColors.error,
          size: 36,
        ),
        const SizedBox(height: 12),
        Text(
          l10n.failedToLoadChildren, // Reuse general error copy
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          message,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: () =>
              context.read<UpcomingNotesCubit>().refresh(),
          icon: const Icon(Icons.refresh_rounded),
          label: Text(l10n.retry),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.event_available,
          color: AppColors.textTertiary,
          size: 40,
        ),
        const SizedBox(height: 12),
        Text(
          l10n.noUpcomingNotices,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          l10n.noUpcomingNoticesDesc,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildNotesList(
    BuildContext context,
    AppLocalizations l10n,
    UpcomingNotesLoaded state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            _buildInfoChip(
              Icons.calendar_today,
              '${state.total} / ${state.daysWindow}d',
            ),
            _buildInfoChip(
              Icons.access_time,
              DateFormat.jm().format(state.fetchedAt),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...state.highlightedNotes.map(
          (note) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _UpcomingNoteTile(note: note, l10n: l10n),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}

class _UpcomingNoteTile extends StatelessWidget {
  final NoteModel note;
  final AppLocalizations l10n;

  const _UpcomingNoteTile({
    required this.note,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final dateLabel = _formatDate(note.date);
    final daysLabel = _buildDaysLabel();
    final typeLabel = _typeLabel(note.type);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _TypeChip(label: typeLabel, type: note.type),
              const Spacer(),
              if (dateLabel.isNotEmpty)
                Text(
                  dateLabel,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            note.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          if ((note.description ?? '').isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              note.description!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (daysLabel.isNotEmpty)
                _buildSecondaryChip(Icons.schedule, daysLabel),
              _buildSecondaryChip(
                note.cancelRides ? Icons.directions_bus : Icons.event,
                note.cancelRides
                    ? l10n.ridesAffected
                    : l10n.ridesNotAffected,
                highlight: note.cancelRides,
              ),
              if ((note.dayName ?? '').isNotEmpty)
                _buildSecondaryChip(Icons.today, note.dayName!),
            ],
          ),
          if ((note.organization.name ?? '').isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.inputBackground,
                  radius: 18,
                  child: Text(
                    note.organization.name![0].toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        note.organization.name!,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if ((note.organizationId ?? '').isNotEmpty)
                        Text(
                          '#${note.organizationId}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('EEE, MMM d').format(date);
  }

  String _buildDaysLabel() {
    final days = note.daysUntil;
    if (days == null) return '';
    if (days == 0) {
      return l10n.today;
    }
    return l10n.inDays(days);
  }

  String _typeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'holiday':
        return l10n.noticeTypeHoliday;
      case 'event':
        return l10n.noticeTypeEvent;
      default:
        return l10n.noticeTypeOther;
    }
  }

  Widget _buildSecondaryChip(
    IconData icon,
    String label, {
    bool highlight = false,
  }) {
    final background = highlight
        ? AppColors.lightOrange
        : AppColors.inputBackground;
    final color = highlight ? AppColors.designOrange : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final String type;

  const _TypeChip({required this.label, required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.bookmark_outline,
            size: 14,
            color: _foregroundColor,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _foregroundColor,
            ),
          ),
        ],
      ),
    );
  }

  Color get _foregroundColor {
    switch (type.toLowerCase()) {
      case 'holiday':
        return AppColors.success;
      case 'event':
        return AppColors.accent;
      default:
        return AppColors.primary;
    }
  }

  Color get _backgroundColor => _foregroundColor.withValues(alpha: 0.1);
}
