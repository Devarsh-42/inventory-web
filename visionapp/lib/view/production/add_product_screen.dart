// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../viewmodels/production_viewmodel.dart';
// import '../../models/production.dart';
// import 'production_bottom_nav.dart';

// class AddProductScreen extends StatefulWidget {
//   final Production? production; // For editing existing production

//   const AddProductScreen({Key? key, this.production}) : super(key: key);

//   @override
//   State<AddProductScreen> createState() => _AddProductScreenState();
// }

// class _AddProductScreenState extends State<AddProductScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _productNameController = TextEditingController();
//   final _targetQuantityController = TextEditingController();
//   final _completedQuantityController = TextEditingController();
  
//   String _selectedStatus = 'queued';
//   bool _isLoading = false;

//   final List<String> _statusOptions = [
//     'queued',
//     'in progress',
//     'completed',
//     'paused'
//   ];

//   @override
//   void initState() {
//     super.initState();
//     if (widget.production != null) {
//       _populateFields();
//     }
    
//     // Add listener to completed quantity
//     _completedQuantityController.addListener(_checkCompletionStatus);
//   }

//   void _populateFields() {
//     final production = widget.production!;
//     _productNameController.text = production.productName;
//     _targetQuantityController.text = production.targetQuantity.toString();
//     _completedQuantityController.text = production.completedQuantity.toString();
//     _selectedStatus = production.status;
//   }

//   @override
//   void dispose() {
//     _completedQuantityController.removeListener(_checkCompletionStatus);
//     _productNameController.dispose();
//     _targetQuantityController.dispose();
//     _completedQuantityController.dispose();
//     super.dispose();
//   }

//   void _checkCompletionStatus() {
//     if (!mounted) return;
    
//     final completedQty = int.tryParse(_completedQuantityController.text) ?? 0;
//     final targetQty = int.tryParse(_targetQuantityController.text) ?? 0;
    
//     if (completedQty >= targetQty && targetQty > 0) {
//       setState(() {
//         _selectedStatus = 'completed';
//       });
//     }
//   }

//   InputDecoration _buildInputDecoration(String hint) {
//     return InputDecoration(
//       hintText: hint,
//       hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
//       filled: true,
//       fillColor: Colors.white,
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 2),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 2),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
//       ),
//       errorBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
//       ),
//       contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//     );
//   }

//   Widget _buildFormGroup({required String label, required Widget child}) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w600,
//             color: Color(0xFF374151),
//           ),
//         ),
//         const SizedBox(height: 8),
//         child,
//         const SizedBox(height: 16),
//       ],
//     );
//   }

//   Future<void> _saveProduction() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => _isLoading = true);

//     try {
//       // Determine status based on quantities
//       final targetQty = int.parse(_targetQuantityController.text);
//       final completedQty = int.tryParse(_completedQuantityController.text) ?? 0;
//       final status = completedQty >= targetQty ? 'completed' : _selectedStatus;

//       final production = Production(
//         id: widget.production!.id,
//         productName: _productNameController.text,
//         targetQuantity: targetQty,
//         completedQuantity: completedQty,
//         status: status,
//       );

//       if (widget.production != null) {
//         await Provider.of<ProductionViewModel>(context, listen: false)
//             .updateProduction(production.id, production.toJson());
//       } else {
//         await Provider.of<ProductionViewModel>(context, listen: false)
//             .createProduction(production);
//       }

//       if (mounted) {
//         Navigator.pop(context, true);
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error saving production: $e'),
//             backgroundColor: const Color(0xFFEF4444),
//           ),
//         );
//       }
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isEditing = widget.production != null;
    
//     return Scaffold(
//       backgroundColor: const Color(0xFF1E3A8A),
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               Color(0xFF1E3A8A),
//               Color(0xFF3B82F6),
//               Color(0xFF1E40AF),
//             ],
//           ),
//         ),
//         child: SafeArea(
//           child: Column(
//             children: [
//               // Header
//               Container(
//                 padding: const EdgeInsets.all(20),
//                 child: Text(
//                   isEditing ? 'Edit Product' : 'Add New Product',
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 24,
//                     fontWeight: FontWeight.w700,
//                     letterSpacing: -0.5,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//               // Main Content Container
//               Expanded(
//                 child: Container(
//                   margin: const EdgeInsets.symmetric(horizontal: 20),
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.98),
//                     borderRadius: BorderRadius.circular(24),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.15),
//                         blurRadius: 25,
//                         offset: const Offset(0, 25),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     children: [
//                       // Screen Header
//                       Container(
//                         height: 70,
//                         decoration: const BoxDecoration(
//                           gradient: LinearGradient(
//                             colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
//                           ),
//                           borderRadius: BorderRadius.only(
//                             topLeft: Radius.circular(24),
//                             topRight: Radius.circular(24),
//                           ),
//                         ),
//                         child: Row(
//                           children: [
//                             const SizedBox(width: 16),
//                             IconButton(
//                               onPressed: () => Navigator.pop(context),
//                               icon: const Icon(
//                                 Icons.arrow_back,
//                                 color: Colors.white,
//                               ),
//                             ),
//                             const SizedBox(width: 8),
//                             Text(
//                               isEditing ? 'Edit Product' : 'Add Product',
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.w600,
//                                 letterSpacing: -0.3,
//                               ),
//                             ),
//                             const Spacer(),
//                             // Status dots
//                             const Row(
//                               children: [
//                                 CircleAvatar(
//                                   radius: 3,
//                                   backgroundColor: Colors.white38,
//                                 ),
//                                 SizedBox(width: 10),
//                                 CircleAvatar(
//                                   radius: 3,
//                                   backgroundColor: Colors.white38,
//                                 ),
//                                 SizedBox(width: 10),
//                                 CircleAvatar(
//                                   radius: 3,
//                                   backgroundColor: Colors.white38,
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(width: 24),
//                           ],
//                         ),
//                       ),
//                       // Form Content
//                       Expanded(
//                         child: Padding(
//                           padding: const EdgeInsets.all(24),
//                           child: Form(
//                             key: _formKey,
//                             child: Column(
//                               children: [
//                                 Expanded(
//                                   child: SingleChildScrollView(
//                                     child: Column(
//                                       crossAxisAlignment: CrossAxisAlignment.start,
//                                       children: [
//                                         // Product Name
//                                         _buildFormGroup(
//                                           label: 'Product Name',
//                                           child: TextFormField(
//                                             controller: _productNameController,
//                                             decoration: _buildInputDecoration('Enter product name'),
//                                             validator: (value) {
//                                               if (value?.isEmpty ?? true) {
//                                                 return 'Product name is required';
//                                               }
//                                               return null;
//                                             },
//                                           ),
//                                         ),
                                        
