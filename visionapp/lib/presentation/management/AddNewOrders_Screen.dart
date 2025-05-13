import 'package:flutter/material.dart';
import 'package:visionapp/domain/entities/Orders.dart';

class AddNewOrderScreen extends StatefulWidget {
  const AddNewOrderScreen({Key? key}) : super(key: key);

  @override
  State<AddNewOrderScreen> createState() => _AddNewOrderScreenState();
}

class _AddNewOrderScreenState extends State<AddNewOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form fields
  String _client = '';
  String _product = '';
  int _quantity = 0;
  DateTime? _dueDate;
  OrderPriority _priority = OrderPriority.standard;

  // Mock product list
  final List<String> _products = ['Product X', 'Product Y', 'Product Z'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Order'),
        backgroundColor: const Color(0xFF6E00FF), // Purple color from image
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Client field
              const Text(
                'Client',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Enter client name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 16.0,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter client name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _client = value ?? '';
                },
              ),
              
              const SizedBox(height: 24),
              
              // Product dropdown
              const Text(
                'Product',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                ),
                hint: const Text('Select Product'),
                items: _products.map((String product) {
                  return DropdownMenuItem(
                    value: product,
                    child: Text(product),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a product';
                  }
                  return null;
                },
                onChanged: (String? newValue) {
                  setState(() {
                    _product = newValue ?? '';
                  });
                },
              ),
              
              const SizedBox(height: 24),
              
              // Quantity field
              const Text(
                'Quantity',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Enter quantity',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 16.0,
                  ),
                  suffixIcon: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          // Increment logic would go here
                        },
                        child: const Icon(Icons.arrow_drop_up),
                      ),
                      InkWell(
                        onTap: () {
                          // Decrement logic would go here
                        },
                        child: const Icon(Icons.arrow_drop_down),
                      ),
                    ],
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter quantity';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                onSaved: (value) {
                  _quantity = int.tryParse(value ?? '0') ?? 0;
                },
              ),
              
              const SizedBox(height: 24),
              
              // Due Date field
              const Text(
                'Due Date',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'dd / mm / yyyy',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 16.0,
                  ),
                  suffixIcon: const Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null && picked != _dueDate) {
                    setState(() {
                      _dueDate = picked;
                    });
                  }
                },
                validator: (value) {
                  if (_dueDate == null) {
                    return 'Please select a due date';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
              
              // Priority selection
              const Text(
                'Priority',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<OrderPriority>(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                ),
                value: _priority,
                items: OrderPriority.values.map((OrderPriority priority) {
                  return DropdownMenuItem<OrderPriority>(
                    value: priority,
                    child: Text(priority.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (OrderPriority? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _priority = newValue;
                    });
                  }
                },
              ),
              
              const SizedBox(height: 16),
              
              // Priority buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildPriorityButton(OrderPriority.standard, Colors.green[100]!, Colors.green),
                  _buildPriorityButton(OrderPriority.high, Colors.amber[100]!, Colors.amber),
                  _buildPriorityButton(OrderPriority.urgent, Colors.red[100]!, Colors.red),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Submit button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6E00FF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text(
                    'Save Order',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityButton(OrderPriority priority, Color backgroundColor, Color borderColor) {
    final bool isSelected = _priority == priority;
    final String label = priority.toString().split('.').last;
    
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _priority = priority;
          });
        },
        child: Container(
          height: 48,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? borderColor : backgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: borderColor,
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : borderColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _saveOrder() {
  if (_formKey.currentState!.validate()) {
    _formKey.currentState!.save();

    final newOrder = Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      client: _client,
      product: _product,
      quantity: _quantity,
      dueDate: _dueDate!,
      status: OrderStatus.queued,
      priority: _priority,
    );

    // Save order to repository
    Navigator.of(context).pop(newOrder);
  }
}
}