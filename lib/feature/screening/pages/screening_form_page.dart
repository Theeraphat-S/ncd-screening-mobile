import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ncd_screening_mobile/data/repositories/screening_draft_store.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/domain/services/id_generator.dart';
import 'package:ncd_screening_mobile/domain/services/ncd_risk_calculator.dart';
import 'package:ncd_screening_mobile/domain/services/screening_validator.dart';
import 'package:ncd_screening_mobile/feature/screening/bloc/screening_bloc.dart';
import 'package:ncd_screening_mobile/feature/screening/pages/risk_assessment_result_page.dart';
import 'package:ncd_screening_mobile/feature/screening/widgets/live_readings_card.dart';
import 'package:ncd_screening_mobile/feature/screening/widgets/measurement_field.dart';
import 'package:ncd_screening_mobile/locator.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_colors.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_typography.dart';

enum _LeaveChoice { stay, keepDraft, discard }

class ScreeningFormPage extends StatefulWidget {
  final Patient patient;
  final VHV vhv;

  const ScreeningFormPage({
    super.key,
    required this.patient,
    required this.vhv,
  });

  @override
  State<ScreeningFormPage> createState() => _ScreeningFormPageState();
}

class _ScreeningFormPageState extends State<ScreeningFormPage> {
  static const _draftDebounce = Duration(milliseconds: 700);

  // Field order matters: it is the keyboard "next" order.
  static const _fieldOrder = [
    ScreeningField.weight,
    ScreeningField.height,
    ScreeningField.waist,
    ScreeningField.sbp,
    ScreeningField.dbp,
    ScreeningField.pulse,
    ScreeningField.bloodSugar,
  ];

  // Fields start EMPTY on purpose: a pre-filled "normal" value that the VHV
  // forgets to overwrite would be saved as a real measurement.
  final Map<ScreeningField, TextEditingController> _controllers = {
    for (final f in ScreeningField.values) f: TextEditingController(),
  };
  final Map<ScreeningField, FocusNode> _focusNodes = {
    for (final f in ScreeningField.values) f: FocusNode(),
  };
  final Set<ScreeningField> _touched = {};

  // Q1 and Q4 feed the risk calculator, so they must be answered explicitly.
  String? _q1PersonalNcd;
  String _q2DrugAllergy = 'ไม่ทราบ';
  String _q3FoodAllergy = 'ไม่ทราบ';
  String? _q4FamilyNcd;
  final List<String> _selectedPersonalNcds = [];

  bool _submitted = false;
  bool _saving = false;
  bool _saved = false;
  DateTime? _restoredAt;
  Timer? _draftTimer;

  ScreeningDraftStore? get _drafts => locator.isRegistered<ScreeningDraftStore>()
      ? locator<ScreeningDraftStore>()
      : null;

  @override
  void initState() {
    super.initState();
    for (final field in ScreeningField.values) {
      _focusNodes[field]!.addListener(() {
        if (!_focusNodes[field]!.hasFocus && mounted) {
          setState(() => _touched.add(field));
        }
      });
    }
    _restoreDraft();
  }

  @override
  void dispose() {
    _draftTimer?.cancel();
    for (final c in _controllers.values) {
      c.dispose();
    }
    for (final n in _focusNodes.values) {
      n.dispose();
    }
    super.dispose();
  }

  // ---- derived state ---------------------------------------------------

  ScreeningInput get _input => ScreeningInput(
        weight: _controllers[ScreeningField.weight]!.text,
        height: _controllers[ScreeningField.height]!.text,
        waist: _controllers[ScreeningField.waist]!.text,
        sbp: _controllers[ScreeningField.sbp]!.text,
        dbp: _controllers[ScreeningField.dbp]!.text,
        pulse: _controllers[ScreeningField.pulse]!.text,
        bloodSugar: _controllers[ScreeningField.bloodSugar]!.text,
      );

