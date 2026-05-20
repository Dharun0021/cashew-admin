import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/custom_card.dart';
import '../../core/widgets/custom_table.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/custom_dialog.dart';
import '../../providers/product_provider.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({Key? key}) : super(key: key);

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final _searchController = TextEditingController();
  String _stockFilter = 'All'; // All, Low Stock, Out of Stock, In Stock

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAdjustStockDialog(String id, String name, int currentStock) {
    final stockController = TextEditingController(text: currentStock.toString());
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return CustomDialog(
          title: 'Manual Stock Adjustment',
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Adjusting stock levels for:\n$name',
                  style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontSize: 13),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  labelText: 'Stock Level Count',
                  hintText: 'e.g. 50',
                  controller: stockController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Stock level is required';
                    if (int.tryParse(value) == null) return 'Please enter a valid integer';
                    return null;
                  },
                ),
              ],
            ),
          ),
          primaryButtonText: 'Update Stock',
          onPrimaryPressed: () async {
            if (formKey.currentState!.validate()) {
              final newStock = int.parse(stockController.text.trim());
              final provider = Provider.of<ProductProvider>(context, listen: false);
              await provider.updateStock(id, newStock);
              if (context.mounted) {
                Navigator.pop(context);
              }
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    
    // Perform filtering based on selected stock status and search query
    final allProducts = productProvider.allProducts;
    final filtered = allProducts.where((p) {
      final matchesSearch = p.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          p.sku.toLowerCase().contains(_searchController.text.toLowerCase());
      
      bool matchesStock = true;
      if (_stockFilter == 'Low Stock') {
        matchesStock = p.isLowStock;
      } else if (_stockFilter == 'Out of Stock') {
        matchesStock = p.isOutOfStock;
      } else if (_stockFilter == 'In Stock') {
        matchesStock = !p.isOutOfStock && !p.isLowStock;
      }

      return matchesSearch && matchesStock;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Filtering Header Card
          CustomCard(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: CustomTextField(
                    labelText: 'Search Inventory SKU',
                    hintText: 'Search by product name, barcode SKU...',
                    controller: _searchController,
                    prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textLight),
                    onChanged: (val) {
                      setState(() {}); // Trigger filtering update
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: _stockFilter,
                    decoration: const InputDecoration(labelText: 'Inventory Status Filter'),
                    items: const [
                      DropdownMenuItem(value: 'All', child: Text('All Products')),
                      DropdownMenuItem(value: 'In Stock', child: Text('Adequately Stocked')),
                      DropdownMenuItem(value: 'Low Stock', child: Text('Low Stock Warnings')),
                      DropdownMenuItem(value: 'Out of Stock', child: Text('Out of Stock Alerts')),
                    ],
                    onChanged: (val) {
                      setState(() {
                        _stockFilter = val!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),

          // Main inventory table
          Expanded(
            child: CustomCard(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Stock Audit Controls',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Showing ${filtered.length} entries',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: filtered.isEmpty
                        ? const EmptyState(
                            title: 'No Stock Mappings Found',
                            description: 'No inventory mappings correspond to your active query filter.',
                            icon: Icons.inventory_2_outlined,
                          )
                        : CustomTable(
                            columns: [
                              CustomTableColumn(title: 'SKU Code', width: 150),
                              CustomTableColumn(title: 'Product'),
                              CustomTableColumn(title: 'In Stock', width: 120),
                              CustomTableColumn(title: 'Status Warning', width: 140),
                              CustomTableColumn(title: 'Stock Adjustment', width: 160, alignment: Alignment.center),
                            ],
                            rowCount: filtered.length,
                            cellBuilder: (context, rowIndex, colIndex) {
                              final p = filtered[rowIndex];
                              switch (colIndex) {
                                case 0:
                                  return Text(
                                    p.sku,
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                  );
                                case 1:
                                  return Text(
                                    p.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  );
                                case 2:
                                  return Text(
                                    '${p.stock} units',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: p.isOutOfStock
                                          ? AppColors.error
                                          : (p.isLowStock ? AppColors.warning : AppColors.success),
                                    ),
                                  );
                                case 3:
                                  String warning = 'Adequate';
                                  if (p.isOutOfStock) warning = 'out of stock';
                                  if (p.isLowStock) warning = 'low stock';
                                  return StatusBadge(status: warning);
                                case 4:
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Decrement Button
                                      IconButton(
                                        icon: const Icon(Icons.remove_circle_outline, color: AppColors.textSecondary, size: 20),
                                        onPressed: () {
                                          if (p.stock > 0) {
                                            productProvider.updateStock(p.id, p.stock - 1);
                                          }
                                        },
                                      ),
                                      // Text field style click trigger
                                      InkWell(
                                        onTap: () => _showAdjustStockDialog(p.id, p.name, p.stock),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: AppColors.background,
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(color: AppColors.border),
                                          ),
                                          child: Text(
                                            p.stock.toString(),
                                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                      // Increment Button
                                      IconButton(
                                        icon: const Icon(Icons.add_circle_outline, color: AppColors.primary, size: 20),
                                        onPressed: () {
                                          productProvider.updateStock(p.id, p.stock + 1);
                                        },
                                      ),
                                    ],
                                  );
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
