import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/custom_card.dart';
import '../../core/widgets/custom_table.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/widgets/empty_state.dart';
import '../../providers/customer_provider.dart';
import '../../providers/order_provider.dart';
import '../orders/order_details_screen.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({Key? key}) : super(key: key);

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showCustomerDetailDrawer(dynamic customer, BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final customerProvider = Provider.of<CustomerProvider>(context, listen: false);

    // Get order history
    final history = customerProvider.getCustomerOrderHistory(customer.email, orderProvider.orders);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          padding: const EdgeInsets.all(24.0),
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: NetworkImage(customer.avatar),
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        child: customer.avatar.isEmpty
                            ? Text(customer.name[0].toUpperCase())
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customer.name,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                          Text(
                            customer.email,
                            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              
              const Divider(height: 32),

              // Contact & Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Phone Number', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      Text(customer.phone, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Joined Date', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      Text(Formatters.formatDate(customer.joinDate), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Spent', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      Text(
                        Formatters.formatCurrency(customer.totalSpend),
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.success, fontSize: 14),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Order Volume', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      Text('${customer.totalOrders} Purchases', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                ],
              ),

              const Divider(height: 32),

              // Order History Header
              const Text(
                'Customer Order History',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),

              // Order History List
              Expanded(
                child: history.isEmpty
                    ? const Center(
                        child: Text(
                          'No purchases found on this customer profile.',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                      )
                    : ListView.separated(
                        itemCount: history.length,
                        separatorBuilder: (context, index) => const Divider(height: 16),
                        itemBuilder: (context, index) {
                          final o = history[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Row(
                              children: [
                                Text(o.id, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                                const SizedBox(width: 12),
                                StatusBadge(status: o.status),
                              ],
                            ),
                            subtitle: Text('Placed: ${Formatters.formatDate(o.date)} • via ${o.paymentMethod}'),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  Formatters.formatCurrency(o.total),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                                ),
                                const Text('View Invoice', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OrderDetailsScreen(order: o),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final customerProvider = Provider.of<CustomerProvider>(context);
    final list = customerProvider.customers;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Filter Search Bar
          CustomCard(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    labelText: 'Search Customer profiles',
                    hintText: 'Search by full name, registered email address...',
                    controller: _searchController,
                    prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textLight),
                    onChanged: (val) {
                      customerProvider.setSearchQuery(val);
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Main data table
          Expanded(
            child: CustomCard(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text(
                      'Customer Registered Directory',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: list.isEmpty
                        ? const EmptyState(
                            title: 'No Customers Found',
                            description: 'No registered user matches your current search terms.',
                            icon: Icons.people_outline,
                          )
                        : CustomTable(
                            columns: [
                              CustomTableColumn(title: 'Avatar', width: 60),
                              CustomTableColumn(title: 'Customer Name'),
                              CustomTableColumn(title: 'Email Address'),
                              CustomTableColumn(title: 'Phone Number', width: 140),
                              CustomTableColumn(title: 'Orders', width: 90, alignment: Alignment.center),
                              CustomTableColumn(title: 'Total Spend', width: 110, alignment: Alignment.centerRight),
                              CustomTableColumn(title: 'Status', width: 110),
                            ],
                            rowCount: list.length,
                            onRowTap: (index) {
                              _showCustomerDetailDrawer(list[index], context);
                            },
                            cellBuilder: (context, rowIndex, colIndex) {
                              final customer = list[rowIndex];
                              switch (colIndex) {
                                case 0:
                                  return CircleAvatar(
                                    radius: 18,
                                    backgroundImage: NetworkImage(customer.avatar),
                                    backgroundColor: AppColors.primary.withOpacity(0.1),
                                    child: customer.avatar.isEmpty
                                        ? Text(customer.name[0].toUpperCase())
                                        : null,
                                  );
                                case 1:
                                  return Text(
                                    customer.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                  );
                                case 2:
                                  return Text(customer.email);
                                case 3:
                                  return Text(customer.phone);
                                case 4:
                                  return Text('${customer.totalOrders} orders');
                                case 5:
                                  return Text(
                                    Formatters.formatCurrency(customer.totalSpend),
                                    style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                  );
                                case 6:
                                  return StatusBadge(status: customer.status);
                                default:
                                  return const Text('');
                              }
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
