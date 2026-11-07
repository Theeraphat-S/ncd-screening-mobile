import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/feature/auth/pages/user_type_selection_page.dart';
import 'package:ncd_screening_mobile/feature/nurse/bloc/village_analytics_bloc.dart';
import 'package:ncd_screening_mobile/feature/nurse/bloc/village_bloc.dart';
import 'package:ncd_screening_mobile/feature/nurse/pages/nurse_add_edit_vhv_page.dart';
import 'package:ncd_screening_mobile/feature/nurse/widgets/analytics_charts_section.dart';
import 'package:ncd_screening_mobile/feature/nurse/widgets/analytics_filter_bar.dart';
import 'package:ncd_screening_mobile/feature/nurse/widgets/analytics_kpi_section.dart';
import 'package:ncd_screening_mobile/feature/nurse/widgets/demographics_section.dart';
import 'package:ncd_screening_mobile/feature/nurse/widgets/export_health_data_dialog.dart';
import 'package:ncd_screening_mobile/feature/nurse/widgets/high_risk_queue_list.dart';
import 'package:ncd_screening_mobile/feature/nurse/widgets/village_comparison_table.dart';
import 'package:ncd_screening_mobile/feature/nurse/widgets/village_management_tab.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_colors.dart';
import 'package:ncd_screening_mobile/shared/widgets/sync_badge_widget.dart';

class NurseVillageListPage extends StatefulWidget {
  final Nurse nurse;

  const NurseVillageListPage({super.key, required this.nurse});

  @override
  State<NurseVillageListPage> createState() => _NurseVillageListPageState();
}

class _NurseVillageListPageState extends State<NurseVillageListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<VillageBloc>().add(VillageListLoadRequested());
    context.read<VillageAnalyticsBloc>().add(
      const VillageAnalyticsLoadRequested(),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PColor.backgroundColor,
      appBar: AppBar(
        backgroundColor: PColor.primaryColor,
        elevation: 0,
        leading: IconButton(
          tooltip: 'ย้อนกลับ',
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: PColor.neutralColor,
          ),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const UserTypeSelectionPage()),
              (route) => false,
            );
          },
        ),
        title: const Text(
          'ระบบพยาบาล รพ.สต.แม่อาย',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: PColor.neutralColor,
          ),
        ),
        centerTitle: true,
        actions: [
          const SyncBadgeWidget(),
          IconButton(
            icon: const Icon(
              Icons.file_download_outlined,
              color: PColor.neutralColor,
            ),
            tooltip: 'ส่งออกข้อมูลสุขภาพ (Excel/CSV)',
            onPressed: () =>
                ExportHealthDataDialog.show(context, nurse: widget.nurse),
          ),
          IconButton(
            icon: const Icon(
              Icons.person_add_alt_1_rounded,
              color: PColor.neutralColor,
            ),
            tooltip: 'เพิ่ม อสม.',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NurseAddEditVhvPage(nurse: widget.nurse),
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: PColor.neutralColor,
          indicatorWeight: 3.5,
          labelColor: PColor.neutralColor,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
          tabs: const [
            Tab(
              icon: Icon(Icons.analytics_rounded, size: 20),
              text: 'ภาพรวมสถิติสุขภาพ',
            ),
            Tab(
              icon: Icon(Icons.holiday_village_rounded, size: 20),
              text: 'จัดการหมู่บ้านและ อสม.',
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Nurse Area Header Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: PColor.primaryDark,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'พยาบาล: ${widget.nurse.fullName}',
                        style: const TextStyle(
                          color: PColor.neutralColor,
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'พื้นที่รับผิดชอบ: ต.ท่าตอน อ.แม่อาย จ.เชียงใหม่',
                        style: TextStyle(color: Colors.white70, fontSize: 11.5),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: PColor.neutralColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        color: PColor.neutralColor,
                        size: 14,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'รพ.สต.แม่อาย',
                        style: TextStyle(
                          color: PColor.neutralColor,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tab Bar View Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAnalyticsDashboardTab(context),
                VillageManagementTab(nurse: widget.nurse),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 1: HEALTH ANALYTICS DASHBOARD
  // ==========================================

  Widget _buildAnalyticsDashboardTab(BuildContext context) {
    return BlocBuilder<VillageAnalyticsBloc, VillageAnalyticsState>(
      builder: (context, state) {
        if (state.status == VillageAnalyticsStatus.loading &&
            state.analytics == null) {
          return const Center(
            child: CircularProgressIndicator(color: PColor.primaryColor),
          );
        }

        if (state.status == VillageAnalyticsStatus.failure &&
            state.analytics == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: PColor.errorColor,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    state.errorMessage ?? 'เกิดข้อผิดพลาดในการโหลดข้อมูล',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: PColor.contentColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<VillageAnalyticsBloc>().add(
                        const VillageAnalyticsLoadRequested(),
                      );
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('ลองใหม่'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PColor.primaryColor,
                      foregroundColor: PColor.neutralColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final analytics = state.analytics;
        if (analytics == null) {
          return const Center(child: Text('ไม่พบข้อมูลสถิติ'));
        }

        return RefreshIndicator(
          color: PColor.primaryColor,
          onRefresh: () async {
            context.read<VillageAnalyticsBloc>().add(
              const VillageAnalyticsRefreshRequested(),
            );
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Filter Controls (Village Filter & Sort Order)
                AnalyticsFilterBar(state: state),
                const SizedBox(height: 16),

                // 4 KPI Summary Cards
                AnalyticsKpiSection(analytics: analytics),
                const SizedBox(height: 20),

                // 4 NCD Risk Breakdown Progress Meters
                AnalyticsChartsSection(analytics: analytics),
                const SizedBox(height: 20),

                // Demographic Distribution (Gender & Age)
                DemographicsSection(demographics: analytics.demographics),
                const SizedBox(height: 20),

                // Village Comparison Ranking (Visible when All Villages is selected)
                if (analytics.isAllVillages &&
                    analytics.villageComparisons.isNotEmpty) ...[
                  VillageComparisonTable(analytics: analytics),
                  const SizedBox(height: 20),
                ],

                // High-Risk Patient Priority Queue
                HighRiskQueueList(
                  queue: analytics.highRiskPriorityQueue,
                  nurse: widget.nurse,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}
