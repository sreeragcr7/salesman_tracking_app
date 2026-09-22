import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class AdminDashboardHeader extends StatelessWidget {
  const AdminDashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Welcome back,',
              style: AppTextStyles.titleLarge.copyWith(color: textTheme.bodyMedium?.color?.withValues(alpha: 0.65)),
            ),
            Text(' ADMIN', style: AppTextStyles.headlineMedium.copyWith(color: AppColors.primary)),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Manage your sales team',
          style: textTheme.bodyMedium?.copyWith(color: textTheme.bodyMedium?.color?.withValues(alpha: 0.65)),
        ),
        const SizedBox(height: 15),
        Text('Salesmen', style: AppTextStyles.titleLarge),
      ],
    );
  }
}
