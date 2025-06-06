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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.surfaceGray,
      appBar: AppBar(
        title: const Text(
          'Performance Management', // Updated title
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sales Stats Grid
                  _buildSalesStatsGrid(),
                  const SizedBox(height: 24),

                  // Yearly Sales Chart
                  _buildChartContainer(),
                  const SizedBox(height: 24),

                  // Calendar View
                  _buildCalendarView(),
                  const SizedBox(height: 24),

                  // Client History
                  _buildSectionTitle('Client History & Patterns'),
                  const SizedBox(height: 16),
                  _buildClientItem(
                    name: 'Acme Corporation',
                    orders: 12,
                    totalValue: '₹850K',
                    lastOrder: 'Mar 28',
                    pattern: 'Monthly Repeat Customer',
                  ),
                  const SizedBox(height: 12),
                  _buildClientItem(
                    name: 'TechFlow Ltd',
                    orders: 8,
                    totalValue: '₹620K',
                    lastOrder: 'Mar 25',
                    pattern: 'Quarterly Bulk Orders',
                  ),
                  const SizedBox(height: 12),
                  _buildClientItem(
                    name: 'Global Industries',
                    orders: 15,
                    totalValue: '₹1.2M',
                    lastOrder: 'Apr 1',
                    pattern: 'Weekly Small Orders',
                  ),
                  const SizedBox(height: 24),

                  // Sales Team Performance
                  _buildSectionTitle('Sales Team Performance'),
                  const SizedBox(height: 16),
                  _buildSalesTeamCard(
                    teamName: 'Sales Team North',
                    target: '₹800K',
                    achieved: '₹920K',
                    isTargetMet: true,
                  ),
                  const SizedBox(height: 12),
                  _buildSalesTeamCard(
                    teamName: 'Sales Team South',
                    target: '₹600K',
                    achieved: '₹540K',
                    isTargetMet: false,
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  _buildActionButton(
                    'Generate Performance Report',
                    Icons.assessment_outlined,
                    () {
                      // Generate sales report
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildActionButton(
                    'Send Client Updates',
                    Icons.send_outlined,
                    () {
                      // Send client updates
                    },
                    color: Palette.inProductionColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesStatsGrid() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            number: '₹2.4M',
            label: 'Monthly Sales',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            number: '18',
            label: 'New Orders',
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({required String number, required String label}) {
    return Container(
      padding: const EdgeInsets.all(18.0),
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
            style: const TextStyle(
              color: Palette.inverseTextColor,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: Palette.inverseTextColor.withOpacity(0.9),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartContainer() {
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
                    '📈 Interactive Sales Chart',
                    style: TextStyle(
                      color: Palette.primaryBlue,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Jan-Mar: ₹6.8M Revenue',
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
            '📅 Order Calendar - April 2025',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Palette.primaryTextColor,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              childAspectRatio: 1,
            ),
            itemCount: 21, // 3 weeks
            itemBuilder: (context, index) {
              List<String> days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
              List<int> daysWithOrders = [7, 9, 14]; // Sample days with orders
              
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
              bool isToday = dayNumber == 3;
              
              return GestureDetector(
                onTap: () {
                  // Handle day selection
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Selected day $dayNumber'),
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
          ),
        ],
      ),
    );
  }

  Widget _buildClientItem({
    required String name,
    required int orders,
    required String totalValue,
    required String lastOrder,
    required String pattern,
  }) {
    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: Palette.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Palette.dividerColor, width: 2),
        boxShadow: Palette.getShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Palette.primaryTextColor,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$orders orders • $totalValue total • Last order: $lastOrder',
            style: const TextStyle(
              color: Palette.secondaryTextColor,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              pattern,
              style: const TextStyle(
                color: Color(0xFF059669),
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Palette.primaryTextColor,
      ),
    );
  }

  Widget _buildActionButton(
    String text,
    IconData icon,
    VoidCallback onPressed, {
    Color? color,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Palette.inverseTextColor),
        label: Text(
          text,
          style: const TextStyle(
            color: Palette.inverseTextColor,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? Palette.primaryBlue,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
      ),
    );
  }

  Widget _buildSalesTeamCard({
    required String teamName,
    required String target,
    required String achieved,
    required bool isTargetMet,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Palette.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Palette.dividerColor, width: 2),
        boxShadow: Palette.getShadow(),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                teamName,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Palette.primaryTextColor,
                  fontSize: 14,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isTargetMet
                        ? [Palette.inProductionColor, const Color(0xFF10B981)]
                        : [Palette.pausedColor, const Color(0xFFF59E0B)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  isTargetMet ? 'Target Met' : '85% Complete',
                  style: const TextStyle(
                    color: Palette.inverseTextColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Target: $target',
                style: const TextStyle(
                  color: Palette.secondaryTextColor,
                  fontSize: 12,
                ),
              ),
              Text(
                'Achieved: $achieved',
                style: const TextStyle(
                  color: Palette.secondaryTextColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}