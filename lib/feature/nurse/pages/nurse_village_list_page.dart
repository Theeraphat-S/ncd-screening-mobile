import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/feature/auth/session_flow.dart';
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
import 'package:ncd_screening_mobile/shared/widgets/app_feedback.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_radius.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_typography.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_spacing.dart';

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
    context
        .read<VillageAnalyticsBloc>()
        .add(const VillageAnalyticsLoadRequested());
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
        leading: IconButton(
          tooltip: 'ออกจากระบบ',
          icon: const Icon(Icons.logout_rounded),
          onPressed: () => requestSignOut(context),
        ),
        title: const Text('ระบบพยาบาล รพ.สต.แม่อาย'),
        actions: [
          const SyncBadgeWidget(),
          IconButton(
            icon: const Icon(Icons.file_download_outlined, color: Colors.white),
            tooltip: 'ส่งออกข้อมูลสุขภาพ (Excel/CSV)',
            onPressed: () =>
                ExportHealthDataDialog.show(context, nurse: widget.nurse),
          ),
          IconButton(
            icon:
                const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
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
          indicatorColor: Colors.white,
          indicatorWeight: 3.5,
          labelColor: Colors.white,
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
            padding: const EdgeInsets.symmetric(horizontal: PSpacing.xl, vertical: PSpacing.md),
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
                        style: PTypography.onPrimaryLabel,
                      ),
                      PSpacing.gapVerticalXs,
                      const Text(
                        'พื้นที่รับผิดชอบ: ต.ท่าตอน อ.แม่อาย จ.เชียงใหม่',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: PSpacing.md, vertical: PSpacing.xs),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(PRadius.md),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shield_outlined,
                          color: Colors.white, size: 14),
                      PSpacing.gapHorizontalXs,
                      Text(
                        'รพ.สต.แม่อาย',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
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
          return ErrorStateView(
            message: state.errorMessage ?? 'กรุณาลองอีกครั้ง',
            onRetry: () => context
                .read<VillageAnalyticsBloc>()
                .add(const VillageAnalyticsLoadRequested()),
          );
        }

        final analytics = state.analytics;
        if (analytics == null) {
          return const Center(child: Text('ไม่พบข้อมูลสถิติ'));
        }

        return RefreshIndicator(
          color: PColor.primaryColor,
          onRefresh: () async {
            context
                .read<VillageAnalyticsBloc>()
                .add(const VillageAnalyticsRefreshRequested());
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: PSpacing.lg, vertical: PSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Filter Controls (Village Filter & Sort Order)
                AnalyticsFilterBar(state: state),
                PSpacing.gapVerticalLg,

                // 4 KPI Summary Cards
                AnalyticsKpiSection(analytics: analytics),
                PSpacing.gapVerticalXl,

                // 4 NCD Risk Breakdown Progress Meters
                AnalyticsChartsSection(analytics: analytics),
                PSpacing.gapVerticalXl,

                // Demographic Distribution (Gender & Age)
                DemographicsSection(demographics: analytics.demographics),
                PSpacing.gapVerticalXl,

                // Village Comparison Ranking (Visible when All Villages is selected)
                if (analytics.isAllVillages &&
                    analytics.villageComparisons.isNotEmpty) ...[
                  VillageComparisonTable(analytics: analytics),
                  PSpacing.gapVerticalXl,
                ],

                // High-Risk Patient Priority Queue
                HighRiskQueueList(
                  queue: analytics.highRiskPriorityQueue,
                  nurse: widget.nurse,
                ),
                PSpacing.gapVerticalXxl,
              ],
            ),
          ),
        );
      },
    );
  }
}
