import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/feature/patient/bloc/patient_bloc.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_colors.dart';

class AddEditPatientPage extends StatefulWidget {
  final VHV? vhv;
  final Patient? patient;
  final String villageId;
  final String? initialCitizenId;
  final String? initialTitle;
  final String? initialFname;
  final String? initialLname;

  const AddEditPatientPage({
    super.key,
    this.vhv,
    this.patient,
    required this.villageId,
    this.initialCitizenId,
    this.initialTitle,
    this.initialFname,
    this.initialLname,
  });

  @override
  State<AddEditPatientPage> createState() => _AddEditPatientPageState();
}

class _AddEditPatientPageState extends State<AddEditPatientPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _citizenIdController;
  late final TextEditingController _titleController;
  late final TextEditingController _fnameController;
  late final TextEditingController _lnameController;
  late final TextEditingController _addressController;
  late final TextEditingController _mobileController;

  String _gender = 'ชาย';
  DateTime _birthDate = DateTime(1980, 1, 1);
  bool get _isEdit => widget.patient != null;

  @override
  void initState() {
    super.initState();
    final p = widget.patient;
    _citizenIdController = TextEditingController(
      text: p?.patientCitizenId ?? widget.initialCitizenId ?? '',
    );
    _titleController = TextEditingController(
      text: p?.patientTitle ?? widget.initialTitle ?? 'นาย',
    );
    _fnameController = TextEditingController(
      text: p?.patientFname ?? widget.initialFname ?? '',
    );
    _lnameController = TextEditingController(
      text: p?.patientLname ?? widget.initialLname ?? '',
    );
    _addressController = TextEditingController(text: p?.patientAddress ?? '');
    _mobileController = TextEditingController(text: p?.patientMobile ?? '');
    if (p != null) {
      _gender = p.patientGender;
      _birthDate = p.patientBirthDate;
    }
  }

  @override
  void dispose() {
    _citizenIdController.dispose();
    _titleController.dispose();
    _fnameController.dispose();
    _lnameController.dispose();
    _addressController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  int get _calculatedAge {
    final now = DateTime.now();
    int age = now.year - _birthDate.year;
    if (now.month < _birthDate.month ||
        (now.month == _birthDate.month && now.day < _birthDate.day)) {
      age--;
    }
    return age;
  }

  Future<void> _selectBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: PColor.primaryColor,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  void _onSave() {
    final citizenId = _citizenIdController.text.trim();
    final title = _titleController.text.trim();
    final fname = _fnameController.text.trim();
    final lname = _lnameController.text.trim();
    final address = _addressController.text.trim();

    // SRS Form Validations
    if (citizenId.length != 13 || int.tryParse(citizenId) == null) {
      _showError('เลขบัตรประชาชนต้องเป็นตัวเลข 13 ตัวอักษร');
      return;
    }
    if (fname.length < 2 || fname.length > 100) {
      _showError('ชื่อต้องมีความยาว 3 ถึง 100 ตัวอักษร');
      return;
    }
    if (lname.length < 2 || lname.length > 100) {
      _showError('นามสกุลต้องมีความยาว 3 ถึง 100 ตัวอักษร');
      return;
    }
    if (address.isEmpty) {
      _showError('กรุณากรอกที่อยู่ให้ครบถ้วน');
      return;
    }

    final newPatient = Patient(
      patientId: widget.patient?.patientId ?? '',
      patientCitizenId: citizenId,
      patientTitle: title.isNotEmpty ? title : (_gender == 'ชาย' ? 'นาย' : 'นาง'),
      patientFname: fname,
      patientLname: lname,
      patientGender: _gender,
      patientBirthDate: _birthDate,
      patientAddress: address,
      patientMobile: _mobileController.text.trim(),
      villageId: widget.villageId,
    );

    if (_isEdit) {
      context.read<PatientBloc>().add(PatientUpdateRequested(newPatient));
    } else {
      context.read<PatientBloc>().add(PatientAddRequested(newPatient));
    }

    Navigator.pop(context);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: PColor.errorColor,
        behavior: SnackBarBehavior.floating,
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
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEdit ? 'แก้ไขผู้ป่วย' : 'เพิ่มผู้ป่วย',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image Upload Card
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: PColor.primaryLight.withValues(alpha: 0.15),
                        child: const Icon(Icons.person, size: 40, color: PColor.primaryColor),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'รูปผู้ป่วย (ไม่บังคับ)',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: PColor.contentColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            OutlinedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('เลือกรูปภาพเรียบร้อยแล้ว'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.image_outlined, size: 18, color: PColor.primaryColor),
                              label: Text(
                                _isEdit ? 'เปลี่ยนรูป' : 'แนบรูป',
                                style: const TextStyle(color: PColor.primaryColor, fontWeight: FontWeight.bold),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: PColor.primaryColor),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Fields Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Citizen ID
                      _buildLabel('เลขบัตรประชาชน (13 หลัก)'),
                      TextFormField(
                        controller: _citizenIdController,
                        keyboardType: TextInputType.number,
                        maxLength: 13,
                        decoration: _inputDecoration('กรอกเลขบัตรประชาชน 13 หลัก'),
                      ),
                      const SizedBox(height: 16),

                      // Title & First Name
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('คำนำหน้า'),
                                TextFormField(
                                  controller: _titleController,
                                  decoration: _inputDecoration('นาย / นาง'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 4,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('ชื่อ'),
                                TextFormField(
                                  controller: _fnameController,
                                  decoration: _inputDecoration('ชื่อจริง'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Last Name
                      _buildLabel('นามสกุล'),
                      TextFormField(
                        controller: _lnameController,
                        decoration: _inputDecoration('นามสกุล'),
                      ),
                      const SizedBox(height: 16),

                      // Gender & Birthdate
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('เพศ'),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: PColor.borderStrong),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _gender,
                                      isExpanded: true,
                                      items: const [
                                        DropdownMenuItem(value: 'ชาย', child: Text('ชาย')),
                                        DropdownMenuItem(value: 'หญิง', child: Text('หญิง')),
                                      ],
                                      onChanged: (v) {
                                        if (v != null) setState(() => _gender = v);
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('วันเกิด'),
                                InkWell(
                                  onTap: _selectBirthDate,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: PColor.borderStrong),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${_birthDate.day.toString().padLeft(2, '0')}/${_birthDate.month.toString().padLeft(2, '0')}/${_birthDate.year + 543}',
                                          style: const TextStyle(fontSize: 13.5),
                                        ),
                                        const Icon(Icons.calendar_today_outlined, size: 18, color: PColor.primaryColor),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Auto-calculated age
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: PColor.surfaceSubtle,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'อายุ (คำนวณอัตโนมัติ): $_calculatedAge ปี',
                          style: const TextStyle(
                            fontSize: 13,
                            color: PColor.contentColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Address
                      _buildLabel('ที่อยู่ (เลขที่บ้าน ซอย ถนน)'),
                      TextFormField(
                        controller: _addressController,
                        maxLines: 2,
                        decoration: _inputDecoration('เช่น 60 หมู่ 1 บ้านท่าตอน อ.แม่อาย'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Save Button
                ElevatedButton.icon(
                  onPressed: _onSave,
                  icon: const Icon(Icons.save_outlined, color: Colors.white),
                  label: const Text(
                    'บันทึก',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PColor.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
          color: PColor.contentColor,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: PColor.textNeutralColor, fontSize: 13.5),
      filled: true,
      fillColor: Colors.white,
      counterText: '',
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: PColor.borderStrong),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: PColor.borderStrong),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: PColor.primaryColor, width: 1.8),
      ),
    );
  }
}
