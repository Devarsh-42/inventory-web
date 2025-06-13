import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:visionapp/viewmodels/product_viewmodel.dart';
import '../../core/constants/app_scrings.dart';
import '../../viewmodels/orders_viewmodel.dart';
import '../../models/orders.dart';
import '../../view/widgets/custom_button.dart';
import '../../view/widgets/custom_textfield.dart';
import '../widgets/number_picker_dialog.dart';

class OrderDetailsScreen extends StatefulWidget {
  Order order; // Remove final keyword

  OrderDetailsScreen({Key? key, required this.order}) : super(key: key);

  @override
  _OrderDetailsScreenState createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  late OrderStatus _selectedStatus;
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.order.status;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1E3A8A),
              Color(0xFF3B82F6),
              Color(0xFF1E40AF),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    Text(
                      'Order Details #${widget.order.displayId}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Content
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        offset: Offset(0, 10),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Order Header
                        _buildOrderHeader(),
                        
                        SizedBox(height: 24),
                        
                        // Products Section
                        _buildProductsSection(),
                        
                        SizedBox(height: 24),
                        
                        // Status Update Section
                        _buildStatusSection(),
                        
                        SizedBox(height: 20),
                        
                        // Notes Section
                        CustomTextField(
                          label: 'Add Note',
                          placeholder: 'Add production notes or updates',
                          controller: _notesController,
                          maxLines: 3,
                        ),
                        
                        SizedBox(height: 30),
                        
                        // Action Buttons
                        _buildActionButtons(),
                      ],
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.order.clientName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1e293b),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Created: ${_formatDate(widget.order.createdDate)}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748b),
                      ),
                    ),
                    Text(
                      'Due: ${_formatDate(widget.order.dueDate)}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748b),
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.order.priority == Priority.high)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFef4444), Color(0xFFdc2626)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'HIGH',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: _getStatusGradient(widget.order.status),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _getStatusText(widget.order.status),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Products Ordered',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
            TextButton.icon(
              onPressed: _showAddProductDialog,
              icon: const Icon(Icons.add_circle_outline, color: Color(0xFF1E40AF)),
              label: const Text('Add Product'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF1E40AF),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        ...widget.order.products.map((product) => _buildProductItem(product)).toList(),
      ],
    );
  }

  Future<void> _updateProductCompletion(ProductItem product, int newCount) async {
    if (newCount > product.quantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completed count cannot exceed total quantity'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await Provider.of<OrdersViewModel>(context, listen: false)
          .updateProductCompletion(widget.order.id, product.name, newCount);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Progress updated successfully'),
          backgroundColor: Color(0xFF10b981),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating progress: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildProductItem(ProductItem product) {
    final textController = TextEditingController(text: product.completed.toString());
    final progress = product.quantity > 0 ? product.completed / product.quantity : 0.0;
    
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFf1f5f9), width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.name,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF1e293b),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: textController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Completed Units',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  onChanged: (value) async {
                    final newValue = int.tryParse(value) ?? 0;
                    if (newValue <= product.quantity) {
                      await _updateProductCompletion(product, newValue);
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'of ${product.quantity}',
                style: const TextStyle(
                  color: Color(0xFF64748b),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0xFFf1f5f9),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Update Status',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        SizedBox(height: 8),
        DropdownButtonFormField<OrderStatus>(
          value: _selectedStatus,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Color(0xFFe5e7eb), width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Color(0xFFe5e7eb), width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Color(0xFF667eea), width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          items: OrderStatus.values.map((status) {
            return DropdownMenuItem<OrderStatus>(
              value: status,
              child: Text(_getStatusText(status)),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedStatus = value!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        CustomButton(
          text: AppStrings.saveChanges,
          width: double.infinity,
          height: 48,
          onPressed: _saveChanges,
        ),
        SizedBox(height: 12),
        CustomButton(
          text: AppStrings.markAsCompleted,
          width: double.infinity,
          height: 48,
          backgroundColor: Color(0xFF10b981),
          onPressed: _markAsCompleted,
        ),
      ],
    );
  }

  LinearGradient _getStatusGradient(OrderStatus status) {
    switch (status) {
      case OrderStatus.inProduction:
        return const LinearGradient(
          colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)]
        );
      case OrderStatus.queued:
        return const LinearGradient(
          colors: [Color(0xFFEAB308), Color(0xFFFACC15)]
        );
      case OrderStatus.completed:
        return const LinearGradient(
          colors: [Color(0xFF22C55E), Color(0xFF16A34A)]
        );
      case OrderStatus.paused:
        return const LinearGradient(
          colors: [Color(0xFFDC2626), Color(0xFFEF4444)]
        );
      case OrderStatus.ready:
        return const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFF8B5CF6)]
        );
      case OrderStatus.shipped:
        return const LinearGradient(
          colors: [Color(0xFF059669), Color(0xFF10B981)]
        );
    }
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.inProduction:
        return 'In Production';
      case OrderStatus.queued:
        return 'Queued';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.paused:
        return 'Paused';
      case OrderStatus.ready:
        return 'Ready';
      case OrderStatus.shipped:
        return 'Shipped';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
  }

  void _saveChanges() async {
    try {
      final ordersVM = Provider.of<OrdersViewModel>(context, listen: false);
      await ordersVM.updateOrderStatus(widget.order.id, _selectedStatus);
      
      if (mounted) {
        Navigator.pop(context); // Pop back to previous screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Changes saved successfully!'),
            backgroundColor: Color(0xFF10b981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving changes: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

// Update the _markAsCompleted method

void _markAsCompleted() async {
  try {
    final ordersVM = Provider.of<OrdersViewModel>(context, listen: false);
    await ordersVM.updateOrderStatus(widget.order.id, OrderStatus.completed);
    
    if (mounted) {
      // Show completion dialog with delete option
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Order Completed'),
          content: const Text(
            'Order has been marked as completed. Would you like to delete all completed orders?'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Keep Orders'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                try {
                  await ordersVM.deleteCompletedOrders();
                  
                  if (context.mounted) {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Return to previous screen
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Completed orders deleted successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error deleting orders: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Delete Completed Orders'),
            ),
          ],
        ),
      );
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error marking as completed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

  Future<void> _showAddProductDialog() async {
    final nameController = TextEditingController();
    final quantityController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Product'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Consumer<ProductViewModel>(
                builder: (context, productVM, _) {
                  if (productVM.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (productVM.error != null) {
                    return Text('Error: ${productVM.error}');
                  }

                  final productNames = productVM.productNames;

                  return DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Select Product',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      ...productNames.map((name) => DropdownMenuItem(
                        value: name,
                        child: Text(name),
                      )).toList(),
                      const DropdownMenuItem(
                        value: "ADD_NEW",
                        child: Row(
                          children: [
                            Icon(Icons.add_circle_outline, color: Color(0xFF1E40AF)),
                            SizedBox(width: 8),
                            Text('Add New Product'),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (value) async {
                      if (value == "ADD_NEW") {
                        Navigator.pop(context);
                        await _showAddNewProductForm();
                      } else {
                        nameController.text = value!;
                      }
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter quantity';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Please enter a valid quantity';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate() && nameController.text.isNotEmpty) {
                try {
                  final quantity = int.parse(quantityController.text);
                  await Provider.of<OrdersViewModel>(context, listen: false)
                      .updateOrder(widget.order.copyWith(
                    products: [
                      ...widget.order.products,
                      ProductItem(
                        name: nameController.text,
                        quantity: quantity,
                        completed: 0,
                      ),
                    ],
                  ));
                  
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Product added successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to add product: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddNewProductForm() async {
    final nameController = TextEditingController();
    final quantityController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Product'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Product Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter product name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter quantity';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Please enter a valid quantity';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                try {
                  final productVM = Provider.of<ProductViewModel>(context, listen: false);
                  final ordersVM = Provider.of<OrdersViewModel>(context, listen: false);
                  final newProductName = nameController.text.trim();
                  final quantity = int.parse(quantityController.text);
                  
                  // Add product to products list
                  await productVM.addProduct(newProductName, quantity);
                  
                  // Create new product item
                  final newProduct = ProductItem(
                    name: newProductName,
                    quantity: quantity,
                    completed: 0,
                  );
                  
                  // Create updated order with new product
                  final updatedOrder = widget.order.copyWith(
                    products: [
                      ...widget.order.products,
                      newProduct,
                    ],
                  );
                  
                  // Update order in database
                  await ordersVM.updateOrder(updatedOrder);

                  // Update local state and trigger rebuild
                  if (mounted) {
                    setState(() {
                      widget.order = updatedOrder;
                    });
                    
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('New product added successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );

                    // Force refresh of product list
                    await productVM.loadProductNames();
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to add product: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
}