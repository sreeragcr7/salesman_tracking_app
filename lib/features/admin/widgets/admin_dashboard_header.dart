import 'package:flutter/material.dart';
import 'package:salesman_tracking_app/core/constants/enums.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class AdminDashboardHeader extends StatelessWidget {
  final int totalSalesmen;
  final int activeSalesmen;
  final int completedSalesmen;
  final int notStartedSalesmen;

  final SalesmanFilter selectedFilter;
  final ValueChanged<SalesmanFilter> onFilterSelected;

  const AdminDashboardHeader({
    super.key,
    required this.totalSalesmen,
    required this.activeSalesmen,
    required this.completedSalesmen,
    required this.notStartedSalesmen,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sales Team Overview', style: AppTextStyles.bodyLarge),
        const SizedBox(height: 16),
        _SalesmenSummary(
          totalSalesmen: totalSalesmen,
          activeSalesmen: activeSalesmen,
          completedSalesmen: completedSalesmen,
          notStartedSalesmen: notStartedSalesmen,
          selectedFilter: selectedFilter,
          onFilterSelected: onFilterSelected,
        ),
        const SizedBox(height: 18),
        Text(_getSelectedTitle(), style: AppTextStyles.titleMedium),
      ],
    );
  }

  String _getSelectedTitle() {
    switch (selectedFilter) {
      case SalesmanFilter.all:
        return 'All Salesmen';
      case SalesmanFilter.active:
        return 'Active Salesmen';
      case SalesmanFilter.completed:
        return 'Completed Salesmen';
      case SalesmanFilter.notStarted:
        return 'Not Started';
    }
  }
}

class _SalesmenSummary extends StatelessWidget {
  final int totalSalesmen;
  final int activeSalesmen;
  final int completedSalesmen;
  final int notStartedSalesmen;

  final SalesmanFilter selectedFilter;
  final ValueChanged<SalesmanFilter> onFilterSelected;

  const _SalesmenSummary({
    required this.totalSalesmen,
    required this.activeSalesmen,
    required this.completedSalesmen,
    required this.notStartedSalesmen,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SummaryItem(
              icon: Icons.people_outline,
              value: totalSalesmen,
              label: 'Total',
              color: AppColors.primary,
              isSelected: selectedFilter == SalesmanFilter.all,
              onTap: () {
                onFilterSelected(SalesmanFilter.all);
              },
            ),
          ),
          _SummaryDivider(),
          Expanded(
            child: _SummaryItem(
              icon: Icons.circle,
              value: activeSalesmen,
              label: 'Active',
              color: AppColors.success,
              isSelected: selectedFilter == SalesmanFilter.active,
              onTap: () {
                onFilterSelected(SalesmanFilter.active);
              },
            ),
          ),
          _SummaryDivider(),
          Expanded(
            child: _SummaryItem(
              icon: Icons.check_circle_outline,
              value: completedSalesmen,
              label: 'Completed',
              color: Colors.grey,
              isSelected: selectedFilter == SalesmanFilter.completed,
              onTap: () {
                onFilterSelected(SalesmanFilter.completed);
              },
            ),
          ),
          _SummaryDivider(),
          Expanded(
            child: _SummaryItem(
              icon: Icons.circle_outlined,
              value: notStartedSalesmen,
              label: 'Not Started',
              color: AppColors.warning,
              isSelected: selectedFilter == SalesmanFilter.notStarted,
              onTap: () {
                onFilterSelected(SalesmanFilter.notStarted);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final int value;
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _SummaryItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(height: 5),
              Text(
                '$value',
                style: AppTextStyles.titleLarge.copyWith(color: color, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodySmall?.copyWith(
                  color: textTheme.bodySmall?.color?.withValues(alpha: isSelected ? 0.90 : 0.65),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              const SizedBox(height: 6),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: isSelected ? 24 : 0,
                height: 2,
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryDivider extends StatelessWidget {
  const _SummaryDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 48, color: Theme.of(context).colorScheme.outlineVariant);
  }
}
