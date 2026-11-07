import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/feature/nurse/bloc/village_bloc.dart';
import 'package:ncd_screening_mobile/feature/vhv/bloc/vhv_bloc.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_colors.dart';

class NurseAddEditVhvPage extends StatefulWidget {
  final Nurse nurse;
  final VHV? vhv;
  final String? villageId;

  const NurseAddEditVhvPage({
    super.key,
    required this.nurse,
    this.vhv,
    this.villageId,
  });

  @override
  State<NurseAddEditVhvPage> createState() => _NurseAddEditVhvPageState();
}

class _NurseAddEditVhvPageState extends State<NurseAddEditVhvPage> {
  late final TextEditingController _citizenIdController;
  late final TextEditingController _titleController;
  late final TextEditingController _fnameController;
  late final TextEditingController _lnameController;
  late final TextEditingController _mobileController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  late String _selectedVillageId;
  String _gender = 'หญิง';
  DateTime _birthDate = DateTime(1985, 1, 1);
  bool get _isEdit => widget.vhv != null;

  @override
  void initState() {
    super.initState();
    final v = widget.vhv;
    _selectedVillageId = v?.villageId ?? widget.villageId ?? 'V001';
    _citizenIdController = TextEditingController(text: v?.vhvCitizenId ?? '');
    _titleController = TextEditingController(text: v?.vhvTitle ?? 'นาง');
    _fnameController = TextEditingController(text: v?.vhvFname ?? '');
    _lnameController = TextEditingController(text: v?.vhvLname ?? '');
    _mobileController = TextEditingController(text: v?.vhvMobile ?? '');
    _emailController = TextEditingController(text: v?.vhvEmail ?? '');
    _passwordController = TextEditingController();
    if (v != null) {
      _gender = v.vhvGender;
      _birthDate = v.vhvBirthDate;
    }
  }

