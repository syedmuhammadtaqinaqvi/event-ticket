import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class ActionToast extends StatelessWidget {
  const ActionToast({
    super.key,
    required this.message,
    required this.icon,
    required this.visible,
  });

  final String message;
  final IconData icon;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 300),
        offset: visible ? Offset.zero : const Offset(0, 2),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: visible ? 1 : 0,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            color: AppColors.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: AppColors.secondary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    message,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.onPrimary,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
