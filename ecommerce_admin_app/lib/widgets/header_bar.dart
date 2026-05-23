import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/auth_provider.dart';

class HeaderBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onMenuPressed;
  final bool showMenuButton;

  const HeaderBar({
    Key? key,
    required this.title,
    this.onMenuPressed,
    this.showMenuButton = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 2,
      shadowColor: AppColors.border.withOpacity(0.2),
      leading: showMenuButton
          ? IconButton(
              icon: const Icon(Icons.menu, color: AppColors.textPrimary, size: 24),
              onPressed: onMenuPressed,
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(),
            )
          : null,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Text(
          title,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: isMobile ? 16 : 20,
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      actions: [
        // Search bar for larger screens (hidden on mobile)
        if (MediaQuery.of(context).size.width > 800)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Container(
              width: 240,
              height: 38,
              margin: const EdgeInsets.only(right: 8),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search...',
                  hintStyle: const TextStyle(color: AppColors.textLight, fontSize: 12),
                  prefixIcon: const Icon(Icons.search, size: 16, color: AppColors.textLight),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  fillColor: AppColors.background,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),

        // Notifications Icon with badge
        Padding(
          padding: const EdgeInsets.only(right: 4.0),
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none_outlined, color: AppColors.textPrimary, size: 22),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No new alerts')),
                  );
                },
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Admin profile dropdown
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'logout') {
              authProvider.logout();
              Navigator.pushReplacementNamed(context, '/login');
            }
          },
          offset: const Offset(0, 48),
          padding: const EdgeInsets.only(right: 8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(
                    authProvider.adminName.isNotEmpty ? authProvider.adminName[0].toUpperCase() : 'A',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
                if (MediaQuery.of(context).size.width > 500) ...[
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      authProvider.adminName.length > 10 
                        ? '${authProvider.adminName.substring(0, 10)}...' 
                        : authProvider.adminName,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary, size: 16),
                ],
              ],
            ),
          ),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'profile',
              child: Row(
                children: const [
                  Icon(Icons.person_outline, size: 16, color: AppColors.textSecondary),
                  SizedBox(width: 8),
                  Text('Profile Settings', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'logout',
              child: Row(
                children: const [
                  Icon(Icons.logout, size: 16, color: AppColors.error),
                  SizedBox(width: 8),
                  Text('Logout', style: TextStyle(fontSize: 12, color: AppColors.error)),
                ],
              ),
            ),
          ],
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.5),
        child: Container(
          color: AppColors.border.withOpacity(0.5),
          height: 1.5,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 2.0);
}
