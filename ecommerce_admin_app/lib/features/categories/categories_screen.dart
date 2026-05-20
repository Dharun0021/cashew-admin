import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/custom_card.dart';
import '../../core/widgets/custom_dialog.dart';
import '../../core/widgets/empty_state.dart';
import '../../providers/category_provider.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddEditDialog({String? categoryId, String? currentName, String? currentImage}) {
    final nameController = TextEditingController(text: currentName);
    final imageController = TextEditingController(text: currentImage);
    final formKey = GlobalKey<FormState>();
    final isEditing = categoryId != null;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return CustomDialog(
              title: isEditing ? 'Edit Category' : 'Add New Category',
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomTextField(
                      labelText: 'Category Name',
                      hintText: 'e.g. Raw Cashews',
                      controller: nameController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter category name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      labelText: 'Category Image URL',
                      hintText: 'https://images.unsplash.com/...',
                      controller: imageController,
                      keyboardType: TextInputType.url,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please provide an image URL';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Quick pick presets
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Quick Image Presets:',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildPresetChip(
                          'Cashew Preset 1',
                          'https://images.unsplash.com/photo-1508061253366-f7da158b6d46?w=400',
                          imageController,
                          setState,
                        ),
                        const SizedBox(width: 8),
                        _buildPresetChip(
                          'Cashew Preset 2',
                          'https://images.unsplash.com/photo-1596515134807-a36f7bc2f009?w=400',
                          imageController,
                          setState,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              primaryButtonText: isEditing ? 'Save Changes' : 'Create Category',
              onPrimaryPressed: () async {
                if (formKey.currentState!.validate()) {
                  final catProvider = Provider.of<CategoryProvider>(context, listen: false);
                  if (isEditing) {
                    await catProvider.editCategory(
                      categoryId,
                      nameController.text.trim(),
                      imageController.text.trim(),
                    );
                  } else {
                    await catProvider.addCategory(
                      nameController.text.trim(),
                      imageController.text.trim(),
                    );
                  }
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                }
              },
            );
          },
        );
      },
    );
  }

  Widget _buildPresetChip(String label, String url, TextEditingController controller, StateSetter setState) {
    final isSelected = controller.text == url;
    return ChoiceChip(
      label: Text(label, style: TextStyle(fontSize: 11, color: isSelected ? Colors.white : AppColors.textPrimary)),
      selected: isSelected,
      selectedColor: AppColors.primary,
      onSelected: (_) {
        setState(() {
          controller.text = url;
        });
      },
    );
  }

  void _showDeleteConfirmation(String categoryId, String categoryName) {
    showDialog(
      context: context,
      builder: (context) {
        return CustomDialog(
          title: 'Delete Category',
          isDestructive: true,
          content: Text('Are you sure you want to delete category "$categoryName"? All products inside this category will become unassigned.'),
          primaryButtonText: 'Delete',
          onPrimaryPressed: () async {
            final catProvider = Provider.of<CategoryProvider>(context, listen: false);
            await catProvider.deleteCategory(categoryId);
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
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final list = categoryProvider.categories;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Header Search & Add bar
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  labelText: 'Search Categories',
                  hintText: 'Type category name...',
                  controller: _searchController,
                  prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textLight),
                  onChanged: (val) {
                    categoryProvider.setSearchQuery(val);
                  },
                ),
              ),
              const SizedBox(width: 16),
              CustomButton(
                text: 'Add Category',
                icon: Icons.add,
                onPressed: () => _showAddEditDialog(),
              ),
            ],
          ),
          
          const SizedBox(height: 24),

          // Content body
          Expanded(
            child: categoryProvider.isLoading
                ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppColors.primary)))
                : list.isEmpty
                    ? const EmptyState(
                        title: 'No Categories Found',
                        description: 'Try refining your search query or create a new category to get started.',
                        icon: Icons.grid_off_outlined,
                      )
                    : GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: MediaQuery.of(context).size.width > 1200
                              ? 4
                              : (MediaQuery.of(context).size.width > 800 ? 3 : 2),
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.25,
                        ),
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          final category = list[index];
                          return CustomCard(
                            padding: EdgeInsets.zero,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Category Image Banner
                                Expanded(
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(15),
                                          topRight: Radius.circular(15),
                                        ),
                                        child: Image.network(
                                          category.image,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, _, __) => Container(
                                            color: AppColors.background,
                                            child: const Icon(Icons.image, color: AppColors.textLight, size: 36),
                                          ),
                                        ),
                                      ),
                                      // Action triggers
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(0.4),
                                            shape: BoxShape.circle,
                                          ),
                                          child: PopupMenuButton<String>(
                                            icon: const Icon(Icons.more_vert, color: Colors.white, size: 18),
                                            onSelected: (value) {
                                              if (value == 'edit') {
                                                _showAddEditDialog(
                                                  categoryId: category.id,
                                                  currentName: category.name,
                                                  currentImage: category.image,
                                                );
                                              } else if (value == 'delete') {
                                                _showDeleteConfirmation(category.id, category.name);
                                              }
                                            },
                                            itemBuilder: (context) => [
                                              PopupMenuItem(
                                                value: 'edit',
                                                child: Row(
                                                  children: const [
                                                    Icon(Icons.edit_outlined, size: 16, color: AppColors.textPrimary),
                                                    SizedBox(width: 8),
                                                    Text('Edit', style: TextStyle(fontSize: 13)),
                                                  ],
                                                ),
                                              ),
                                              PopupMenuItem(
                                                value: 'delete',
                                                child: Row(
                                                  children: const [
                                                    Icon(Icons.delete_outline, size: 16, color: AppColors.error),
                                                    SizedBox(width: 8),
                                                    Text('Delete', style: TextStyle(fontSize: 13, color: AppColors.error)),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Category Info
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        category.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: AppColors.textPrimary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${category.productCount} items cataloged',
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
