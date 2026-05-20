import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/custom_card.dart';
import '../../core/widgets/custom_table.dart';
import '../../core/widgets/status_badge.dart';
import '../../providers/category_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/order_provider.dart';
import 'widgets/stat_card.dart';
import 'widgets/analytics_chart.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);

    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 1100.0;
    final isTablet = size.width >= 600.0 && size.width < 1100.0;

    final statsLoading = categoryProvider.isLoading || productProvider.isLoading || orderProvider.isLoading;

    if (statsLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row of Stat Cards
          GridView.count(
            crossAxisCount: isDesktop ? 4 : (isTablet ? 2 : 1),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.6,
            children: [
              StatCard(
                title: 'Total Revenue',
                value: Formatters.formatCurrency(orderProvider.totalRevenue),
                icon: Icons.monetization_on_outlined,
                changeText: '+14.2%',
                isPositiveChange: true,
                iconColor: Colors.deepPurple,
                iconBgColor: Colors.deepPurple.shade50,
              ),
              StatCard(
                title: 'Total Orders',
                value: orderProvider.totalOrdersCount.toString(),
                icon: Icons.shopping_cart_outlined,
                changeText: '+8.4%',
                isPositiveChange: true,
                iconColor: Colors.blue,
                iconBgColor: Colors.blue.shade50,
              ),
              StatCard(
                title: 'Products in Catalog',
                value: productProvider.allProducts.length.toString(),
                icon: Icons.shopping_bag_outlined,
                changeText: '+4.1%',
                isPositiveChange: true,
                iconColor: AppColors.primary,
                iconBgColor: const Color(0xFFFEF3C7),
              ),
              StatCard(
                title: 'Categories',
                value: categoryProvider.categories.length.toString(),
                icon: Icons.grid_view_outlined,
                changeText: '+12.5%',
                isPositiveChange: true,
                iconColor: Colors.teal,
                iconBgColor: Colors.teal.shade50,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Charts & Secondary metrics
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      const CustomCard(child: AnalyticsChart()),
                      const SizedBox(height: 24),
                      _buildRecentOrders(context, orderProvider),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      _buildLowStockProducts(context, productProvider),
                      const SizedBox(height: 24),
                      _buildQuickLinks(context),
                    ],
                  ),
                ),
              ],
            )
          else
            Column(
              children: [
                const CustomCard(child: AnalyticsChart()),
                const SizedBox(height: 24),
                _buildRecentOrders(context, orderProvider),
                const SizedBox(height: 24),
                _buildLowStockProducts(context, productProvider),
                const SizedBox(height: 24),
                _buildQuickLinks(context),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildRecentOrders(BuildContext context, OrderProvider provider) {
    final recent = provider.orders.take(5).toList();

    return CustomCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              'Recent Orders',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          CustomTable(
            columns: [
              CustomTableColumn(title: 'Order ID', width: 100),
              CustomTableColumn(title: 'Customer'),
              CustomTableColumn(title: 'Total', width: 90, alignment: Alignment.centerRight),
              CustomTableColumn(title: 'Status', width: 110),
            ],
            rowCount: recent.length,
            cellBuilder: (context, rowIndex, colIndex) {
              final order = recent[rowIndex];
              switch (colIndex) {
                case 0:
                  return Text(
                    order.id,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                  );
                case 1:
                  return Text(order.customerName);
                case 2:
                  return Text(
                    Formatters.formatCurrency(order.total),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  );
                case 3:
                  return StatusBadge(status: order.status);
                default:
                  return const Text('');
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLowStockProducts(BuildContext context, ProductProvider provider) {
    final lowStock = provider.lowStockProducts;

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Low Stock Warning',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              if (lowStock.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.errorBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${lowStock.length} items',
                    style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (lowStock.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: Center(
                child: Text(
                  'All products are adequately stocked.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: lowStock.length.clamp(0, 4),
              separatorBuilder: (context, index) => const Divider(height: 20),
              itemBuilder: (context, index) {
                final product = lowStock[index];
                return Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        product.image,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        errorBuilder: (context, _, __) => Container(
                          width: 40,
                          height: 40,
                          color: AppColors.background,
                          child: const Icon(Icons.image, color: AppColors.textLight),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'SKU: ${product.sku}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${product.stock} left',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.error,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const StatusBadge(status: 'low stock'),
                      ],
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildQuickLinks(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Integrations',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildQuickLinkItem(
            icon: Icons.api_outlined,
            title: 'API Gateway Status',
            subtitle: 'Mock API sandbox online',
            color: Colors.blue,
          ),
          const Divider(height: 24),
          _buildQuickLinkItem(
            icon: Icons.webhook_outlined,
            title: 'Webhook Endpoints',
            subtitle: '0 connected webhooks',
            color: Colors.purple,
          ),
          const Divider(height: 24),
          _buildQuickLinkItem(
            icon: Icons.shield_outlined,
            title: 'Security Compliance',
            subtitle: 'SSL active, M3 standards met',
            color: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickLinkItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const Icon(Icons.chevron_right, color: AppColors.textLight, size: 16),
      ],
    );
  }
}