//                                         // Target Quantity
//                                         _buildFormGroup(
//                                           label: 'Target Quantity',
//                                           child: TextFormField(
//                                             controller: _targetQuantityController,
//                                             decoration: _buildInputDecoration('Enter target quantity'),
//                                             keyboardType: TextInputType.number,
//                                             validator: (value) {
//                                               if (value?.isEmpty ?? true) {
//                                                 return 'Target quantity is required';
//                                               }
//                                               final quantity = int.tryParse(value!);
//                                               if (quantity == null || quantity <= 0) {
//                                                 return 'Please enter a valid quantity';
//                                               }
//                                               return null;
//                                             },
//                                           ),
//                                         ),
                                        
//                                         // Completed Quantity (only show if editing)
//                                         if (isEditing)
//                                           _buildFormGroup(
//                                             label: 'Completed Quantity',
//                                             child: TextFormField(
//                                               controller: _completedQuantityController,
//                                               decoration: _buildInputDecoration('Enter completed quantity'),
//                                               keyboardType: TextInputType.number,
//                                               enabled: _selectedStatus != 'completed', // Disable if completed
//                                               validator: (value) {
//                                                 if (value?.isEmpty ?? true) {
//                                                   return 'Completed quantity is required';
//                                                 }
//                                                 final quantity = int.tryParse(value!);
//                                                 if (quantity == null || quantity < 0) {
//                                                   return 'Please enter a valid quantity';
//                                                 }
//                                                 final targetQuantity = int.tryParse(_targetQuantityController.text) ?? 0;
//                                                 if (quantity > targetQuantity) {
//                                                   return 'Cannot exceed target quantity';
//                                                 }
//                                                 return null;
//                                               },
//                                             ),
//                                           ),
                                        
//                                         // Status
//                                         _buildFormGroup(
//                                           label: 'Status',
//                                           child: Container(
//                                             padding: const EdgeInsets.symmetric(horizontal: 14),
//                                             decoration: BoxDecoration(
//                                               border: Border.all(color: const Color(0xFFE5E7EB), width: 2),
//                                               borderRadius: BorderRadius.circular(12),
//                                             ),
//                                             child: DropdownButtonFormField<String>(
//                                               value: _selectedStatus,
//                                               onChanged: (value) {
//                                                 if (value != null) {
//                                                   setState(() {
//                                                     _selectedStatus = value;
//                                                   });
//                                                 }
//                                               },
//                                               items: _statusOptions.map((status) {
//                                                 return DropdownMenuItem<String>(
//                                                   value: status,
//                                                   child: Text(
//                                                     status.capitalize(),
//                                                     style: const TextStyle(
//                                                       fontSize: 16,
//                                                       fontWeight: FontWeight.w500,
//                                                       color: Color(0xFF374151),
//                                                     ),
//                                                   ),
//                                                 );
//                                               }).toList(),
//                                               decoration: InputDecoration(
//                                                 hintText: 'Select status',
//                                                 hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
//                                                 border: InputBorder.none,
//                                               ),
//                                               dropdownColor: Colors.white,
//                                               iconEnabledColor: const Color(0xFF3B82F6),
//                                               validator: (value) {
//                                                 if (value == null) {
//                                                   return 'Status is required';
//                                                 }
//                                                 return null;
//                                               },
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                                 // Submit button
//                                 Container(
//                                   width: double.infinity,
//                                   height: 50,
//                                   margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//                                   child: ElevatedButton(
//                                     onPressed: _isLoading ? null : _saveProduction,
//                                     style: ElevatedButton.styleFrom(
//                                       backgroundColor: const Color(0xFF3B82F6),
//                                       foregroundColor: Colors.white,
//                                       shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(12),
//                                       ),
//                                       elevation: 4,
//                                       shadowColor: const Color(0xFF1E40AF).withOpacity(0.2),
//                                     ),
//                                     child: _isLoading
//                                       ? const CircularProgressIndicator(color: Colors.white)
//                                       : Text(
//                                           widget.production != null ? 'Update Production' : 'Create Production',
//                                           style: const TextStyle(
//                                             fontSize: 16,
//                                             fontWeight: FontWeight.w600,
//                                             letterSpacing: -0.2,
//                                           ),
//                                         ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//       bottomNavigationBar: const ProductionBottomNav(currentRoute: '/products'),
//     );
//   }
// }

// extension StringCasingExtension on String {
//   String capitalize() {
//     if (this == null || this.isEmpty) {
//       return '';
//     }

//     return '${this[0].toUpperCase()}${this.substring(1)}';
//   }
// }