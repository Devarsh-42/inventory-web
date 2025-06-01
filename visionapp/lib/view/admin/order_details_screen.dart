import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_scrings.dart';
import '../../viewmodels/orders_viewmodel.dart';
import '../../models/orders.dart';
import '../../view/widgets/custom_button.dart';
import '../../view/widgets/custom_textfield.dart';
import '../widgets/number_picker_dialog.dart';

class OrderDetailsScreen extends StatefulWidget {
  final Order order;

  const OrderDetailsScreen({Key? key, required this.order}) : super(key: key);

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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
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
                      'Order Details #${widget.order.id}',
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
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFf8fafc),
        border: Border.all(color: Color(0xFFe2e8f0)),
        borderRadius: BorderRadius.circular(12),
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
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1e293b),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Created: ${_formatDate(widget.order.createdDate)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748b),
                      ),
                    ),
                    Text(
                      'Due: ${_formatDate(widget.order.dueDate)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748b),
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.order.priority == Priority.high)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFef4444), Color(0xFFdc2626)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
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
          
          SizedBox(height: 12),
          
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: _getStatusGradient(widget.order.status),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _getStatusText(widget.order.status),
              style: TextStyle(
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
        Text(
          'Products Ordered',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        SizedBox(height: 12),
        
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
    return Container(
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Color(0xFFf1f5f9), width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.name,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF1e293b),
              fontSize: 14,
            ),
          ),
          SizedBox(height: 4),
          Text(
            '${product.quantity} units • Progress: ${product.completed}/${product.quantity}',
            style: TextStyle(
              color: Color(0xFF64748b),
              fontSize: 12,
            ),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Text('Completed: '),
              SizedBox(width: 8),
              InkWell(
                onTap: () async {
                  final result = await showDialog<int>(
                    context: context,
                    builder: (context) => NumberPickerDialog(
                      minValue: 0,
                      maxValue: product.quantity,
                      initialValue: product.completed,
                    ),
                  );
                  if (result != null) {
                    await _updateProductCompletion(product, result);
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFF667eea)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('${product.completed}/${product.quantity}'),
                ),
              ),
            ],
          ),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Color(0xFFf1f5f9),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              widthFactor: product.progress,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
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
        return LinearGradient(colors: [Color(0xFF10b981), Color(0xFF059669)]);
      case OrderStatus.queued:
        return LinearGradient(colors: [Color(0xFF3b82f6), Color(0xFF2563eb)]);
      case OrderStatus.completed:
        return LinearGradient(colors: [Color(0xFF6b7280), Color(0xFF4b5563)]);
      case OrderStatus.paused:
        return LinearGradient(colors: [Color(0xFFf59e0b), Color(0xFFd97706)]);
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
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
  }

  void _saveChanges() {
    final ordersVM = Provider.of<OrdersViewModel>(context, listen: false);
    ordersVM.updateOrderStatus(widget.order.id, _selectedStatus);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Changes saved successfully!'),
        backgroundColor: Color(0xFF10b981),
      ),
    );
  }

  void _markAsCompleted() {
    final ordersVM = Provider.of<OrdersViewModel>(context, listen: false);
    ordersVM.updateOrderStatus(widget.order.id, OrderStatus.completed);
    
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Order marked as completed!'),
        backgroundColor: Color(0xFF10b981),
      ),
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
}