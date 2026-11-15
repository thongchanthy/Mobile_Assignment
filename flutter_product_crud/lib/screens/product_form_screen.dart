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
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Wrap(
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.photo_library_outlined, color: Color(0xFF2563EB)),
                ),
                title: const Text('Choose from Gallery', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.camera_alt_outlined, color: Color(0xFF2563EB)),
                ),
                title: const Text('Take a Photo', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
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
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          isEdit ? 'Edit Product' : 'Add New Product',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
        ),
      ),
      body: _isLoadingCategories
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Section 1: General Info Card
                    _buildFormCard(
                      title: 'General Information',
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Product Name *',
                            hintText: 'e.g. iPhone 15 Pro Max',
                          ),
                          validator: (val) =>
                              (val == null || val.trim().isEmpty) ? 'Please enter product name' : null,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<int>(
                          initialValue: _selectedCategoryId,
                          decoration: const InputDecoration(labelText: 'Category *'),
                          items: _categories.map((c) {
                            return DropdownMenuItem<int>(
                              value: c.categoryId,
                              child: Text(c.categoryName),
                            );
                          }).toList(),
                          onChanged: (val) => setState(() => _selectedCategoryId = val),
                          validator: (val) => val == null ? 'Please select a category' : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Section 2: Pricing & Stock Card
                    _buildFormCard(
                      title: 'Pricing & Inventory',
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _priceInController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(
                                  labelText: 'Cost Price (\$) *',
                                  prefixText: '\$ ',
                                ),
                                validator: (val) =>
                                    (val == null || double.tryParse(val) == null) ? 'Invalid' : null,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: _priceOutController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(
                                  labelText: 'Selling Price (\$) *',
                                  prefixText: '\$ ',
                                ),
                                validator: (val) =>
                                    (val == null || double.tryParse(val) == null) ? 'Invalid' : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _qtyController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(labelText: 'Stock Qty *'),
                                validator: (val) =>
                                    (val == null || int.tryParse(val) == null) ? 'Invalid' : null,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: _barcodeController,
                                decoration: const InputDecoration(
                                  labelText: 'Barcode',
                                  hintText: 'e.g. 885123456789',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _expireDateController,
                          readOnly: true,
                          onTap: _pickExpireDate,
                          decoration: const InputDecoration(
                            labelText: 'Expiration Date (YYYY-MM-DD)',
                            suffixIcon: Icon(Icons.calendar_today_outlined, size: 20),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Section 3: Product Image Card
                    _buildFormCard(
                      title: 'Product Image',
                      children: [
                        // Upload / Browse Action
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  foregroundColor: const Color(0xFF2563EB),
                                  side: const BorderSide(color: Color(0xFFBFDBFE)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                icon: const Icon(Icons.add_photo_alternate_outlined, size: 20),
                                label: const Text('Pick Image from Device', style: TextStyle(fontWeight: FontWeight.w600)),
                                onPressed: _showImagePickerSheet,
                              ),
                            ),
                          ],
                        ),

                        // Image Preview if picked
                        if (_selectedImageBytes != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.memory(
                                    _selectedImageBytes!,
                                    height: 60,
                                    width: 60,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Local image selected', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                      Text('Will be uploaded to server', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close_rounded, color: Color(0xFFEF4444)),
                                  onPressed: () => setState(() {
                                    _selectedImageFile = null;
                                    _selectedImageBytes = null;
                                  }),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 12),
                        const Row(
                          children: [
                            Expanded(child: Divider(color: Color(0xFFF1F5F9))),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text('OR USE IMAGE URL', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.bold)),
                            ),
                            Expanded(child: Divider(color: Color(0xFFF1F5F9))),
                          ],
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                          controller: _imageController,
                          decoration: InputDecoration(
                            labelText: 'Image Web URL',
                            hintText: 'https://...',
                            suffixIcon: _imageController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 18),
                                    onPressed: () => setState(() => _imageController.clear()),
                                  )
                                : null,
                          ),
                          onChanged: (_) => setState(() {}),
                        ),

                        if (_selectedImageBytes == null && _imageController.text.trim().isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                _resolveImageUrl(_imageController.text.trim()),
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => const Text(
                                  'Unable to load preview',
                                  style: TextStyle(color: Colors.red, fontSize: 12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Section 4: Description Card
                    _buildFormCard(
                      title: 'Description (Optional)',
                      children: [
                        TextFormField(
                          controller: _descController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            hintText: 'Enter brief product description or notes...',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Submit Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        elevation: 1,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _isSubmitting ? null : _submitForm,
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Text(
                              isEdit ? 'Update Product' : 'Create Product',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildFormCard({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}
