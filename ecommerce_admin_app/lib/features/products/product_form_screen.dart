import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
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
  final ImagePicker _imagePicker = ImagePicker();
  
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _discountPriceController;
  late TextEditingController _descriptionController;
  late TextEditingController _kgController;

  String? _selectedCategoryName;
  String? _selectedCategoryId;
  String _selectedStatus = 'Active';
  bool _isFeatured = false;
  bool _inStock = true;
  File? _selectedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameController = TextEditingController(text: p?.name ?? '');
    _priceController = TextEditingController(text: p?.price.toString() ?? '');
    _discountPriceController = TextEditingController(text: p?.discountPrice?.toString() ?? '');
    _descriptionController = TextEditingController(text: p?.description ?? '');
    _kgController = TextEditingController(text: p?.kg.toString() ?? '');
    _inStock = (p?.stock ?? 0) > 0;
    
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
    _priceController.dispose();
    _discountPriceController.dispose();
    _descriptionController.dispose();
    _kgController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategoryId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a product category')),
        );
        return;
      }

      if (widget.product == null && _selectedImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a product image')),
        );
        return;
      }

      final double price = double.parse(_priceController.text.trim());
      final double? discountPrice = _discountPriceController.text.trim().isNotEmpty
          ? double.parse(_discountPriceController.text.trim())
          : null;
      final double kg = _kgController.text.trim().isNotEmpty
          ? double.parse(_kgController.text.trim())
          : 0.0;
      final int stock = _inStock ? 100 : 0;

      final productProvider = Provider.of<ProductProvider>(context, listen: false);

      setState(() => _isLoading = true);

      try {
        if (widget.product == null) {
          // Create new product
          await productProvider.addProduct(
            productName: _nameController.text.trim(),
            categoryId: _selectedCategoryId!,
            description: _descriptionController.text.trim(),
            amount: price,
            discountAmount: discountPrice ?? 0.0,
            inStock: _inStock,
            imageFile: _selectedImage!,
            kg: kg,
          );
        } else {
          // Update existing product
          await productProvider.editProduct(
            id: widget.product!.id,
            productName: _nameController.text.trim(),
            categoryId: _selectedCategoryId!,
            description: _descriptionController.text.trim(),
            amount: price,
            discountAmount: discountPrice ?? 0.0,
            inStock: _inStock,
            imageFile: _selectedImage,
            kg: kg,
          );
        }

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.product == null ? 'Product created successfully!' : 'Product updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${productProvider.errorMessage}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
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
            constraints: const BoxConstraints(maxWidth: 600),
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
                        
                        // Product Name - Vertical Layout
                        CustomTextField(
                          labelText: 'Product Name',
                          hintText: 'e.g. Honey Sea Salt Cashews',
                          controller: _nameController,
                          validator: (value) => value!.isEmpty ? 'Product name is required' : null,
                        ),
                        const SizedBox(height: 16),
                        // Standard Price - Vertical Layout
                        CustomTextField(
                          labelText: 'Standard Price (\$)',
                          hintText: 'e.g. 14.99',
                          controller: _priceController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (value) {
                            if (value!.isEmpty) return 'Price is required';
                            if (double.tryParse(value) == null) return 'Enter a valid number';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Discount Price - Vertical Layout
                        CustomTextField(
                          labelText: 'Discount Price (\$)',
                          hintText: 'e.g. 12.49 (optional)',
                          controller: _discountPriceController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (value) {
                            if (value!.isNotEmpty && double.tryParse(value) == null) {
                              return 'Enter a valid number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Kg Weight - Vertical Layout
                        CustomTextField(
                          labelText: 'Weight (Kg)',
                          hintText: 'e.g. 0.5',
                          controller: _kgController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (value) {
                            if (value!.isNotEmpty && double.tryParse(value) == null) {
                              return 'Enter a valid number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Stock Toggle Switch - Replace manual entry
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text(
                            'In Stock',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                          ),
                          subtitle: const Text(
                            'Toggle to mark product as available',
                            style: TextStyle(fontSize: 12),
                          ),
                          value: _inStock,
                          activeColor: AppColors.primary,
                          onChanged: (val) {
                            setState(() {
                              _inStock = val;
                            });
                          },
                        ),
                        const SizedBox(height: 24),

                        // Category Dropdown - Vertical Layout
                        DropdownButtonFormField<String>(
                          value: _selectedCategoryId,
                          decoration: const InputDecoration(
                            labelText: 'Select Category',
                            hintText: 'Choose a category',
                          ),
                          items: categoryProvider.categories.map<DropdownMenuItem<String>>((cat) {
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
                        const SizedBox(height: 24),

                        // Product Image Upload
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Product Image',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              height: 180,
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.border, width: 2),
                                borderRadius: BorderRadius.circular(8),
                                color: AppColors.background,
                              ),
                              child: _selectedImage != null
                                  ? Stack(
                                      children: [
                                        Image.file(
                                          _selectedImage!,
                                          width: double.infinity,
                                          height: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                        Positioned(
                                          bottom: 8,
                                          right: 8,
                                          child: GestureDetector(
                                            onTap: _pickImage,
                                            child: Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: AppColors.primary,
                                                borderRadius: BorderRadius.circular(50),
                                              ),
                                              child: const Icon(Icons.edit, color: Colors.white, size: 16),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : (widget.product?.image != null && widget.product!.image.isNotEmpty
                                      ? Stack(
                                          children: [
                                            Image.network(
                                              widget.product!.image,
                                              width: double.infinity,
                                              height: double.infinity,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, _, __) => const Center(
                                                child: Icon(Icons.image_not_supported, size: 40, color: AppColors.textLight),
                                              ),
                                            ),
                                            Positioned(
                                              bottom: 8,
                                              right: 8,
                                              child: GestureDetector(
                                                onTap: _pickImage,
                                                child: Container(
                                                  padding: const EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.primary,
                                                    borderRadius: BorderRadius.circular(50),
                                                  ),
                                                  child: const Icon(Icons.edit, color: Colors.white, size: 16),
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      : GestureDetector(
                                          onTap: _pickImage,
                                          child: const Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.cloud_upload_outlined, size: 48, color: AppColors.textLight),
                                              SizedBox(height: 12),
                                              Text(
                                                'Click to upload product image',
                                                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                'or drag and drop',
                                                style: TextStyle(color: AppColors.textLight, fontSize: 12),
                                              ),
                                            ],
                                          ),
                                        )),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Product Description
                        CustomTextField(
                          labelText: 'Product Description',
                          hintText: 'Enter product details, ingredients, specifications...',
                          controller: _descriptionController,
                          maxLines: 4,
                        ),
                        const SizedBox(height: 24),

                        // Featured Switch
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text(
                            'Featured Product',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                          ),
                          subtitle: const Text(
                            'Display on store home banner',
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
                        onPressed: _isLoading ? null : () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 16),
                      CustomButton(
                        text: _isLoading
                            ? (isEditing ? 'Saving...' : 'Publishing...')
                            : (isEditing ? 'Save Changes' : 'Publish Product'),
                        onPressed: _isLoading ? null : _handleSave,
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
