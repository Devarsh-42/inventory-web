import 'package:flutter/material.dart';
import '../../pallet.dart';
import '../../core/utils/responsive_helper.dart';
import '../../models/Orders.dart';

class PerformanceManagementScreen extends StatefulWidget {
  const PerformanceManagementScreen({Key? key}) : super(key: key);

  @override
  State<PerformanceManagementScreen> createState() => _PerformanceManagementScreenState();
}

class _PerformanceManagementScreenState extends State<PerformanceManagementScreen> {
  String selectedTimeframe = 'Monthly';
  final List<String> timeframes = ['Yearly', 'Monthly', 'Weekly'];
  
  // Sample product data for clients
  final Map<String, List<String>> clientProducts = {
    'Acme Corporation': ['Product A', 'Product B', 'Product C'],
    'TechFlow Ltd': ['Product X', 'Product Y'],
    'Global Industries': ['Product A', 'Product D', 'Product E', 'Product F'],
    'Innovation Corp': ['Product B', 'Product C'],
    'Future Tech': ['Product X', 'Product Z'],
  };

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ResponsiveHelper.isMobile(context);
    final bool isTablet = ResponsiveHelper.isTablet(context);
    final bool isDesktop = ResponsiveHelper.isDesktop(context);

    return Scaffold(
      backgroundColor: Palette.surfaceGray,
      appBar: AppBar(
        title: const Text(
          'Performance Management',
          style: TextStyle(
            color: Palette.inverseTextColor,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        backgroundColor: Palette.primaryBlue,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined, color: Palette.inverseTextColor),
            onPressed: () {
              // Show calendar
            },
          ),
          IconButton(
            icon: const Icon(Icons.download_outlined, color: Palette.inverseTextColor),
            onPressed: () {
              // Export data
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 12.0 : 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sales Stats Grid
              _buildSalesStatsGrid(isMobile),
              const SizedBox(height: 24),

              // Charts Section
              if (isDesktop) 
                _buildDesktopChartsLayout()
              else 
                _buildMobileTabletChartsLayout(),
              
              const SizedBox(height: 24),

              // Main Content Layout
              if (isDesktop)
                _buildDesktopLayout()
              else if (isTablet)
                _buildTabletLayout()
              else
                _buildMobileLayout(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSalesStatsGrid(bool isMobile) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            number: '₹2.4M',
            label: 'Monthly Sales',
            isMobile: isMobile,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            number: '18',
            label: 'New Orders',
            isMobile: isMobile,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String number, 
    required String label, 
    required bool isMobile
  }) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 14.0 : 18.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: Palette.buttonGradient,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: Palette.getButtonShadow(opacity: 0.2),
      ),
      child: Column(
        children: [
          Text(
            number,
            style: TextStyle(
              color: Palette.inverseTextColor,
              fontSize: isMobile ? 24 : 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: Palette.inverseTextColor.withOpacity(0.9),
              fontSize: isMobile ? 10 : 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopChartsLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: _buildYearlyChart()),
        const SizedBox(width: 16),
        Expanded(flex: 2, child: _buildMonthlyChart()),
      ],
    );
  }

  Widget _buildMobileTabletChartsLayout() {
    return Column(
      children: [
        _buildYearlyChart(),
        const SizedBox(height: 16),
        _buildMonthlyChart(),
      ],
    );
  }

  Widget _buildYearlyChart() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Palette.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Palette.dividerColor, width: 2),
        boxShadow: Palette.getShadow(opacity: 0.08),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Yearly Sales Trend',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Palette.primaryTextColor,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 180,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF93C5FD),
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.trending_up,
                    color: Palette.primaryBlue,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '📈 Yearly Growth Chart',
                    style: TextStyle(
                      color: Palette.primaryBlue,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '2024: ₹28.5M Revenue',
                    style: TextStyle(
                      color: Palette.primaryBlue.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyChart() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Palette.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Palette.dividerColor, width: 2),
        boxShadow: Palette.getShadow(opacity: 0.08),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Sales Graph',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Palette.primaryTextColor,
                ),
              ),
              _buildTimeframeDropdown(),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 180,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFF0FDF4), Color(0xFFDCFCE7)],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF86EFAC),
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.bar_chart,
                    color: Color(0xFF059669),
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '📊 $selectedTimeframe Sales',
                    style: const TextStyle(
                      color: Color(0xFF059669),
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getTimeframeData(),
                    style: TextStyle(
                      color: const Color(0xFF059669).withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeframeDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Palette.dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: selectedTimeframe,
        underline: const SizedBox(),
        items: timeframes.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                color: Palette.primaryTextColor,
              ),
            ),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            selectedTimeframe = newValue!;
          });
        },
      ),
    );
  }

  String _getTimeframeData() {
    switch (selectedTimeframe) {
      case 'Yearly':
        return '2024: ₹28.5M Revenue';
      case 'Monthly':
        return 'March: ₹2.4M Revenue';
      case 'Weekly':
        return 'This Week: ₹580K Revenue';
      default:
        return 'March: ₹2.4M Revenue';
    }
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _buildClientsList(),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 1,
          child: _buildCalendarView(),
        ),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Column(
      children: [
        _buildClientsList(),
        const SizedBox(height: 24),
        _buildCalendarView(),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildClientsList(),
        const SizedBox(height: 24),
        _buildCompactCalendarView(),
      ],
    );
  }

  Widget _buildClientsList() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Palette.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Palette.dividerColor, width: 2),
        boxShadow: Palette.getShadow(opacity: 0.08),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Client Orders & Products',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Palette.primaryTextColor,
            ),
          ),
          const SizedBox(height: 16),
          ...clientProducts.entries.map((entry) => 
            _buildClientItem(
              name: entry.key,
              orders: _getOrderCount(entry.key),
              totalValue: _getTotalValue(entry.key),
              lastOrder: _getLastOrder(entry.key),
              products: entry.value,
            )
          ).toList(),
        ],
      ),
    );
  }

  Widget _buildClientItem({
    required String name,
    required int orders,
    required String totalValue,
    required String lastOrder,
    required List<String> products,
  }) {
    final bool isMobile = ResponsiveHelper.isMobile(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Palette.dividerColor, width: 1),
        boxShadow: Palette.getShadow(opacity: 0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Palette.primaryTextColor,
                    fontSize: 14,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Palette.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$orders Orders',
                  style: const TextStyle(
                    color: Palette.primaryBlue,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (isMobile)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total: $totalValue',
                  style: const TextStyle(
                    color: Palette.secondaryTextColor,
                    fontSize: 12,
                  ),
                ),
                Text(
                  'Last order: $lastOrder',
                  style: const TextStyle(
                    color: Palette.secondaryTextColor,
                    fontSize: 12,
                  ),
                ),
              ],
            )
          else
            Text(
              '$totalValue total • Last order: $lastOrder',
              style: const TextStyle(
                color: Palette.secondaryTextColor,
                fontSize: 12,
              ),
            ),
          const SizedBox(height: 8),
          const Text(
            'Products:',
            style: TextStyle(
              color: Palette.primaryTextColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: products.map((product) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                product,
                style: const TextStyle(
                  color: Color(0xFF059669),
                  fontWeight: FontWeight.w500,
                  fontSize: 10,
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarView() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Palette.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Palette.dividerColor, width: 2),
        boxShadow: Palette.getShadow(opacity: 0.08),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📅 Order Calendar - June 2025',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Palette.primaryTextColor,
            ),
          ),
          const SizedBox(height: 12),
          _buildCalendarGrid(7, 35), // Full calendar
        ],
      ),
    );
  }

  Widget _buildCompactCalendarView() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Palette.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Palette.dividerColor, width: 2),
        boxShadow: Palette.getShadow(opacity: 0.08),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📅 Order Calendar - June 2025',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Palette.primaryTextColor,
            ),
          ),
          const SizedBox(height: 12),
          _buildCalendarGrid(7, 21), // Compact calendar (3 weeks)
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(int columns, int totalItems) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        childAspectRatio: 1,
      ),
      itemCount: totalItems,
      itemBuilder: (context, index) {
        List<String> days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
        List<int> daysWithOrders = [7, 9, 14, 18, 22, 25]; // Sample days with orders
        
        if (index < 7) {
          return Container(
            alignment: Alignment.center,
            child: Text(
              days[index],
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: Palette.secondaryTextColor,
              ),
            ),
          );
        }
        
        int dayNumber = index - 6;
        bool hasOrders = daysWithOrders.contains(dayNumber);
        bool isToday = dayNumber == 10; // June 10, 2025
        
        return GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Selected June $dayNumber'),
                duration: const Duration(seconds: 1),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isToday
                  ? Palette.primaryBlue
                  : hasOrders
                      ? const Color(0xFFFEF3C7)
                      : null,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              dayNumber.toString(),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: isToday
                    ? Palette.inverseTextColor
                    : hasOrders
                        ? const Color(0xFF92400E)
                        : Palette.primaryTextColor,
              ),
            ),
          ),
        );
      },
    );
  }

  // Helper methods for sample data
  int _getOrderCount(String clientName) {
    switch (clientName) {
      case 'Acme Corporation': return 12;
      case 'TechFlow Ltd': return 8;
      case 'Global Industries': return 15;
      case 'Innovation Corp': return 6;
      case 'Future Tech': return 4;
      default: return 0;
    }
  }

  String _getTotalValue(String clientName) {
    switch (clientName) {
      case 'Acme Corporation': return '₹850K';
      case 'TechFlow Ltd': return '₹620K';
      case 'Global Industries': return '₹1.2M';
      case 'Innovation Corp': return '₹450K';
      case 'Future Tech': return '₹280K';
      default: return '₹0';
    }
  }

  String _getLastOrder(String clientName) {
    switch (clientName) {
      case 'Acme Corporation': return 'Jun 8';
      case 'TechFlow Ltd': return 'Jun 5';
      case 'Global Industries': return 'Jun 9';
      case 'Innovation Corp': return 'Jun 3';
      case 'Future Tech': return 'May 28';
      default: return 'N/A';
    }
  }
}