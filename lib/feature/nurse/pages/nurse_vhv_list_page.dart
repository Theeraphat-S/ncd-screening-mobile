import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/feature/nurse/pages/nurse_add_edit_vhv_page.dart';
import 'package:ncd_screening_mobile/feature/nurse/pages/nurse_vhv_detail_page.dart';
import 'package:ncd_screening_mobile/feature/vhv/bloc/vhv_bloc.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_colors.dart';
import 'package:ncd_screening_mobile/shared/widgets/app_feedback.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_radius.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_typography.dart';

class NurseVhvListPage extends StatefulWidget {
  final Nurse nurse;
  final Village village;

  const NurseVhvListPage({
    super.key,
    required this.nurse,
    required this.village,
  });

  @override
  State<NurseVhvListPage> createState() => _NurseVhvListPageState();
}

class _NurseVhvListPageState extends State<NurseVhvListPage> {
  @override
  void initState() {
    super.initState();
    context.read<VhvBloc>().add(
          VhvListLoadRequested(villageId: widget.village.villageId),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PColor.backgroundColor,
      appBar: AppBar(
        title: Text('รายชื่อ อสม. ในหมู่ ${widget.village.villageNumber}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
            tooltip: 'เพิ่ม อสม.',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NurseAddEditVhvPage(
                    nurse: widget.nurse,
                    villageId: widget.village.villageId,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: PColor.primaryDark,
            child: Text(
              '${widget.village.villageName} • หมู่ ${widget.village.villageNumber}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: BlocConsumer<VhvBloc, VhvState>(
              listener: (context, state) {
                if (state.message != null) {
                  AppSnackBar.success(context, state.message!);
                } else if (state.status == VhvStatus.failure &&
                    state.errorMessage != null &&
                    (ModalRoute.of(context)?.isCurrent ?? true)) {
                  // A form on top reports its own save failure in place.
                  AppSnackBar.error(context, state.errorMessage!);
                }
              },
              builder: (context, state) {
                if (state.status == VhvStatus.loading && state.vhvs.isEmpty) {
                  return const Center(child: CircularProgressIndicator(color: PColor.primaryColor));
                }

                if (state.status == VhvStatus.failure && state.vhvs.isEmpty) {
                  return ErrorStateView(
                    message: state.errorMessage ?? 'กรุณาลองอีกครั้ง',
                    onRetry: () => context.read<VhvBloc>().add(
                          VhvListLoadRequested(villageId: widget.village.villageId),
                        ),
                  );
                }

                if (state.vhvs.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_off_outlined, size: 64, color: PColor.primaryTint),
                        SizedBox(height: 12),
                        Text(
                          'ยังไม่มีรายชื่อ อสม. ในหมู่บ้านนี้',
                          style: TextStyle(
                            fontSize: 15,
                            color: PColor.textNeutralColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  color: PColor.primaryColor,
                  onRefresh: () async {
                    context.read<VhvBloc>().add(
                          VhvListLoadRequested(villageId: widget.village.villageId),
                        );
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.vhvs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final vhv = state.vhvs[index];
                      return _buildVhvCard(context, vhv);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVhvCard(BuildContext context, VHV vhv) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(PRadius.md),
      elevation: 1.5,
      child: InkWell(
        borderRadius: BorderRadius.circular(PRadius.md),
        onTap: () {
          context.read<VhvBloc>().add(VhvSelected(vhv));
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NurseVhvDetailPage(
                nurse: widget.nurse,
                vhv: vhv,
                village: widget.village,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: PColor.primaryLight.withValues(alpha: 0.15),
                child: const Icon(Icons.volunteer_activism_rounded, color: PColor.primaryColor, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vhv.fullName,
                      style: PTypography.sectionHeader,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'โทร: ${vhv.vhvMobile}',
                      style: PTypography.caption,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: PColor.borderStrong,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
