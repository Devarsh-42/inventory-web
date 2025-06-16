import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/production.dart';
import '../../viewmodels/production_viewmodel.dart';
import '../../core/utils/responsive_helper.dart';
import '../../pallet.dart';
import 'production_bottom_nav.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Production production;
  final String? orderId;
  
  const ProductDetailsScreen({
    Key? key,
    required this.production,
    this.orderId,
  }) : super(key: key);

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  late Production _production;
  late TextEditingController _completedController;
  late String _status;
  bool get _isReadOnly => ['ready', 'completed', 'shipped'].contains(_status.toLowerCase());

  @override
  void initState() {
    super.initState();
    _production = widget.production;
    _status = _production.status;
    // Set completed quantity equal to target if status is ready/complete/shipped
    final completedQty = _isReadOnly 
        ? _production.targetQuantity 
        : _production.completedQuantity;
    _completedController = TextEditingController(text: completedQty.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Palette.backgroundColor,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _buildContentContainer(
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProductionInfo(),
                        const SizedBox(height: 24),
                        _buildProgressSection(),
                        const SizedBox(height: 24),
                        _buildStatusSection(),
                        const SizedBox(height: 24),
                        _buildActionButtons(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const ProductionBottomNav(currentRoute: '/products'),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Palette.primaryColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Palette.whiteColor,
              size: 20,
            ),
          ),
          Expanded(
            child: Text(
              'Production Details - ${_production.productName}',
              style: TextStyle(
                color: Palette.whiteColor,
                fontSize: ResponsiveHelper.isMobile(context) ? 20 : 28,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildProductionInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.production.productName,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Palette.primaryTextColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Order ID: ${widget.production.orderId ?? 'N/A'}',
          style: const TextStyle(
            color: Palette.secondaryTextColor,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  // Update the _buildProgressSection method
  Widget _buildProgressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Production Progress',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _completedController,
                keyboardType: TextInputType.number,
                enabled: !_isReadOnly, // Disable if order is ready/complete/shipped
                decoration: InputDecoration(
                  labelText: 'Completed Units',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: _isReadOnly,
                  fillColor: _isReadOnly ? const Color(0xFFF1F5F9) : null,
                  suffixIcon: _isReadOnly 
                    ? const Icon(Icons.check_circle, color: Color(0xFF22C55E))
                    : null,
                ),
                onChanged: (value) {
                  if (_isReadOnly) return;
                  final completed = int.tryParse(value) ?? 0;
                  if (completed <= widget.production.targetQuantity) {
                    _updateProgress(completed);
                  }
                },
              ),
            ),
            const SizedBox(width: 16),
            Text(
              'of ${widget.production.targetQuantity}',
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
        if (_isReadOnly) ...[
          const SizedBox(height: 8),
          Text(
            'This production is ${_status.toLowerCase()} and cannot be edited',
            style: TextStyle(
              fontSize: 12,
              color: const Color(0xFF64748B).withOpacity(0.8),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Status',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Palette.primaryTextColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Palette.cardBackground,
            borderRadius: BorderRadius.circular(12),
            boxShadow: Palette.getShadow(),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _status.toUpperCase(),
                style: TextStyle(
                  color: _getStatusColor(),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Icon(
                Icons.check_circle,
                color: _getStatusColor(),
                size: 20,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor() {
    switch (_status) {
      case 'completed':
        return Palette.completedColor;
      case 'in progress':
        return Palette.inProductionColor;
      case 'queued':
        return Palette.queuedColor;
      default:
        return Palette.normalPriorityColor;
    }
  }

  Widget _buildContentContainer(Widget child) {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Palette.cardBackground, // Changed from cardColor to cardBackground
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Palette.shadowColor.withOpacity(0.1), // Changed from Pallete.blackColor
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }

  // Also update the _buildActionButtons method to disable buttons when completed
  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (!_isReadOnly) ...[
          ElevatedButton(
            onPressed: _saveChanges,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E40AF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Save Changes'),
          ),
        ],
      ],
    );
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Delete Production',
            style: TextStyle(
              color: Palette.urgentColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: const Text(
            'Are you sure you want to delete this production record?',
            style: TextStyle(
              color: Palette.primaryTextColor,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Palette.secondaryTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: Palette.buttonGradient,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Perform delete action
                  _deleteProduction();
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  backgroundColor: Colors.transparent,
                ),
                child: const Text(
                  'Delete',
                  style: TextStyle(
                    color: Palette.inverseTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteProduction() async {
    try {
      await Provider.of<ProductionViewModel>(context, listen: false)
          .deleteProduction(widget.production.id);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Production deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back to the previous screen
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting production: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _updateProgress(int completed) async {
    if (completed > widget.production.targetQuantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completed quantity cannot exceed target quantity'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await Provider.of<ProductionViewModel>(context, listen: false)
          .updateProduction(widget.production.id, {
        'completed_quantity': completed,
        'status': completed == widget.production.targetQuantity ? 'completed' : _status,
        'updated_at': DateTime.now().toIso8601String(),
      });
      
      setState(() {
        if (completed == widget.production.targetQuantity) {
          _status = 'completed';
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Progress updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating progress: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _saveChanges() {
    final completed = int.tryParse(_completedController.text) ?? 0;
    if (completed > widget.production.targetQuantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completed quantity cannot exceed target quantity'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Only update status to completed if it was not already
    final newStatus = completed == widget.production.targetQuantity && _status != 'completed' 
        ? 'completed' 
        : _status;

    Provider.of<ProductionViewModel>(context, listen: false)
        .updateProduction(widget.production.id, {
      'completed_quantity': completed,
      'status': newStatus,
      'updated_at': DateTime.now().toIso8601String(),
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Changes saved successfully'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {
        _status = newStatus;
      });
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving changes: $error'),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  @override
  void dispose() {
    _completedController.dispose();
    super.dispose();
  }
}