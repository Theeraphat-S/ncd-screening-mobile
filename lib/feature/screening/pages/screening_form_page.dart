import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/domain/services/ncd_risk_calculator.dart';
import 'package:ncd_screening_mobile/feature/screening/bloc/screening_bloc.dart';
import 'package:ncd_screening_mobile/feature/screening/pages/risk_assessment_result_page.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_colors.dart';

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
  final _random = Random.secure();
  // Biometrics Controllers
  final _weightController = TextEditingController(text: '60');
  final _heightController = TextEditingController(text: '175');
  final _waistController = TextEditingController(text: '72');
  final _sbpController = TextEditingController(text: '125');
  final _dbpController = TextEditingController(text: '65');
  final _pulseController = TextEditingController(text: '72');
  final _bloodSugarController = TextEditingController(text: '100');

  // Questionnaire States
  String _q1PersonalNcd = 'ไม่มี'; // มี / ไม่มี / ไม่ทราบ
  final List<String> _selectedPersonalNcds = [];
  String _q2DrugAllergy = 'ไม่ทราบ';
  String _q3FoodAllergy = 'ไม่ทราบ';
  String _q4FamilyNcd = 'ไม่ทราบ';

  double get _calculatedBmi {
    final w = double.tryParse(_weightController.text) ?? 0.0;
    final h = double.tryParse(_heightController.text) ?? 0.0;
    return NcdRiskCalculator.calculateBmi(w, h);
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _waistController.dispose();
    _sbpController.dispose();
    _dbpController.dispose();
    _pulseController.dispose();
    _bloodSugarController.dispose();
    super.dispose();
  }

  /// Returns a Thai error message when [value] is missing or outside the
  /// clinically plausible range, otherwise null.
  String? _rangeError(String label, String raw, double min, double max) {
    final value = double.tryParse(raw.trim());
    if (value == null) return 'กรุณากรอก$label';
    if (value < min || value > max) {
      return '$labelต้องอยู่ระหว่าง ${min.toStringAsFixed(0)}-${max.toStringAsFixed(0)}';
    }
    return null;
  }

  void _onSubmit() {
    final errors = [
      _rangeError('น้ำหนัก (กก.)', _weightController.text, 1, 300),
      _rangeError('ส่วนสูง (ซม.)', _heightController.text, 50, 250),
      _rangeError('รอบเอว (ซม.)', _waistController.text, 20, 200),
      _rangeError('ความดันตัวบน (SBP)', _sbpController.text, 60, 260),
      _rangeError('ความดันตัวล่าง (DBP)', _dbpController.text, 30, 160),
      _rangeError('ชีพจร', _pulseController.text, 30, 220),
      _rangeError('น้ำตาลในเลือด (FBS)', _bloodSugarController.text, 20, 600),
    ].whereType<String>().toList();

    if (errors.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errors.first),
          backgroundColor: PColor.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final weight = double.parse(_weightController.text.trim());
    final height = double.parse(_heightController.text.trim());
    final waist = double.parse(_waistController.text.trim());
    final sbp = double.parse(_sbpController.text.trim());
    final dbp = double.parse(_dbpController.text.trim());
    final pulse = double.parse(_pulseController.text.trim());
    final bloodSugar = double.parse(_bloodSugarController.text.trim());

    // Unique per device and per save, not just per millisecond.
    final screeningId =
        'S${DateTime.now().millisecondsSinceEpoch}${_random.nextInt(9000) + 1000}';
    final bmi = NcdRiskCalculator.calculateBmi(weight, height);

    final histories = [
      ScreeningHistory(
        historyId: '${screeningId}_H1',
        screeningId: screeningId,
        questionId: 'Q001',
        questionText: '1) ประวัติเจ็บป่วย/พบแพทย์ด้วยโรค NCDs',
        answerText: _q1PersonalNcd == 'มี'
            ? 'มี (${_selectedPersonalNcds.join(', ')})'
            : _q1PersonalNcd,
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
        answerText: _q4FamilyNcd,
      ),
    ];

    final results = NcdRiskCalculator.evaluateRisk(
      screeningId: screeningId,
      weight: weight,
      height: height,
      bmi: bmi,
      waistCm: waist,
      sbp: sbp,
      dbp: dbp,
      pulse: pulse,
      bloodSugar: bloodSugar,
      gender: widget.patient.patientGender,
      hasDirectFamilyNcd: _q4FamilyNcd == 'มี',
      hasPersonalNcd: _q1PersonalNcd == 'มี',
      personalNcdDetail: _selectedPersonalNcds.join(', '),
    );

    final newScreening = Screening(
      screenId: screeningId,
      patientId: widget.patient.patientId,
      vhvId: widget.vhv.vhvId,
      screeningDate: DateTime.now(),
      ageAtScreening: widget.patient.age,
      createdAt: DateTime.now(),
      reviewStatus: ReviewStatus.pending,
      weight: weight,
      height: height,
      bmi: bmi,
      waistCm: waist,
      sbp: sbp,
      dbp: dbp,
      pulse: pulse,
      bloodSugar: bloodSugar,
      histories: histories,
      results: results,
    );

    context.read<ScreeningBloc>().add(ScreeningSaveRequested(newScreening));

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => RiskAssessmentResultPage(
          patient: widget.patient,
          screening: newScreening,
          vhv: widget.vhv,
        ),
      ),
    );
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
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'แบบฟอร์มคัดกรองโรค',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: PColor.neutralColor,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Stepper Bar matching SRS Fig 3.20 & 5.9
              _buildStepIndicator(),
              const SizedBox(height: 18),

              // Section 1: Vital Signs & Biometrics
              _buildSectionCard(
                title: 'ตอนที่ 1: สัญญาณชีพ / ค่าตรวจวัดร่างกาย',
                icon: Icons.favorite_outline_rounded,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildBiometricField(
                            controller: _weightController,
                            label: 'น้ำหนัก (kg)',
                            hint: 'เช่น 60',
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildBiometricField(
                            controller: _heightController,
                            label: 'ส่วนสูง (cm)',
                            hint: 'เช่น 175',
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Auto BMI Banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: PColor.primaryColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'ดัชนีมวลกาย (BMI คำนวณอัตโนมัติ):',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: PColor.primaryDark,
                            ),
                          ),
                          Text(
                            '$_calculatedBmi kg/m²',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: PColor.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    _buildBiometricField(
                      controller: _waistController,
                      label: 'รอบเอว (cm)',
                      hint: 'เช่น 72',
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _buildBiometricField(
                            controller: _sbpController,
                            label: 'ความดันตัวบน SBP (mmHg)',
                            hint: 'เช่น 125',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildBiometricField(
                            controller: _dbpController,
                            label: 'ความดันตัวล่าง DBP (mmHg)',
                            hint: 'เช่น 65',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _buildBiometricField(
                            controller: _pulseController,
                            label: 'ชีพจร PULSE (ครั้ง/นาที)',
                            hint: 'เช่น 72',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildBiometricField(
                            controller: _bloodSugarController,
                            label: 'ระดับน้ำตาลในเลือด (mg/dL)',
                            hint: 'เช่น 100',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Section 2: Medical History & Family Questionnaire
              _buildSectionCard(
                title: 'ตอนที่ 2: ประวัติครอบครัว / การแพ้',
                icon: Icons.family_restroom_rounded,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question 1
                    _buildQuestionTitle(
                      '1) ท่านมีประวัติการเจ็บป่วย/พบแพทย์ด้วยโรค NCDs หรือไม่:',
                    ),
                    _buildRadioGroup(
                      value: _q1PersonalNcd,
                      options: const ['มี', 'ไม่มี', 'ไม่ทราบ'],
                      onChanged: (val) => setState(() => _q1PersonalNcd = val!),
                    ),
                    if (_q1PersonalNcd == 'มี') ...[
                      const Padding(
                        padding: EdgeInsets.only(
                          left: 8.0,
                          top: 4.0,
                          bottom: 6.0,
                        ),
                        child: Text(
                          'เลือกโรคที่ป่วย (เลือกได้มากกว่า 1 ข้อ):',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: PColor.primaryDark,
                          ),
                        ),
                      ),
                      ...[
                        'โรคเบาหวาน',
                        'โรคความดันโลหิตสูง',
                        'โรคหลอดเลือดหัวใจ',
                        'โรคอ้วนลงพุง',
                      ].map(
                        (disease) => CheckboxListTile(
                          dense: true,
                          title: Text(
                            disease,
                            style: const TextStyle(fontSize: 13.5),
                          ),
                          value: _selectedPersonalNcds.contains(disease),
                          activeColor: PColor.primaryColor,
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                          onChanged: (checked) {
                            setState(() {
                              if (checked == true) {
                                _selectedPersonalNcds.add(disease);
                              } else {
                                _selectedPersonalNcds.remove(disease);
                              }
                            });
                          },
                        ),
                      ),
                    ],
                    const Divider(height: 24),

                    // Question 2
                    _buildQuestionTitle('2) ท่านมีประวัติแพ้ยาหรือไม่:'),
                    _buildRadioGroup(
                      value: _q2DrugAllergy,
                      options: const ['มี', 'ไม่มี', 'ไม่ทราบ'],
                      onChanged: (val) => setState(() => _q2DrugAllergy = val!),
                    ),
                    const Divider(height: 24),

                    // Question 3
                    _buildQuestionTitle('3) ท่านมีประวัติแพ้อาหารหรือไม่:'),
                    _buildRadioGroup(
                      value: _q3FoodAllergy,
                      options: const ['มี', 'ไม่มี', 'ไม่ทราบ'],
                      onChanged: (val) => setState(() => _q3FoodAllergy = val!),
                    ),
                    const Divider(height: 24),

                    // Question 4
                    _buildQuestionTitle(
                      '4) ญาติตรงสาย (พ่อ/แม่/พี่/น้อง) ป่วยเป็นโรค NCDs หรือไม่:',
                    ),
                    _buildRadioGroup(
                      value: _q4FamilyNcd,
                      options: const ['มี', 'ไม่มี', 'ไม่ทราบ'],
                      onChanged: (val) => setState(() => _q4FamilyNcd = val!),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton.icon(
                onPressed: _onSubmit,
                icon: const Icon(
                  Icons.analytics_outlined,
                  color: PColor.neutralColor,
                ),
                label: const Text(
                  'บันทึกและประเมินความเสี่ยง',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: PColor.neutralColor,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: PColor.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
      decoration: BoxDecoration(
        color: PColor.neutralColor,
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
              color: (isActive || isDone)
                  ? PColor.primaryColor
                  : PColor.borderSubtle,
              width: 1.5,
            ),
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check, size: 16, color: PColor.neutralColor)
                : Text(
                    number,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isActive
                          ? PColor.primaryDark
                          : PColor.textNeutralColor,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: (isActive || isDone)
                ? FontWeight.w700
                : FontWeight.w500,
            color: (isActive || isDone)
                ? PColor.contentColor
                : PColor.textNeutralColor,
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
        color: PColor.neutralColor,
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
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: PColor.contentColor,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const Divider(height: 24, color: PColor.borderSubtle),
          child,
        ],
      ),
    );
  }

  Widget _buildBiometricField({
    required TextEditingController controller,
    required String label,
    required String hint,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: PColor.contentColor,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: PColor.textNeutralColor,
              fontSize: 13.5,
            ),
            filled: true,
            fillColor: PColor.backgroundColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: PColor.borderSubtle),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: PColor.borderSubtle),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: PColor.primaryColor,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: PColor.contentColor,
        height: 1.3,
      ),
    );
  }

  Widget _buildRadioGroup({
    required String value,
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
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => onChanged(opt),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? PColor.primaryLight
                        : PColor.surfaceSubtle,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? PColor.primaryColor
                          : PColor.borderSubtle,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      opt,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isSelected
                            ? PColor.primaryDark
                            : PColor.textSecondary,
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
