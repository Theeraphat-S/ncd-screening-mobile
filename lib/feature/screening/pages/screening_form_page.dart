import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ncd_screening_mobile/data/repositories/screening_draft_store.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/domain/services/screening_builder.dart';
import 'package:ncd_screening_mobile/domain/services/screening_validator.dart';
import 'package:ncd_screening_mobile/feature/screening/bloc/screening_bloc.dart';
import 'package:ncd_screening_mobile/feature/screening/pages/risk_assessment_result_page.dart';
import 'package:ncd_screening_mobile/feature/screening/widgets/choice_question.dart';
import 'package:ncd_screening_mobile/feature/screening/widgets/live_readings_card.dart';
import 'package:ncd_screening_mobile/feature/screening/widgets/measurement_field.dart';
import 'package:ncd_screening_mobile/feature/screening/widgets/restored_draft_banner.dart';
import 'package:ncd_screening_mobile/feature/screening/widgets/screening_dialogs.dart';
import 'package:ncd_screening_mobile/feature/screening/widgets/screening_section_card.dart';
import 'package:ncd_screening_mobile/feature/screening/widgets/screening_step_indicator.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_colors.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_typography.dart';
import 'package:ncd_screening_mobile/shared/widgets/app_feedback.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_radius.dart';

const _personalNcdOptions = [
  'โรคเบาหวาน',
  'โรคความดันโลหิตสูง',
  'โรคหลอดเลือดหัวใจ',
  'โรคอ้วนลงพุง',
];

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

  // Resolved once so later async callbacks never touch a dead context.
  late final ScreeningDraftStore _drafts = context.read<ScreeningDraftStore>();

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
    final draft = await _drafts.load(widget.patient.patientId, widget.vhv.vhvId);
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
    if (_saved) return;
    final patientId = widget.patient.patientId;
    final vhvId = widget.vhv.vhvId;
    if (_hasContent) {
      await _drafts.save(patientId, vhvId, _draftData());
    } else {
      await _drafts.delete(patientId, vhvId);
    }
  }

  Future<void> _discardDraft() async {
    _draftTimer?.cancel();
    await _drafts.delete(widget.patient.patientId, widget.vhv.vhvId);
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
    final choice = await askLeaveForm(context);
    if (!mounted) return;
    switch (choice) {
      case LeaveChoice.keepDraft:
        await _saveDraftNow();
        if (mounted) Navigator.of(context).pop();
      case LeaveChoice.discard:
        await _discardDraft();
        if (mounted) Navigator.of(context).pop();
      case LeaveChoice.stay:
        break;
    }
  }

  // ---- submit ----------------------------------------------------------

  void _showSnack(String message) {
    AppSnackBar.error(context, message);
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
        !await confirmAbnormalValues(context, validation.warnings.values)) {
      return;
    }
    if (!mounted) return;

    final screening = ScreeningBuilder.build(
      measurements: ScreeningValidator.parse(_input)!,
      answers: ScreeningAnswers(
        personalNcd: _q1PersonalNcd!,
        personalNcdDiseases: _selectedPersonalNcds,
        drugAllergy: _q2DrugAllergy,
        foodAllergy: _q3FoodAllergy,
        familyNcd: _q4FamilyNcd!,
      ),
      patient: widget.patient,
      vhv: widget.vhv,
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
            title: const Text('แบบฟอร์มคัดกรองโรค'),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const ScreeningStepIndicator(),
                  const SizedBox(height: 18),
                  if (_restoredAt != null) ...[
                    RestoredDraftBanner(
                      key: const Key('restored_banner'),
                      savedAt: _restoredAt!,
                      onStartOver: _startOver,
                    ),
                    const SizedBox(height: 14),
                  ],
                  ScreeningSectionCard(
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(PRadius.md)),
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

  Widget _buildQuestionnaire() {
    return ScreeningSectionCard(
      title: 'ตอนที่ 2: ประวัติครอบครัว / การแพ้',
      icon: Icons.family_restroom_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ChoiceQuestion(
            title: '1) ท่านมีประวัติการเจ็บป่วย/พบแพทย์ด้วยโรค NCDs หรือไม่:',
            keyPrefix: 'q1',
            value: _q1PersonalNcd,
            showMissing: _submitted && _q1PersonalNcd == null,
            onChanged: (v) {
              _q1PersonalNcd = v;
              _changed();
            },
          ),
          if (_q1PersonalNcd == 'มี') ..._buildDiseaseChecklist(),
          const Divider(height: 24),
          ChoiceQuestion(
            title: '2) ท่านมีประวัติแพ้ยาหรือไม่:',
            keyPrefix: 'q2',
            value: _q2DrugAllergy,
            onChanged: (v) {
              _q2DrugAllergy = v;
              _changed();
            },
          ),
          const Divider(height: 24),
          ChoiceQuestion(
            title: '3) ท่านมีประวัติแพ้อาหารหรือไม่:',
            keyPrefix: 'q3',
            value: _q3FoodAllergy,
            onChanged: (v) {
              _q3FoodAllergy = v;
              _changed();
            },
          ),
          const Divider(height: 24),
          ChoiceQuestion(
            title: '4) ญาติตรงสาย (พ่อ/แม่/พี่/น้อง) ป่วยเป็นโรค NCDs หรือไม่:',
            keyPrefix: 'q4',
            value: _q4FamilyNcd,
            showMissing: _submitted && _q4FamilyNcd == null,
            onChanged: (v) {
              _q4FamilyNcd = v;
              _changed();
            },
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDiseaseChecklist() => [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, top: 4.0, bottom: 6.0),
          child: Text(
            'เลือกโรคที่ป่วย (เลือกได้มากกว่า 1 ข้อ):',
            style: PTypography.labelSmall
                .copyWith(color: PColor.primaryDark, fontSize: 14),
          ),
        ),
        for (final disease in _personalNcdOptions)
          CheckboxListTile(
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
      ];
}
