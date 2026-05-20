import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/custom_card.dart';
import '../../models/product_model.dart';
import '../../providers/product_provider.dart';
import '../../providers/category_provider.dart';

class ProductFormScreen extends StatefulWidget {
  final ProductModel? product;

  const ProductFormScreen({Key? key, this.product}) : super(key: key);

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _skuController;
  late TextEditingController _priceController;
  late TextEditingController _discountPriceController;
  late TextEditingController _stockController;
  late TextEditingController _imageController;
  late TextEditingController _descriptionController;

  String? _selectedCategoryName;
  String? _selectedCategoryId;
  String _selectedStatus = 'Active';
  bool _isFeatured = false;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameController = TextEditingController(text: p?.name ?? '');
    _skuController = TextEditingController(text: p?.sku ?? '');
    _priceController = TextEditingController(text: p?.price.toString() ?? '');
    _discountPriceController = TextEditingController(text: p?.discountPrice?.toString() ?? '');
    _stockController = TextEditingController(text: p?.stock.toString() ?? '');
    _imageController = TextEditingController(text: p?.image ?? 'https://images.unsplash.com/photo-1508061253366-f7da158b6d46?w=400');
    _descriptionController = TextEditingController(text: p?.description ?? '');
    
    if (p != null) {
      _selectedCategoryId = p.categoryId;
      _selectedCategoryName = p.category;
      _selectedStatus = p.status;
      _isFeatured = p.isFeatured;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _priceController.dispose();
    _discountPriceController.dispose();
    _stockController.dispose();
    _imageController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategoryId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a product category')),
        );
        return;
      }

      final double price = double.parse(_priceController.text.trim());
      final double? discountPrice = _discountPriceController.text.trim().isNotEmpty
          ? double.parse(_discountPriceController.text.trim())
          : null;
      final int stock = int.parse(_stockController.text.trim());

      final productProvider = Provider.of<ProductProvider>(context, listen: false);

      final productData = ProductModel(
        id: widget.product?.id ?? '',
        name: _nameController.text.trim(),
        sku: _skuController.text.trim(),
        category: _selectedCategoryName!,
        categoryId: _selectedCategoryId!,
        price: price,
        discountPrice: discountPrice,
        stock: stock,
        status: stock <= 0 ? 'Out of Stock' : _selectedStatus,
        isFeatured: _isFeatured,
        image: _imageController.text.trim(),
        description: _descriptionController.text.trim(),
      );

      if (widget.product == null) {
        await productProvider.addProduct(productData);
      } else {
        await productProvider.editProduct(productData);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final isEditing = widget.product != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Modify Product Info' : 'New Product Registration'),
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  CustomCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEditing ? 'Modify Product details' : 'Product Information',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 24),
                        
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: CustomTextField(
                                labelText: 'Product Name',
                                hintText: 'e.g. Honey Sea Salt Cashews',
                                controller: _nameController,
                                validator: (value) => value!.isEmpty ? 'Product name is required' : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 1,
                              child: CustomTextField(
                                labelText: 'SKU Code',
                                hintText: 'CSH-HNY-500',
                                controller: _skuController,
                                validator: (value) => value!.isEmpty ? 'SKU code is required' : null,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Row for price, discount price, and stock levels
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                labelText: 'Standard Price (\$)',
                                hintText: '14.99',
                                controller: _priceController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                validator: (value) {
                                  if (value!.isEmpty) return 'Price required';
                                  if (double.tryParse(value) == null) return 'Invalid number';
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: CustomTextField(
                                labelText: 'Discount Price (\$)',
                                hintText: '12.49',
                                controller: _discountPriceController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                validator: (value) {
                                  if (value!.isNotEmpty && double.tryParse(value) == null) return 'Invalid number';
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: CustomTextField(
                                labelText: 'Initial Stock Count',
                                hintText: '100',
                                controller: _stockController,
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value!.isEmpty) return 'Stock required';
                                  if (int.tryParse(value) == null) return 'Invalid number';
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Dropdown for Category and Status Selectors
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedCategoryId,
                                decoration: const InputDecoration(labelText: 'Select Category'),
                                items: categoryProvider.categories.map((cat) {
                                  return DropdownMenuItem<String>(
                                    value: cat.id,
                                    child: Text(cat.name),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  setState(() {
                                    _selectedCategoryId = val;
                                    _selectedCategoryName = categoryProvider.categories
                                        .firstWhere((cat) => cat.id == val)
                                        .name;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedStatus,
                                decoration: const InputDecoration(labelText: 'Store Status'),
                                items: const [
                                  DropdownMenuItem(value: 'Active', child: Text('Active Listing')),
                                  DropdownMenuItem(value: 'Inactive', child: Text('Inactive (Draft)')),
                                  DropdownMenuItem(value: 'Out of Stock', child: Text('Out of Stock')),
                                ],
                                onChanged: (val) {
                                  setState(() {
                                    _selectedStatus = val!;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Image URL Input
                        CustomTextField(
                          labelText: 'Product Image URL',
                          hintText: 'https://images.unsplash.com/...',
                          controller: _imageController,
                          keyboardType: TextInputType.url,
                          validator: (value) => value!.isEmpty ? 'Product Image URL is required' : null,
                        ),

                        const SizedBox(height: 24),

                        // Product Description
                        CustomTextField(
                          labelText: 'Product Description',
                          hintText: 'Enter specifications, ingredients, nutrition charts...',
                          controller: _descriptionController,
                          maxLines: 4,
                        ),

                        const SizedBox(height: 24),

                        // Featured Switch
                        SwitchListTile(
                          title: const Text(
                            'Featured Product',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                          ),
                          subtitle: const Text(
                            'Pin this product to the store home banner screen.',
                            style: TextStyle(fontSize: 12),
                          ),
                          value: _isFeatured,
                          activeColor: AppColors.primary,
                          onChanged: (val) {
                            setState(() {
                              _isFeatured = val;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Submit buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CustomButton(
                        text: 'Cancel',
                        type: CustomButtonType.outlined,
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 16),
                      CustomButton(
                        text: isEditing ? 'Save Changes' : 'Publish Product',
                        onPressed: _handleSave,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
