import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class PiAlertAppBar extends StatelessWidget implements PreferredSizeWidget {
  final IconData icon;
  final String title;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;

  const PiAlertAppBar({
    super.key,
    required this.icon,
    required this.title,
    this.actions,
    this.bottom,
  });

  @override
  Size get preferredSize => Size.fromHeight(
        44 + (bottom?.preferredSize.height ?? 0),
      );

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Colors.white,
                ),
          ),
        ],
      ),
      automaticallyImplyLeading: false,
      toolbarHeight: 44,
      elevation: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primaryGradientEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      actions: actions,
      bottom: bottom,
    );
  }
}

class PiAlertProfileAction extends StatelessWidget {
  final VoidCallback onPressed;

  const PiAlertProfileAction({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: const Icon(Icons.person, size: 20),
        tooltip: 'Profil',
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
        onPressed: onPressed,
      ),
    );
  }
}
