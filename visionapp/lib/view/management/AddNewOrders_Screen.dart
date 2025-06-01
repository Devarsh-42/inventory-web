// lib/views/admin/order_placement_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/orders_viewmodel.dart';
import '../../viewmodels/client_viewmodel.dart';
import '../../models/orders.dart'; // This contains the ProductItem class
import '../../models/client.dart';
import '../../models/product.dart';
import '../../view/widgets/custom_button.dart';
import '../../view/widgets/custom_textfield.dart';
import '../../core/constants/app_scrings.dart';

class AddOrderScreen extends StatefulWidget {
  final Order? orderToEdit;

  const AddOrderScreen({Key? key, this.orderToEdit}) : super(key: key);

  @override
  _AddOrderScreenState createState() => _AddOrderScreenState();
}

class _AddOrderScreenState extends State<AddOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _specialInstructionsController = TextEditingController();
  
  // Add controllers for new client form
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  
  Client? _selectedClient;
  DateTime? _selectedDueDate;
  Priority _selectedPriority = Priority.normal;
  List<ProductItem> _orderProducts = []; // Change this line near the top of the class
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ClientViewModel>(context, listen: false).loadClients();
      _initializeForm();
    });
  }

  void _initializeForm() {
    if (widget.orderToEdit != null) {
      final order = widget.orderToEdit!;
      _selectedClient = Client(
        id: order.clientId,
        name: order.clientName,
        email: '',
        phone: '',
        address: '',
      );
      _selectedDueDate = order.dueDate;
      _selectedPriority = order.priority;
      _orderProducts = List.from(order.products);
      _specialInstructionsController.text = order.specialInstructions ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E40AF),
      appBar: _buildAppBar(),
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
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.98),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 25,
                  offset: const Offset(0, 25),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildClientSection(),
                            const SizedBox(height: 24),
                            _buildProductsSection(),
                            const SizedBox(height: 24),
                            _buildOrderDetailsSection(),
                            const SizedBox(height: 24),
                            _buildActionButtons(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        widget.orderToEdit != null ? 'Edit Order' : 'Create New Order',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Text(
      widget.orderToEdit != null ? 'Edit Order #${widget.orderToEdit!.id}' : 'New Order',
      style: const TextStyle(
        color: Color(0xFF1F2937),
        fontSize: 24,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.3,
      ),
    );
  }

  Widget _buildClientSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Client',
          style: TextStyle(
            color: Color(0xFF374151),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Consumer<ClientViewModel>(
          builder: (context, viewModel, _) => Container(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFD1D5DB)),
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            child: DropdownButtonFormField<Client>(
              value: _selectedClient,
              decoration: const InputDecoration(
                hintText: 'Select Client',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              items: viewModel.clients.map((client) {
                return DropdownMenuItem<Client>(
                  value: client,
                  child: Text(client.name),
                );
              }).toList(),
              onChanged: (client) {
                setState(() {
                  _selectedClient = client;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a client';
                }
                return null;
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
        CustomButton(
          text: '+ Add New Client',
          onPressed: _showAddClientDialog,
          backgroundColor: const Color(0xFF6B7280),
          textColor: Colors.white,
        ),
      ],
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
              'Products',
              style: TextStyle(
                color: Color(0xFF374151),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton.icon(
              onPressed: _addProduct,
              icon: const Icon(Icons.add, color: Color(0xFF1E40AF), size: 20),
              label: const Text(
                'Add',
                style: TextStyle(color: Color(0xFF1E40AF)),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_orderProducts.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 12),
                Text(
                  'No products added yet',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Click "Add Product" to get started',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          )
        else
          Column(
            children: _orderProducts.asMap().entries.map((entry) {
              final index = entry.key;
              final product = entry.value;
              return _buildProductItem(product, index);
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildProductItem(ProductItem product, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Quantity: ${product.quantity} units',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _removeProduct(index),
            icon: const Icon(
              Icons.remove_circle_outline,
              color: Color(0xFFEF4444),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Order Details',
          style: TextStyle(
            color: Color(0xFF374151),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Due Date',
                    style: TextStyle(
                      color: Color(0xFF374151),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _selectDueDate,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFD1D5DB)),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                      ),
                      child: Text(
                        _selectedDueDate != null
                            ? '${_selectedDueDate!.day}/${_selectedDueDate!.month}/${_selectedDueDate!.year}'
                            : 'Select due date',
                        style: TextStyle(
                          color: _selectedDueDate != null
                              ? const Color(0xFF111827)
                              : const Color(0xFF9CA3AF),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Priority Level',
                    style: TextStyle(
                      color: Color(0xFF374151),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFD1D5DB)),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                    ),
                    child: DropdownButtonFormField<Priority>(
                      value: _selectedPriority,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      items: Priority.values.map((priority) {
                        return DropdownMenuItem<Priority>(
                          value: priority,
                          child: Text(_getPriorityText(priority)),
                        );
                      }).toList(),
                      onChanged: (priority) {
                        setState(() {
                          _selectedPriority = priority!;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Special Instructions',
              style: TextStyle(
                color: Color(0xFF374151),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _specialInstructionsController,
              label: 'Enter any special instructions or notes...',
              maxLines: 4,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: 'Cancel',
            onPressed: () => Navigator.pop(context),
            backgroundColor: const Color(0xFF6B7280),
            textColor: Colors.white,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: CustomButton(
            text: _isLoading
                ? 'Saving...'
                : (widget.orderToEdit != null ? 'Update Order' : 'Create Order'),
            onPressed: _isLoading ? null : _submitOrder,
            backgroundColor: const Color(0xFF1E40AF),
            textColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Future<void> _showAddClientDialog() async {
    final formKey = GlobalKey<FormState>();
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Client'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    hintText: 'Enter client name',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter client name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter client email',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter client email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    hintText: 'Enter client phone',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter client phone';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address (Optional)',
                    hintText: 'Enter client address',
                  ),
                  maxLines: 2,
                ),
              ],
            ),
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
                  final clientViewModel = Provider.of<ClientViewModel>(context, listen: false);
                  final newClient = Client(
                    id: '', // ID will be generated by Supabase
                    name: _nameController.text.trim(),
                    email: _emailController.text.trim(),
                    phone: _phoneController.text.trim(),
                    address: _addressController.text.trim(),
                  );
                  
                  await clientViewModel.addClient(newClient);
                  
                  // Clear form fields
                  _nameController.clear();
                  _emailController.clear();
                  _phoneController.clear();
                  _addressController.clear();
                  
                  if (mounted) {
                    Navigator.pop(context);
                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Client added successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to add client: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _addProduct() {
    final productNameController = TextEditingController();
    final quantityController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Product'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: productNameController,
                label: 'Product Name',
                placeholder: 'Enter product name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter product name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: quantityController,
                label: 'Quantity',
                placeholder: 'Enter quantity',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter quantity';
                  }
                  final quantity = int.tryParse(value);
                  if (quantity == null || quantity <= 0) {
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
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                try {
                  final product = ProductItem(
                    name: productNameController.text.trim(),
                    quantity: int.parse(quantityController.text.trim()),
                    completed: 0,
                  );

                  setState(() {
                    _orderProducts.add(product);
                  });

                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to add product: ${e.toString()}'),
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

  void _removeProduct(int index) {
    setState(() {
      _orderProducts.removeAt(index);
    });
  }

  void _selectDueDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }

  bool _validateForm() {
    if (!_formKey.currentState!.validate()) {
      return false;
    }

    if (_selectedClient == null) {
      _showError('Please select a client');
      return false;
    }

    if (_orderProducts.isEmpty) {
      _showError('Please add at least one product');
      return false;
    }

    if (_selectedDueDate == null) {
      _showError('Please select a due date');
      return false;
    }

    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _submitOrder() async {
    if (!_validateForm()) return;

    setState(() => _isLoading = true);

    try {
      final order = Order(
        id: widget.orderToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        clientId: _selectedClient!.id,
        clientName: _selectedClient!.name,
        products: _orderProducts,
        dueDate: _selectedDueDate!,
        createdDate: widget.orderToEdit?.createdDate ?? DateTime.now(),
        status: widget.orderToEdit?.status ?? OrderStatus.queued,
        priority: _selectedPriority,
        specialInstructions: _specialInstructionsController.text.isEmpty
            ? null
            : _specialInstructionsController.text,
      );

      final ordersViewModel = Provider.of<OrdersViewModel>(context, listen: false);

      if (widget.orderToEdit != null) {
        await ordersViewModel.updateOrder(order);
        _showSuccess('Order updated successfully');
      } else {
        await ordersViewModel.addOrder(order);
        _showSuccess('Order created successfully');
      }

      Navigator.pop(context);
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  String _getPriorityText(Priority priority) {
    switch (priority) {
      case Priority.urgent:
        return 'Urgent';
      case Priority.normal:
        return 'Normal';
      case Priority.high:
        return 'High';
    }
  }

  @override
  void dispose() {
    _specialInstructionsController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}