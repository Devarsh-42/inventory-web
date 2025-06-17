import 'package:flutter/material.dart';
import '../models/inventory.dart';

class InventoryStatusWidget extends StatelessWidget {
  final Inventory inventory;

  const InventoryStatusWidget({
    Key? key,
    required this.inventory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              inventory.productName,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _buildStatusIndicator(),
            const SizedBox(height: 8),
            _buildQuantityInfo(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator() {
    return Row(
      children: [
        _getStatusIcon(),
        const SizedBox(width: 8),
        Text(_getStatusText()),
      ],
    );
  }

  Widget _getStatusIcon() {
    final color = _getStatusColor();
    return Icon(
      Icons.circle,
      size: 12,
      color: color,
    );
  }

  Color _getStatusColor() {
    switch (inventory.status) {
      case InventoryStatus.inStock:
        return Colors.green;
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildQuantityRow(
          'Required Quantity:',
          inventory.totalRequiredQty.toString(),
          context,
        ),
        const SizedBox(height: 4),
        _buildQuantityRow(
          'Available:',
          inventory.availableQty.toString(),
          context,
          color: _getAvailableColor(),
        ),
        const SizedBox(height: 8),
        _buildProgressIndicator(),
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
        Text(label),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    final percentage = inventory.availableQty / inventory.totalRequiredQty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: percentage.clamp(0.0, 1.0),
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor()),
        ),
        const SizedBox(height: 4),
        Text(
          '${(percentage * 100).toStringAsFixed(1)}% of required quantity',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
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
    return Colors.green;
  }
}