import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/custom_card.dart';
import '../../core/widgets/custom_table.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/widgets/custom_dialog.dart';
import '../../core/widgets/empty_state.dart';
import '../../providers/product_provider.dart';
import '../../providers/category_provider.dart';
import 'product_form_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({Key? key}) : super(key: key);

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showDeleteDialog(String id, String name) {
    showDialog(
      context: context,
      builder: (context) {
        return CustomDialog(
          title: 'Delete Product',
          isDestructive: true,
          content: Text('Are you sure you want to delete "$name" from the cashew catalog? This action is permanent.'),
          primaryButtonText: 'Delete Product',
          onPrimaryPressed: () async {
            final provider = Provider.of<ProductProvider>(context, listen: false);
            await provider.deleteProduct(id);
            if (context.mounted) {
              Navigator.pop(context);
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);
    
    final products = productProvider.products;
    final categories = ['All', ...categoryProvider.categories.map((c) => c.name)];

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Filter Bar Card
          CustomCard(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Search Input
                Expanded(
                  flex: 3,
                  child: CustomTextField(
                    labelText: 'Search Products',
                    hintText: 'Search by name, SKU...',
                    controller: _searchController,
                    prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textLight),
                    onChanged: (val) {
                      productProvider.setSearchQuery(val);
                    },
                  ),
                ),
                const SizedBox(width: 16),

                // Category Filter
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: productProvider.selectedCategoryFilter,
                    decoration: const InputDecoration(labelText: 'Category Filter'),
                    items: categories.map((cat) {
                      return DropdownMenuItem(value: cat, child: Text(cat));
                    }).toList(),
                    onChanged: (val) {
                      productProvider.setCategoryFilter(val!);
                    },
                  ),
                ),
                const SizedBox(width: 16),

                // Status Filter
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: productProvider.selectedStatusFilter,
                    decoration: const InputDecoration(labelText: 'Listing Status'),
                    items: const [
                      DropdownMenuItem(value: 'All', child: Text('All Statuses')),
                      DropdownMenuItem(value: 'Active', child: Text('Active Only')),
                      DropdownMenuItem(value: 'Inactive', child: Text('Inactive Only')),
                      DropdownMenuItem(value: 'Out of Stock', child: Text('Out of Stock Only')),
                    ],
                    onChanged: (val) {
                      productProvider.setStatusFilter(val!);
                    },
                  ),
                ),
                const SizedBox(width: 16),

                // Add button
                CustomButton(
                  text: 'Add Product',
                  icon: Icons.add,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ProductFormScreen()),
                    );
                  },
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
                      'Product Catalog Listings',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: products.isEmpty
                        ? const EmptyState(
                            title: 'No Products Found',
                            description: 'No products matched your search or filters. Create a new product to list it.',
                            icon: Icons.shopping_basket_outlined,
                          )
                        : CustomTable(
                            columns: [
                              CustomTableColumn(title: 'Image', width: 60),
                              CustomTableColumn(title: 'Product Details'),
                              CustomTableColumn(title: 'SKU', width: 140),
                              CustomTableColumn(title: 'Price', width: 100),
                              CustomTableColumn(title: 'Stock Level', width: 100),
                              CustomTableColumn(title: 'Status', width: 110),
                              CustomTableColumn(title: 'Featured', width: 80, alignment: Alignment.center),
                              CustomTableColumn(title: 'Actions', width: 100, alignment: Alignment.centerRight),
                            ],
                            rowCount: products.length,
                            cellBuilder: (context, rowIndex, colIndex) {
                              final product = products[rowIndex];
                              switch (colIndex) {
                                case 0:
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
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
                                  );
                                case 1:
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        product.name,
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        product.category,
                                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                                      ),
                                    ],
                                  );
                                case 2:
                                  return Text(product.sku);
                                case 3:
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        Formatters.formatCurrency(product.activePrice),
                                        style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                      ),
                                      if (product.hasDiscount)
                                        Text(
                                          Formatters.formatCurrency(product.price),
                                          style: const TextStyle(
                                            color: AppColors.textLight,
                                            fontSize: 10,
                                            decoration: TextDecoration.lineThrough,
                                          ),
                                        ),
                                    ],
                                  );
                                case 4:
                                  return Text(
                                    '${product.stock} units',
                                    style: TextStyle(
                                      color: product.isOutOfStock
                                          ? AppColors.error
                                          : (product.isLowStock ? AppColors.warning : AppColors.textPrimary),
                                      fontWeight: product.isLowStock || product.isOutOfStock
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  );
                                case 5:
                                  return StatusBadge(status: product.status);
                                case 6:
                                  return IconButton(
                                    icon: Icon(
                                      product.isFeatured ? Icons.star : Icons.star_border,
                                      color: product.isFeatured ? Colors.amber : AppColors.textLight,
                                    ),
                                    onPressed: () {
                                      productProvider.toggleFeatured(product.id);
                                    },
                                  );
                                case 7:
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined, color: AppColors.textSecondary, size: 20),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ProductFormScreen(product: product),
                                            ),
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                                        onPressed: () => _showDeleteDialog(product.id, product.name),
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
