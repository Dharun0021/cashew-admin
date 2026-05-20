import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/custom_card.dart';
import '../../core/widgets/custom_table.dart';
import '../../core/widgets/status_badge.dart';
import '../../providers/notification_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _pushFormKey = GlobalKey<FormState>();
  final _waFormKey = GlobalKey<FormState>();

  final _pushTitleController = TextEditingController();
  final _pushBodyController = TextEditingController();
  String _pushTargetGroup = 'All Customers';

  final _waCustomerNameController = TextEditingController();
  final _waOrderIdController = TextEditingController();
  String _waTemplate = 'Order Shipment Notification Template';

  @override
  void dispose() {
    _pushTitleController.dispose();
    _pushBodyController.dispose();
    _waCustomerNameController.dispose();
    _waOrderIdController.dispose();
    super.dispose();
  }

  void _handleSendPush() async {
    if (_pushFormKey.currentState!.validate()) {
      final provider = Provider.of<NotificationProvider>(context, listen: false);
      await provider.sendNotification(
        title: _pushTitleController.text.trim(),
        body: _pushBodyController.text.trim(),
        type: 'Push Notification',
        targetGroup: _pushTargetGroup,
      );

      _pushTitleController.clear();
      _pushBodyController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Push Notification Broadcasted Successfully!')),
        );
      }
    }
  }

  void _handleSendWhatsApp() async {
    if (_waFormKey.currentState!.validate()) {
      final provider = Provider.of<NotificationProvider>(context, listen: false);
      final bodyText = 'Hi ${_waCustomerNameController.text.trim()}, your order ${_waOrderIdController.text.trim()} has been shipped! Track it here: cashew.com/track';
      
      await provider.sendNotification(
        title: _waTemplate,
        body: bodyText,
        type: 'WhatsApp Placeholder UI',
        targetGroup: 'Single Client (${_waCustomerNameController.text.trim()})',
      );

      _waCustomerNameController.clear();
      _waOrderIdController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('WhatsApp Notification Dispatched!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final history = notificationProvider.notifications;
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 1000.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row of Forms
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildPushBroadcastCard()),
                const SizedBox(width: 24),
                Expanded(child: _buildWhatsAppCard()),
              ],
            )
          else
            Column(
              children: [
                _buildPushBroadcastCard(),
                const SizedBox(height: 24),
                _buildWhatsAppCard(),
              ],
            ),
          
          const SizedBox(height: 24),

          // Broadcast History Card
          _buildBroadcastHistoryCard(notificationProvider, history),
        ],
      ),
    );
  }

  Widget _buildPushBroadcastCard() {
    return CustomCard(
      child: Form(
        key: _pushFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.campaign_outlined, color: AppColors.primary, size: 24),
                SizedBox(width: 10),
                Text(
                  'Push Broadcast Campaign',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            CustomTextField(
              labelText: 'Campaign Title',
              hintText: 'e.g. Flash Discount 20%',
              controller: _pushTitleController,
              validator: (v) => v!.isEmpty ? 'Campaign title is required' : null,
            ),
            const SizedBox(height: 16),
            
            CustomTextField(
              labelText: 'Message Body',
              hintText: 'Write notifications details here...',
              controller: _pushBodyController,
              maxLines: 3,
              validator: (v) => v!.isEmpty ? 'Message body is required' : null,
            ),
            const SizedBox(height: 16),
            
            DropdownButtonFormField<String>(
              value: _pushTargetGroup,
              decoration: const InputDecoration(labelText: 'Target Audience Group'),
              items: const [
                DropdownMenuItem(value: 'All Customers', child: Text('All Registered Customers')),
                DropdownMenuItem(value: 'Active Shoppers', child: Text('Active Shoppers (Last 30d)')),
                DropdownMenuItem(value: 'Inactive Leads', child: Text('Inactive Leads (30d+)')),
              ],
              onChanged: (val) {
                setState(() {
                  _pushTargetGroup = val!;
                });
              },
            ),
            const SizedBox(height: 20),
            
            Align(
              alignment: Alignment.centerRight,
              child: CustomButton(
                text: 'Send Broadcast',
                icon: Icons.send_outlined,
                onPressed: _handleSendPush,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWhatsAppCard() {
    return CustomCard(
      child: Form(
        key: _waFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.chat_bubble_outline, color: Colors.green, size: 24),
                SizedBox(width: 10),
                Text(
                  'WhatsApp Notification Sandbox',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            DropdownButtonFormField<String>(
              value: _waTemplate,
              decoration: const InputDecoration(labelText: 'WhatsApp Template'),
              items: const [
                DropdownMenuItem(
                  value: 'Order Shipment Notification Template',
                  child: Text('Order Shipment (Standard)'),
                ),
              ],
              onChanged: (val) {
                setState(() {
                  _waTemplate = val!;
                });
              },
            ),
            const SizedBox(height: 16),
            
            CustomTextField(
              labelText: 'Customer Variable {{name}}',
              hintText: 'e.g. Jane Cooper',
              controller: _waCustomerNameController,
              validator: (v) => v!.isEmpty ? 'Customer name variable required' : null,
            ),
            const SizedBox(height: 16),

            CustomTextField(
              labelText: 'Order Variable {{order_id}}',
              hintText: 'e.g. ORD-9823',
              controller: _waOrderIdController,
              validator: (v) => v!.isEmpty ? 'Order ID variable required' : null,
            ),
            const SizedBox(height: 20),

            Align(
              alignment: Alignment.centerRight,
              child: CustomButton(
                text: 'Send WhatsApp API',
                icon: Icons.api_outlined,
                customColor: Colors.green,
                onPressed: _handleSendWhatsApp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBroadcastHistoryCard(NotificationProvider provider, List<dynamic> list) {
    return CustomCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              'Broadcast Messaging History Logs',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
          ),
          list.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.0),
                  child: Center(
                    child: Text('No messages sent in this session', style: TextStyle(color: AppColors.textSecondary)),
                  ),
                )
              : CustomTable(
                  columns: [
                    CustomTableColumn(title: 'Category Type', width: 180),
                    CustomTableColumn(title: 'Campaign Message Details'),
                    CustomTableColumn(title: 'Target Audience Group', width: 180),
                    CustomTableColumn(title: 'Date Broadcasted', width: 180),
                    CustomTableColumn(title: 'Status', width: 130),
                  ],
                  rowCount: list.length,
                  cellBuilder: (context, rowIndex, colIndex) {
                    final n = list[rowIndex];
                    switch (colIndex) {
                      case 0:
                        return Row(
                          children: [
                            Icon(
                              n.type.contains('WhatsApp') ? Icons.chat_bubble_outline : Icons.campaign_outlined,
                              size: 16,
                              color: n.type.contains('WhatsApp') ? Colors.green : AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(n.type, style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        );
                      case 1:
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              n.title,
                              style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              n.body,
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        );
                      case 2:
                        return Text(n.targetGroup);
                      case 3:
                        return Text(Formatters.formatDateTime(n.sentDate));
                      case 4:
                        return StatusBadge(status: n.status);
                      default:
                        return const Text('');
                    }
                  },
                ),
        ],
      ),
    );
  }
}
