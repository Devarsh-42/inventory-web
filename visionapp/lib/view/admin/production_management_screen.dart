import 'package:flutter/material.dart';
import '../../pallet.dart';
import '../../core/utils/responsive_helper.dart';

class ProductionManagementScreen extends StatefulWidget {
  const ProductionManagementScreen({Key? key}) : super(key: key);

  @override
  State<ProductionManagementScreen> createState() => _ProductionManagementScreenState();
}

class _ProductionManagementScreenState extends State<ProductionManagementScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.surfaceGray,
      appBar: AppBar(
        title: const Text(
          'Production Management',
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
            icon: const Icon(Icons.analytics_outlined, color: Palette.inverseTextColor),
            onPressed: () {
              // Navigate to analytics
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Palette.inverseTextColor),
            onPressed: () {
              // Show notifications
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Alert Cards
            _buildAlertCard(
              title: '⚠️ Maintenance Alert',
              description: 'Machine #3 scheduled for maintenance in 2 hours',
              color: Palette.pausedColor,
            ),
            const SizedBox(height: 12),
            _buildAlertCard(
              title: '📦 Inventory Alert',
              description: 'Product Alpha materials below minimum level (45 units left)',
              color: Palette.urgentColor,
            ),
            const SizedBox(height: 24),

            // Performance Stats Grid
            _buildStatsGrid(),
            const SizedBox(height: 24),

            // Live Production Status
            _buildSectionTitle('Live Production Status'),
            const SizedBox(height: 16),
            _buildProductionItem(
              orderNumber: 'Order #1082 - Acme Corp',
              product: 'Product Alpha',
              machine: 'Machine #1',
              startTime: '09:30',
              progress: 0.75,
              completed: 1500,
              total: 2000,
              status: ProductionStatus.running,
            ),
            const SizedBox(height: 12),
            _buildProductionItem(
              orderNumber: 'Order #1081 - TechFlow',
              product: 'Product Beta',
              machine: 'Machine #2',
              startTime: '11:15',
              progress: 0.30,
              completed: 300,
              total: 1000,
              status: ProductionStatus.paused,
            ),
            const SizedBox(height: 12),
            _buildProductionItem(
              orderNumber: 'Order #1080 - Global Inc',
              product: 'Product Gamma',
              machine: 'Machine #3',
              startTime: '10:45',
              progress: 1.0,
              completed: 500,
              total: 500,
              status: ProductionStatus.completed,
            ),
            const SizedBox(height: 24),

            // Team Performance
            _buildSectionTitle('Team Performance'),
            const SizedBox(height: 16),
            _buildTeamPerformanceCard(
              teamName: 'Production Team A',
              target: 2000,
              achieved: 2150,
              isTargetMet: true,
            ),
            const SizedBox(height: 12),
            _buildTeamPerformanceCard(
              teamName: 'Production Team B',
              target: 1500,
              achieved: 1275,
              isTargetMet: false,
            ),
            const SizedBox(height: 24),

            // Action Buttons
            _buildActionButton(
              'View Detailed Reports',
              Icons.analytics_outlined,
              () {
                // Navigate to detailed reports
              },
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              'Send SMS Updates',
              Icons.sms_outlined,
              () {
                // Send SMS updates
              },
              color: Palette.inProductionColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertCard({
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Palette.inverseTextColor,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              color: Palette.inverseTextColor.withOpacity(0.9),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            number: '12',
            label: 'Active Jobs',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            number: '85%',
            label: 'Efficiency',
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

  Widget _buildProductionItem({
    required String orderNumber,
    required String product,
    required String machine,
    required String startTime,
    required double progress,
    required int completed,
    required int total,
    required ProductionStatus status,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  orderNumber,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Palette.primaryTextColor,
                    fontSize: 15,
                  ),
                ),
              ),
              _buildStatusChip(status),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '$product • $machine • Started: $startTime',
            style: const TextStyle(
              fontSize: 12,
              color: Palette.secondaryTextColor,
            ),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Palette.dividerColor,
            valueColor: const AlwaysStoppedAnimation<Color>(Palette.primaryBlue),
            minHeight: 8,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$completed / $total units completed',
                style: const TextStyle(
                  fontSize: 12,
                  color: Palette.tertiaryTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (status == ProductionStatus.completed)
                const Icon(
                  Icons.check_circle,
                  color: Palette.inProductionColor,
                  size: 16,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(ProductionStatus status) {
    Color backgroundColor;
    Color textColor;
    String text;

    switch (status) {
      case ProductionStatus.running:
        backgroundColor = const Color(0xFFDCFCE7);
        textColor = const Color(0xFF166534);
        text = 'RUNNING';
        break;
      case ProductionStatus.paused:
        backgroundColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFF92400E);
        text = 'PAUSED';
        break;
      case ProductionStatus.completed:
        backgroundColor = const Color(0xFFE0E7FF);
        textColor = const Color(0xFF3730A3);
        text = 'COMPLETED';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildTeamPerformanceCard({
    required String teamName,
    required int target,
    required int achieved,
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
                  isTargetMet ? 'Target Met' : '${(achieved / target * 100).round()}% Complete',
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
                'Target: ${target.toString()} units',
                style: const TextStyle(
                  fontSize: 12,
                  color: Palette.secondaryTextColor,
                ),
              ),
              Text(
                'Achieved: ${achieved.toString()} units',
                style: const TextStyle(
                  fontSize: 12,
                  color: Palette.secondaryTextColor,
                ),
              ),
            ],
          ),
        ],
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
}

enum ProductionStatus {
  running,
  paused,
  completed,
}