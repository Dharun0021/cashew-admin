import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:ui' as ui;
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/custom_card.dart';
import '../../core/widgets/custom_dialog.dart';
import '../../core/widgets/empty_state.dart';
import '../../providers/category_provider.dart';
import '../../core/services/image_upload_service.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load categories when the screen is initialized
    Future.microtask(() {
      Provider.of<CategoryProvider>(context, listen: false).loadCategories();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showImageSourceBottomSheet(
    BuildContext context,
    Function(File) onImageSelected,
    ImageUploadService imageUploadService,
  ) {
    showModalBottomSheet(
      context: context,
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
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text(
                    'Select Image Source',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.infoBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.photo_library_outlined, color: AppColors.info),
                  ),
                  title: const Text('Choose from Gallery'),
                  subtitle: const Text('Pick an existing photo from storage'),
                  onTap: () async {
                    Navigator.pop(context);
                    try {
                      final image = await imageUploadService.pickImageFromGallery();
                      if (image != null) {
                        onImageSelected(image);
                      }
                    } catch (e) {
                      _showSnackBar('Error opening gallery: $e', Colors.red);
                    }
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.warningBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.camera_alt_outlined, color: AppColors.warning),
                  ),
                  title: const Text('Take Photo with Camera'),
                  subtitle: const Text('Open camera to capture a new photo'),
                  onTap: () async {
                    Navigator.pop(context);
                    try {
                      final image = await imageUploadService.takePhotoWithCamera();
                      if (image != null) {
                        onImageSelected(image);
                      }
                    } catch (e) {
                      _showSnackBar('Error opening camera: $e', Colors.red);
                    }
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSnackBar(String message, Color backgroundColor) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _showAddEditDialog({String? categoryId, String? currentName, String? currentImage}) {
    final nameController = TextEditingController(text: currentName);
    File? selectedImage;
    final formKey = GlobalKey<FormState>();
    final isEditing = categoryId != null;
    final imageUploadService = ImageUploadService();
    bool isDialogLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return CustomDialog(
              title: isEditing ? 'Edit Category' : 'Add New Category',
              isLoading: isDialogLoading,
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Name Field
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
                    const SizedBox(height: 20),

                    const Text(
                      'Category Image',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Image Preview or Upload Section
                    GestureDetector(
                      onTap: isDialogLoading
                          ? null
                          : () {
                              _showImageSourceBottomSheet(
                                context,
                                (File image) {
                                  setState(() {
                                    selectedImage = image;
                                  });
                                },
                                imageUploadService,
                              );
                            },
                      child: Container(
                        width: double.infinity,
                        height: 180,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: selectedImage != null || (currentImage != null && currentImage!.isNotEmpty)
                                ? AppColors.primary.withOpacity(0.5)
                                : AppColors.border,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          color: selectedImage != null || (currentImage != null && currentImage!.isNotEmpty)
                              ? Colors.black.withOpacity(0.01)
                              : AppColors.background,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              if (selectedImage != null)
                                Image.file(
                                  selectedImage!,
                                  fit: BoxFit.cover,
                                )
                              else if (currentImage != null && currentImage!.isNotEmpty)
                                Image.network(
                                  currentImage!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                                )
                              else
                                _buildImagePlaceholder(),
                              
                              // Tap overlay instructions
                              if (selectedImage != null || (currentImage != null && currentImage!.isNotEmpty))
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    color: Colors.black.withOpacity(0.5),
                                    child: const Text(
                                      'Tap to change image',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              
                              // Remove button overlay if local selected image exists
                              if (selectedImage != null)
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Material(
                                    color: Colors.black.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(20),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(20),
                                      onTap: () {
                                        setState(() {
                                          selectedImage = null;
                                        });
                                      },
                                      child: const Padding(
                                        padding: EdgeInsets.all(6.0),
                                        child: Icon(
                                          Icons.close,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    if (selectedImage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8, left: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, size: 14, color: AppColors.success),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'Selected: ${imageUploadService.getImageFileName(selectedImage!)}',
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              primaryButtonText: isEditing ? 'Save Changes' : 'Create Category',
              onPrimaryPressed: isDialogLoading
                  ? null
                  : () async {
                      if (formKey.currentState!.validate()) {
                        if (selectedImage == null && !isEditing) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please select an image'),
                              backgroundColor: Colors.orange,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }

                        setState(() {
                          isDialogLoading = true;
                        });

                        final catProvider = Provider.of<CategoryProvider>(context, listen: false);
                        
                        try {
                          if (isEditing) {
                            // Edit category (with optional new image file)
                            await catProvider.editCategory(
                              categoryId!,
                              nameController.text.trim(),
                              imageFile: selectedImage,
                            );
                          } else {
                            // Create category (requires image file)
                            await catProvider.addCategoryWithImage(
                              nameController.text.trim(),
                              selectedImage!,
                            );
                          }

                          if (context.mounted) {
                            setState(() {
                              isDialogLoading = false;
                            });
                            if (catProvider.errorMessage.isEmpty) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(isEditing ? 'Category updated successfully' : 'Category added successfully'),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: ${catProvider.errorMessage}'),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          }
                        } catch (e) {
                          if (context.mounted) {
                            setState(() {
                              isDialogLoading = false;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error: $e'),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        }
                      }
                    },
            );
          },
        );
      },
    );
  }

  Widget _buildImagePlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.cloud_upload_outlined,
              size: 32,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Upload Category Image',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Tap to browse gallery or take a photo',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
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
              if (catProvider.errorMessage.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${catProvider.errorMessage}'),
                    backgroundColor: Colors.red,
                  ),
                );
              } else {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Category deleted successfully'),
                    backgroundColor: Colors.green,
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
                          childAspectRatio: MediaQuery.of(context).size.width > 600 ? 1.15 : 1.05,
                        ),
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          final category = list[index];
                          return CustomCard(
                            padding: EdgeInsets.zero,
                            enableHoverEffect: true,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Category Image Banner (Full Image Contain View on clean background)
                                Expanded(
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(15),
                                          topRight: Radius.circular(15),
                                        ),
                                        child: Container(
                                          color: AppColors.background,
                                          child: category.image.isEmpty
                                              ? const Icon(
                                                  Icons.image_outlined,
                                                  color: AppColors.textLight,
                                                  size: 36,
                                                )
                                              : Padding(
                                                  padding: const EdgeInsets.all(12.0),
                                                  child: Image.network(
                                                    category.image,
                                                    fit: BoxFit.contain,
                                                    errorBuilder: (context, _, __) => const Icon(
                                                      Icons.image_not_supported_outlined,
                                                      color: AppColors.textLight,
                                                      size: 32,
                                                    ),
                                                  ),
                                                ),
                                        ),
                                      ),
                                      // Action triggers with Glassmorphic design
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: ClipOval(
                                          child: BackdropFilter(
                                            filter: ui.ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                                            child: Container(
                                              width: 32,
                                              height: 32,
                                              decoration: BoxDecoration(
                                                color: Colors.black.withOpacity(0.25),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Theme(
                                                data: Theme.of(context).copyWith(
                                                  cardColor: AppColors.surface,
                                                ),
                                                child: PopupMenuButton<String>(
                                                  icon: const Icon(Icons.more_vert, color: Colors.white, size: 18),
                                                  padding: EdgeInsets.zero,
                                                  tooltip: 'Options',
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
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Subtle Divider
                                Container(
                                  height: 1,
                                  color: AppColors.border.withOpacity(0.5),
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
                                          fontSize: 15,
                                          color: AppColors.textPrimary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
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
