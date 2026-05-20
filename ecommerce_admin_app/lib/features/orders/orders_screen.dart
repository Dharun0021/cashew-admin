import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/custom_card.dart';
import '../../core/widgets/custom_table.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/widgets/empty_state.dart';
import '../../providers/order_provider.dart';
import 'order_details_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Search & Filter Header
          CustomCard(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    labelText: 'Search Orders',
                    hintText: 'Search by Order ID or customer name...',
                    controller: _searchController,
                    prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textLight),
                    onChanged: (val) {
                      orderProvider.setSearchQuery(val);
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Tab selectors
          TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            tabs: const [
              Tab(text: 'All Orders'),
              Tab(text: 'Pending'),
              Tab(text: 'Packed'),
              Tab(text: 'Shipped'),
              Tab(text: 'Delivered'),
              Tab(text: 'Cancelled'),
            ],
          ),

          const SizedBox(height: 20),

          // Tab content area
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOrderList(orderProvider.orders),
                _buildOrderList(orderProvider.pendingOrders),
                _buildOrderList(orderProvider.packedOrders),
                _buildOrderList(orderProvider.shippedOrders),
                _buildOrderList(orderProvider.deliveredOrders),
                _buildOrderList(orderProvider.cancelledOrders),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList(List<dynamic> list) {
    return CustomCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: list.isEmpty
                ? const EmptyState(
                    title: 'No Orders Registered',
                    description: 'No customer purchases matched your current search parameters.',
                    icon: Icons.local_shipping_outlined,
                  )
                : CustomTable(
                    columns: [
                      CustomTableColumn(title: 'Order ID', width: 120),
                      CustomTableColumn(title: 'Date & Time', width: 180),
                      CustomTableColumn(title: 'Customer Name'),
                      CustomTableColumn(title: 'Items Bought', width: 110, alignment: Alignment.center),
                      CustomTableColumn(title: 'Total Revenue', width: 110, alignment: Alignment.centerRight),
                      CustomTableColumn(title: 'Payment Status', width: 130),
                      CustomTableColumn(title: 'Logistics', width: 130),
                    ],
                    rowCount: list.length,
                    onRowTap: (index) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderDetailsScreen(order: list[index]),
                        ),
                      );
                    },
                    cellBuilder: (context, rowIndex, colIndex) {
                      final order = list[rowIndex];
                      final itemsCount = order.items.fold(0, (sum, item) => sum + item.quantity);

                      switch (colIndex) {
                        case 0:
                          return Text(
                            order.id,
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                          );
                        case 1:
                          return Text(Formatters.formatDateTime(order.date));
                        case 2:
                          return Text(
                            order.customerName,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          );
                        case 3:
                          return Text('$itemsCount items');
                        case 4:
                          return Text(
                            Formatters.formatCurrency(order.total),
                            style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                          );
                        case 5:
                          return StatusBadge(status: order.paymentStatus);
                        case 6:
                          return StatusBadge(status: order.status);
                        default:
                          return const Text('');
                      }
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