  bool get _hasContent =>
      _controllers.values.any((c) => c.text.trim().isNotEmpty) ||
      _q1PersonalNcd != null ||
      _q4FamilyNcd != null ||
      _q2DrugAllergy != 'ไม่ทราบ' ||
      _q3FoodAllergy != 'ไม่ทราบ' ||
      _selectedPersonalNcds.isNotEmpty;

  String? _errorFor(ScreeningField field, ScreeningValidation strict,
      ScreeningValidation lenient) {
    final show = _submitted || _touched.contains(field);
    return (show ? strict : lenient).errors[field];
  }

  // ---- draft -----------------------------------------------------------

  Map<String, dynamic> _draftData() => {
        for (final f in ScreeningField.values) f.name: _controllers[f]!.text,
        'q1': _q1PersonalNcd,
        'q2': _q2DrugAllergy,
        'q3': _q3FoodAllergy,
        'q4': _q4FamilyNcd,
        'ncds': List<String>.of(_selectedPersonalNcds),
      };

  Future<void> _restoreDraft() async {
    final store = _drafts;
    if (store == null) return;
    final draft = await store.load(widget.patient.patientId, widget.vhv.vhvId);
    if (draft == null || !mounted) return;
    setState(() {
      for (final f in ScreeningField.values) {
        _controllers[f]!.text = (draft.data[f.name] as String?) ?? '';
      }
      _q1PersonalNcd = draft.data['q1'] as String?;
      _q2DrugAllergy = (draft.data['q2'] as String?) ?? 'ไม่ทราบ';
      _q3FoodAllergy = (draft.data['q3'] as String?) ?? 'ไม่ทราบ';
      _q4FamilyNcd = draft.data['q4'] as String?;
      _selectedPersonalNcds
        ..clear()
        ..addAll(((draft.data['ncds'] as List?) ?? const []).cast<String>());
      _restoredAt = draft.updatedAt;
    });
  }

  void _scheduleDraftSave() {
    _draftTimer?.cancel();
    _draftTimer = Timer(_draftDebounce, _saveDraftNow);
  }

  Future<void> _saveDraftNow() async {
    _draftTimer?.cancel();
    final store = _drafts;
    if (store == null || _saved) return;
    final patientId = widget.patient.patientId;
    final vhvId = widget.vhv.vhvId;
    if (_hasContent) {
      await store.save(patientId, vhvId, _draftData());
    } else {
      await store.delete(patientId, vhvId);
    }
  }

  Future<void> _discardDraft() async {
    _draftTimer?.cancel();
    await _drafts?.delete(widget.patient.patientId, widget.vhv.vhvId);
  }

  void _changed() {
    setState(() {});
    _scheduleDraftSave();
  }

  Future<void> _startOver() async {
    await _discardDraft();
    if (!mounted) return;
    setState(() {
      for (final c in _controllers.values) {
        c.clear();
      }
      _q1PersonalNcd = null;
      _q4FamilyNcd = null;
      _q2DrugAllergy = 'ไม่ทราบ';
      _q3FoodAllergy = 'ไม่ทราบ';
      _selectedPersonalNcds.clear();
      _touched.clear();
      _submitted = false;
      _restoredAt = null;
    });
  }

  // ---- leaving ---------------------------------------------------------

