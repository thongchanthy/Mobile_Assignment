import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product; // null = Add, non-null = Edit

  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  final ImagePicker _imagePicker = ImagePicker();

  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _barcodeController;
  late TextEditingController _expireDateController;
  late TextEditingController _qtyController;
  late TextEditingController _priceInController;
  late TextEditingController _priceOutController;
  late TextEditingController _imageController;

  int? _selectedCategoryId;
  List<Category> _categories = [];
  bool _isLoadingCategories = true;
  bool _isSubmitting = false;
  bool _showUrlField = false;

  XFile? _selectedImageFile;
  Uint8List? _selectedImageBytes;

  bool get isEdit => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameController = TextEditingController(text: p?.productName ?? '');
    _descController = TextEditingController(text: p?.description ?? '');
    _barcodeController = TextEditingController(text: p?.barcode ?? '');
    _expireDateController = TextEditingController(text: p?.expireDate ?? '');
    _qtyController = TextEditingController(text: p != null ? p.qty.toString() : '0');
    _priceInController = TextEditingController(text: p != null ? p.unitPriceIn.toStringAsFixed(2) : '0.00');
    _priceOutController = TextEditingController(text: p != null ? p.unitPriceOut.toStringAsFixed(2) : '0.00');
    _imageController = TextEditingController(text: p?.productImage ?? '');
    _selectedCategoryId = p?.categoryID;

    if (p?.productImage != null && p!.productImage!.isNotEmpty) {
      _showUrlField = false;
    }

    _loadCategories();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _barcodeController.dispose();
    _expireDateController.dispose();
    _qtyController.dispose();
    _priceInController.dispose();
    _priceOutController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _apiService.getCategories();
      if (mounted) {
        setState(() {
          _categories = categories;
          _isLoadingCategories = false;
          if (_selectedCategoryId == null && _categories.isNotEmpty) {
            _selectedCategoryId = _categories.first.categoryId;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingCategories = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load categories: $e')),
        );
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        imageQuality: 80,
      );

      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _selectedImageFile = picked;
          _selectedImageBytes = bytes;
          _imageController.clear();
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

  String _resolveImageUrl(String rawUrl) {
    return Product(
      productName: '',
      categoryID: 0,
      productImage: rawUrl,
    ).displayImageUrl ?? rawUrl;
  }

  void _showImagePickerSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          child: Wrap(
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.photo_library_outlined, color: Color(0xFF2563EB)),
                ),
                title: const Text('Choose from Gallery', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: const Text('Select a photo from device storage', style: TextStyle(fontSize: 12, color: Colors.grey)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.camera_alt_outlined, color: Color(0xFF2563EB)),
                ),
                title: const Text('Take a Photo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: const Text('Use camera to capture product image', style: TextStyle(fontSize: 12, color: Colors.grey)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickExpireDate() async {
    DateTime initial = DateTime.now().add(const Duration(days: 365));
    if (_expireDateController.text.isNotEmpty) {
      try {
        initial = DateTime.parse(_expireDateController.text);
      } catch (_) {}
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2040),
    );

    if (picked != null) {
      setState(() {
        _expireDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final newProduct = Product(
      productID: widget.product?.productID,
      productName: _nameController.text.trim(),
      description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
      categoryID: _selectedCategoryId!,
      barcode: _barcodeController.text.trim().isEmpty ? null : _barcodeController.text.trim(),
      expireDate: _expireDateController.text.trim().isEmpty ? null : _expireDateController.text.trim(),
      qty: int.tryParse(_qtyController.text.trim()) ?? 0,
      unitPriceIn: double.tryParse(_priceInController.text.trim()) ?? 0.0,
      unitPriceOut: double.tryParse(_priceOutController.text.trim()) ?? 0.0,
      productImage: _imageController.text.trim().isEmpty ? null : _imageController.text.trim(),
      isDeleted: widget.product?.isDeleted ?? 0,
    );

    try {
      if (isEdit) {
        await _apiService.updateProduct(
          widget.product!.productID!,
          newProduct,
          imageFile: _selectedImageFile,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text('Product updated successfully!'),
              backgroundColor: Color(0xFF059669),
            ),
          );
        }
      } else {
        await _apiService.createProduct(
          newProduct,
          imageFile: _selectedImageFile,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text('Product created successfully!'),
              backgroundColor: Color(0xFF059669),
            ),
          );
        }
      }
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: const Color(0xFFEF4444)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasExistingWebImage = _selectedImageBytes == null && _imageController.text.trim().isNotEmpty;
    final hasPickedImage = _selectedImageBytes != null;
    final hasImage = hasPickedImage || hasExistingWebImage;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEdit ? 'Edit Product' : 'Add New Product',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(
              isEdit ? 'Update product info & image' : 'Fill details to add item',
              style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.8)),
            ),
          ],
        ),
      ),
      body: _isLoadingCategories
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)))
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Section 1: General Information
                    _buildSectionCard(
                      icon: Icons.info_outline_rounded,
                      title: 'General Information',
                      children: [
                        _buildFieldLabel('Product Name *'),
                        TextFormField(
                          controller: _nameController,
                          decoration: _inputDecoration(
                            hintText: 'e.g. Coca-Cola 330ml',
                            prefixIcon: Icons.shopping_bag_outlined,
                          ),
                          validator: (val) =>
                              (val == null || val.trim().isEmpty) ? 'Please enter product name' : null,
                        ),
                        const SizedBox(height: 14),

                        _buildFieldLabel('Category *'),
                        DropdownButtonFormField<int>(
                          initialValue: _selectedCategoryId,
                          decoration: _inputDecoration(
                            hintText: 'Select category',
                            prefixIcon: Icons.category_outlined,
                          ),
                          items: _categories.map((c) {
                            return DropdownMenuItem<int>(
                              value: c.categoryId,
                              child: Text(c.categoryName, style: const TextStyle(fontSize: 14)),
                            );
                          }).toList(),
                          onChanged: (val) => setState(() => _selectedCategoryId = val),
                          validator: (val) => val == null ? 'Please select a category' : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Section 2: Pricing & Inventory
                    _buildSectionCard(
                      icon: Icons.monetization_on_outlined,
                      title: 'Pricing & Inventory',
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildFieldLabel('Cost Price (\$) *'),
                                  TextFormField(
                                    controller: _priceInController,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    decoration: _inputDecoration(
                                      hintText: '0.00',
                                      prefixText: '\$ ',
                                      prefixIcon: Icons.arrow_downward_rounded,
                                    ),
                                    validator: (val) =>
                                        (val == null || double.tryParse(val) == null) ? 'Invalid' : null,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildFieldLabel('Selling Price (\$) *'),
                                  TextFormField(
                                    controller: _priceOutController,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    decoration: _inputDecoration(
                                      hintText: '0.00',
                                      prefixText: '\$ ',
                                      prefixIcon: Icons.arrow_upward_rounded,
                                    ),
                                    validator: (val) =>
                                        (val == null || double.tryParse(val) == null) ? 'Invalid' : null,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildFieldLabel('Stock Quantity *'),
                                  TextFormField(
                                    controller: _qtyController,
                                    keyboardType: TextInputType.number,
                                    decoration: _inputDecoration(
                                      hintText: '0',
                                      prefixIcon: Icons.layers_outlined,
                                    ),
                                    validator: (val) =>
                                        (val == null || int.tryParse(val) == null) ? 'Invalid' : null,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildFieldLabel('Barcode'),
                                  TextFormField(
                                    controller: _barcodeController,
                                    decoration: _inputDecoration(
                                      hintText: '885123456789',
                                      prefixIcon: Icons.qr_code_scanner_rounded,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        _buildFieldLabel('Expiration Date'),
                        TextFormField(
                          controller: _expireDateController,
                          readOnly: true,
                          onTap: _pickExpireDate,
                          decoration: _inputDecoration(
                            hintText: 'YYYY-MM-DD',
                            prefixIcon: Icons.calendar_today_outlined,
                            suffixIcon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Section 3: Product Image (Pinterest Style Upload & Preview Box)
                    _buildSectionCard(
                      icon: Icons.image_outlined,
                      title: 'Product Image',
                      children: [
                        // If Image is present, show a polished preview box
                        if (hasImage) ...[
                          Container(
                            height: 150,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Stack(
                              children: [
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: hasPickedImage
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(10),
                                            child: Image.memory(
                                              _selectedImageBytes!,
                                              fit: BoxFit.contain,
                                            ),
                                          )
                                        : ClipRRect(
                                            borderRadius: BorderRadius.circular(10),
                                            child: Image.network(
                                              _resolveImageUrl(_imageController.text.trim()),
                                              fit: BoxFit.contain,
                                              errorBuilder: (context, error, stackTrace) => const Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.broken_image_outlined, color: Colors.grey, size: 36),
                                                  SizedBox(height: 6),
                                                  Text('Could not load image', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                                ],
                                              ),
                                            ),
                                          ),
                                  ),
                                ),
                                // Badge indicating source
                                Positioned(
                                  top: 8,
                                  left: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: hasPickedImage ? const Color(0xFF10B981) : const Color(0xFF2563EB),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      hasPickedImage ? 'New Device Image' : 'Current Image',
                                      style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Action Buttons: Change & Remove
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    foregroundColor: const Color(0xFF2563EB),
                                    side: const BorderSide(color: Color(0xFFBFDBFE)),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  icon: const Icon(Icons.sync_rounded, size: 18),
                                  label: const Text('Change Photo', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                                  onPressed: _showImagePickerSheet,
                                ),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                  foregroundColor: const Color(0xFFEF4444),
                                  side: const BorderSide(color: Color(0xFFFCA5A5)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                                label: const Text('Remove', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                                onPressed: () {
                                  setState(() {
                                    _selectedImageFile = null;
                                    _selectedImageBytes = null;
                                    _imageController.clear();
                                  });
                                },
                              ),
                            ],
                          ),
                        ] else ...[
                          // Clean Upload Dropzone when no image is selected
                          InkWell(
                            onTap: _showImagePickerSheet,
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0xFFCBD5E1),
                                  style: BorderStyle.solid,
                                  width: 1.2,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEFF6FF),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.cloud_upload_outlined, size: 30, color: Color(0xFF2563EB)),
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    'Upload Product Photo',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Color(0xFF1E293B)),
                                  ),
                                  const SizedBox(height: 3),
                                  const Text(
                                    'Take a photo or choose from gallery',
                                    style: TextStyle(color: Color(0xFF64748B), fontSize: 11.5),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _buildMiniActionButton(
                                        icon: Icons.camera_alt_outlined,
                                        label: 'Camera',
                                        onTap: () => _pickImage(ImageSource.camera),
                                      ),
                                      const SizedBox(width: 8),
                                      _buildMiniActionButton(
                                        icon: Icons.photo_library_outlined,
                                        label: 'Gallery',
                                        onTap: () => _pickImage(ImageSource.gallery),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 10),

                        // Secondary Option: Web Image URL (Toggleable)
                        Center(
                          child: TextButton.icon(
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF64748B),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            ),
                            icon: Icon(
                              _showUrlField ? Icons.keyboard_arrow_up_rounded : Icons.link_rounded,
                              size: 16,
                            ),
                            label: Text(
                              _showUrlField ? 'Hide Web URL Input' : 'Or paste an Image Web URL',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                            onPressed: () => setState(() => _showUrlField = !_showUrlField),
                          ),
                        ),

                        if (_showUrlField) ...[
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _imageController,
                            decoration: _inputDecoration(
                              hintText: 'https://example.com/image.jpg',
                              prefixIcon: Icons.link_rounded,
                              suffixIcon: _imageController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, size: 16),
                                      onPressed: () => setState(() => _imageController.clear()),
                                    )
                                  : null,
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Section 4: Description (Optional)
                    _buildSectionCard(
                      icon: Icons.notes_rounded,
                      title: 'Description (Optional)',
                      children: [
                        _buildFieldLabel('Notes / Details'),
                        TextFormField(
                          controller: _descController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Enter product details, ingredients, or notes...',
                            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            contentPadding: const EdgeInsets.all(12),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Save Button (Pinterest Styled Elevated Gradient Pill)
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2563EB).withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: _isSubmitting ? null : _submitForm,
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    isEdit ? 'Update Product' : 'Create Product',
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildFieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: Color(0xFF334155),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    IconData? prefixIcon,
    String? prefixText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      isDense: true,
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
      prefixText: prefixText,
      prefixStyle: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 18, color: const Color(0xFF64748B)) : null,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEF4444)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
      ),
    );
  }

  Widget _buildMiniActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: const Color(0xFF2563EB)),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: const Color(0xFF2563EB)),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const Divider(height: 20, color: Color(0xFFF1F5F9)),
          ...children,
        ],
      ),
    );
  }
}
