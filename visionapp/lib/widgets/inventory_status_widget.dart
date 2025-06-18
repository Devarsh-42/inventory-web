import 'package:flutter/material.dart';
import '../models/inventory.dart';

class InventoryStatusWidget extends StatelessWidget {
  final Inventory inventory;
  
  // Purple theme color
  static const Color primaryPurple = Color(0xFF9349FC);

  const InventoryStatusWidget({
    Key? key,
    required this.inventory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      width: 300,
      child: Card(
        margin: const EdgeInsets.all(4),
        child: Padding(
          padding: const EdgeInsets.all(8.0), // Reduced padding
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product name - Flexible height
              Flexible(
                flex: 1,
                child: Text(
                  inventory.productName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 13, // Slightly smaller
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 4),
              
              // Status indicator - Flexible
              Flexible(
                flex: 1,
                child: _buildStatusIndicator(),
              ),
              const SizedBox(height: 4),
              
              // Quantity info - Takes remaining space but is flexible
              Flexible(
                flex: 3,
                child: _buildQuantityInfo(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min, // Don't take full width if not needed
      children: [
        _getStatusIcon(),
        const SizedBox(width: 6),
        Flexible( // Changed from Expanded to Flexible
          child: Text(
            _getStatusText(),
            style: const TextStyle(fontSize: 11),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  Widget _getStatusIcon() {
    final color = _getStatusColor();
    return Icon(
      Icons.circle,
      size: 10, // Slightly smaller
      color: color,
    );
  }

  Color _getStatusColor() {
    switch (inventory.status) {
      case InventoryStatus.inStock:
        return primaryPurple;
      case InventoryStatus.lowStock:
        return Colors.orange;
      case InventoryStatus.outOfStock:
        return Colors.red;
    }
  }

  String _getStatusText() {
    switch (inventory.status) {
      case InventoryStatus.inStock:
        return 'In Stock';
      case InventoryStatus.lowStock:
        return 'Low Stock';
      case InventoryStatus.outOfStock:
        return 'Out of Stock';
    }
  }

  Widget _buildQuantityInfo(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Quantity rows - Use Flexible instead of fixed heights
        Flexible(
          child: _buildQuantityRow(
            'Required:',
            inventory.totalRequiredQty.toString(),
            context,
          ),
        ),
        const SizedBox(height: 2),
        Flexible(
          child: _buildQuantityRow(
            'Available:',
            inventory.availableQty.toString(),
            context,
            color: _getAvailableColor(),
          ),
        ),
        const SizedBox(height: 4),
        
        // Progress indicator - Flexible and can shrink
        Flexible(
          flex: 2,
          child: _buildProgressIndicator(),
        ),
      ],
    );
  }

  Widget _buildQuantityRow(
    String label,
    String value,
    BuildContext context, {
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: const TextStyle(fontSize: 10),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 10,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    final percentage = inventory.totalRequiredQty > 0 
        ? inventory.availableQty / inventory.totalRequiredQty 
        : 0.0;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress bar - Flexible
        Flexible(
          child: LinearProgressIndicator(
            value: percentage.clamp(0.0, 1.0),
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor()),
            minHeight: 3, // Thinner progress bar
          ),
        ),
        const SizedBox(height: 2),
        
        // Percentage text - Flexible and can shrink
        Flexible(
          child: Text(
            '${(percentage * 100).toStringAsFixed(1)}% of required',
            style: TextStyle(
              fontSize: 9, // Smaller font
              color: Colors.grey[600],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Color _getAvailableColor() {
    if (inventory.availableQty <= 0) {
      return Colors.red;
    } else if (inventory.availableQty < inventory.totalRequiredQty) {
      return Colors.orange;
    }
    return primaryPurple;
  }
}