  @override
  void dispose() {
    _citizenIdController.dispose();
    _titleController.dispose();
    _fnameController.dispose();
    _lnameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _selectBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate,
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: PColor.primaryColor,
              onPrimary: PColor.neutralColor,
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
    final mobile = _mobileController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // SRS Validations
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
    if (mobile.length != 10 ||
        (!mobile.startsWith('06') &&
            !mobile.startsWith('08') &&
            !mobile.startsWith('09'))) {
      _showError('เบอร์โทรศัพท์ต้องเป็นตัวเลข 10 หลัก ขึ้นต้นด้วย 06, 08, 09');
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      _showError('รูปแบบอีเมลไม่ถูกต้อง');
      return;
    }
    if (!_isEdit && password.isEmpty) {
      _showError('กรุณากำหนดรหัสผ่าน');
      return;
    }
    if (password.isNotEmpty && (password.length < 8 || password.length > 64)) {
      _showError('รหัสผ่านต้องมีความยาว 8-64 ตัวอักษร');
      return;
    }

    final newVhv = VHV(
      vhvId: widget.vhv?.vhvId ?? '',
      vhvCitizenId: citizenId,
      vhvTitle: title.isNotEmpty ? title : (_gender == 'ชาย' ? 'นาย' : 'นาง'),
      vhvFname: fname,
      vhvLname: lname,
      vhvMobile: mobile,
      vhvEmail: email,
      // Empty on edit means "keep current password"; the repository hashes it.
      vhvPassword: password,
      vhvBirthDate: _birthDate,
      vhvGender: _gender,
      vhvAddress:
          widget.vhv?.vhvAddress ?? 'หมู่บ้าน $_selectedVillageId อ.แม่อาย',
      villageId: _selectedVillageId,
    );

    if (_isEdit) {
      context.read<VhvBloc>().add(VhvUpdateRequested(newVhv));
    } else {
      context.read<VhvBloc>().add(VhvAddRequested(newVhv));
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
          tooltip: 'ย้อนกลับ',
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: PColor.neutralColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEdit ? 'แก้ไขข้อมูล อสม.' : 'เพิ่ม อสม.',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: PColor.neutralColor,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Avatar
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: PColor.neutralColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: PColor.primaryLight.withValues(
                        alpha: 0.15,
                      ),
                      child: const Icon(
                        Icons.volunteer_activism_rounded,
                        size: 40,
                        color: PColor.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'รูป อสม. (ไม่บังคับ)',
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
                            icon: const Icon(
                              Icons.image_outlined,
                              size: 18,
                              color: PColor.primaryColor,
                            ),
                            label: Text(
                              _isEdit ? 'เปลี่ยนรูป' : 'แนบรูป',
                              style: const TextStyle(
                                color: PColor.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: PColor.primaryColor,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
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
                  color: PColor.neutralColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Village Selector
                    _buildLabel('หมู่บ้าน'),
                    BlocBuilder<VillageBloc, VillageState>(
                      builder: (context, vState) {
                        final villages = vState.villages.isNotEmpty
                            ? vState.villages
                            : [
                                const Village(
                                  villageId: 'V001',
                                  villageName: 'บ้านท่าตอน',
                                  villageNumber: '1',
                                ),
                                const Village(
                                  villageId: 'V002',
                                  villageName: 'บ้านใหม่หมอกจ๋าม',
                                  villageNumber: '2',
                                ),
                                const Village(
                                  villageId: 'V003',
                                  villageName: 'บ้านห้วยปู',
                                  villageNumber: '3',
                                ),
                                const Village(
                                  villageId: 'V004',
                                  villageName: 'บ้านแม่ฮ่าง',
                                  villageNumber: '4',
                                ),
                                const Village(
                                  villageId: 'V005',
                                  villageName: 'บ้านร่มไทย',
                                  villageNumber: '5',
                                ),
                              ];
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedVillageId,
                              isExpanded: true,
                              items: villages
                                  .map(
                                    (v) => DropdownMenuItem(
                                      value: v.villageId,
                                      child: Text(
                                        'หมู่ ${v.villageNumber} ${v.villageName}',
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _selectedVillageId = val);
                                }
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Citizen ID
                    _buildLabel('เลขบัตรประชาชน (13 หลัก)'),
                    TextFormField(
                      controller: _citizenIdController,
                      keyboardType: TextInputType.number,
                      maxLength: 13,
                      decoration: _inputDecoration(
                        'กรอกเลขบัตรประชาชน 13 หลัก',
                      ),
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _gender,
                                    isExpanded: true,
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'หญิง',
                                        child: Text('หญิง'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'ชาย',
                                        child: Text('ชาย'),
                                      ),
                                    ],
                                    onChanged: (v) {
                                      if (v != null) {
                                        setState(() => _gender = v);
                                      }
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
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${_birthDate.day.toString().padLeft(2, '0')}/${_birthDate.month.toString().padLeft(2, '0')}/${_birthDate.year + 543}',
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                      const Icon(
                                        Icons.calendar_today_outlined,
                                        size: 16,
                                        color: PColor.primaryColor,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Phone Number
                    _buildLabel('เบอร์มือถือ'),
                    TextFormField(
                      controller: _mobileController,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      decoration: _inputDecoration('เช่น 0812345678'),
                    ),
                    const SizedBox(height: 16),

                    // Email
                    _buildLabel('อีเมล'),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _inputDecoration('เช่น vhv01@example.com'),
                    ),
                    const SizedBox(height: 16),

                    // Password
                    _buildLabel(
                      _isEdit
                          ? 'รหัสผ่านใหม่ (ปล่อยว่าง = ไม่เปลี่ยน)'
                          : 'รหัสผ่าน',
                    ),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: _inputDecoration(
                        'กำหนดรหัสผ่าน 8-64 ตัวอักษร',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton.icon(
                onPressed: _onSave,
                icon: const Icon(
                  Icons.save_outlined,
                  color: PColor.neutralColor,
                ),
                label: const Text(
                  'บันทึก',
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
                  elevation: 2,
                ),
              ),
              const SizedBox(height: 20),
            ],
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
      hintStyle: const TextStyle(
        color: PColor.textNeutralColor,
        fontSize: 13.5,
      ),
      filled: true,
      fillColor: PColor.neutralColor,
      counterText: '',
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: PColor.primaryColor, width: 1.8),
      ),
    );
  }
}
