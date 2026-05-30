import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_card.dart';
import '../../core/widgets/custom_table.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/widgets/custom_dialog.dart';
import '../../core/widgets/empty_state.dart';
import '../../providers/product_provider.dart';
import 'product_form_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({Key? key}) : super(key: key);

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  @override
  void initState() {
    super.initState();
    // Load products when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).loadProducts();
    });
  }

  @override
  void dispose() {
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
              
              if (provider.errorMessage.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Product "$name" deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${provider.errorMessage}'),
                    backgroundColor: Colors.red,
                  ),
                );
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
    final products = productProvider.products;

    // Show error message if any
    if (productProvider.errorMessage.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${productProvider.errorMessage}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      });
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Add Product button - Top Right
          Align(
            alignment: Alignment.centerRight,
            child: CustomButton(
              text: 'Add Product',
              icon: Icons.add,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProductFormScreen()),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // Main data table
          Expanded(
            child: productProvider.isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : CustomCard(
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
                                  description: 'No products in catalog. Create a new product to get started.',
                                  icon: Icons.shopping_basket_outlined,
                                )
                              : CustomTable(
                                  columns: [
                                    CustomTableColumn(title: 'Image', width: 60),
                                    CustomTableColumn(title: 'Product Name'),
                                    CustomTableColumn(title: 'Price', width: 100),
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
                                        return Text(
                                          product.name,
                                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        );
                                      case 2:
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
                                      case 3:
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
