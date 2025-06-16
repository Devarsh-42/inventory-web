import 'package:flutter/material.dart';
import 'package:visionapp/core/utils/responsive_helper.dart';
import 'package:visionapp/pallet.dart';
import '../models/inventory.dart';

class InventoryStatusWidget extends StatelessWidget {
  final Map<String, InventoryStatusData> inventory;
  final bool isExpanded;
  
  const InventoryStatusWidget({
    Key? key,
    required this.inventory,
    this.isExpanded = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final isDesktop = ResponsiveHelper.isDesktop(context);
    
    return Container(
      height: isMobile ? 60 : (isTablet ? 70 : 80), // Reduced height significantly
      decoration: BoxDecoration(
        color: Palette.cardBackground,
        borderRadius: BorderRadius.circular(isMobile ? 6 : 8),
        boxShadow: Palette.getShadow(opacity: 0.06),
        border: Border.all(color: Palette.borderColor, width: 0.5),
      ),
      child: Row(
        children: [
          // Header section - compact
          Container(
            width: isMobile ? 120 : (isTablet ? 140 : 160),
            padding: EdgeInsets.all(isMobile ? 6 : 8),
            child: _buildCompactHeader(context, isMobile),
          ),
          
          // Vertical divider
          Container(
            width: 1,
            height: double.infinity,
            color: Palette.dividerColor,
            margin: EdgeInsets.symmetric(vertical: isMobile ? 8 : 10),
          ),
          
          // Inventory list - horizontal scrollable
          Expanded(
            child: inventory.isEmpty
                ? _buildEmptyState(isMobile)
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 6 : 8,
                      vertical: isMobile ? 4 : 6,
                    ),
                    child: Row(
                      children: inventory.entries.map((entry) {
                        final index = inventory.entries.toList().indexOf(entry);
                        return Container(
                          margin: EdgeInsets.only(
                            right: index < inventory.length - 1 ? (isMobile ? 6 : 8) : 0,
                          ),
                          child: _buildHorizontalInventoryItem(
                            entry.key, 
                            entry.value, 
                            isMobile, 
                            isTablet,
                            isDesktop,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactHeader(BuildContext context, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Palette.lightBlue,
                borderRadius: BorderRadius.circular(3),
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                color: Palette.primaryBlue,
                size: isMobile ? 10 : 12,
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                'Inventory',
                style: TextStyle(
                  fontSize: isMobile ? 10 : 11,
                  fontWeight: FontWeight.w600,
                  color: Palette.primaryTextColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          decoration: BoxDecoration(
            color: Palette.normalPriorityColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '${inventory.length} items',
            style: TextStyle(
              fontSize: isMobile ? 8 : 9,
              fontWeight: FontWeight.w500,
              color: Palette.normalPriorityColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(bool isMobile) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_outlined,
            size: isMobile ? 14 : 16,
            color: Palette.tertiaryTextColor,
          ),
          SizedBox(width: isMobile ? 4 : 6),
          Text(
            'No inventory',
            style: TextStyle(
              fontSize: isMobile ? 9 : 10,
              color: Palette.secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalInventoryItem(
    String itemName, 
    InventoryStatusData item, 
    bool isMobile, 
    bool isTablet,
    bool isDesktop,
  ) {
    final totalQuantity = item.totalQuantity;
    final availableQuantity = item.availableQuantity;
    final allocatedQuantity = item.allocatedQuantity;
    
    final stockLevel = totalQuantity > 0 ? availableQuantity / totalQuantity : 0.0;
    final stockColor = _getStockColor(stockLevel);
    final stockStatus = _getStockStatus(stockLevel);
    
    final itemWidth = isMobile ? 140 : (isTablet ? 160 : 180);
    
    return Container(
      width: itemWidth.toDouble(),
      padding: EdgeInsets.all(isMobile ? 4 : 6),
      decoration: BoxDecoration(
        color: Palette.surfaceGray,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Palette.dividerColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Item name and status in one row
          Row(
            children: [
              Expanded(
                child: Text(
                  itemName,
                  style: TextStyle(
                    fontSize: isMobile ? 9 : 10,
                    fontWeight: FontWeight.w600,
                    color: Palette.primaryTextColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                decoration: BoxDecoration(
                  color: stockColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  stockStatus,
                  style: TextStyle(
                    fontSize: isMobile ? 6 : 7,
                    fontWeight: FontWeight.w500,
                    color: stockColor,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 2),
          
          // Compact quantity indicators in horizontal layout
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCompactQuantityIndicator('A', availableQuantity, Palette.normalPriorityColor, isMobile),
              _buildCompactQuantityIndicator('L', allocatedQuantity, Palette.highPriorityColor, isMobile),
              _buildCompactQuantityIndicator('T', totalQuantity, Palette.primaryBlue, isMobile),
            ],
          ),
          
          const SizedBox(height: 2),
          
          // Compact progress bar
          Container(
            height: 1.5,
            decoration: BoxDecoration(
              color: Palette.progressBackground,
              borderRadius: BorderRadius.circular(1),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: stockLevel,
              child: Container(
                decoration: BoxDecoration(
                  color: stockColor,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactQuantityIndicator(String label, int value, Color color, bool isMobile) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 2,
          height: 2,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 1),
        Text(
          '$label:$value',
          style: TextStyle(
            fontSize: isMobile ? 7 : 8,
            color: Palette.primaryTextColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getStockColor(double stockLevel) {
    if (stockLevel >= 0.7) return Palette.normalPriorityColor;
    if (stockLevel >= 0.3) return Palette.highPriorityColor;
    return Palette.urgentColor;
  }

  String _getStockStatus(double stockLevel) {
    if (stockLevel >= 0.7) return 'Good';
    if (stockLevel >= 0.3) return 'Low';
    return 'Critical';
  }
}