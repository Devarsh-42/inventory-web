import 'package:flutter/material.dart';
import 'package:visionapp/repositories/product_repository.dart';
import 'package:visionapp/repositories/production_completion_repository.dart';
import 'package:visionapp/view/admin/admin_bottom_nav.dart';
import 'package:visionapp/viewmodels/production_viewmodel.dart';
import 'package:visionapp/repositories/production_repository.dart';
import '../../pallet.dart';
import '../../core/utils/responsive_helper.dart';// Adjust the import based on your project structure


class ProductionManagementScreen extends StatefulWidget {
  const ProductionManagementScreen({Key? key}) : super(key: key);

  @override
  State<ProductionManagementScreen> createState() => _ProductionManagementScreenState();
}

class _ProductionManagementScreenState extends State<ProductionManagementScreen> {
  late ProductionViewModel _viewModel;
  final int _selectedIndex = 3; // Production tab

  @override
  void initState() {
    super.initState();
    _viewModel = ProductionViewModel(
      repository: ProductionRepository(),
      completionRepository: ProductionCompletionRepository(),
    );
    _loadData();
  }

  Future<void> _loadData() async {
    await _viewModel.loadProductions();
    await _viewModel.getSystemAlerts();
  }

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
            icon: const Icon(Icons.refresh, color: Palette.inverseTextColor),
            onPressed: _loadData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // System Alerts
              if (_viewModel.stats['alerts']?.isNotEmpty ?? false)
                ..._buildAlertCards(_viewModel.stats['alerts']),
              const SizedBox(height: 24),

              // Performance Stats Grid
              _buildStatsGrid(_viewModel.stats),
              const SizedBox(height: 24),

              // Live Production Status
              _buildSectionTitle('Live Production Status'),
              const SizedBox(height: 16),
              _buildLiveProductionList(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show dialog to create new production
        },
        child: const Icon(Icons.add),
        backgroundColor: Palette.primaryBlue,
      ),
      bottomNavigationBar: AdminBottomNav(
        selectedIndex: _selectedIndex,
        onItemTapped: (index) => AdminBottomNav.handleNavigation(context, index),
      ),
    );
  }

  List<Widget> _buildAlertCards(List<dynamic> alerts) {
    return alerts.map((alert) => _buildAlertCard(
      title: alert['title'],
      description: alert['description'],
      color: _getAlertColor(alert['type']),
    )).toList();
  }

  Widget _buildLiveProductionList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _viewModel.productions.length,
      itemBuilder: (context, index) {
        final prod = _viewModel.productions[index];
        return _buildProductionItem(
          orderNumber: 'Order #${prod.orderId}',
          product: prod.productName,
          machine: 'Queue #${index + 1}',
          startTime: _formatDateTime(prod.createdAt),
          progress: prod.completedQuantity / prod.targetQuantity,
          completed: prod.completedQuantity,
          total: prod.targetQuantity,
          status: _getProductionStatus(prod.status),
        );
      },
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  ProductionStatus _getProductionStatus(String status) {
    switch (status) {
      case 'in progress':
        return ProductionStatus.running;
      case 'paused':
        return ProductionStatus.paused;
      case 'completed':
        return ProductionStatus.completed;
      default:
        return ProductionStatus.paused;
    }
  }

  Color _getAlertColor(String type) {
    switch (type) {
      case 'warning':
        return Palette.pausedColor;
      case 'error':
        return Palette.urgentColor;
      default:
        return Palette.primaryBlue;
    }
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

  Widget _buildStatsGrid(Map<String, dynamic> stats) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            number: stats['activeJobs']?.toString() ?? '0',
            label: 'Active Jobs',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            number: '${(stats['efficiency'] ?? 0).round()}%',
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