  Future<void> _onBackRequested() async {
    final choice = await showDialog<_LeaveChoice>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ออกจากแบบฟอร์มคัดกรอง?'),
        content: const Text(
          'ข้อมูลที่กรอกถูกเก็บเป็นฉบับร่างอัตโนมัติ สามารถกลับมากรอกต่อได้ภายใน 7 วัน',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, _LeaveChoice.stay),
            child: const Text('อยู่ต่อ'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, _LeaveChoice.discard),
            child: const Text('ทิ้งฉบับร่าง'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, _LeaveChoice.keepDraft),
            child: const Text('ออก (เก็บไว้)'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    switch (choice) {
      case _LeaveChoice.keepDraft:
        await _saveDraftNow();
        if (mounted) Navigator.of(context).pop();
      case _LeaveChoice.discard:
        await _discardDraft();
        if (mounted) Navigator.of(context).pop();
      case _LeaveChoice.stay:
      case null:
        break;
    }
  }

  // ---- submit ----------------------------------------------------------

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: PColor.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<bool> _confirmWarnings(Iterable<String> warnings) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ค่าที่กรอกผิดปกติ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final w in warnings)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text('• $w'),
              ),
            const SizedBox(height: 4),
            const Text('ตรวจสอบค่าอีกครั้งก่อนบันทึก หรือยืนยันหากวัดซ้ำแล้ว'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('ตรวจสอบอีกครั้ง'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('ยืนยันและบันทึก'),
          ),
        ],
      ),
    );
    return ok ?? false;
  }

  Future<void> _onSubmit() async {
    if (_saving) return;
    setState(() => _submitted = true);

    final validation = ScreeningValidator.validate(_input);
    final missingAnswers = [
      if (_q1PersonalNcd == null) 'ข้อ 1',
      if (_q4FamilyNcd == null) 'ข้อ 4',
    ];

    if (!validation.isValid || missingAnswers.isNotEmpty) {
      final firstBad = _fieldOrder.firstWhere(
        validation.errors.containsKey,
        orElse: () => ScreeningField.weight,
      );
      if (validation.errors.isNotEmpty) _focusNodes[firstBad]!.requestFocus();
      final count = validation.errors.length + missingAnswers.length;
      _showSnack(
        missingAnswers.isEmpty
            ? 'กรุณาแก้ไขข้อมูลที่ไม่ถูกต้อง $count รายการ'
            : 'กรุณาตรวจสอบข้อมูลที่ยังไม่ครบ $count รายการ (ตอบ ${missingAnswers.join(', ')})',
      );
      return;
    }

    if (validation.warnings.isNotEmpty &&
        !await _confirmWarnings(validation.warnings.values)) {
      return;
    }
    if (!mounted) return;

    final m = ScreeningValidator.parse(_input)!;
    final screeningId = generateId();
    final bmi = NcdRiskCalculator.calculateBmi(m.weight, m.height);

    final histories = [
      ScreeningHistory(
        historyId: '${screeningId}_H1',
        screeningId: screeningId,
        questionId: 'Q001',
        questionText: '1) ประวัติเจ็บป่วย/พบแพทย์ด้วยโรค NCDs',
        answerText: _q1PersonalNcd == 'มี'
            ? 'มี (${_selectedPersonalNcds.join(', ')})'
            : _q1PersonalNcd!,
      ),
      ScreeningHistory(
        historyId: '${screeningId}_H2',
        screeningId: screeningId,
        questionId: 'Q002',
        questionText: '2) ประวัติแพ้ยา',
        answerText: _q2DrugAllergy,
      ),
      ScreeningHistory(
        historyId: '${screeningId}_H3',
        screeningId: screeningId,
        questionId: 'Q003',
        questionText: '3) ประวัติแพ้อาหาร',
        answerText: _q3FoodAllergy,
      ),
      ScreeningHistory(
        historyId: '${screeningId}_H4',
        screeningId: screeningId,
        questionId: 'Q004',
        questionText: '4) ญาติตรงสาย (พ่อ/แม่/พี่/น้อง) ป่วยเป็นโรค NCDs',
        answerText: _q4FamilyNcd!,
      ),
    ];

    final results = NcdRiskCalculator.evaluateRisk(
      screeningId: screeningId,
      weight: m.weight,
      height: m.height,
      bmi: bmi,
      waistCm: m.waist,
      sbp: m.sbp,
      dbp: m.dbp,
      pulse: m.pulse,
      bloodSugar: m.bloodSugar,
      gender: widget.patient.patientGender,
      hasDirectFamilyNcd: _q4FamilyNcd == 'มี',
      hasPersonalNcd: _q1PersonalNcd == 'มี',
      personalNcdDetail: _selectedPersonalNcds.join(', '),
    );

    final screening = Screening(
      screenId: screeningId,
      patientId: widget.patient.patientId,
      vhvId: widget.vhv.vhvId,
      screeningDate: DateTime.now(),
      ageAtScreening: widget.patient.age,
      createdAt: DateTime.now(),
      reviewStatus: ReviewStatus.pending,
      weight: m.weight,
      height: m.height,
      bmi: bmi,
      waistCm: m.waist,
      sbp: m.sbp,
      dbp: m.dbp,
      pulse: m.pulse,
      bloodSugar: m.bloodSugar,
      histories: histories,
      results: results,
    );

    // Wait for the save result (listener below) before leaving the page, and
    // lock the button meanwhile so a double tap cannot save twice.
    setState(() => _saving = true);
    context.read<ScreeningBloc>().add(ScreeningSaveRequested(screening));
  }

  Future<void> _onSaveResult(BuildContext context, ScreeningState state) async {
    if (!_saving) return;
    if (state.status == ScreeningStatus.success &&
        state.currentScreening != null) {
      _saved = true;
      await _discardDraft();
      if (!context.mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => RiskAssessmentResultPage(
            patient: widget.patient,
            screening: state.currentScreening!,
            vhv: widget.vhv,
          ),
        ),
      );
    } else if (state.status == ScreeningStatus.failure) {
      setState(() => _saving = false);
      _showSnack(
        '${state.errorMessage ?? 'บันทึกไม่สำเร็จ'} ข้อมูลที่กรอกยังอยู่ กรุณาลองใหม่อีกครั้ง',
      );
    }
  }

  // ---- UI --------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final strict = ScreeningValidator.validate(_input);
    final lenient = ScreeningValidator.validate(_input, lenient: true);
    final input = _input;
    final bmi = ScreeningValidator.bmi(input.weight, input.height);
    final bpLevel = ScreeningValidator.bpLevel(
      ScreeningValidator.parseNumber(input.sbp),
      ScreeningValidator.parseNumber(input.dbp),
    );

    Widget field(ScreeningField f, String label, String unit, String hint,
        {bool optional = false}) {
      return MeasurementField(
        fieldKey: Key('field_${f.name}'),
        controller: _controllers[f]!,
        focusNode: _focusNodes[f]!,
        label: label,
        unit: unit,
        hint: hint,
        optional: optional,
        errorText: _errorFor(f, strict, lenient),
        warningText: strict.warnings[f],
        textInputAction:
            f == ScreeningField.bloodSugar ? TextInputAction.done : TextInputAction.next,
        onChanged: (_) => _changed(),
      );
    }

    return BlocListener<ScreeningBloc, ScreeningState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: _onSaveResult,
      child: PopScope(
        canPop: _saved || !_hasContent,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _onBackRequested();
        },
        child: Scaffold(
          backgroundColor: PColor.backgroundColor,
          appBar: AppBar(
            backgroundColor: PColor.primaryColor,
            elevation: 0,
            leading: IconButton(
              tooltip: 'ย้อนกลับ',
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            title: const Text('แบบฟอร์มคัดกรองโรค', style: PTypography.appBarTitle),
            centerTitle: true,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildStepIndicator(),
                  const SizedBox(height: 18),
                  if (_restoredAt != null) ...[
                    _buildRestoredBanner(),
                    const SizedBox(height: 14),
                  ],
                  _buildSectionCard(
                    title: 'ตอนที่ 1: สัญญาณชีพ / ค่าตรวจวัดร่างกาย',
                    icon: Icons.favorite_outline_rounded,
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: field(ScreeningField.weight, 'น้ำหนัก', 'กก.', 'เช่น 60'),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: field(ScreeningField.height, 'ส่วนสูง', 'ซม.', 'เช่น 165'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        field(ScreeningField.waist, 'รอบเอว', 'ซม.', 'เช่น 80'),
                        const SizedBox(height: 14),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: field(ScreeningField.sbp, 'ความดันตัวบน (SBP)', 'mmHg', 'เช่น 120'),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: field(ScreeningField.dbp, 'ความดันตัวล่าง (DBP)', 'mmHg', 'เช่น 80'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: field(ScreeningField.pulse, 'ชีพจร', 'ครั้ง/นาที', 'เช่น 72'),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: field(
                                ScreeningField.bloodSugar,
                                'น้ำตาลในเลือด',
                                'mg/dL',
                                'เช่น 95',
                                optional: true,
                              ),
                            ),
                          ],
                        ),
                        LiveReadingsCard(bmi: bmi, bpLevel: bpLevel),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildQuestionnaire(),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    key: const Key('submit_screening'),
                    onPressed: _saving ? null : _onSubmit,
                    icon: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
                          )
                        : const Icon(Icons.analytics_outlined, color: Colors.white),
                    label: Text(
                      _saving ? 'กำลังบันทึก...' : 'บันทึกและประเมินความเสี่ยง',
                      style: PTypography.appBarTitle,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PColor.primaryColor,
                      disabledBackgroundColor: PColor.primaryColor.withValues(alpha: 0.6),
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 3,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRestoredBanner() {
    final at = _restoredAt!;
    final now = DateTime.now();
    final sameDay = at.year == now.year && at.month == now.month && at.day == now.day;
    String two(int n) => n.toString().padLeft(2, '0');
    final when = sameDay
        ? '${two(at.hour)}:${two(at.minute)} น.'
        : '${two(at.day)}/${two(at.month)} ${two(at.hour)}:${two(at.minute)} น.';
    return Container(
      key: const Key('restored_banner'),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: PColor.riskModerateBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PColor.riskModerate.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.history_rounded, color: PColor.riskModerate),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'กู้คืนข้อมูลที่กรอกค้างไว้เมื่อ $when',
              style: PTypography.bodyBold,
            ),
          ),
          TextButton(
            key: const Key('start_over'),
            onPressed: _startOver,
            child: const Text('เริ่มใหม่'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionnaire() {
    final q1Missing = _submitted && _q1PersonalNcd == null;
    final q4Missing = _submitted && _q4FamilyNcd == null;
    return _buildSectionCard(
      title: 'ตอนที่ 2: ประวัติครอบครัว / การแพ้',
      icon: Icons.family_restroom_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuestionTitle('1) ท่านมีประวัติการเจ็บป่วย/พบแพทย์ด้วยโรค NCDs หรือไม่:'),
          _buildRadioGroup(
            keyPrefix: 'q1',
            value: _q1PersonalNcd,
            options: const ['มี', 'ไม่มี', 'ไม่ทราบ'],
            onChanged: (val) {
              _q1PersonalNcd = val;
              _changed();
            },
          ),
          if (q1Missing) _missingAnswer(),
          if (_q1PersonalNcd == 'มี') ...[
            Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 4.0, bottom: 6.0),
              child: Text(
                'เลือกโรคที่ป่วย (เลือกได้มากกว่า 1 ข้อ):',
                style: PTypography.labelSmall.copyWith(color: PColor.primaryDark, fontSize: 14),
              ),
            ),
            ...['โรคเบาหวาน', 'โรคความดันโลหิตสูง', 'โรคหลอดเลือดหัวใจ', 'โรคอ้วนลงพุง'].map(
              (disease) => CheckboxListTile(
                dense: true,
                title: Text(disease, style: const TextStyle(fontSize: 15)),
                value: _selectedPersonalNcds.contains(disease),
                activeColor: PColor.primaryColor,
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                onChanged: (checked) {
                  if (checked == true) {
                    _selectedPersonalNcds.add(disease);
                  } else {
                    _selectedPersonalNcds.remove(disease);
                  }
                  _changed();
                },
              ),
            ),
          ],
          const Divider(height: 24),
          _buildQuestionTitle('2) ท่านมีประวัติแพ้ยาหรือไม่:'),
          _buildRadioGroup(
            keyPrefix: 'q2',
            value: _q2DrugAllergy,
            options: const ['มี', 'ไม่มี', 'ไม่ทราบ'],
            onChanged: (val) {
              _q2DrugAllergy = val!;
              _changed();
            },
          ),
          const Divider(height: 24),
          _buildQuestionTitle('3) ท่านมีประวัติแพ้อาหารหรือไม่:'),
          _buildRadioGroup(
            keyPrefix: 'q3',
            value: _q3FoodAllergy,
            options: const ['มี', 'ไม่มี', 'ไม่ทราบ'],
            onChanged: (val) {
              _q3FoodAllergy = val!;
              _changed();
            },
          ),
          const Divider(height: 24),
          _buildQuestionTitle('4) ญาติตรงสาย (พ่อ/แม่/พี่/น้อง) ป่วยเป็นโรค NCDs หรือไม่:'),
          _buildRadioGroup(
            keyPrefix: 'q4',
            value: _q4FamilyNcd,
            options: const ['มี', 'ไม่มี', 'ไม่ทราบ'],
            onChanged: (val) {
              _q4FamilyNcd = val;
              _changed();
            },
          ),
          if (q4Missing) _missingAnswer(),
        ],
      ),
    );
  }

  Widget _missingAnswer() => const Padding(
        padding: EdgeInsets.only(top: 6, left: 4),
        child: Text('กรุณาเลือกคำตอบ', style: PTypography.fieldError),
      );

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PColor.borderSubtle),
        boxShadow: PShadow.card,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStepItem(number: '1', label: 'ข้อมูลผู้ป่วย', isDone: true),
          _buildStepLine(isActive: true),
          _buildStepItem(number: '2', label: 'แบบคัดกรอง', isActive: true),
          _buildStepLine(isActive: false),
          _buildStepItem(number: '3', label: 'ผลการประเมิน', isActive: false),
        ],
      ),
    );
  }

  Widget _buildStepItem({
    required String number,
    required String label,
    bool isActive = false,
    bool isDone = false,
  }) {
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone
                ? PColor.primaryColor
                : isActive
                    ? PColor.primaryLight
                    : PColor.surfaceSubtle,
            border: Border.all(
              color: (isActive || isDone) ? PColor.primaryColor : PColor.borderSubtle,
              width: 1.5,
            ),
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : Text(
                    number,
                    style: PTypography.bodyBold.copyWith(color: isActive ? PColor.primaryDark : PColor.textNeutralColor, fontSize: 13),
                  ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: (isActive || isDone) ? FontWeight.w700 : FontWeight.w500,
            color: (isActive || isDone) ? PColor.contentColor : PColor.textNeutralColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine({required bool isActive}) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 18),
        color: isActive ? PColor.primaryColor : PColor.borderSubtle,
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: PColor.borderSubtle),
        boxShadow: PShadow.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: PColor.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: PColor.primaryColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(title, style: PTypography.sectionHeader)),
            ],
          ),
          const Divider(height: 24, color: PColor.borderSubtle),
          // Lets ListTile ink show through the card's decoration.
          Material(type: MaterialType.transparency, child: child),
        ],
      ),
    );
  }

  Widget _buildQuestionTitle(String text) {
    return Text(
      text,
      style: PTypography.labelSmall,
    );
  }

  Widget _buildRadioGroup({
    required String keyPrefix,
    required String? value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
      child: Row(
        children: options.map((opt) {
          final isSelected = value == opt;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Semantics(
                button: true,
                selected: isSelected,
                label: opt,
                child: InkWell(
                  key: Key('${keyPrefix}_$opt'),
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => onChanged(opt),
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 48),
                    decoration: BoxDecoration(
                      color: isSelected ? PColor.primaryLight : PColor.surfaceSubtle,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? PColor.primaryColor : PColor.borderSubtle,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        opt,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? PColor.primaryDark : PColor.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
