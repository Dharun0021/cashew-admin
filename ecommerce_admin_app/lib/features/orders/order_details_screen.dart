import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/custom_card.dart';
import '../../core/widgets/status_badge.dart';
import '../../models/order_model.dart';
import '../../providers/order_provider.dart';

class OrderDetailsScreen extends StatelessWidget {
  final OrderModel order;

  const OrderDetailsScreen({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 900.0;

    // Load active order values directly from state (so changes sync immediately)
    final activeOrder = orderProvider.orders.firstWhere((o) => o.id == order.id, orElse: () => order);

    return Scaffold(
      appBar: AppBar(
        title: Text('Invoice Summary: ${activeOrder.id}'),
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quick Status Header Bar
                CustomCard(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Placed on: ${Formatters.formatDateTime(activeOrder.date)}',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Text(
                                'Payment status: ',
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                              ),
                              StatusBadge(status: activeOrder.paymentStatus),
                            ],
                          ),
                        ],
                      ),
                      // Dropdown updates
                      Row(
                        children: [
                          DropdownButton<String>(
                            value: activeOrder.status,
                            onChanged: (val) {
                              if (val != null) {
                                orderProvider.updateOrderStatus(activeOrder.id, val);
                              }
                            },
                            items: const [
                              DropdownMenuItem(value: 'Pending', child: Text('Pending Dispatch')),
                              DropdownMenuItem(value: 'Packed', child: Text('Packed & Ready')),
                              DropdownMenuItem(value: 'Shipped', child: Text('Shipped (Transit)')),
                              DropdownMenuItem(value: 'Delivered', child: Text('Delivered')),
                              DropdownMenuItem(value: 'Cancelled', child: Text('Cancelled')),
                            ],
                          ),
                          const SizedBox(width: 16),
                          DropdownButton<String>(
                            value: activeOrder.paymentStatus,
                            onChanged: (val) {
                              if (val != null) {
                                orderProvider.updatePaymentStatus(activeOrder.id, val);
                              }
                            },
                            items: const [
                              DropdownMenuItem(value: 'Paid', child: Text('Mark Paid')),
                              DropdownMenuItem(value: 'Unpaid', child: Text('Mark Unpaid')),
                              DropdownMenuItem(value: 'Refunded', child: Text('Mark Refunded')),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),

                if (isDesktop)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            _buildOrderItemsCard(activeOrder),
                            const SizedBox(height: 24),
                            _buildTimelineCard(activeOrder),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            _buildCustomerCard(activeOrder),
                            const SizedBox(height: 24),
                            _buildInvoiceSummary(activeOrder),
                          ],
                        ),
                      ),
                    ],
                  )
                else
                  Column(
                    children: [
                      _buildCustomerCard(activeOrder),
                      const SizedBox(height: 24),
                      _buildOrderItemsCard(activeOrder),
                      const SizedBox(height: 24),
                      _buildTimelineCard(activeOrder),
                      const SizedBox(height: 24),
                      _buildInvoiceSummary(activeOrder),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderItemsCard(OrderModel o) {
    return CustomCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              'Ordered Items',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
          ),
          Table(
            border: TableBorder(
              horizontalInside: BorderSide(color: AppColors.border, width: 0.5),
            ),
            columnWidths: const {
              0: FlexColumnWidth(3),
              1: FlexColumnWidth(1),
              2: FlexColumnWidth(1),
              3: FlexColumnWidth(1),
            },
            children: [
              // Header Row
              TableRow(
                decoration: const BoxDecoration(color: AppColors.background),
                children: const [
                  Padding(padding: EdgeInsets.all(12), child: Text('Product Item', style: TextStyle(fontWeight: FontWeight.w600))),
                  Padding(padding: EdgeInsets.all(12), child: Text('Price', style: TextStyle(fontWeight: FontWeight.w600))),
                  Padding(padding: EdgeInsets.all(12), child: Text('Qty', style: TextStyle(fontWeight: FontWeight.w600))),
                  Padding(padding: EdgeInsets.all(12), child: Text('Total', style: TextStyle(fontWeight: FontWeight.w600))),
                ],
              ),
              // Body Rows
              ...o.items.map((item) {
                return TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(item.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(Formatters.formatCurrency(item.price), style: const TextStyle(fontSize: 13)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text('x${item.quantity}', style: const TextStyle(fontSize: 13)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(Formatters.formatCurrency(item.price * item.quantity), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                  ],
                );
              }).toList(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard(OrderModel o) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Customer Details',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(o.customerName[0].toUpperCase(), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(o.customerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(o.customerEmail, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          const Text('Contact Information', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          Text('Phone: ${o.customerPhone}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          const Divider(height: 24),
          const Text('Shipping Address', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          Text(o.shippingAddress, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildTimelineCard(OrderModel o) {
    // Determine active steps based on status
    final steps = ['Pending', 'Packed', 'Shipped', 'Delivered'];
    final currentStep = steps.indexOf(o.status);

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Delivery Timeline Tracker',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(steps.length, (index) {
              final stepName = steps[index];
              final isCompleted = index <= currentStep && o.status != 'Cancelled';
              final isCurrent = index == currentStep;
              final isCancelled = o.status == 'Cancelled';

              Color iconColor = isCompleted ? AppColors.success : AppColors.textLight;
              if (isCancelled) iconColor = AppColors.error;

              return Expanded(
                child: Row(
                  children: [
                    // Dot
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: iconColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isCurrent ? AppColors.primary : iconColor,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            isCancelled
                                ? Icons.cancel_outlined
                                : (isCompleted ? Icons.check : Icons.circle),
                            size: 16,
                            color: isCancelled ? AppColors.error : (isCompleted ? AppColors.success : AppColors.textLight),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          stepName,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                            color: isCurrent ? AppColors.primary : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    // Line
                    if (index < steps.length - 1)
                      Expanded(
                        child: Container(
                          height: 2,
                          color: index < currentStep && !isCancelled
                              ? AppColors.success
                              : AppColors.border,
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceSummary(OrderModel o) {
    final subtotal = o.items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
    final shipping = 5.00;
    final tax = subtotal * 0.08;

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Cost Breakdown',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16),
          _buildInvoiceRow('Subtotal', Formatters.formatCurrency(subtotal)),
          const SizedBox(height: 8),
          _buildInvoiceRow('Shipping Flat Rate', Formatters.formatCurrency(shipping)),
          const SizedBox(height: 8),
          _buildInvoiceRow('Taxes (8% GST)', Formatters.formatCurrency(tax)),
          const Divider(height: 24),
          _buildInvoiceRow(
            'Total Charge',
            Formatters.formatCurrency(subtotal + shipping + tax),
            isBold: true,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.payment_outlined, size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(
                'Paid via: ${o.paymentMethod}',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildInvoiceRow(String label, String val, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 14 : 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
        Text(
          val,
          style: TextStyle(
            fontSize: isBold ? 15 : 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
