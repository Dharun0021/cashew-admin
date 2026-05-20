import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';

class SidebarNavigation extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onDestinationSelected;
  final bool isCollapsed;

  const SidebarNavigation({
    Key? key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.isCollapsed = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isCollapsed ? 80 : 260,
      height: double.infinity,
      color: AppColors.sidebarBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Logo Area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFF1E293B), width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.shopping_bag_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                if (!isCollapsed) ...[
                  const SizedBox(width: 12),
                  const Text(
                    AppConstants.appName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Navigation Items List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
              children: [
                _buildNavItem(context, index: 0, icon: Icons.dashboard_outlined, label: 'Dashboard'),
                _buildNavItem(context, index: 1, icon: Icons.category_outlined, label: 'Categories'),
                _buildNavItem(context, index: 2, icon: Icons.shopping_basket_outlined, label: 'Products'),
                _buildNavItem(context, index: 3, icon: Icons.inventory_2_outlined, label: 'Inventory'),
                _buildNavItem(context, index: 4, icon: Icons.local_shipping_outlined, label: 'Orders'),
                _buildNavItem(context, index: 5, icon: Icons.people_outline, label: 'Customers'),
                _buildNavItem(context, index: 6, icon: Icons.notifications_none_outlined, label: 'Notifications'),
                _buildNavItem(context, index: 7, icon: Icons.settings_outlined, label: 'Settings'),
              ],
            ),
          ),

          // Footer version tag
          if (!isCollapsed)
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'v${AppConstants.appVersion}',
                style: TextStyle(
                  color: AppColors.sidebarText,
                  fontSize: 11,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: InkWell(
        onTap: () => onDestinationSelected(index),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isCollapsed ? 12 : 16,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.sidebarText,
                size: 22,
              ),
              if (!isCollapsed) ...[
                const SizedBox(width: 14),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.sidebarText,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
