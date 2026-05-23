import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/sidebar_navigation.dart';
import '../widgets/header_bar.dart';

// Features
import '../features/dashboard/dashboard_screen.dart';
import '../features/categories/categories_screen.dart';
import '../features/products/products_screen.dart';
import '../features/inventory/inventory_screen.dart';
import '../features/orders/orders_screen.dart';
import '../features/customers/customers_screen.dart';
import '../features/notifications/notifications_screen.dart';
import '../features/settings/settings_screen.dart';

// Providers
import '../providers/category_provider.dart';
import '../providers/product_provider.dart';
import '../providers/order_provider.dart';
import '../providers/customer_provider.dart';
import '../providers/notification_provider.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({Key? key}) : super(key: key);

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<String> _pageTitles = [
    'Dashboard Overview',
    'Category Management',
    'Product Catalog',
    'Inventory Stock Control',
    'Order Management',
    'Customer Database',
    'Notification Broadcasts',
    'Application Settings',
  ];

  @override
  void initState() {
    super.initState();
    // Prefetch all data to display rich mock numbers instantly
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CategoryProvider>(context, listen: false).loadCategories();
      Provider.of<ProductProvider>(context, listen: false).loadProducts();
      Provider.of<OrderProvider>(context, listen: false).loadOrders();
      Provider.of<CustomerProvider>(context, listen: false).loadCustomers();
      Provider.of<NotificationProvider>(context, listen: false).loadNotifications();
    });
  }

  Widget _buildSelectedScreen() {
    switch (_selectedIndex) {
      case 0:
        return const DashboardScreen();
      case 1:
        return const CategoriesScreen();
      case 2:
        return const ProductsScreen();
      case 3:
        return const InventoryScreen();
      case 4:
        return const OrdersScreen();
      case 5:
        return const CustomersScreen();
      case 6:
        return const NotificationsScreen();
      case 7:
        return const SettingsScreen();
      default:
        return const DashboardScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);

    if (isMobile) {
      // Mobile Layout: Header is fixed at the top using Scaffold appBar
      return Scaffold(
        key: _scaffoldKey,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: HeaderBar(
            title: _pageTitles[_selectedIndex],
            showMenuButton: isMobile,
            onMenuPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
        ),
        drawer: SidebarNavigation(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() {
              _selectedIndex = index;
            });
            _scaffoldKey.currentState?.closeDrawer();
          },
        ),
        body: Container(
          color: AppColors.background,
          child: _buildSelectedScreen(),
        ),
      );
    } else {
      // Desktop/Tablet Layout
      return Scaffold(
        key: _scaffoldKey,
        body: Row(
          children: [
            // Persistent sidebar on Desktop/Tablet
            SidebarNavigation(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              isCollapsed: ResponsiveLayout.isTablet(context),
            ),
            
            // Main content area
            Expanded(
              child: Column(
                children: [
                  HeaderBar(
                    title: _pageTitles[_selectedIndex],
                    showMenuButton: false,
                    onMenuPressed: () {
                      _scaffoldKey.currentState?.openDrawer();
                    },
                  ),
                  Expanded(
                    child: Container(
                      color: AppColors.background,
                      child: _buildSelectedScreen(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }
}