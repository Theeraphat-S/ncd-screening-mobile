// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $VillagesTableTable extends VillagesTable
    with TableInfo<$VillagesTableTable, VillagesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VillagesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _villageIdMeta = const VerificationMeta(
    'villageId',
  );
  @override
  late final GeneratedColumn<String> villageId = GeneratedColumn<String>(
    'village_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _villageNameMeta = const VerificationMeta(
    'villageName',
  );
  @override
  late final GeneratedColumn<String> villageName = GeneratedColumn<String>(
    'village_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _villageNumberMeta = const VerificationMeta(
    'villageNumber',
  );
  @override
  late final GeneratedColumn<String> villageNumber = GeneratedColumn<String>(
    'village_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subdistrictIdMeta = const VerificationMeta(
    'subdistrictId',
  );
  @override
  late final GeneratedColumn<String> subdistrictId = GeneratedColumn<String>(
    'subdistrict_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('SD001'),
  );
  static const VerificationMeta _subdistrictNameMeta = const VerificationMeta(
    'subdistrictName',
  );
  @override
  late final GeneratedColumn<String> subdistrictName = GeneratedColumn<String>(
    'subdistrict_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('ท่าตอน'),
  );
  static const VerificationMeta _districtNameMeta = const VerificationMeta(
    'districtName',
  );
  @override
  late final GeneratedColumn<String> districtName = GeneratedColumn<String>(
    'district_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('แม่อาย'),
  );
  static const VerificationMeta _provinceNameMeta = const VerificationMeta(
    'provinceName',
  );
  @override
  late final GeneratedColumn<String> provinceName = GeneratedColumn<String>(
    'province_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('เชียงใหม่'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    villageId,
    villageName,
    villageNumber,
    subdistrictId,
    subdistrictName,
    districtName,
    provinceName,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'villages';
  @override
  VerificationContext validateIntegrity(
    Insertable<VillagesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('village_id')) {
      context.handle(
        _villageIdMeta,
        villageId.isAcceptableOrUnknown(data['village_id']!, _villageIdMeta),
      );
    } else if (isInserting) {
      context.missing(_villageIdMeta);
    }
    if (data.containsKey('village_name')) {
      context.handle(
        _villageNameMeta,
        villageName.isAcceptableOrUnknown(
          data['village_name']!,
          _villageNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_villageNameMeta);
    }
    if (data.containsKey('village_number')) {
      context.handle(
        _villageNumberMeta,
        villageNumber.isAcceptableOrUnknown(
          data['village_number']!,
          _villageNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_villageNumberMeta);
    }
    if (data.containsKey('subdistrict_id')) {
      context.handle(
        _subdistrictIdMeta,
        subdistrictId.isAcceptableOrUnknown(
          data['subdistrict_id']!,
          _subdistrictIdMeta,
        ),
      );
    }
    if (data.containsKey('subdistrict_name')) {
      context.handle(
        _subdistrictNameMeta,
        subdistrictName.isAcceptableOrUnknown(
          data['subdistrict_name']!,
          _subdistrictNameMeta,
        ),
      );
    }
    if (data.containsKey('district_name')) {
      context.handle(
        _districtNameMeta,
        districtName.isAcceptableOrUnknown(
          data['district_name']!,
          _districtNameMeta,
        ),
      );
    }
    if (data.containsKey('province_name')) {
      context.handle(
        _provinceNameMeta,
        provinceName.isAcceptableOrUnknown(
          data['province_name']!,
          _provinceNameMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {villageId};
  @override
  VillagesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VillagesTableData(
      villageId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}village_id'],
          )!,
      villageName:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}village_name'],
          )!,
      villageNumber:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}village_number'],
          )!,
      subdistrictId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}subdistrict_id'],
          )!,
      subdistrictName:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}subdistrict_name'],
          )!,
      districtName:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}district_name'],
          )!,
      provinceName:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}province_name'],
          )!,
    );
  }

  @override
  $VillagesTableTable createAlias(String alias) {
    return $VillagesTableTable(attachedDatabase, alias);
  }
}

class VillagesTableData extends DataClass
    implements Insertable<VillagesTableData> {
  final String villageId;
  final String villageName;
  final String villageNumber;
  final String subdistrictId;
  final String subdistrictName;
  final String districtName;
  final String provinceName;
  const VillagesTableData({
    required this.villageId,
    required this.villageName,
    required this.villageNumber,
    required this.subdistrictId,
    required this.subdistrictName,
    required this.districtName,
    required this.provinceName,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['village_id'] = Variable<String>(villageId);
    map['village_name'] = Variable<String>(villageName);
    map['village_number'] = Variable<String>(villageNumber);
    map['subdistrict_id'] = Variable<String>(subdistrictId);
    map['subdistrict_name'] = Variable<String>(subdistrictName);
    map['district_name'] = Variable<String>(districtName);
    map['province_name'] = Variable<String>(provinceName);
    return map;
  }

  VillagesTableCompanion toCompanion(bool nullToAbsent) {
    return VillagesTableCompanion(
      villageId: Value(villageId),
      villageName: Value(villageName),
      villageNumber: Value(villageNumber),
      subdistrictId: Value(subdistrictId),
      subdistrictName: Value(subdistrictName),
      districtName: Value(districtName),
      provinceName: Value(provinceName),
    );
  }

  factory VillagesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VillagesTableData(
      villageId: serializer.fromJson<String>(json['villageId']),
      villageName: serializer.fromJson<String>(json['villageName']),
      villageNumber: serializer.fromJson<String>(json['villageNumber']),
      subdistrictId: serializer.fromJson<String>(json['subdistrictId']),
      subdistrictName: serializer.fromJson<String>(json['subdistrictName']),
      districtName: serializer.fromJson<String>(json['districtName']),
      provinceName: serializer.fromJson<String>(json['provinceName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'villageId': serializer.toJson<String>(villageId),
      'villageName': serializer.toJson<String>(villageName),
      'villageNumber': serializer.toJson<String>(villageNumber),
      'subdistrictId': serializer.toJson<String>(subdistrictId),
      'subdistrictName': serializer.toJson<String>(subdistrictName),
      'districtName': serializer.toJson<String>(districtName),
      'provinceName': serializer.toJson<String>(provinceName),
    };
  }

  VillagesTableData copyWith({
    String? villageId,
    String? villageName,
    String? villageNumber,
    String? subdistrictId,
    String? subdistrictName,
    String? districtName,
    String? provinceName,
  }) => VillagesTableData(
    villageId: villageId ?? this.villageId,
    villageName: villageName ?? this.villageName,
    villageNumber: villageNumber ?? this.villageNumber,
    subdistrictId: subdistrictId ?? this.subdistrictId,
    subdistrictName: subdistrictName ?? this.subdistrictName,
    districtName: districtName ?? this.districtName,
    provinceName: provinceName ?? this.provinceName,
  );
  VillagesTableData copyWithCompanion(VillagesTableCompanion data) {
    return VillagesTableData(
      villageId: data.villageId.present ? data.villageId.value : this.villageId,
      villageName:
          data.villageName.present ? data.villageName.value : this.villageName,
      villageNumber:
          data.villageNumber.present
              ? data.villageNumber.value
              : this.villageNumber,
      subdistrictId:
          data.subdistrictId.present
              ? data.subdistrictId.value
              : this.subdistrictId,
      subdistrictName:
          data.subdistrictName.present
              ? data.subdistrictName.value
              : this.subdistrictName,
      districtName:
          data.districtName.present
              ? data.districtName.value
              : this.districtName,
      provinceName:
          data.provinceName.present
              ? data.provinceName.value
              : this.provinceName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VillagesTableData(')
          ..write('villageId: $villageId, ')
          ..write('villageName: $villageName, ')
          ..write('villageNumber: $villageNumber, ')
          ..write('subdistrictId: $subdistrictId, ')
          ..write('subdistrictName: $subdistrictName, ')
          ..write('districtName: $districtName, ')
          ..write('provinceName: $provinceName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    villageId,
    villageName,
    villageNumber,
    subdistrictId,
    subdistrictName,
    districtName,
    provinceName,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VillagesTableData &&
          other.villageId == this.villageId &&
          other.villageName == this.villageName &&
          other.villageNumber == this.villageNumber &&
          other.subdistrictId == this.subdistrictId &&
          other.subdistrictName == this.subdistrictName &&
          other.districtName == this.districtName &&
          other.provinceName == this.provinceName);
}

class VillagesTableCompanion extends UpdateCompanion<VillagesTableData> {
  final Value<String> villageId;
  final Value<String> villageName;
  final Value<String> villageNumber;
  final Value<String> subdistrictId;
  final Value<String> subdistrictName;
  final Value<String> districtName;
  final Value<String> provinceName;
  final Value<int> rowid;
  const VillagesTableCompanion({
    this.villageId = const Value.absent(),
    this.villageName = const Value.absent(),
    this.villageNumber = const Value.absent(),
    this.subdistrictId = const Value.absent(),
    this.subdistrictName = const Value.absent(),
    this.districtName = const Value.absent(),
    this.provinceName = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VillagesTableCompanion.insert({
    required String villageId,
    required String villageName,
    required String villageNumber,
    this.subdistrictId = const Value.absent(),
    this.subdistrictName = const Value.absent(),
    this.districtName = const Value.absent(),
    this.provinceName = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : villageId = Value(villageId),
       villageName = Value(villageName),
       villageNumber = Value(villageNumber);
  static Insertable<VillagesTableData> custom({
    Expression<String>? villageId,
    Expression<String>? villageName,
    Expression<String>? villageNumber,
    Expression<String>? subdistrictId,
    Expression<String>? subdistrictName,
    Expression<String>? districtName,
    Expression<String>? provinceName,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (villageId != null) 'village_id': villageId,
      if (villageName != null) 'village_name': villageName,
      if (villageNumber != null) 'village_number': villageNumber,
      if (subdistrictId != null) 'subdistrict_id': subdistrictId,
      if (subdistrictName != null) 'subdistrict_name': subdistrictName,
      if (districtName != null) 'district_name': districtName,
      if (provinceName != null) 'province_name': provinceName,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VillagesTableCompanion copyWith({
    Value<String>? villageId,
    Value<String>? villageName,
    Value<String>? villageNumber,
    Value<String>? subdistrictId,
    Value<String>? subdistrictName,
    Value<String>? districtName,
    Value<String>? provinceName,
    Value<int>? rowid,
  }) {
    return VillagesTableCompanion(
      villageId: villageId ?? this.villageId,
      villageName: villageName ?? this.villageName,
      villageNumber: villageNumber ?? this.villageNumber,
      subdistrictId: subdistrictId ?? this.subdistrictId,
      subdistrictName: subdistrictName ?? this.subdistrictName,
      districtName: districtName ?? this.districtName,
      provinceName: provinceName ?? this.provinceName,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (villageId.present) {
      map['village_id'] = Variable<String>(villageId.value);
    }
    if (villageName.present) {
      map['village_name'] = Variable<String>(villageName.value);
    }
    if (villageNumber.present) {
      map['village_number'] = Variable<String>(villageNumber.value);
    }
    if (subdistrictId.present) {
      map['subdistrict_id'] = Variable<String>(subdistrictId.value);
    }
    if (subdistrictName.present) {
      map['subdistrict_name'] = Variable<String>(subdistrictName.value);
    }
    if (districtName.present) {
      map['district_name'] = Variable<String>(districtName.value);
    }
    if (provinceName.present) {
      map['province_name'] = Variable<String>(provinceName.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VillagesTableCompanion(')
          ..write('villageId: $villageId, ')
          ..write('villageName: $villageName, ')
          ..write('villageNumber: $villageNumber, ')
          ..write('subdistrictId: $subdistrictId, ')
          ..write('subdistrictName: $subdistrictName, ')
          ..write('districtName: $districtName, ')
          ..write('provinceName: $provinceName, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NursesTableTable extends NursesTable
    with TableInfo<$NursesTableTable, NursesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NursesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _nurseIdMeta = const VerificationMeta(
    'nurseId',
  );
  @override
  late final GeneratedColumn<String> nurseId = GeneratedColumn<String>(
    'nurse_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nurseTitleMeta = const VerificationMeta(
    'nurseTitle',
  );
  @override
  late final GeneratedColumn<String> nurseTitle = GeneratedColumn<String>(
    'nurse_title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nurseFnameMeta = const VerificationMeta(
    'nurseFname',
  );
  @override
  late final GeneratedColumn<String> nurseFname = GeneratedColumn<String>(
    'nurse_fname',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nurseLnameMeta = const VerificationMeta(
    'nurseLname',
  );
  @override
  late final GeneratedColumn<String> nurseLname = GeneratedColumn<String>(
    'nurse_lname',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nurseMobileMeta = const VerificationMeta(
    'nurseMobile',
  );
  @override
  late final GeneratedColumn<String> nurseMobile = GeneratedColumn<String>(
    'nurse_mobile',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nurseEmailMeta = const VerificationMeta(
    'nurseEmail',
  );
  @override
  late final GeneratedColumn<String> nurseEmail = GeneratedColumn<String>(
    'nurse_email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nursePasswordMeta = const VerificationMeta(
    'nursePassword',
  );
  @override
  late final GeneratedColumn<String> nursePassword = GeneratedColumn<String>(
    'nurse_password',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nurseGenderMeta = const VerificationMeta(
    'nurseGender',
  );
  @override
  late final GeneratedColumn<String> nurseGender = GeneratedColumn<String>(
    'nurse_gender',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nurseBirthDateMeta = const VerificationMeta(
    'nurseBirthDate',
  );
  @override
  late final GeneratedColumn<DateTime> nurseBirthDate =
      GeneratedColumn<DateTime>(
        'nurse_birth_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _nurseImgMeta = const VerificationMeta(
    'nurseImg',
  );
  @override
  late final GeneratedColumn<String> nurseImg = GeneratedColumn<String>(
    'nurse_img',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _subdistrictIdMeta = const VerificationMeta(
    'subdistrictId',
  );
  @override
  late final GeneratedColumn<String> subdistrictId = GeneratedColumn<String>(
    'subdistrict_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('SD001'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    nurseId,
    nurseTitle,
    nurseFname,
    nurseLname,
    nurseMobile,
    nurseEmail,
    nursePassword,
    nurseGender,
    nurseBirthDate,
    nurseImg,
    subdistrictId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'nurses';
  @override
  VerificationContext validateIntegrity(
    Insertable<NursesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('nurse_id')) {
      context.handle(
        _nurseIdMeta,
        nurseId.isAcceptableOrUnknown(data['nurse_id']!, _nurseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_nurseIdMeta);
    }
    if (data.containsKey('nurse_title')) {
      context.handle(
        _nurseTitleMeta,
        nurseTitle.isAcceptableOrUnknown(data['nurse_title']!, _nurseTitleMeta),
      );
    } else if (isInserting) {
      context.missing(_nurseTitleMeta);
    }
    if (data.containsKey('nurse_fname')) {
      context.handle(
        _nurseFnameMeta,
        nurseFname.isAcceptableOrUnknown(data['nurse_fname']!, _nurseFnameMeta),
      );
    } else if (isInserting) {
      context.missing(_nurseFnameMeta);
    }
    if (data.containsKey('nurse_lname')) {
      context.handle(
        _nurseLnameMeta,
        nurseLname.isAcceptableOrUnknown(data['nurse_lname']!, _nurseLnameMeta),
      );
    } else if (isInserting) {
      context.missing(_nurseLnameMeta);
    }
    if (data.containsKey('nurse_mobile')) {
      context.handle(
        _nurseMobileMeta,
        nurseMobile.isAcceptableOrUnknown(
          data['nurse_mobile']!,
          _nurseMobileMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nurseMobileMeta);
    }
    if (data.containsKey('nurse_email')) {
      context.handle(
        _nurseEmailMeta,
        nurseEmail.isAcceptableOrUnknown(data['nurse_email']!, _nurseEmailMeta),
      );
    } else if (isInserting) {
      context.missing(_nurseEmailMeta);
    }
    if (data.containsKey('nurse_password')) {
      context.handle(
        _nursePasswordMeta,
        nursePassword.isAcceptableOrUnknown(
          data['nurse_password']!,
          _nursePasswordMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nursePasswordMeta);
    }
    if (data.containsKey('nurse_gender')) {
      context.handle(
        _nurseGenderMeta,
        nurseGender.isAcceptableOrUnknown(
          data['nurse_gender']!,
          _nurseGenderMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nurseGenderMeta);
    }
    if (data.containsKey('nurse_birth_date')) {
      context.handle(
        _nurseBirthDateMeta,
        nurseBirthDate.isAcceptableOrUnknown(
          data['nurse_birth_date']!,
          _nurseBirthDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nurseBirthDateMeta);
    }
    if (data.containsKey('nurse_img')) {
      context.handle(
        _nurseImgMeta,
        nurseImg.isAcceptableOrUnknown(data['nurse_img']!, _nurseImgMeta),
      );
    }
    if (data.containsKey('subdistrict_id')) {
      context.handle(
        _subdistrictIdMeta,
        subdistrictId.isAcceptableOrUnknown(
          data['subdistrict_id']!,
          _subdistrictIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {nurseId};
  @override
  NursesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NursesTableData(
      nurseId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}nurse_id'],
          )!,
      nurseTitle:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}nurse_title'],
          )!,
      nurseFname:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}nurse_fname'],
          )!,
      nurseLname:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}nurse_lname'],
          )!,
      nurseMobile:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}nurse_mobile'],
          )!,
      nurseEmail:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}nurse_email'],
          )!,
      nursePassword:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}nurse_password'],
          )!,
      nurseGender:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}nurse_gender'],
          )!,
      nurseBirthDate:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}nurse_birth_date'],
          )!,
      nurseImg: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nurse_img'],
      ),
      subdistrictId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}subdistrict_id'],
          )!,
    );
  }

  @override
  $NursesTableTable createAlias(String alias) {
    return $NursesTableTable(attachedDatabase, alias);
  }
}

class NursesTableData extends DataClass implements Insertable<NursesTableData> {
  final String nurseId;
  final String nurseTitle;
  final String nurseFname;
  final String nurseLname;
  final String nurseMobile;
  final String nurseEmail;
  final String nursePassword;
  final String nurseGender;
  final DateTime nurseBirthDate;
  final String? nurseImg;
  final String subdistrictId;
  const NursesTableData({
    required this.nurseId,
    required this.nurseTitle,
    required this.nurseFname,
    required this.nurseLname,
    required this.nurseMobile,
    required this.nurseEmail,
    required this.nursePassword,
    required this.nurseGender,
    required this.nurseBirthDate,
    this.nurseImg,
    required this.subdistrictId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['nurse_id'] = Variable<String>(nurseId);
    map['nurse_title'] = Variable<String>(nurseTitle);
    map['nurse_fname'] = Variable<String>(nurseFname);
    map['nurse_lname'] = Variable<String>(nurseLname);
    map['nurse_mobile'] = Variable<String>(nurseMobile);
    map['nurse_email'] = Variable<String>(nurseEmail);
    map['nurse_password'] = Variable<String>(nursePassword);
    map['nurse_gender'] = Variable<String>(nurseGender);
    map['nurse_birth_date'] = Variable<DateTime>(nurseBirthDate);
    if (!nullToAbsent || nurseImg != null) {
      map['nurse_img'] = Variable<String>(nurseImg);
    }
    map['subdistrict_id'] = Variable<String>(subdistrictId);
    return map;
  }

  NursesTableCompanion toCompanion(bool nullToAbsent) {
    return NursesTableCompanion(
      nurseId: Value(nurseId),
      nurseTitle: Value(nurseTitle),
      nurseFname: Value(nurseFname),
      nurseLname: Value(nurseLname),
      nurseMobile: Value(nurseMobile),
      nurseEmail: Value(nurseEmail),
      nursePassword: Value(nursePassword),
      nurseGender: Value(nurseGender),
      nurseBirthDate: Value(nurseBirthDate),
      nurseImg:
          nurseImg == null && nullToAbsent
              ? const Value.absent()
              : Value(nurseImg),
      subdistrictId: Value(subdistrictId),
    );
  }

  factory NursesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NursesTableData(
      nurseId: serializer.fromJson<String>(json['nurseId']),
      nurseTitle: serializer.fromJson<String>(json['nurseTitle']),
      nurseFname: serializer.fromJson<String>(json['nurseFname']),
      nurseLname: serializer.fromJson<String>(json['nurseLname']),
      nurseMobile: serializer.fromJson<String>(json['nurseMobile']),
      nurseEmail: serializer.fromJson<String>(json['nurseEmail']),
      nursePassword: serializer.fromJson<String>(json['nursePassword']),
      nurseGender: serializer.fromJson<String>(json['nurseGender']),
      nurseBirthDate: serializer.fromJson<DateTime>(json['nurseBirthDate']),
      nurseImg: serializer.fromJson<String?>(json['nurseImg']),
      subdistrictId: serializer.fromJson<String>(json['subdistrictId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'nurseId': serializer.toJson<String>(nurseId),
      'nurseTitle': serializer.toJson<String>(nurseTitle),
      'nurseFname': serializer.toJson<String>(nurseFname),
      'nurseLname': serializer.toJson<String>(nurseLname),
      'nurseMobile': serializer.toJson<String>(nurseMobile),
      'nurseEmail': serializer.toJson<String>(nurseEmail),
      'nursePassword': serializer.toJson<String>(nursePassword),
      'nurseGender': serializer.toJson<String>(nurseGender),
      'nurseBirthDate': serializer.toJson<DateTime>(nurseBirthDate),
      'nurseImg': serializer.toJson<String?>(nurseImg),
      'subdistrictId': serializer.toJson<String>(subdistrictId),
    };
  }

  NursesTableData copyWith({
    String? nurseId,
    String? nurseTitle,
    String? nurseFname,
    String? nurseLname,
    String? nurseMobile,
    String? nurseEmail,
    String? nursePassword,
    String? nurseGender,
    DateTime? nurseBirthDate,
    Value<String?> nurseImg = const Value.absent(),
    String? subdistrictId,
  }) => NursesTableData(
    nurseId: nurseId ?? this.nurseId,
    nurseTitle: nurseTitle ?? this.nurseTitle,
    nurseFname: nurseFname ?? this.nurseFname,
    nurseLname: nurseLname ?? this.nurseLname,
    nurseMobile: nurseMobile ?? this.nurseMobile,
    nurseEmail: nurseEmail ?? this.nurseEmail,
    nursePassword: nursePassword ?? this.nursePassword,
    nurseGender: nurseGender ?? this.nurseGender,
    nurseBirthDate: nurseBirthDate ?? this.nurseBirthDate,
    nurseImg: nurseImg.present ? nurseImg.value : this.nurseImg,
    subdistrictId: subdistrictId ?? this.subdistrictId,
  );
  NursesTableData copyWithCompanion(NursesTableCompanion data) {
    return NursesTableData(
      nurseId: data.nurseId.present ? data.nurseId.value : this.nurseId,
      nurseTitle:
          data.nurseTitle.present ? data.nurseTitle.value : this.nurseTitle,
      nurseFname:
          data.nurseFname.present ? data.nurseFname.value : this.nurseFname,
      nurseLname:
          data.nurseLname.present ? data.nurseLname.value : this.nurseLname,
      nurseMobile:
          data.nurseMobile.present ? data.nurseMobile.value : this.nurseMobile,
      nurseEmail:
          data.nurseEmail.present ? data.nurseEmail.value : this.nurseEmail,
      nursePassword:
          data.nursePassword.present
              ? data.nursePassword.value
              : this.nursePassword,
      nurseGender:
          data.nurseGender.present ? data.nurseGender.value : this.nurseGender,
      nurseBirthDate:
          data.nurseBirthDate.present
              ? data.nurseBirthDate.value
              : this.nurseBirthDate,
      nurseImg: data.nurseImg.present ? data.nurseImg.value : this.nurseImg,
      subdistrictId:
          data.subdistrictId.present
              ? data.subdistrictId.value
              : this.subdistrictId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NursesTableData(')
          ..write('nurseId: $nurseId, ')
          ..write('nurseTitle: $nurseTitle, ')
          ..write('nurseFname: $nurseFname, ')
          ..write('nurseLname: $nurseLname, ')
          ..write('nurseMobile: $nurseMobile, ')
          ..write('nurseEmail: $nurseEmail, ')
          ..write('nursePassword: $nursePassword, ')
          ..write('nurseGender: $nurseGender, ')
          ..write('nurseBirthDate: $nurseBirthDate, ')
          ..write('nurseImg: $nurseImg, ')
          ..write('subdistrictId: $subdistrictId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    nurseId,
    nurseTitle,
    nurseFname,
    nurseLname,
    nurseMobile,
    nurseEmail,
    nursePassword,
    nurseGender,
    nurseBirthDate,
    nurseImg,
    subdistrictId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NursesTableData &&
          other.nurseId == this.nurseId &&
          other.nurseTitle == this.nurseTitle &&
          other.nurseFname == this.nurseFname &&
          other.nurseLname == this.nurseLname &&
          other.nurseMobile == this.nurseMobile &&
          other.nurseEmail == this.nurseEmail &&
          other.nursePassword == this.nursePassword &&
          other.nurseGender == this.nurseGender &&
          other.nurseBirthDate == this.nurseBirthDate &&
          other.nurseImg == this.nurseImg &&
          other.subdistrictId == this.subdistrictId);
}

class NursesTableCompanion extends UpdateCompanion<NursesTableData> {
  final Value<String> nurseId;
  final Value<String> nurseTitle;
  final Value<String> nurseFname;
  final Value<String> nurseLname;
  final Value<String> nurseMobile;
  final Value<String> nurseEmail;
  final Value<String> nursePassword;
  final Value<String> nurseGender;
  final Value<DateTime> nurseBirthDate;
  final Value<String?> nurseImg;
  final Value<String> subdistrictId;
  final Value<int> rowid;
  const NursesTableCompanion({
    this.nurseId = const Value.absent(),
    this.nurseTitle = const Value.absent(),
    this.nurseFname = const Value.absent(),
    this.nurseLname = const Value.absent(),
    this.nurseMobile = const Value.absent(),
    this.nurseEmail = const Value.absent(),
    this.nursePassword = const Value.absent(),
    this.nurseGender = const Value.absent(),
    this.nurseBirthDate = const Value.absent(),
    this.nurseImg = const Value.absent(),
    this.subdistrictId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NursesTableCompanion.insert({
    required String nurseId,
    required String nurseTitle,
    required String nurseFname,
    required String nurseLname,
    required String nurseMobile,
    required String nurseEmail,
    required String nursePassword,
    required String nurseGender,
    required DateTime nurseBirthDate,
    this.nurseImg = const Value.absent(),
    this.subdistrictId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : nurseId = Value(nurseId),
       nurseTitle = Value(nurseTitle),
       nurseFname = Value(nurseFname),
       nurseLname = Value(nurseLname),
       nurseMobile = Value(nurseMobile),
       nurseEmail = Value(nurseEmail),
       nursePassword = Value(nursePassword),
       nurseGender = Value(nurseGender),
       nurseBirthDate = Value(nurseBirthDate);
  static Insertable<NursesTableData> custom({
    Expression<String>? nurseId,
    Expression<String>? nurseTitle,
    Expression<String>? nurseFname,
    Expression<String>? nurseLname,
    Expression<String>? nurseMobile,
    Expression<String>? nurseEmail,
    Expression<String>? nursePassword,
    Expression<String>? nurseGender,
    Expression<DateTime>? nurseBirthDate,
    Expression<String>? nurseImg,
    Expression<String>? subdistrictId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (nurseId != null) 'nurse_id': nurseId,
      if (nurseTitle != null) 'nurse_title': nurseTitle,
      if (nurseFname != null) 'nurse_fname': nurseFname,
      if (nurseLname != null) 'nurse_lname': nurseLname,
      if (nurseMobile != null) 'nurse_mobile': nurseMobile,
      if (nurseEmail != null) 'nurse_email': nurseEmail,
      if (nursePassword != null) 'nurse_password': nursePassword,
      if (nurseGender != null) 'nurse_gender': nurseGender,
      if (nurseBirthDate != null) 'nurse_birth_date': nurseBirthDate,
      if (nurseImg != null) 'nurse_img': nurseImg,
      if (subdistrictId != null) 'subdistrict_id': subdistrictId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NursesTableCompanion copyWith({
    Value<String>? nurseId,
    Value<String>? nurseTitle,
    Value<String>? nurseFname,
    Value<String>? nurseLname,
    Value<String>? nurseMobile,
    Value<String>? nurseEmail,
    Value<String>? nursePassword,
    Value<String>? nurseGender,
    Value<DateTime>? nurseBirthDate,
    Value<String?>? nurseImg,
    Value<String>? subdistrictId,
    Value<int>? rowid,
  }) {
    return NursesTableCompanion(
      nurseId: nurseId ?? this.nurseId,
      nurseTitle: nurseTitle ?? this.nurseTitle,
      nurseFname: nurseFname ?? this.nurseFname,
      nurseLname: nurseLname ?? this.nurseLname,
      nurseMobile: nurseMobile ?? this.nurseMobile,
      nurseEmail: nurseEmail ?? this.nurseEmail,
      nursePassword: nursePassword ?? this.nursePassword,
      nurseGender: nurseGender ?? this.nurseGender,
      nurseBirthDate: nurseBirthDate ?? this.nurseBirthDate,
      nurseImg: nurseImg ?? this.nurseImg,
      subdistrictId: subdistrictId ?? this.subdistrictId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (nurseId.present) {
      map['nurse_id'] = Variable<String>(nurseId.value);
    }
    if (nurseTitle.present) {
      map['nurse_title'] = Variable<String>(nurseTitle.value);
    }
    if (nurseFname.present) {
      map['nurse_fname'] = Variable<String>(nurseFname.value);
    }
    if (nurseLname.present) {
      map['nurse_lname'] = Variable<String>(nurseLname.value);
    }
    if (nurseMobile.present) {
      map['nurse_mobile'] = Variable<String>(nurseMobile.value);
    }
    if (nurseEmail.present) {
      map['nurse_email'] = Variable<String>(nurseEmail.value);
    }
    if (nursePassword.present) {
      map['nurse_password'] = Variable<String>(nursePassword.value);
    }
    if (nurseGender.present) {
      map['nurse_gender'] = Variable<String>(nurseGender.value);
    }
    if (nurseBirthDate.present) {
      map['nurse_birth_date'] = Variable<DateTime>(nurseBirthDate.value);
    }
    if (nurseImg.present) {
      map['nurse_img'] = Variable<String>(nurseImg.value);
    }
    if (subdistrictId.present) {
      map['subdistrict_id'] = Variable<String>(subdistrictId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NursesTableCompanion(')
          ..write('nurseId: $nurseId, ')
          ..write('nurseTitle: $nurseTitle, ')
          ..write('nurseFname: $nurseFname, ')
          ..write('nurseLname: $nurseLname, ')
          ..write('nurseMobile: $nurseMobile, ')
          ..write('nurseEmail: $nurseEmail, ')
          ..write('nursePassword: $nursePassword, ')
          ..write('nurseGender: $nurseGender, ')
          ..write('nurseBirthDate: $nurseBirthDate, ')
          ..write('nurseImg: $nurseImg, ')
          ..write('subdistrictId: $subdistrictId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VhvsTableTable extends VhvsTable
    with TableInfo<$VhvsTableTable, VhvsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VhvsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _vhvIdMeta = const VerificationMeta('vhvId');
  @override
  late final GeneratedColumn<String> vhvId = GeneratedColumn<String>(
    'vhv_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vhvCitizenIdMeta = const VerificationMeta(
    'vhvCitizenId',
  );
  @override
  late final GeneratedColumn<String> vhvCitizenId = GeneratedColumn<String>(
    'vhv_citizen_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vhvTitleMeta = const VerificationMeta(
    'vhvTitle',
  );
  @override
  late final GeneratedColumn<String> vhvTitle = GeneratedColumn<String>(
    'vhv_title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vhvFnameMeta = const VerificationMeta(
    'vhvFname',
  );
  @override
  late final GeneratedColumn<String> vhvFname = GeneratedColumn<String>(
    'vhv_fname',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vhvLnameMeta = const VerificationMeta(
    'vhvLname',
  );
  @override
  late final GeneratedColumn<String> vhvLname = GeneratedColumn<String>(
    'vhv_lname',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vhvMobileMeta = const VerificationMeta(
    'vhvMobile',
  );
  @override
  late final GeneratedColumn<String> vhvMobile = GeneratedColumn<String>(
    'vhv_mobile',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vhvEmailMeta = const VerificationMeta(
    'vhvEmail',
  );
  @override
  late final GeneratedColumn<String> vhvEmail = GeneratedColumn<String>(
    'vhv_email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vhvPasswordMeta = const VerificationMeta(
    'vhvPassword',
  );
  @override
  late final GeneratedColumn<String> vhvPassword = GeneratedColumn<String>(
    'vhv_password',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vhvBirthDateMeta = const VerificationMeta(
    'vhvBirthDate',
  );
  @override
  late final GeneratedColumn<DateTime> vhvBirthDate = GeneratedColumn<DateTime>(
    'vhv_birth_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vhvGenderMeta = const VerificationMeta(
    'vhvGender',
  );
  @override
  late final GeneratedColumn<String> vhvGender = GeneratedColumn<String>(
    'vhv_gender',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vhvAddressMeta = const VerificationMeta(
    'vhvAddress',
  );
  @override
  late final GeneratedColumn<String> vhvAddress = GeneratedColumn<String>(
    'vhv_address',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vhvImgMeta = const VerificationMeta('vhvImg');
  @override
  late final GeneratedColumn<String> vhvImg = GeneratedColumn<String>(
    'vhv_img',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _villageIdMeta = const VerificationMeta(
    'villageId',
  );
  @override
  late final GeneratedColumn<String> villageId = GeneratedColumn<String>(
    'village_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    vhvId,
    vhvCitizenId,
    vhvTitle,
    vhvFname,
    vhvLname,
    vhvMobile,
    vhvEmail,
    vhvPassword,
    vhvBirthDate,
    vhvGender,
    vhvAddress,
    vhvImg,
    villageId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vhvs';
  @override
  VerificationContext validateIntegrity(
    Insertable<VhvsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('vhv_id')) {
      context.handle(
        _vhvIdMeta,
        vhvId.isAcceptableOrUnknown(data['vhv_id']!, _vhvIdMeta),
      );
    } else if (isInserting) {
      context.missing(_vhvIdMeta);
    }
    if (data.containsKey('vhv_citizen_id')) {
      context.handle(
        _vhvCitizenIdMeta,
        vhvCitizenId.isAcceptableOrUnknown(
          data['vhv_citizen_id']!,
          _vhvCitizenIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_vhvCitizenIdMeta);
    }
    if (data.containsKey('vhv_title')) {
      context.handle(
        _vhvTitleMeta,
        vhvTitle.isAcceptableOrUnknown(data['vhv_title']!, _vhvTitleMeta),
      );
    } else if (isInserting) {
      context.missing(_vhvTitleMeta);
    }
    if (data.containsKey('vhv_fname')) {
      context.handle(
        _vhvFnameMeta,
        vhvFname.isAcceptableOrUnknown(data['vhv_fname']!, _vhvFnameMeta),
      );
    } else if (isInserting) {
      context.missing(_vhvFnameMeta);
    }
    if (data.containsKey('vhv_lname')) {
      context.handle(
        _vhvLnameMeta,
        vhvLname.isAcceptableOrUnknown(data['vhv_lname']!, _vhvLnameMeta),
      );
    } else if (isInserting) {
      context.missing(_vhvLnameMeta);
    }
    if (data.containsKey('vhv_mobile')) {
      context.handle(
        _vhvMobileMeta,
        vhvMobile.isAcceptableOrUnknown(data['vhv_mobile']!, _vhvMobileMeta),
      );
    } else if (isInserting) {
      context.missing(_vhvMobileMeta);
    }
    if (data.containsKey('vhv_email')) {
      context.handle(
        _vhvEmailMeta,
        vhvEmail.isAcceptableOrUnknown(data['vhv_email']!, _vhvEmailMeta),
      );
    } else if (isInserting) {
      context.missing(_vhvEmailMeta);
    }
    if (data.containsKey('vhv_password')) {
      context.handle(
        _vhvPasswordMeta,
        vhvPassword.isAcceptableOrUnknown(
          data['vhv_password']!,
          _vhvPasswordMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_vhvPasswordMeta);
    }
    if (data.containsKey('vhv_birth_date')) {
      context.handle(
        _vhvBirthDateMeta,
        vhvBirthDate.isAcceptableOrUnknown(
          data['vhv_birth_date']!,
          _vhvBirthDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_vhvBirthDateMeta);
    }
    if (data.containsKey('vhv_gender')) {
      context.handle(
        _vhvGenderMeta,
        vhvGender.isAcceptableOrUnknown(data['vhv_gender']!, _vhvGenderMeta),
      );
    } else if (isInserting) {
      context.missing(_vhvGenderMeta);
    }
    if (data.containsKey('vhv_address')) {
      context.handle(
        _vhvAddressMeta,
        vhvAddress.isAcceptableOrUnknown(data['vhv_address']!, _vhvAddressMeta),
      );
    } else if (isInserting) {
      context.missing(_vhvAddressMeta);
    }
    if (data.containsKey('vhv_img')) {
      context.handle(
        _vhvImgMeta,
        vhvImg.isAcceptableOrUnknown(data['vhv_img']!, _vhvImgMeta),
      );
    }
    if (data.containsKey('village_id')) {
      context.handle(
        _villageIdMeta,
        villageId.isAcceptableOrUnknown(data['village_id']!, _villageIdMeta),
      );
    } else if (isInserting) {
      context.missing(_villageIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {vhvId};
  @override
  VhvsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VhvsTableData(
      vhvId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}vhv_id'],
          )!,
      vhvCitizenId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}vhv_citizen_id'],
          )!,
      vhvTitle:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}vhv_title'],
          )!,
      vhvFname:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}vhv_fname'],
          )!,
      vhvLname:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}vhv_lname'],
          )!,
      vhvMobile:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}vhv_mobile'],
          )!,
      vhvEmail:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}vhv_email'],
          )!,
      vhvPassword:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}vhv_password'],
          )!,
      vhvBirthDate:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}vhv_birth_date'],
          )!,
      vhvGender:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}vhv_gender'],
          )!,
      vhvAddress:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}vhv_address'],
          )!,
      vhvImg: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vhv_img'],
      ),
      villageId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}village_id'],
          )!,
    );
  }

  @override
  $VhvsTableTable createAlias(String alias) {
    return $VhvsTableTable(attachedDatabase, alias);
  }
}

class VhvsTableData extends DataClass implements Insertable<VhvsTableData> {
  final String vhvId;
  final String vhvCitizenId;
  final String vhvTitle;
  final String vhvFname;
  final String vhvLname;
  final String vhvMobile;
  final String vhvEmail;
  final String vhvPassword;
  final DateTime vhvBirthDate;
  final String vhvGender;
  final String vhvAddress;
  final String? vhvImg;
  final String villageId;
  const VhvsTableData({
    required this.vhvId,
    required this.vhvCitizenId,
    required this.vhvTitle,
    required this.vhvFname,
    required this.vhvLname,
    required this.vhvMobile,
    required this.vhvEmail,
    required this.vhvPassword,
    required this.vhvBirthDate,
    required this.vhvGender,
    required this.vhvAddress,
    this.vhvImg,
    required this.villageId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['vhv_id'] = Variable<String>(vhvId);
    map['vhv_citizen_id'] = Variable<String>(vhvCitizenId);
    map['vhv_title'] = Variable<String>(vhvTitle);
    map['vhv_fname'] = Variable<String>(vhvFname);
    map['vhv_lname'] = Variable<String>(vhvLname);
    map['vhv_mobile'] = Variable<String>(vhvMobile);
    map['vhv_email'] = Variable<String>(vhvEmail);
    map['vhv_password'] = Variable<String>(vhvPassword);
    map['vhv_birth_date'] = Variable<DateTime>(vhvBirthDate);
    map['vhv_gender'] = Variable<String>(vhvGender);
    map['vhv_address'] = Variable<String>(vhvAddress);
    if (!nullToAbsent || vhvImg != null) {
      map['vhv_img'] = Variable<String>(vhvImg);
    }
    map['village_id'] = Variable<String>(villageId);
    return map;
  }

  VhvsTableCompanion toCompanion(bool nullToAbsent) {
    return VhvsTableCompanion(
      vhvId: Value(vhvId),
      vhvCitizenId: Value(vhvCitizenId),
      vhvTitle: Value(vhvTitle),
      vhvFname: Value(vhvFname),
      vhvLname: Value(vhvLname),
      vhvMobile: Value(vhvMobile),
      vhvEmail: Value(vhvEmail),
      vhvPassword: Value(vhvPassword),
      vhvBirthDate: Value(vhvBirthDate),
      vhvGender: Value(vhvGender),
      vhvAddress: Value(vhvAddress),
      vhvImg:
          vhvImg == null && nullToAbsent ? const Value.absent() : Value(vhvImg),
      villageId: Value(villageId),
    );
  }

  factory VhvsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VhvsTableData(
      vhvId: serializer.fromJson<String>(json['vhvId']),
      vhvCitizenId: serializer.fromJson<String>(json['vhvCitizenId']),
      vhvTitle: serializer.fromJson<String>(json['vhvTitle']),
      vhvFname: serializer.fromJson<String>(json['vhvFname']),
      vhvLname: serializer.fromJson<String>(json['vhvLname']),
      vhvMobile: serializer.fromJson<String>(json['vhvMobile']),
      vhvEmail: serializer.fromJson<String>(json['vhvEmail']),
      vhvPassword: serializer.fromJson<String>(json['vhvPassword']),
      vhvBirthDate: serializer.fromJson<DateTime>(json['vhvBirthDate']),
      vhvGender: serializer.fromJson<String>(json['vhvGender']),
      vhvAddress: serializer.fromJson<String>(json['vhvAddress']),
      vhvImg: serializer.fromJson<String?>(json['vhvImg']),
      villageId: serializer.fromJson<String>(json['villageId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'vhvId': serializer.toJson<String>(vhvId),
      'vhvCitizenId': serializer.toJson<String>(vhvCitizenId),
      'vhvTitle': serializer.toJson<String>(vhvTitle),
      'vhvFname': serializer.toJson<String>(vhvFname),
      'vhvLname': serializer.toJson<String>(vhvLname),
      'vhvMobile': serializer.toJson<String>(vhvMobile),
      'vhvEmail': serializer.toJson<String>(vhvEmail),
      'vhvPassword': serializer.toJson<String>(vhvPassword),
      'vhvBirthDate': serializer.toJson<DateTime>(vhvBirthDate),
      'vhvGender': serializer.toJson<String>(vhvGender),
      'vhvAddress': serializer.toJson<String>(vhvAddress),
      'vhvImg': serializer.toJson<String?>(vhvImg),
      'villageId': serializer.toJson<String>(villageId),
    };
  }

  VhvsTableData copyWith({
    String? vhvId,
    String? vhvCitizenId,
    String? vhvTitle,
    String? vhvFname,
    String? vhvLname,
    String? vhvMobile,
    String? vhvEmail,
    String? vhvPassword,
    DateTime? vhvBirthDate,
    String? vhvGender,
    String? vhvAddress,
    Value<String?> vhvImg = const Value.absent(),
    String? villageId,
  }) => VhvsTableData(
    vhvId: vhvId ?? this.vhvId,
    vhvCitizenId: vhvCitizenId ?? this.vhvCitizenId,
    vhvTitle: vhvTitle ?? this.vhvTitle,
    vhvFname: vhvFname ?? this.vhvFname,
    vhvLname: vhvLname ?? this.vhvLname,
    vhvMobile: vhvMobile ?? this.vhvMobile,
    vhvEmail: vhvEmail ?? this.vhvEmail,
    vhvPassword: vhvPassword ?? this.vhvPassword,
    vhvBirthDate: vhvBirthDate ?? this.vhvBirthDate,
    vhvGender: vhvGender ?? this.vhvGender,
    vhvAddress: vhvAddress ?? this.vhvAddress,
    vhvImg: vhvImg.present ? vhvImg.value : this.vhvImg,
    villageId: villageId ?? this.villageId,
  );
  VhvsTableData copyWithCompanion(VhvsTableCompanion data) {
    return VhvsTableData(
      vhvId: data.vhvId.present ? data.vhvId.value : this.vhvId,
      vhvCitizenId:
          data.vhvCitizenId.present
              ? data.vhvCitizenId.value
              : this.vhvCitizenId,
      vhvTitle: data.vhvTitle.present ? data.vhvTitle.value : this.vhvTitle,
      vhvFname: data.vhvFname.present ? data.vhvFname.value : this.vhvFname,
      vhvLname: data.vhvLname.present ? data.vhvLname.value : this.vhvLname,
      vhvMobile: data.vhvMobile.present ? data.vhvMobile.value : this.vhvMobile,
      vhvEmail: data.vhvEmail.present ? data.vhvEmail.value : this.vhvEmail,
      vhvPassword:
          data.vhvPassword.present ? data.vhvPassword.value : this.vhvPassword,
      vhvBirthDate:
          data.vhvBirthDate.present
              ? data.vhvBirthDate.value
              : this.vhvBirthDate,
      vhvGender: data.vhvGender.present ? data.vhvGender.value : this.vhvGender,
      vhvAddress:
          data.vhvAddress.present ? data.vhvAddress.value : this.vhvAddress,
      vhvImg: data.vhvImg.present ? data.vhvImg.value : this.vhvImg,
      villageId: data.villageId.present ? data.villageId.value : this.villageId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VhvsTableData(')
          ..write('vhvId: $vhvId, ')
          ..write('vhvCitizenId: $vhvCitizenId, ')
          ..write('vhvTitle: $vhvTitle, ')
          ..write('vhvFname: $vhvFname, ')
          ..write('vhvLname: $vhvLname, ')
          ..write('vhvMobile: $vhvMobile, ')
          ..write('vhvEmail: $vhvEmail, ')
          ..write('vhvPassword: $vhvPassword, ')
          ..write('vhvBirthDate: $vhvBirthDate, ')
          ..write('vhvGender: $vhvGender, ')
          ..write('vhvAddress: $vhvAddress, ')
          ..write('vhvImg: $vhvImg, ')
          ..write('villageId: $villageId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    vhvId,
    vhvCitizenId,
    vhvTitle,
    vhvFname,
    vhvLname,
    vhvMobile,
    vhvEmail,
    vhvPassword,
    vhvBirthDate,
    vhvGender,
    vhvAddress,
    vhvImg,
    villageId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VhvsTableData &&
          other.vhvId == this.vhvId &&
          other.vhvCitizenId == this.vhvCitizenId &&
          other.vhvTitle == this.vhvTitle &&
          other.vhvFname == this.vhvFname &&
          other.vhvLname == this.vhvLname &&
          other.vhvMobile == this.vhvMobile &&
          other.vhvEmail == this.vhvEmail &&
          other.vhvPassword == this.vhvPassword &&
          other.vhvBirthDate == this.vhvBirthDate &&
          other.vhvGender == this.vhvGender &&
          other.vhvAddress == this.vhvAddress &&
          other.vhvImg == this.vhvImg &&
          other.villageId == this.villageId);
}

class VhvsTableCompanion extends UpdateCompanion<VhvsTableData> {
  final Value<String> vhvId;
  final Value<String> vhvCitizenId;
  final Value<String> vhvTitle;
  final Value<String> vhvFname;
  final Value<String> vhvLname;
  final Value<String> vhvMobile;
  final Value<String> vhvEmail;
  final Value<String> vhvPassword;
  final Value<DateTime> vhvBirthDate;
  final Value<String> vhvGender;
  final Value<String> vhvAddress;
  final Value<String?> vhvImg;
  final Value<String> villageId;
  final Value<int> rowid;
  const VhvsTableCompanion({
    this.vhvId = const Value.absent(),
    this.vhvCitizenId = const Value.absent(),
    this.vhvTitle = const Value.absent(),
    this.vhvFname = const Value.absent(),
    this.vhvLname = const Value.absent(),
    this.vhvMobile = const Value.absent(),
    this.vhvEmail = const Value.absent(),
    this.vhvPassword = const Value.absent(),
    this.vhvBirthDate = const Value.absent(),
    this.vhvGender = const Value.absent(),
    this.vhvAddress = const Value.absent(),
    this.vhvImg = const Value.absent(),
    this.villageId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VhvsTableCompanion.insert({
    required String vhvId,
    required String vhvCitizenId,
    required String vhvTitle,
    required String vhvFname,
    required String vhvLname,
    required String vhvMobile,
    required String vhvEmail,
    required String vhvPassword,
    required DateTime vhvBirthDate,
    required String vhvGender,
    required String vhvAddress,
    this.vhvImg = const Value.absent(),
    required String villageId,
    this.rowid = const Value.absent(),
  }) : vhvId = Value(vhvId),
       vhvCitizenId = Value(vhvCitizenId),
       vhvTitle = Value(vhvTitle),
       vhvFname = Value(vhvFname),
       vhvLname = Value(vhvLname),
       vhvMobile = Value(vhvMobile),
       vhvEmail = Value(vhvEmail),
       vhvPassword = Value(vhvPassword),
       vhvBirthDate = Value(vhvBirthDate),
       vhvGender = Value(vhvGender),
       vhvAddress = Value(vhvAddress),
       villageId = Value(villageId);
  static Insertable<VhvsTableData> custom({
    Expression<String>? vhvId,
    Expression<String>? vhvCitizenId,
    Expression<String>? vhvTitle,
    Expression<String>? vhvFname,
    Expression<String>? vhvLname,
    Expression<String>? vhvMobile,
    Expression<String>? vhvEmail,
    Expression<String>? vhvPassword,
    Expression<DateTime>? vhvBirthDate,
    Expression<String>? vhvGender,
    Expression<String>? vhvAddress,
    Expression<String>? vhvImg,
    Expression<String>? villageId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (vhvId != null) 'vhv_id': vhvId,
      if (vhvCitizenId != null) 'vhv_citizen_id': vhvCitizenId,
      if (vhvTitle != null) 'vhv_title': vhvTitle,
      if (vhvFname != null) 'vhv_fname': vhvFname,
      if (vhvLname != null) 'vhv_lname': vhvLname,
      if (vhvMobile != null) 'vhv_mobile': vhvMobile,
      if (vhvEmail != null) 'vhv_email': vhvEmail,
      if (vhvPassword != null) 'vhv_password': vhvPassword,
      if (vhvBirthDate != null) 'vhv_birth_date': vhvBirthDate,
      if (vhvGender != null) 'vhv_gender': vhvGender,
      if (vhvAddress != null) 'vhv_address': vhvAddress,
      if (vhvImg != null) 'vhv_img': vhvImg,
      if (villageId != null) 'village_id': villageId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VhvsTableCompanion copyWith({
    Value<String>? vhvId,
    Value<String>? vhvCitizenId,
    Value<String>? vhvTitle,
    Value<String>? vhvFname,
    Value<String>? vhvLname,
    Value<String>? vhvMobile,
    Value<String>? vhvEmail,
    Value<String>? vhvPassword,
    Value<DateTime>? vhvBirthDate,
    Value<String>? vhvGender,
    Value<String>? vhvAddress,
    Value<String?>? vhvImg,
    Value<String>? villageId,
    Value<int>? rowid,
  }) {
    return VhvsTableCompanion(
      vhvId: vhvId ?? this.vhvId,
      vhvCitizenId: vhvCitizenId ?? this.vhvCitizenId,
      vhvTitle: vhvTitle ?? this.vhvTitle,
      vhvFname: vhvFname ?? this.vhvFname,
      vhvLname: vhvLname ?? this.vhvLname,
      vhvMobile: vhvMobile ?? this.vhvMobile,
      vhvEmail: vhvEmail ?? this.vhvEmail,
      vhvPassword: vhvPassword ?? this.vhvPassword,
      vhvBirthDate: vhvBirthDate ?? this.vhvBirthDate,
      vhvGender: vhvGender ?? this.vhvGender,
      vhvAddress: vhvAddress ?? this.vhvAddress,
      vhvImg: vhvImg ?? this.vhvImg,
      villageId: villageId ?? this.villageId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (vhvId.present) {
      map['vhv_id'] = Variable<String>(vhvId.value);
    }
    if (vhvCitizenId.present) {
      map['vhv_citizen_id'] = Variable<String>(vhvCitizenId.value);
    }
    if (vhvTitle.present) {
      map['vhv_title'] = Variable<String>(vhvTitle.value);
    }
    if (vhvFname.present) {
      map['vhv_fname'] = Variable<String>(vhvFname.value);
    }
    if (vhvLname.present) {
      map['vhv_lname'] = Variable<String>(vhvLname.value);
    }
    if (vhvMobile.present) {
      map['vhv_mobile'] = Variable<String>(vhvMobile.value);
    }
    if (vhvEmail.present) {
      map['vhv_email'] = Variable<String>(vhvEmail.value);
    }
    if (vhvPassword.present) {
      map['vhv_password'] = Variable<String>(vhvPassword.value);
    }
    if (vhvBirthDate.present) {
      map['vhv_birth_date'] = Variable<DateTime>(vhvBirthDate.value);
    }
    if (vhvGender.present) {
      map['vhv_gender'] = Variable<String>(vhvGender.value);
    }
    if (vhvAddress.present) {
      map['vhv_address'] = Variable<String>(vhvAddress.value);
    }
    if (vhvImg.present) {
      map['vhv_img'] = Variable<String>(vhvImg.value);
    }
    if (villageId.present) {
      map['village_id'] = Variable<String>(villageId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VhvsTableCompanion(')
          ..write('vhvId: $vhvId, ')
          ..write('vhvCitizenId: $vhvCitizenId, ')
          ..write('vhvTitle: $vhvTitle, ')
          ..write('vhvFname: $vhvFname, ')
          ..write('vhvLname: $vhvLname, ')
          ..write('vhvMobile: $vhvMobile, ')
          ..write('vhvEmail: $vhvEmail, ')
          ..write('vhvPassword: $vhvPassword, ')
          ..write('vhvBirthDate: $vhvBirthDate, ')
          ..write('vhvGender: $vhvGender, ')
          ..write('vhvAddress: $vhvAddress, ')
          ..write('vhvImg: $vhvImg, ')
          ..write('villageId: $villageId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PatientsTableTable extends PatientsTable
    with TableInfo<$PatientsTableTable, PatientsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PatientsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _patientIdMeta = const VerificationMeta(
    'patientId',
  );
  @override
  late final GeneratedColumn<String> patientId = GeneratedColumn<String>(
    'patient_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _patientCitizenIdMeta = const VerificationMeta(
    'patientCitizenId',
  );
  @override
  late final GeneratedColumn<String> patientCitizenId = GeneratedColumn<String>(
    'patient_citizen_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _patientTitleMeta = const VerificationMeta(
    'patientTitle',
  );
  @override
  late final GeneratedColumn<String> patientTitle = GeneratedColumn<String>(
    'patient_title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _patientFnameMeta = const VerificationMeta(
    'patientFname',
  );
  @override
  late final GeneratedColumn<String> patientFname = GeneratedColumn<String>(
    'patient_fname',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _patientLnameMeta = const VerificationMeta(
    'patientLname',
  );
  @override
  late final GeneratedColumn<String> patientLname = GeneratedColumn<String>(
    'patient_lname',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _patientGenderMeta = const VerificationMeta(
    'patientGender',
  );
  @override
  late final GeneratedColumn<String> patientGender = GeneratedColumn<String>(
    'patient_gender',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _patientBirthDateMeta = const VerificationMeta(
    'patientBirthDate',
  );
  @override
  late final GeneratedColumn<DateTime> patientBirthDate =
      GeneratedColumn<DateTime>(
        'patient_birth_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _patientAddressMeta = const VerificationMeta(
    'patientAddress',
  );
  @override
  late final GeneratedColumn<String> patientAddress = GeneratedColumn<String>(
    'patient_address',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _patientMobileMeta = const VerificationMeta(
    'patientMobile',
  );
  @override
  late final GeneratedColumn<String> patientMobile = GeneratedColumn<String>(
    'patient_mobile',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _patientImgMeta = const VerificationMeta(
    'patientImg',
  );
  @override
  late final GeneratedColumn<String> patientImg = GeneratedColumn<String>(
    'patient_img',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _villageIdMeta = const VerificationMeta(
    'villageId',
  );
  @override
  late final GeneratedColumn<String> villageId = GeneratedColumn<String>(
    'village_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    patientId,
    patientCitizenId,
    patientTitle,
    patientFname,
    patientLname,
    patientGender,
    patientBirthDate,
    patientAddress,
    patientMobile,
    patientImg,
    villageId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'patients';
  @override
  VerificationContext validateIntegrity(
    Insertable<PatientsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('patient_id')) {
      context.handle(
        _patientIdMeta,
        patientId.isAcceptableOrUnknown(data['patient_id']!, _patientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_patientIdMeta);
    }
    if (data.containsKey('patient_citizen_id')) {
      context.handle(
        _patientCitizenIdMeta,
        patientCitizenId.isAcceptableOrUnknown(
          data['patient_citizen_id']!,
          _patientCitizenIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_patientCitizenIdMeta);
    }
    if (data.containsKey('patient_title')) {
      context.handle(
        _patientTitleMeta,
        patientTitle.isAcceptableOrUnknown(
          data['patient_title']!,
          _patientTitleMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_patientTitleMeta);
    }
    if (data.containsKey('patient_fname')) {
      context.handle(
        _patientFnameMeta,
        patientFname.isAcceptableOrUnknown(
          data['patient_fname']!,
          _patientFnameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_patientFnameMeta);
    }
    if (data.containsKey('patient_lname')) {
      context.handle(
        _patientLnameMeta,
        patientLname.isAcceptableOrUnknown(
          data['patient_lname']!,
          _patientLnameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_patientLnameMeta);
    }
    if (data.containsKey('patient_gender')) {
      context.handle(
        _patientGenderMeta,
        patientGender.isAcceptableOrUnknown(
          data['patient_gender']!,
          _patientGenderMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_patientGenderMeta);
    }
    if (data.containsKey('patient_birth_date')) {
      context.handle(
        _patientBirthDateMeta,
        patientBirthDate.isAcceptableOrUnknown(
          data['patient_birth_date']!,
          _patientBirthDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_patientBirthDateMeta);
    }
    if (data.containsKey('patient_address')) {
      context.handle(
        _patientAddressMeta,
        patientAddress.isAcceptableOrUnknown(
          data['patient_address']!,
          _patientAddressMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_patientAddressMeta);
    }
    if (data.containsKey('patient_mobile')) {
      context.handle(
        _patientMobileMeta,
        patientMobile.isAcceptableOrUnknown(
          data['patient_mobile']!,
          _patientMobileMeta,
        ),
      );
    }
    if (data.containsKey('patient_img')) {
      context.handle(
        _patientImgMeta,
        patientImg.isAcceptableOrUnknown(data['patient_img']!, _patientImgMeta),
      );
    }
    if (data.containsKey('village_id')) {
      context.handle(
        _villageIdMeta,
        villageId.isAcceptableOrUnknown(data['village_id']!, _villageIdMeta),
      );
    } else if (isInserting) {
      context.missing(_villageIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {patientId};
  @override
  PatientsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PatientsTableData(
      patientId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}patient_id'],
          )!,
      patientCitizenId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}patient_citizen_id'],
          )!,
      patientTitle:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}patient_title'],
          )!,
      patientFname:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}patient_fname'],
          )!,
      patientLname:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}patient_lname'],
          )!,
      patientGender:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}patient_gender'],
          )!,
      patientBirthDate:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}patient_birth_date'],
          )!,
      patientAddress:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}patient_address'],
          )!,
      patientMobile:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}patient_mobile'],
          )!,
      patientImg: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}patient_img'],
      ),
      villageId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}village_id'],
          )!,
    );
  }

  @override
  $PatientsTableTable createAlias(String alias) {
    return $PatientsTableTable(attachedDatabase, alias);
  }
}

class PatientsTableData extends DataClass
    implements Insertable<PatientsTableData> {
  final String patientId;
  final String patientCitizenId;
  final String patientTitle;
  final String patientFname;
  final String patientLname;
  final String patientGender;
  final DateTime patientBirthDate;
  final String patientAddress;
  final String patientMobile;
  final String? patientImg;
  final String villageId;
  const PatientsTableData({
    required this.patientId,
    required this.patientCitizenId,
    required this.patientTitle,
    required this.patientFname,
    required this.patientLname,
    required this.patientGender,
    required this.patientBirthDate,
    required this.patientAddress,
    required this.patientMobile,
    this.patientImg,
    required this.villageId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['patient_id'] = Variable<String>(patientId);
    map['patient_citizen_id'] = Variable<String>(patientCitizenId);
    map['patient_title'] = Variable<String>(patientTitle);
    map['patient_fname'] = Variable<String>(patientFname);
    map['patient_lname'] = Variable<String>(patientLname);
    map['patient_gender'] = Variable<String>(patientGender);
    map['patient_birth_date'] = Variable<DateTime>(patientBirthDate);
    map['patient_address'] = Variable<String>(patientAddress);
    map['patient_mobile'] = Variable<String>(patientMobile);
    if (!nullToAbsent || patientImg != null) {
      map['patient_img'] = Variable<String>(patientImg);
    }
    map['village_id'] = Variable<String>(villageId);
    return map;
  }

  PatientsTableCompanion toCompanion(bool nullToAbsent) {
    return PatientsTableCompanion(
      patientId: Value(patientId),
      patientCitizenId: Value(patientCitizenId),
      patientTitle: Value(patientTitle),
      patientFname: Value(patientFname),
      patientLname: Value(patientLname),
      patientGender: Value(patientGender),
      patientBirthDate: Value(patientBirthDate),
      patientAddress: Value(patientAddress),
      patientMobile: Value(patientMobile),
      patientImg:
          patientImg == null && nullToAbsent
              ? const Value.absent()
              : Value(patientImg),
      villageId: Value(villageId),
    );
  }

  factory PatientsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PatientsTableData(
      patientId: serializer.fromJson<String>(json['patientId']),
      patientCitizenId: serializer.fromJson<String>(json['patientCitizenId']),
      patientTitle: serializer.fromJson<String>(json['patientTitle']),
      patientFname: serializer.fromJson<String>(json['patientFname']),
      patientLname: serializer.fromJson<String>(json['patientLname']),
      patientGender: serializer.fromJson<String>(json['patientGender']),
      patientBirthDate: serializer.fromJson<DateTime>(json['patientBirthDate']),
      patientAddress: serializer.fromJson<String>(json['patientAddress']),
      patientMobile: serializer.fromJson<String>(json['patientMobile']),
      patientImg: serializer.fromJson<String?>(json['patientImg']),
      villageId: serializer.fromJson<String>(json['villageId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'patientId': serializer.toJson<String>(patientId),
      'patientCitizenId': serializer.toJson<String>(patientCitizenId),
      'patientTitle': serializer.toJson<String>(patientTitle),
      'patientFname': serializer.toJson<String>(patientFname),
      'patientLname': serializer.toJson<String>(patientLname),
      'patientGender': serializer.toJson<String>(patientGender),
      'patientBirthDate': serializer.toJson<DateTime>(patientBirthDate),
      'patientAddress': serializer.toJson<String>(patientAddress),
      'patientMobile': serializer.toJson<String>(patientMobile),
      'patientImg': serializer.toJson<String?>(patientImg),
      'villageId': serializer.toJson<String>(villageId),
    };
  }

  PatientsTableData copyWith({
    String? patientId,
    String? patientCitizenId,
    String? patientTitle,
    String? patientFname,
    String? patientLname,
    String? patientGender,
    DateTime? patientBirthDate,
    String? patientAddress,
    String? patientMobile,
    Value<String?> patientImg = const Value.absent(),
    String? villageId,
  }) => PatientsTableData(
    patientId: patientId ?? this.patientId,
    patientCitizenId: patientCitizenId ?? this.patientCitizenId,
    patientTitle: patientTitle ?? this.patientTitle,
    patientFname: patientFname ?? this.patientFname,
    patientLname: patientLname ?? this.patientLname,
    patientGender: patientGender ?? this.patientGender,
    patientBirthDate: patientBirthDate ?? this.patientBirthDate,
    patientAddress: patientAddress ?? this.patientAddress,
    patientMobile: patientMobile ?? this.patientMobile,
    patientImg: patientImg.present ? patientImg.value : this.patientImg,
    villageId: villageId ?? this.villageId,
  );
  PatientsTableData copyWithCompanion(PatientsTableCompanion data) {
    return PatientsTableData(
      patientId: data.patientId.present ? data.patientId.value : this.patientId,
      patientCitizenId:
          data.patientCitizenId.present
              ? data.patientCitizenId.value
              : this.patientCitizenId,
      patientTitle:
          data.patientTitle.present
              ? data.patientTitle.value
              : this.patientTitle,
      patientFname:
          data.patientFname.present
              ? data.patientFname.value
              : this.patientFname,
      patientLname:
          data.patientLname.present
              ? data.patientLname.value
              : this.patientLname,
      patientGender:
          data.patientGender.present
              ? data.patientGender.value
              : this.patientGender,
      patientBirthDate:
          data.patientBirthDate.present
              ? data.patientBirthDate.value
              : this.patientBirthDate,
      patientAddress:
          data.patientAddress.present
              ? data.patientAddress.value
              : this.patientAddress,
      patientMobile:
          data.patientMobile.present
              ? data.patientMobile.value
              : this.patientMobile,
      patientImg:
          data.patientImg.present ? data.patientImg.value : this.patientImg,
      villageId: data.villageId.present ? data.villageId.value : this.villageId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PatientsTableData(')
          ..write('patientId: $patientId, ')
          ..write('patientCitizenId: $patientCitizenId, ')
          ..write('patientTitle: $patientTitle, ')
          ..write('patientFname: $patientFname, ')
          ..write('patientLname: $patientLname, ')
          ..write('patientGender: $patientGender, ')
          ..write('patientBirthDate: $patientBirthDate, ')
          ..write('patientAddress: $patientAddress, ')
          ..write('patientMobile: $patientMobile, ')
          ..write('patientImg: $patientImg, ')
          ..write('villageId: $villageId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    patientId,
    patientCitizenId,
    patientTitle,
    patientFname,
    patientLname,
    patientGender,
    patientBirthDate,
    patientAddress,
    patientMobile,
    patientImg,
    villageId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PatientsTableData &&
          other.patientId == this.patientId &&
          other.patientCitizenId == this.patientCitizenId &&
          other.patientTitle == this.patientTitle &&
          other.patientFname == this.patientFname &&
          other.patientLname == this.patientLname &&
          other.patientGender == this.patientGender &&
          other.patientBirthDate == this.patientBirthDate &&
          other.patientAddress == this.patientAddress &&
          other.patientMobile == this.patientMobile &&
          other.patientImg == this.patientImg &&
          other.villageId == this.villageId);
}

class PatientsTableCompanion extends UpdateCompanion<PatientsTableData> {
  final Value<String> patientId;
  final Value<String> patientCitizenId;
  final Value<String> patientTitle;
  final Value<String> patientFname;
  final Value<String> patientLname;
  final Value<String> patientGender;
  final Value<DateTime> patientBirthDate;
  final Value<String> patientAddress;
  final Value<String> patientMobile;
  final Value<String?> patientImg;
  final Value<String> villageId;
  final Value<int> rowid;
  const PatientsTableCompanion({
    this.patientId = const Value.absent(),
    this.patientCitizenId = const Value.absent(),
    this.patientTitle = const Value.absent(),
    this.patientFname = const Value.absent(),
    this.patientLname = const Value.absent(),
    this.patientGender = const Value.absent(),
    this.patientBirthDate = const Value.absent(),
    this.patientAddress = const Value.absent(),
    this.patientMobile = const Value.absent(),
    this.patientImg = const Value.absent(),
    this.villageId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PatientsTableCompanion.insert({
    required String patientId,
    required String patientCitizenId,
    required String patientTitle,
    required String patientFname,
    required String patientLname,
    required String patientGender,
    required DateTime patientBirthDate,
    required String patientAddress,
    this.patientMobile = const Value.absent(),
    this.patientImg = const Value.absent(),
    required String villageId,
    this.rowid = const Value.absent(),
  }) : patientId = Value(patientId),
       patientCitizenId = Value(patientCitizenId),
       patientTitle = Value(patientTitle),
       patientFname = Value(patientFname),
       patientLname = Value(patientLname),
       patientGender = Value(patientGender),
       patientBirthDate = Value(patientBirthDate),
       patientAddress = Value(patientAddress),
       villageId = Value(villageId);
  static Insertable<PatientsTableData> custom({
    Expression<String>? patientId,
    Expression<String>? patientCitizenId,
    Expression<String>? patientTitle,
    Expression<String>? patientFname,
    Expression<String>? patientLname,
    Expression<String>? patientGender,
    Expression<DateTime>? patientBirthDate,
    Expression<String>? patientAddress,
    Expression<String>? patientMobile,
    Expression<String>? patientImg,
    Expression<String>? villageId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (patientId != null) 'patient_id': patientId,
      if (patientCitizenId != null) 'patient_citizen_id': patientCitizenId,
      if (patientTitle != null) 'patient_title': patientTitle,
      if (patientFname != null) 'patient_fname': patientFname,
      if (patientLname != null) 'patient_lname': patientLname,
      if (patientGender != null) 'patient_gender': patientGender,
      if (patientBirthDate != null) 'patient_birth_date': patientBirthDate,
      if (patientAddress != null) 'patient_address': patientAddress,
      if (patientMobile != null) 'patient_mobile': patientMobile,
      if (patientImg != null) 'patient_img': patientImg,
      if (villageId != null) 'village_id': villageId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PatientsTableCompanion copyWith({
    Value<String>? patientId,
    Value<String>? patientCitizenId,
    Value<String>? patientTitle,
    Value<String>? patientFname,
    Value<String>? patientLname,
    Value<String>? patientGender,
    Value<DateTime>? patientBirthDate,
    Value<String>? patientAddress,
    Value<String>? patientMobile,
    Value<String?>? patientImg,
    Value<String>? villageId,
    Value<int>? rowid,
  }) {
    return PatientsTableCompanion(
      patientId: patientId ?? this.patientId,
      patientCitizenId: patientCitizenId ?? this.patientCitizenId,
      patientTitle: patientTitle ?? this.patientTitle,
      patientFname: patientFname ?? this.patientFname,
      patientLname: patientLname ?? this.patientLname,
      patientGender: patientGender ?? this.patientGender,
      patientBirthDate: patientBirthDate ?? this.patientBirthDate,
      patientAddress: patientAddress ?? this.patientAddress,
      patientMobile: patientMobile ?? this.patientMobile,
      patientImg: patientImg ?? this.patientImg,
      villageId: villageId ?? this.villageId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (patientId.present) {
      map['patient_id'] = Variable<String>(patientId.value);
    }
    if (patientCitizenId.present) {
      map['patient_citizen_id'] = Variable<String>(patientCitizenId.value);
    }
    if (patientTitle.present) {
      map['patient_title'] = Variable<String>(patientTitle.value);
    }
    if (patientFname.present) {
      map['patient_fname'] = Variable<String>(patientFname.value);
    }
    if (patientLname.present) {
      map['patient_lname'] = Variable<String>(patientLname.value);
    }
    if (patientGender.present) {
      map['patient_gender'] = Variable<String>(patientGender.value);
    }
    if (patientBirthDate.present) {
      map['patient_birth_date'] = Variable<DateTime>(patientBirthDate.value);
    }
    if (patientAddress.present) {
      map['patient_address'] = Variable<String>(patientAddress.value);
    }
    if (patientMobile.present) {
      map['patient_mobile'] = Variable<String>(patientMobile.value);
    }
    if (patientImg.present) {
      map['patient_img'] = Variable<String>(patientImg.value);
    }
    if (villageId.present) {
      map['village_id'] = Variable<String>(villageId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PatientsTableCompanion(')
          ..write('patientId: $patientId, ')
          ..write('patientCitizenId: $patientCitizenId, ')
          ..write('patientTitle: $patientTitle, ')
          ..write('patientFname: $patientFname, ')
          ..write('patientLname: $patientLname, ')
          ..write('patientGender: $patientGender, ')
          ..write('patientBirthDate: $patientBirthDate, ')
          ..write('patientAddress: $patientAddress, ')
          ..write('patientMobile: $patientMobile, ')
          ..write('patientImg: $patientImg, ')
          ..write('villageId: $villageId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ScreeningsTableTable extends ScreeningsTable
    with TableInfo<$ScreeningsTableTable, ScreeningsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScreeningsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _screenIdMeta = const VerificationMeta(
    'screenId',
  );
  @override
  late final GeneratedColumn<String> screenId = GeneratedColumn<String>(
    'screen_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _patientIdMeta = const VerificationMeta(
    'patientId',
  );
  @override
  late final GeneratedColumn<String> patientId = GeneratedColumn<String>(
    'patient_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vhvIdMeta = const VerificationMeta('vhvId');
  @override
  late final GeneratedColumn<String> vhvId = GeneratedColumn<String>(
    'vhv_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _screeningDateMeta = const VerificationMeta(
    'screeningDate',
  );
  @override
  late final GeneratedColumn<DateTime> screeningDate =
      GeneratedColumn<DateTime>(
        'screening_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _ageAtScreeningMeta = const VerificationMeta(
    'ageAtScreening',
  );
  @override
  late final GeneratedColumn<int> ageAtScreening = GeneratedColumn<int>(
    'age_at_screening',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reviewStatusMeta = const VerificationMeta(
    'reviewStatus',
  );
  @override
  late final GeneratedColumn<String> reviewStatus = GeneratedColumn<String>(
    'review_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('PENDING'),
  );
  static const VerificationMeta _reviewedByNurseIdMeta = const VerificationMeta(
    'reviewedByNurseId',
  );
  @override
  late final GeneratedColumn<String> reviewedByNurseId =
      GeneratedColumn<String>(
        'reviewed_by_nurse_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _reviewedAtMeta = const VerificationMeta(
    'reviewedAt',
  );
  @override
  late final GeneratedColumn<DateTime> reviewedAt = GeneratedColumn<DateTime>(
    'reviewed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  @override
  late final GeneratedColumn<double> weight = GeneratedColumn<double>(
    'weight',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<double> height = GeneratedColumn<double>(
    'height',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bmiMeta = const VerificationMeta('bmi');
  @override
  late final GeneratedColumn<double> bmi = GeneratedColumn<double>(
    'bmi',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _waistCmMeta = const VerificationMeta(
    'waistCm',
  );
  @override
  late final GeneratedColumn<double> waistCm = GeneratedColumn<double>(
    'waist_cm',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sbpMeta = const VerificationMeta('sbp');
  @override
  late final GeneratedColumn<double> sbp = GeneratedColumn<double>(
    'sbp',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dbpMeta = const VerificationMeta('dbp');
  @override
  late final GeneratedColumn<double> dbp = GeneratedColumn<double>(
    'dbp',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pulseMeta = const VerificationMeta('pulse');
  @override
  late final GeneratedColumn<double> pulse = GeneratedColumn<double>(
    'pulse',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bloodSugarMeta = const VerificationMeta(
    'bloodSugar',
  );
  @override
  late final GeneratedColumn<double> bloodSugar = GeneratedColumn<double>(
    'blood_sugar',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    screenId,
    patientId,
    vhvId,
    screeningDate,
    ageAtScreening,
    createdAt,
    reviewStatus,
    reviewedByNurseId,
    reviewedAt,
    weight,
    height,
    bmi,
    waistCm,
    sbp,
    dbp,
    pulse,
    bloodSugar,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'screenings';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScreeningsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('screen_id')) {
      context.handle(
        _screenIdMeta,
        screenId.isAcceptableOrUnknown(data['screen_id']!, _screenIdMeta),
      );
    } else if (isInserting) {
      context.missing(_screenIdMeta);
    }
    if (data.containsKey('patient_id')) {
      context.handle(
        _patientIdMeta,
        patientId.isAcceptableOrUnknown(data['patient_id']!, _patientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_patientIdMeta);
    }
    if (data.containsKey('vhv_id')) {
      context.handle(
        _vhvIdMeta,
        vhvId.isAcceptableOrUnknown(data['vhv_id']!, _vhvIdMeta),
      );
    } else if (isInserting) {
      context.missing(_vhvIdMeta);
    }
    if (data.containsKey('screening_date')) {
      context.handle(
        _screeningDateMeta,
        screeningDate.isAcceptableOrUnknown(
          data['screening_date']!,
          _screeningDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_screeningDateMeta);
    }
    if (data.containsKey('age_at_screening')) {
      context.handle(
        _ageAtScreeningMeta,
        ageAtScreening.isAcceptableOrUnknown(
          data['age_at_screening']!,
          _ageAtScreeningMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ageAtScreeningMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('review_status')) {
      context.handle(
        _reviewStatusMeta,
        reviewStatus.isAcceptableOrUnknown(
          data['review_status']!,
          _reviewStatusMeta,
        ),
      );
    }
    if (data.containsKey('reviewed_by_nurse_id')) {
      context.handle(
        _reviewedByNurseIdMeta,
        reviewedByNurseId.isAcceptableOrUnknown(
          data['reviewed_by_nurse_id']!,
          _reviewedByNurseIdMeta,
        ),
      );
    }
    if (data.containsKey('reviewed_at')) {
      context.handle(
        _reviewedAtMeta,
        reviewedAt.isAcceptableOrUnknown(data['reviewed_at']!, _reviewedAtMeta),
      );
    }
    if (data.containsKey('weight')) {
      context.handle(
        _weightMeta,
        weight.isAcceptableOrUnknown(data['weight']!, _weightMeta),
      );
    } else if (isInserting) {
      context.missing(_weightMeta);
    }
    if (data.containsKey('height')) {
      context.handle(
        _heightMeta,
        height.isAcceptableOrUnknown(data['height']!, _heightMeta),
      );
    } else if (isInserting) {
      context.missing(_heightMeta);
    }
    if (data.containsKey('bmi')) {
      context.handle(
        _bmiMeta,
        bmi.isAcceptableOrUnknown(data['bmi']!, _bmiMeta),
      );
    } else if (isInserting) {
      context.missing(_bmiMeta);
    }
    if (data.containsKey('waist_cm')) {
      context.handle(
        _waistCmMeta,
        waistCm.isAcceptableOrUnknown(data['waist_cm']!, _waistCmMeta),
      );
    } else if (isInserting) {
      context.missing(_waistCmMeta);
    }
    if (data.containsKey('sbp')) {
      context.handle(
        _sbpMeta,
        sbp.isAcceptableOrUnknown(data['sbp']!, _sbpMeta),
      );
    } else if (isInserting) {
      context.missing(_sbpMeta);
    }
    if (data.containsKey('dbp')) {
      context.handle(
        _dbpMeta,
        dbp.isAcceptableOrUnknown(data['dbp']!, _dbpMeta),
      );
    } else if (isInserting) {
      context.missing(_dbpMeta);
    }
    if (data.containsKey('pulse')) {
      context.handle(
        _pulseMeta,
        pulse.isAcceptableOrUnknown(data['pulse']!, _pulseMeta),
      );
    } else if (isInserting) {
      context.missing(_pulseMeta);
    }
    if (data.containsKey('blood_sugar')) {
      context.handle(
        _bloodSugarMeta,
        bloodSugar.isAcceptableOrUnknown(data['blood_sugar']!, _bloodSugarMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {screenId};
  @override
  ScreeningsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScreeningsTableData(
      screenId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}screen_id'],
          )!,
      patientId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}patient_id'],
          )!,
      vhvId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}vhv_id'],
          )!,
      screeningDate:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}screening_date'],
          )!,
      ageAtScreening:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}age_at_screening'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      reviewStatus:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}review_status'],
          )!,
      reviewedByNurseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reviewed_by_nurse_id'],
      ),
      reviewedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}reviewed_at'],
      ),
      weight:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}weight'],
          )!,
      height:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}height'],
          )!,
      bmi:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}bmi'],
          )!,
      waistCm:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}waist_cm'],
          )!,
      sbp:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}sbp'],
          )!,
      dbp:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}dbp'],
          )!,
      pulse:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}pulse'],
          )!,
      bloodSugar: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}blood_sugar'],
      ),
    );
  }

  @override
  $ScreeningsTableTable createAlias(String alias) {
    return $ScreeningsTableTable(attachedDatabase, alias);
  }
}

class ScreeningsTableData extends DataClass
    implements Insertable<ScreeningsTableData> {
  final String screenId;
  final String patientId;
  final String vhvId;
  final DateTime screeningDate;
  final int ageAtScreening;
  final DateTime createdAt;
  final String reviewStatus;
  final String? reviewedByNurseId;
  final DateTime? reviewedAt;
  final double weight;
  final double height;
  final double bmi;
  final double waistCm;
  final double sbp;
  final double dbp;
  final double pulse;
  final double? bloodSugar;
  const ScreeningsTableData({
    required this.screenId,
    required this.patientId,
    required this.vhvId,
    required this.screeningDate,
    required this.ageAtScreening,
    required this.createdAt,
    required this.reviewStatus,
    this.reviewedByNurseId,
    this.reviewedAt,
    required this.weight,
    required this.height,
    required this.bmi,
    required this.waistCm,
    required this.sbp,
    required this.dbp,
    required this.pulse,
    this.bloodSugar,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['screen_id'] = Variable<String>(screenId);
    map['patient_id'] = Variable<String>(patientId);
    map['vhv_id'] = Variable<String>(vhvId);
    map['screening_date'] = Variable<DateTime>(screeningDate);
    map['age_at_screening'] = Variable<int>(ageAtScreening);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['review_status'] = Variable<String>(reviewStatus);
    if (!nullToAbsent || reviewedByNurseId != null) {
      map['reviewed_by_nurse_id'] = Variable<String>(reviewedByNurseId);
    }
    if (!nullToAbsent || reviewedAt != null) {
      map['reviewed_at'] = Variable<DateTime>(reviewedAt);
    }
    map['weight'] = Variable<double>(weight);
    map['height'] = Variable<double>(height);
    map['bmi'] = Variable<double>(bmi);
    map['waist_cm'] = Variable<double>(waistCm);
    map['sbp'] = Variable<double>(sbp);
    map['dbp'] = Variable<double>(dbp);
    map['pulse'] = Variable<double>(pulse);
    if (!nullToAbsent || bloodSugar != null) {
      map['blood_sugar'] = Variable<double>(bloodSugar);
    }
    return map;
  }

  ScreeningsTableCompanion toCompanion(bool nullToAbsent) {
    return ScreeningsTableCompanion(
      screenId: Value(screenId),
      patientId: Value(patientId),
      vhvId: Value(vhvId),
      screeningDate: Value(screeningDate),
      ageAtScreening: Value(ageAtScreening),
      createdAt: Value(createdAt),
      reviewStatus: Value(reviewStatus),
      reviewedByNurseId:
          reviewedByNurseId == null && nullToAbsent
              ? const Value.absent()
              : Value(reviewedByNurseId),
      reviewedAt:
          reviewedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(reviewedAt),
      weight: Value(weight),
      height: Value(height),
      bmi: Value(bmi),
      waistCm: Value(waistCm),
      sbp: Value(sbp),
      dbp: Value(dbp),
      pulse: Value(pulse),
      bloodSugar:
          bloodSugar == null && nullToAbsent
              ? const Value.absent()
              : Value(bloodSugar),
    );
  }

  factory ScreeningsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScreeningsTableData(
      screenId: serializer.fromJson<String>(json['screenId']),
      patientId: serializer.fromJson<String>(json['patientId']),
      vhvId: serializer.fromJson<String>(json['vhvId']),
      screeningDate: serializer.fromJson<DateTime>(json['screeningDate']),
      ageAtScreening: serializer.fromJson<int>(json['ageAtScreening']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      reviewStatus: serializer.fromJson<String>(json['reviewStatus']),
      reviewedByNurseId: serializer.fromJson<String?>(
        json['reviewedByNurseId'],
      ),
      reviewedAt: serializer.fromJson<DateTime?>(json['reviewedAt']),
      weight: serializer.fromJson<double>(json['weight']),
      height: serializer.fromJson<double>(json['height']),
      bmi: serializer.fromJson<double>(json['bmi']),
      waistCm: serializer.fromJson<double>(json['waistCm']),
      sbp: serializer.fromJson<double>(json['sbp']),
      dbp: serializer.fromJson<double>(json['dbp']),
      pulse: serializer.fromJson<double>(json['pulse']),
      bloodSugar: serializer.fromJson<double?>(json['bloodSugar']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'screenId': serializer.toJson<String>(screenId),
      'patientId': serializer.toJson<String>(patientId),
      'vhvId': serializer.toJson<String>(vhvId),
      'screeningDate': serializer.toJson<DateTime>(screeningDate),
      'ageAtScreening': serializer.toJson<int>(ageAtScreening),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'reviewStatus': serializer.toJson<String>(reviewStatus),
      'reviewedByNurseId': serializer.toJson<String?>(reviewedByNurseId),
      'reviewedAt': serializer.toJson<DateTime?>(reviewedAt),
      'weight': serializer.toJson<double>(weight),
      'height': serializer.toJson<double>(height),
      'bmi': serializer.toJson<double>(bmi),
      'waistCm': serializer.toJson<double>(waistCm),
      'sbp': serializer.toJson<double>(sbp),
      'dbp': serializer.toJson<double>(dbp),
      'pulse': serializer.toJson<double>(pulse),
      'bloodSugar': serializer.toJson<double?>(bloodSugar),
    };
  }

  ScreeningsTableData copyWith({
    String? screenId,
    String? patientId,
    String? vhvId,
    DateTime? screeningDate,
    int? ageAtScreening,
    DateTime? createdAt,
    String? reviewStatus,
    Value<String?> reviewedByNurseId = const Value.absent(),
    Value<DateTime?> reviewedAt = const Value.absent(),
    double? weight,
    double? height,
    double? bmi,
    double? waistCm,
    double? sbp,
    double? dbp,
    double? pulse,
    Value<double?> bloodSugar = const Value.absent(),
  }) => ScreeningsTableData(
    screenId: screenId ?? this.screenId,
    patientId: patientId ?? this.patientId,
    vhvId: vhvId ?? this.vhvId,
    screeningDate: screeningDate ?? this.screeningDate,
    ageAtScreening: ageAtScreening ?? this.ageAtScreening,
    createdAt: createdAt ?? this.createdAt,
    reviewStatus: reviewStatus ?? this.reviewStatus,
    reviewedByNurseId:
        reviewedByNurseId.present
            ? reviewedByNurseId.value
            : this.reviewedByNurseId,
    reviewedAt: reviewedAt.present ? reviewedAt.value : this.reviewedAt,
    weight: weight ?? this.weight,
    height: height ?? this.height,
    bmi: bmi ?? this.bmi,
    waistCm: waistCm ?? this.waistCm,
    sbp: sbp ?? this.sbp,
    dbp: dbp ?? this.dbp,
    pulse: pulse ?? this.pulse,
    bloodSugar: bloodSugar.present ? bloodSugar.value : this.bloodSugar,
  );
  ScreeningsTableData copyWithCompanion(ScreeningsTableCompanion data) {
    return ScreeningsTableData(
      screenId: data.screenId.present ? data.screenId.value : this.screenId,
      patientId: data.patientId.present ? data.patientId.value : this.patientId,
      vhvId: data.vhvId.present ? data.vhvId.value : this.vhvId,
      screeningDate:
          data.screeningDate.present
              ? data.screeningDate.value
              : this.screeningDate,
      ageAtScreening:
          data.ageAtScreening.present
              ? data.ageAtScreening.value
              : this.ageAtScreening,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      reviewStatus:
          data.reviewStatus.present
              ? data.reviewStatus.value
              : this.reviewStatus,
      reviewedByNurseId:
          data.reviewedByNurseId.present
              ? data.reviewedByNurseId.value
              : this.reviewedByNurseId,
      reviewedAt:
          data.reviewedAt.present ? data.reviewedAt.value : this.reviewedAt,
      weight: data.weight.present ? data.weight.value : this.weight,
      height: data.height.present ? data.height.value : this.height,
      bmi: data.bmi.present ? data.bmi.value : this.bmi,
      waistCm: data.waistCm.present ? data.waistCm.value : this.waistCm,
      sbp: data.sbp.present ? data.sbp.value : this.sbp,
      dbp: data.dbp.present ? data.dbp.value : this.dbp,
      pulse: data.pulse.present ? data.pulse.value : this.pulse,
      bloodSugar:
          data.bloodSugar.present ? data.bloodSugar.value : this.bloodSugar,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScreeningsTableData(')
          ..write('screenId: $screenId, ')
          ..write('patientId: $patientId, ')
          ..write('vhvId: $vhvId, ')
          ..write('screeningDate: $screeningDate, ')
          ..write('ageAtScreening: $ageAtScreening, ')
          ..write('createdAt: $createdAt, ')
          ..write('reviewStatus: $reviewStatus, ')
          ..write('reviewedByNurseId: $reviewedByNurseId, ')
          ..write('reviewedAt: $reviewedAt, ')
          ..write('weight: $weight, ')
          ..write('height: $height, ')
          ..write('bmi: $bmi, ')
          ..write('waistCm: $waistCm, ')
          ..write('sbp: $sbp, ')
          ..write('dbp: $dbp, ')
          ..write('pulse: $pulse, ')
          ..write('bloodSugar: $bloodSugar')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    screenId,
    patientId,
    vhvId,
    screeningDate,
    ageAtScreening,
    createdAt,
    reviewStatus,
    reviewedByNurseId,
    reviewedAt,
    weight,
    height,
    bmi,
    waistCm,
    sbp,
    dbp,
    pulse,
    bloodSugar,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScreeningsTableData &&
          other.screenId == this.screenId &&
          other.patientId == this.patientId &&
          other.vhvId == this.vhvId &&
          other.screeningDate == this.screeningDate &&
          other.ageAtScreening == this.ageAtScreening &&
          other.createdAt == this.createdAt &&
          other.reviewStatus == this.reviewStatus &&
          other.reviewedByNurseId == this.reviewedByNurseId &&
          other.reviewedAt == this.reviewedAt &&
          other.weight == this.weight &&
          other.height == this.height &&
          other.bmi == this.bmi &&
          other.waistCm == this.waistCm &&
          other.sbp == this.sbp &&
          other.dbp == this.dbp &&
          other.pulse == this.pulse &&
          other.bloodSugar == this.bloodSugar);
}

class ScreeningsTableCompanion extends UpdateCompanion<ScreeningsTableData> {
  final Value<String> screenId;
  final Value<String> patientId;
  final Value<String> vhvId;
  final Value<DateTime> screeningDate;
  final Value<int> ageAtScreening;
  final Value<DateTime> createdAt;
  final Value<String> reviewStatus;
  final Value<String?> reviewedByNurseId;
  final Value<DateTime?> reviewedAt;
  final Value<double> weight;
  final Value<double> height;
  final Value<double> bmi;
  final Value<double> waistCm;
  final Value<double> sbp;
  final Value<double> dbp;
  final Value<double> pulse;
  final Value<double?> bloodSugar;
  final Value<int> rowid;
  const ScreeningsTableCompanion({
    this.screenId = const Value.absent(),
    this.patientId = const Value.absent(),
    this.vhvId = const Value.absent(),
    this.screeningDate = const Value.absent(),
    this.ageAtScreening = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.reviewStatus = const Value.absent(),
    this.reviewedByNurseId = const Value.absent(),
    this.reviewedAt = const Value.absent(),
    this.weight = const Value.absent(),
    this.height = const Value.absent(),
    this.bmi = const Value.absent(),
    this.waistCm = const Value.absent(),
    this.sbp = const Value.absent(),
    this.dbp = const Value.absent(),
    this.pulse = const Value.absent(),
    this.bloodSugar = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ScreeningsTableCompanion.insert({
    required String screenId,
    required String patientId,
    required String vhvId,
    required DateTime screeningDate,
    required int ageAtScreening,
    required DateTime createdAt,
    this.reviewStatus = const Value.absent(),
    this.reviewedByNurseId = const Value.absent(),
    this.reviewedAt = const Value.absent(),
    required double weight,
    required double height,
    required double bmi,
    required double waistCm,
    required double sbp,
    required double dbp,
    required double pulse,
    this.bloodSugar = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : screenId = Value(screenId),
       patientId = Value(patientId),
       vhvId = Value(vhvId),
       screeningDate = Value(screeningDate),
       ageAtScreening = Value(ageAtScreening),
       createdAt = Value(createdAt),
       weight = Value(weight),
       height = Value(height),
       bmi = Value(bmi),
       waistCm = Value(waistCm),
       sbp = Value(sbp),
       dbp = Value(dbp),
       pulse = Value(pulse);
  static Insertable<ScreeningsTableData> custom({
    Expression<String>? screenId,
    Expression<String>? patientId,
    Expression<String>? vhvId,
    Expression<DateTime>? screeningDate,
    Expression<int>? ageAtScreening,
    Expression<DateTime>? createdAt,
    Expression<String>? reviewStatus,
    Expression<String>? reviewedByNurseId,
    Expression<DateTime>? reviewedAt,
    Expression<double>? weight,
    Expression<double>? height,
    Expression<double>? bmi,
    Expression<double>? waistCm,
    Expression<double>? sbp,
    Expression<double>? dbp,
    Expression<double>? pulse,
    Expression<double>? bloodSugar,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (screenId != null) 'screen_id': screenId,
      if (patientId != null) 'patient_id': patientId,
      if (vhvId != null) 'vhv_id': vhvId,
      if (screeningDate != null) 'screening_date': screeningDate,
      if (ageAtScreening != null) 'age_at_screening': ageAtScreening,
      if (createdAt != null) 'created_at': createdAt,
      if (reviewStatus != null) 'review_status': reviewStatus,
      if (reviewedByNurseId != null) 'reviewed_by_nurse_id': reviewedByNurseId,
      if (reviewedAt != null) 'reviewed_at': reviewedAt,
      if (weight != null) 'weight': weight,
      if (height != null) 'height': height,
      if (bmi != null) 'bmi': bmi,
      if (waistCm != null) 'waist_cm': waistCm,
      if (sbp != null) 'sbp': sbp,
      if (dbp != null) 'dbp': dbp,
      if (pulse != null) 'pulse': pulse,
      if (bloodSugar != null) 'blood_sugar': bloodSugar,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ScreeningsTableCompanion copyWith({
    Value<String>? screenId,
    Value<String>? patientId,
    Value<String>? vhvId,
    Value<DateTime>? screeningDate,
    Value<int>? ageAtScreening,
    Value<DateTime>? createdAt,
    Value<String>? reviewStatus,
    Value<String?>? reviewedByNurseId,
    Value<DateTime?>? reviewedAt,
    Value<double>? weight,
    Value<double>? height,
    Value<double>? bmi,
    Value<double>? waistCm,
    Value<double>? sbp,
    Value<double>? dbp,
    Value<double>? pulse,
    Value<double?>? bloodSugar,
    Value<int>? rowid,
  }) {
    return ScreeningsTableCompanion(
      screenId: screenId ?? this.screenId,
      patientId: patientId ?? this.patientId,
      vhvId: vhvId ?? this.vhvId,
      screeningDate: screeningDate ?? this.screeningDate,
      ageAtScreening: ageAtScreening ?? this.ageAtScreening,
      createdAt: createdAt ?? this.createdAt,
      reviewStatus: reviewStatus ?? this.reviewStatus,
      reviewedByNurseId: reviewedByNurseId ?? this.reviewedByNurseId,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      bmi: bmi ?? this.bmi,
      waistCm: waistCm ?? this.waistCm,
      sbp: sbp ?? this.sbp,
      dbp: dbp ?? this.dbp,
      pulse: pulse ?? this.pulse,
      bloodSugar: bloodSugar ?? this.bloodSugar,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (screenId.present) {
      map['screen_id'] = Variable<String>(screenId.value);
    }
    if (patientId.present) {
      map['patient_id'] = Variable<String>(patientId.value);
    }
    if (vhvId.present) {
      map['vhv_id'] = Variable<String>(vhvId.value);
    }
    if (screeningDate.present) {
      map['screening_date'] = Variable<DateTime>(screeningDate.value);
    }
    if (ageAtScreening.present) {
      map['age_at_screening'] = Variable<int>(ageAtScreening.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (reviewStatus.present) {
      map['review_status'] = Variable<String>(reviewStatus.value);
    }
    if (reviewedByNurseId.present) {
      map['reviewed_by_nurse_id'] = Variable<String>(reviewedByNurseId.value);
    }
    if (reviewedAt.present) {
      map['reviewed_at'] = Variable<DateTime>(reviewedAt.value);
    }
    if (weight.present) {
      map['weight'] = Variable<double>(weight.value);
    }
    if (height.present) {
      map['height'] = Variable<double>(height.value);
    }
    if (bmi.present) {
      map['bmi'] = Variable<double>(bmi.value);
    }
    if (waistCm.present) {
      map['waist_cm'] = Variable<double>(waistCm.value);
    }
    if (sbp.present) {
      map['sbp'] = Variable<double>(sbp.value);
    }
    if (dbp.present) {
      map['dbp'] = Variable<double>(dbp.value);
    }
    if (pulse.present) {
      map['pulse'] = Variable<double>(pulse.value);
    }
    if (bloodSugar.present) {
      map['blood_sugar'] = Variable<double>(bloodSugar.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScreeningsTableCompanion(')
          ..write('screenId: $screenId, ')
          ..write('patientId: $patientId, ')
          ..write('vhvId: $vhvId, ')
          ..write('screeningDate: $screeningDate, ')
          ..write('ageAtScreening: $ageAtScreening, ')
          ..write('createdAt: $createdAt, ')
          ..write('reviewStatus: $reviewStatus, ')
          ..write('reviewedByNurseId: $reviewedByNurseId, ')
          ..write('reviewedAt: $reviewedAt, ')
          ..write('weight: $weight, ')
          ..write('height: $height, ')
          ..write('bmi: $bmi, ')
          ..write('waistCm: $waistCm, ')
          ..write('sbp: $sbp, ')
          ..write('dbp: $dbp, ')
          ..write('pulse: $pulse, ')
          ..write('bloodSugar: $bloodSugar, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ScreeningHistoriesTableTable extends ScreeningHistoriesTable
    with TableInfo<$ScreeningHistoriesTableTable, ScreeningHistoriesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScreeningHistoriesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _historyIdMeta = const VerificationMeta(
    'historyId',
  );
  @override
  late final GeneratedColumn<String> historyId = GeneratedColumn<String>(
    'history_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _screeningIdMeta = const VerificationMeta(
    'screeningId',
  );
  @override
  late final GeneratedColumn<String> screeningId = GeneratedColumn<String>(
    'screening_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _questionIdMeta = const VerificationMeta(
    'questionId',
  );
  @override
  late final GeneratedColumn<String> questionId = GeneratedColumn<String>(
    'question_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _questionTextMeta = const VerificationMeta(
    'questionText',
  );
  @override
  late final GeneratedColumn<String> questionText = GeneratedColumn<String>(
    'question_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _answerValueMeta = const VerificationMeta(
    'answerValue',
  );
  @override
  late final GeneratedColumn<double> answerValue = GeneratedColumn<double>(
    'answer_value',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _answerTextMeta = const VerificationMeta(
    'answerText',
  );
  @override
  late final GeneratedColumn<String> answerText = GeneratedColumn<String>(
    'answer_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    historyId,
    screeningId,
    questionId,
    questionText,
    answerValue,
    answerText,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'screening_histories';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScreeningHistoriesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('history_id')) {
      context.handle(
        _historyIdMeta,
        historyId.isAcceptableOrUnknown(data['history_id']!, _historyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_historyIdMeta);
    }
    if (data.containsKey('screening_id')) {
      context.handle(
        _screeningIdMeta,
        screeningId.isAcceptableOrUnknown(
          data['screening_id']!,
          _screeningIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_screeningIdMeta);
    }
    if (data.containsKey('question_id')) {
      context.handle(
        _questionIdMeta,
        questionId.isAcceptableOrUnknown(data['question_id']!, _questionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_questionIdMeta);
    }
    if (data.containsKey('question_text')) {
      context.handle(
        _questionTextMeta,
        questionText.isAcceptableOrUnknown(
          data['question_text']!,
          _questionTextMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_questionTextMeta);
    }
    if (data.containsKey('answer_value')) {
      context.handle(
        _answerValueMeta,
        answerValue.isAcceptableOrUnknown(
          data['answer_value']!,
          _answerValueMeta,
        ),
      );
    }
    if (data.containsKey('answer_text')) {
      context.handle(
        _answerTextMeta,
        answerText.isAcceptableOrUnknown(data['answer_text']!, _answerTextMeta),
      );
    } else if (isInserting) {
      context.missing(_answerTextMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {historyId};
  @override
  ScreeningHistoriesTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScreeningHistoriesTableData(
      historyId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}history_id'],
          )!,
      screeningId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}screening_id'],
          )!,
      questionId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}question_id'],
          )!,
      questionText:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}question_text'],
          )!,
      answerValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}answer_value'],
      ),
      answerText:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}answer_text'],
          )!,
    );
  }

  @override
  $ScreeningHistoriesTableTable createAlias(String alias) {
    return $ScreeningHistoriesTableTable(attachedDatabase, alias);
  }
}

class ScreeningHistoriesTableData extends DataClass
    implements Insertable<ScreeningHistoriesTableData> {
  final String historyId;
  final String screeningId;
  final String questionId;
  final String questionText;
  final double? answerValue;
  final String answerText;
  const ScreeningHistoriesTableData({
    required this.historyId,
    required this.screeningId,
    required this.questionId,
    required this.questionText,
    this.answerValue,
    required this.answerText,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['history_id'] = Variable<String>(historyId);
    map['screening_id'] = Variable<String>(screeningId);
    map['question_id'] = Variable<String>(questionId);
    map['question_text'] = Variable<String>(questionText);
    if (!nullToAbsent || answerValue != null) {
      map['answer_value'] = Variable<double>(answerValue);
    }
    map['answer_text'] = Variable<String>(answerText);
    return map;
  }

  ScreeningHistoriesTableCompanion toCompanion(bool nullToAbsent) {
    return ScreeningHistoriesTableCompanion(
      historyId: Value(historyId),
      screeningId: Value(screeningId),
      questionId: Value(questionId),
      questionText: Value(questionText),
      answerValue:
          answerValue == null && nullToAbsent
              ? const Value.absent()
              : Value(answerValue),
      answerText: Value(answerText),
    );
  }

  factory ScreeningHistoriesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScreeningHistoriesTableData(
      historyId: serializer.fromJson<String>(json['historyId']),
      screeningId: serializer.fromJson<String>(json['screeningId']),
      questionId: serializer.fromJson<String>(json['questionId']),
      questionText: serializer.fromJson<String>(json['questionText']),
      answerValue: serializer.fromJson<double?>(json['answerValue']),
      answerText: serializer.fromJson<String>(json['answerText']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'historyId': serializer.toJson<String>(historyId),
      'screeningId': serializer.toJson<String>(screeningId),
      'questionId': serializer.toJson<String>(questionId),
      'questionText': serializer.toJson<String>(questionText),
      'answerValue': serializer.toJson<double?>(answerValue),
      'answerText': serializer.toJson<String>(answerText),
    };
  }

  ScreeningHistoriesTableData copyWith({
    String? historyId,
    String? screeningId,
    String? questionId,
    String? questionText,
    Value<double?> answerValue = const Value.absent(),
    String? answerText,
  }) => ScreeningHistoriesTableData(
    historyId: historyId ?? this.historyId,
    screeningId: screeningId ?? this.screeningId,
    questionId: questionId ?? this.questionId,
    questionText: questionText ?? this.questionText,
    answerValue: answerValue.present ? answerValue.value : this.answerValue,
    answerText: answerText ?? this.answerText,
  );
  ScreeningHistoriesTableData copyWithCompanion(
    ScreeningHistoriesTableCompanion data,
  ) {
    return ScreeningHistoriesTableData(
      historyId: data.historyId.present ? data.historyId.value : this.historyId,
      screeningId:
          data.screeningId.present ? data.screeningId.value : this.screeningId,
      questionId:
          data.questionId.present ? data.questionId.value : this.questionId,
      questionText:
          data.questionText.present
              ? data.questionText.value
              : this.questionText,
      answerValue:
          data.answerValue.present ? data.answerValue.value : this.answerValue,
      answerText:
          data.answerText.present ? data.answerText.value : this.answerText,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScreeningHistoriesTableData(')
          ..write('historyId: $historyId, ')
          ..write('screeningId: $screeningId, ')
          ..write('questionId: $questionId, ')
          ..write('questionText: $questionText, ')
          ..write('answerValue: $answerValue, ')
          ..write('answerText: $answerText')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    historyId,
    screeningId,
    questionId,
    questionText,
    answerValue,
    answerText,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScreeningHistoriesTableData &&
          other.historyId == this.historyId &&
          other.screeningId == this.screeningId &&
          other.questionId == this.questionId &&
          other.questionText == this.questionText &&
          other.answerValue == this.answerValue &&
          other.answerText == this.answerText);
}

class ScreeningHistoriesTableCompanion
    extends UpdateCompanion<ScreeningHistoriesTableData> {
  final Value<String> historyId;
  final Value<String> screeningId;
  final Value<String> questionId;
  final Value<String> questionText;
  final Value<double?> answerValue;
  final Value<String> answerText;
  final Value<int> rowid;
  const ScreeningHistoriesTableCompanion({
    this.historyId = const Value.absent(),
    this.screeningId = const Value.absent(),
    this.questionId = const Value.absent(),
    this.questionText = const Value.absent(),
    this.answerValue = const Value.absent(),
    this.answerText = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ScreeningHistoriesTableCompanion.insert({
    required String historyId,
    required String screeningId,
    required String questionId,
    required String questionText,
    this.answerValue = const Value.absent(),
    required String answerText,
    this.rowid = const Value.absent(),
  }) : historyId = Value(historyId),
       screeningId = Value(screeningId),
       questionId = Value(questionId),
       questionText = Value(questionText),
       answerText = Value(answerText);
  static Insertable<ScreeningHistoriesTableData> custom({
    Expression<String>? historyId,
    Expression<String>? screeningId,
    Expression<String>? questionId,
    Expression<String>? questionText,
    Expression<double>? answerValue,
    Expression<String>? answerText,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (historyId != null) 'history_id': historyId,
      if (screeningId != null) 'screening_id': screeningId,
      if (questionId != null) 'question_id': questionId,
      if (questionText != null) 'question_text': questionText,
      if (answerValue != null) 'answer_value': answerValue,
      if (answerText != null) 'answer_text': answerText,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ScreeningHistoriesTableCompanion copyWith({
    Value<String>? historyId,
    Value<String>? screeningId,
    Value<String>? questionId,
    Value<String>? questionText,
    Value<double?>? answerValue,
    Value<String>? answerText,
    Value<int>? rowid,
  }) {
    return ScreeningHistoriesTableCompanion(
      historyId: historyId ?? this.historyId,
      screeningId: screeningId ?? this.screeningId,
      questionId: questionId ?? this.questionId,
      questionText: questionText ?? this.questionText,
      answerValue: answerValue ?? this.answerValue,
      answerText: answerText ?? this.answerText,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (historyId.present) {
      map['history_id'] = Variable<String>(historyId.value);
    }
    if (screeningId.present) {
      map['screening_id'] = Variable<String>(screeningId.value);
    }
    if (questionId.present) {
      map['question_id'] = Variable<String>(questionId.value);
    }
    if (questionText.present) {
      map['question_text'] = Variable<String>(questionText.value);
    }
    if (answerValue.present) {
      map['answer_value'] = Variable<double>(answerValue.value);
    }
    if (answerText.present) {
      map['answer_text'] = Variable<String>(answerText.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScreeningHistoriesTableCompanion(')
          ..write('historyId: $historyId, ')
          ..write('screeningId: $screeningId, ')
          ..write('questionId: $questionId, ')
          ..write('questionText: $questionText, ')
          ..write('answerValue: $answerValue, ')
          ..write('answerText: $answerText, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ScreeningResultsTableTable extends ScreeningResultsTable
    with TableInfo<$ScreeningResultsTableTable, ScreeningResultsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScreeningResultsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _resultIdMeta = const VerificationMeta(
    'resultId',
  );
  @override
  late final GeneratedColumn<String> resultId = GeneratedColumn<String>(
    'result_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _screeningIdMeta = const VerificationMeta(
    'screeningId',
  );
  @override
  late final GeneratedColumn<String> screeningId = GeneratedColumn<String>(
    'screening_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _diseaseNameMeta = const VerificationMeta(
    'diseaseName',
  );
  @override
  late final GeneratedColumn<String> diseaseName = GeneratedColumn<String>(
    'disease_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _diseaseCodeMeta = const VerificationMeta(
    'diseaseCode',
  );
  @override
  late final GeneratedColumn<String> diseaseCode = GeneratedColumn<String>(
    'disease_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<int> score = GeneratedColumn<int>(
    'score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _riskLevelMeta = const VerificationMeta(
    'riskLevel',
  );
  @override
  late final GeneratedColumn<String> riskLevel = GeneratedColumn<String>(
    'risk_level',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _adviceTextMeta = const VerificationMeta(
    'adviceText',
  );
  @override
  late final GeneratedColumn<String> adviceText = GeneratedColumn<String>(
    'advice_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _criteriaTextMeta = const VerificationMeta(
    'criteriaText',
  );
  @override
  late final GeneratedColumn<String> criteriaText = GeneratedColumn<String>(
    'criteria_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    resultId,
    screeningId,
    diseaseName,
    diseaseCode,
    score,
    riskLevel,
    adviceText,
    criteriaText,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'screening_results';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScreeningResultsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('result_id')) {
      context.handle(
        _resultIdMeta,
        resultId.isAcceptableOrUnknown(data['result_id']!, _resultIdMeta),
      );
    } else if (isInserting) {
      context.missing(_resultIdMeta);
    }
    if (data.containsKey('screening_id')) {
      context.handle(
        _screeningIdMeta,
        screeningId.isAcceptableOrUnknown(
          data['screening_id']!,
          _screeningIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_screeningIdMeta);
    }
    if (data.containsKey('disease_name')) {
      context.handle(
        _diseaseNameMeta,
        diseaseName.isAcceptableOrUnknown(
          data['disease_name']!,
          _diseaseNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_diseaseNameMeta);
    }
    if (data.containsKey('disease_code')) {
      context.handle(
        _diseaseCodeMeta,
        diseaseCode.isAcceptableOrUnknown(
          data['disease_code']!,
          _diseaseCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_diseaseCodeMeta);
    }
    if (data.containsKey('score')) {
      context.handle(
        _scoreMeta,
        score.isAcceptableOrUnknown(data['score']!, _scoreMeta),
      );
    } else if (isInserting) {
      context.missing(_scoreMeta);
    }
    if (data.containsKey('risk_level')) {
      context.handle(
        _riskLevelMeta,
        riskLevel.isAcceptableOrUnknown(data['risk_level']!, _riskLevelMeta),
      );
    } else if (isInserting) {
      context.missing(_riskLevelMeta);
    }
    if (data.containsKey('advice_text')) {
      context.handle(
        _adviceTextMeta,
        adviceText.isAcceptableOrUnknown(data['advice_text']!, _adviceTextMeta),
      );
    } else if (isInserting) {
      context.missing(_adviceTextMeta);
    }
    if (data.containsKey('criteria_text')) {
      context.handle(
        _criteriaTextMeta,
        criteriaText.isAcceptableOrUnknown(
          data['criteria_text']!,
          _criteriaTextMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {resultId};
  @override
  ScreeningResultsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScreeningResultsTableData(
      resultId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}result_id'],
          )!,
      screeningId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}screening_id'],
          )!,
      diseaseName:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}disease_name'],
          )!,
      diseaseCode:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}disease_code'],
          )!,
      score:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}score'],
          )!,
      riskLevel:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}risk_level'],
          )!,
      adviceText:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}advice_text'],
          )!,
      criteriaText:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}criteria_text'],
          )!,
    );
  }

  @override
  $ScreeningResultsTableTable createAlias(String alias) {
    return $ScreeningResultsTableTable(attachedDatabase, alias);
  }
}

class ScreeningResultsTableData extends DataClass
    implements Insertable<ScreeningResultsTableData> {
  final String resultId;
  final String screeningId;
  final String diseaseName;
  final String diseaseCode;
  final int score;
  final String riskLevel;
  final String adviceText;
  final String criteriaText;
  const ScreeningResultsTableData({
    required this.resultId,
    required this.screeningId,
    required this.diseaseName,
    required this.diseaseCode,
    required this.score,
    required this.riskLevel,
    required this.adviceText,
    required this.criteriaText,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['result_id'] = Variable<String>(resultId);
    map['screening_id'] = Variable<String>(screeningId);
    map['disease_name'] = Variable<String>(diseaseName);
    map['disease_code'] = Variable<String>(diseaseCode);
    map['score'] = Variable<int>(score);
    map['risk_level'] = Variable<String>(riskLevel);
    map['advice_text'] = Variable<String>(adviceText);
    map['criteria_text'] = Variable<String>(criteriaText);
    return map;
  }

  ScreeningResultsTableCompanion toCompanion(bool nullToAbsent) {
    return ScreeningResultsTableCompanion(
      resultId: Value(resultId),
      screeningId: Value(screeningId),
      diseaseName: Value(diseaseName),
      diseaseCode: Value(diseaseCode),
      score: Value(score),
      riskLevel: Value(riskLevel),
      adviceText: Value(adviceText),
      criteriaText: Value(criteriaText),
    );
  }

  factory ScreeningResultsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScreeningResultsTableData(
      resultId: serializer.fromJson<String>(json['resultId']),
      screeningId: serializer.fromJson<String>(json['screeningId']),
      diseaseName: serializer.fromJson<String>(json['diseaseName']),
      diseaseCode: serializer.fromJson<String>(json['diseaseCode']),
      score: serializer.fromJson<int>(json['score']),
      riskLevel: serializer.fromJson<String>(json['riskLevel']),
      adviceText: serializer.fromJson<String>(json['adviceText']),
      criteriaText: serializer.fromJson<String>(json['criteriaText']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'resultId': serializer.toJson<String>(resultId),
      'screeningId': serializer.toJson<String>(screeningId),
      'diseaseName': serializer.toJson<String>(diseaseName),
      'diseaseCode': serializer.toJson<String>(diseaseCode),
      'score': serializer.toJson<int>(score),
      'riskLevel': serializer.toJson<String>(riskLevel),
      'adviceText': serializer.toJson<String>(adviceText),
      'criteriaText': serializer.toJson<String>(criteriaText),
    };
  }

  ScreeningResultsTableData copyWith({
    String? resultId,
    String? screeningId,
    String? diseaseName,
    String? diseaseCode,
    int? score,
    String? riskLevel,
    String? adviceText,
    String? criteriaText,
  }) => ScreeningResultsTableData(
    resultId: resultId ?? this.resultId,
    screeningId: screeningId ?? this.screeningId,
    diseaseName: diseaseName ?? this.diseaseName,
    diseaseCode: diseaseCode ?? this.diseaseCode,
    score: score ?? this.score,
    riskLevel: riskLevel ?? this.riskLevel,
    adviceText: adviceText ?? this.adviceText,
    criteriaText: criteriaText ?? this.criteriaText,
  );
  ScreeningResultsTableData copyWithCompanion(
    ScreeningResultsTableCompanion data,
  ) {
    return ScreeningResultsTableData(
      resultId: data.resultId.present ? data.resultId.value : this.resultId,
      screeningId:
          data.screeningId.present ? data.screeningId.value : this.screeningId,
      diseaseName:
          data.diseaseName.present ? data.diseaseName.value : this.diseaseName,
      diseaseCode:
          data.diseaseCode.present ? data.diseaseCode.value : this.diseaseCode,
      score: data.score.present ? data.score.value : this.score,
      riskLevel: data.riskLevel.present ? data.riskLevel.value : this.riskLevel,
      adviceText:
          data.adviceText.present ? data.adviceText.value : this.adviceText,
      criteriaText:
          data.criteriaText.present
              ? data.criteriaText.value
              : this.criteriaText,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScreeningResultsTableData(')
          ..write('resultId: $resultId, ')
          ..write('screeningId: $screeningId, ')
          ..write('diseaseName: $diseaseName, ')
          ..write('diseaseCode: $diseaseCode, ')
          ..write('score: $score, ')
          ..write('riskLevel: $riskLevel, ')
          ..write('adviceText: $adviceText, ')
          ..write('criteriaText: $criteriaText')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    resultId,
    screeningId,
    diseaseName,
    diseaseCode,
    score,
    riskLevel,
    adviceText,
    criteriaText,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScreeningResultsTableData &&
          other.resultId == this.resultId &&
          other.screeningId == this.screeningId &&
          other.diseaseName == this.diseaseName &&
          other.diseaseCode == this.diseaseCode &&
          other.score == this.score &&
          other.riskLevel == this.riskLevel &&
          other.adviceText == this.adviceText &&
          other.criteriaText == this.criteriaText);
}

class ScreeningResultsTableCompanion
    extends UpdateCompanion<ScreeningResultsTableData> {
  final Value<String> resultId;
  final Value<String> screeningId;
  final Value<String> diseaseName;
  final Value<String> diseaseCode;
  final Value<int> score;
  final Value<String> riskLevel;
  final Value<String> adviceText;
  final Value<String> criteriaText;
  final Value<int> rowid;
  const ScreeningResultsTableCompanion({
    this.resultId = const Value.absent(),
    this.screeningId = const Value.absent(),
    this.diseaseName = const Value.absent(),
    this.diseaseCode = const Value.absent(),
    this.score = const Value.absent(),
    this.riskLevel = const Value.absent(),
    this.adviceText = const Value.absent(),
    this.criteriaText = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ScreeningResultsTableCompanion.insert({
    required String resultId,
    required String screeningId,
    required String diseaseName,
    required String diseaseCode,
    required int score,
    required String riskLevel,
    required String adviceText,
    this.criteriaText = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : resultId = Value(resultId),
       screeningId = Value(screeningId),
       diseaseName = Value(diseaseName),
       diseaseCode = Value(diseaseCode),
       score = Value(score),
       riskLevel = Value(riskLevel),
       adviceText = Value(adviceText);
  static Insertable<ScreeningResultsTableData> custom({
    Expression<String>? resultId,
    Expression<String>? screeningId,
    Expression<String>? diseaseName,
    Expression<String>? diseaseCode,
    Expression<int>? score,
    Expression<String>? riskLevel,
    Expression<String>? adviceText,
    Expression<String>? criteriaText,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (resultId != null) 'result_id': resultId,
      if (screeningId != null) 'screening_id': screeningId,
      if (diseaseName != null) 'disease_name': diseaseName,
      if (diseaseCode != null) 'disease_code': diseaseCode,
      if (score != null) 'score': score,
      if (riskLevel != null) 'risk_level': riskLevel,
      if (adviceText != null) 'advice_text': adviceText,
      if (criteriaText != null) 'criteria_text': criteriaText,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ScreeningResultsTableCompanion copyWith({
    Value<String>? resultId,
    Value<String>? screeningId,
    Value<String>? diseaseName,
    Value<String>? diseaseCode,
    Value<int>? score,
    Value<String>? riskLevel,
    Value<String>? adviceText,
    Value<String>? criteriaText,
    Value<int>? rowid,
  }) {
    return ScreeningResultsTableCompanion(
      resultId: resultId ?? this.resultId,
      screeningId: screeningId ?? this.screeningId,
      diseaseName: diseaseName ?? this.diseaseName,
      diseaseCode: diseaseCode ?? this.diseaseCode,
      score: score ?? this.score,
      riskLevel: riskLevel ?? this.riskLevel,
      adviceText: adviceText ?? this.adviceText,
      criteriaText: criteriaText ?? this.criteriaText,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (resultId.present) {
      map['result_id'] = Variable<String>(resultId.value);
    }
    if (screeningId.present) {
      map['screening_id'] = Variable<String>(screeningId.value);
    }
    if (diseaseName.present) {
      map['disease_name'] = Variable<String>(diseaseName.value);
    }
    if (diseaseCode.present) {
      map['disease_code'] = Variable<String>(diseaseCode.value);
    }
    if (score.present) {
      map['score'] = Variable<int>(score.value);
    }
    if (riskLevel.present) {
      map['risk_level'] = Variable<String>(riskLevel.value);
    }
    if (adviceText.present) {
      map['advice_text'] = Variable<String>(adviceText.value);
    }
    if (criteriaText.present) {
      map['criteria_text'] = Variable<String>(criteriaText.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScreeningResultsTableCompanion(')
          ..write('resultId: $resultId, ')
          ..write('screeningId: $screeningId, ')
          ..write('diseaseName: $diseaseName, ')
          ..write('diseaseCode: $diseaseCode, ')
          ..write('score: $score, ')
          ..write('riskLevel: $riskLevel, ')
          ..write('adviceText: $adviceText, ')
          ..write('criteriaText: $criteriaText, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueTableTable extends SyncQueueTable
    with TableInfo<$SyncQueueTableTable, SyncQueueTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _retryCountMeta = const VerificationMeta(
    'retryCount',
  );
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _errorMessageMeta = const VerificationMeta(
    'errorMessage',
  );
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
    'error_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entityType,
    entityId,
    action,
    payload,
    createdAt,
    retryCount,
    status,
    errorMessage,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncQueueTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('error_message')) {
      context.handle(
        _errorMessageMeta,
        errorMessage.isAcceptableOrUnknown(
          data['error_message']!,
          _errorMessageMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueTableData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      entityType:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}entity_type'],
          )!,
      entityId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}entity_id'],
          )!,
      action:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}action'],
          )!,
      payload:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}payload'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      retryCount:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}retry_count'],
          )!,
      status:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}status'],
          )!,
      errorMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_message'],
      ),
    );
  }

  @override
  $SyncQueueTableTable createAlias(String alias) {
    return $SyncQueueTableTable(attachedDatabase, alias);
  }
}

class SyncQueueTableData extends DataClass
    implements Insertable<SyncQueueTableData> {
  final String id;
  final String entityType;
  final String entityId;
  final String action;
  final String payload;
  final DateTime createdAt;
  final int retryCount;
  final String status;
  final String? errorMessage;
  const SyncQueueTableData({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.action,
    required this.payload,
    required this.createdAt,
    required this.retryCount,
    required this.status,
    this.errorMessage,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['action'] = Variable<String>(action);
    map['payload'] = Variable<String>(payload);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['retry_count'] = Variable<int>(retryCount);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    return map;
  }

  SyncQueueTableCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueTableCompanion(
      id: Value(id),
      entityType: Value(entityType),
      entityId: Value(entityId),
      action: Value(action),
      payload: Value(payload),
      createdAt: Value(createdAt),
      retryCount: Value(retryCount),
      status: Value(status),
      errorMessage:
          errorMessage == null && nullToAbsent
              ? const Value.absent()
              : Value(errorMessage),
    );
  }

  factory SyncQueueTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueTableData(
      id: serializer.fromJson<String>(json['id']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      action: serializer.fromJson<String>(json['action']),
      payload: serializer.fromJson<String>(json['payload']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      status: serializer.fromJson<String>(json['status']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'action': serializer.toJson<String>(action),
      'payload': serializer.toJson<String>(payload),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'retryCount': serializer.toJson<int>(retryCount),
      'status': serializer.toJson<String>(status),
      'errorMessage': serializer.toJson<String?>(errorMessage),
    };
  }

  SyncQueueTableData copyWith({
    String? id,
    String? entityType,
    String? entityId,
    String? action,
    String? payload,
    DateTime? createdAt,
    int? retryCount,
    String? status,
    Value<String?> errorMessage = const Value.absent(),
  }) => SyncQueueTableData(
    id: id ?? this.id,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    action: action ?? this.action,
    payload: payload ?? this.payload,
    createdAt: createdAt ?? this.createdAt,
    retryCount: retryCount ?? this.retryCount,
    status: status ?? this.status,
    errorMessage: errorMessage.present ? errorMessage.value : this.errorMessage,
  );
  SyncQueueTableData copyWithCompanion(SyncQueueTableCompanion data) {
    return SyncQueueTableData(
      id: data.id.present ? data.id.value : this.id,
      entityType:
          data.entityType.present ? data.entityType.value : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      action: data.action.present ? data.action.value : this.action,
      payload: data.payload.present ? data.payload.value : this.payload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      retryCount:
          data.retryCount.present ? data.retryCount.value : this.retryCount,
      status: data.status.present ? data.status.value : this.status,
      errorMessage:
          data.errorMessage.present
              ? data.errorMessage.value
              : this.errorMessage,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueTableData(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('action: $action, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('status: $status, ')
          ..write('errorMessage: $errorMessage')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    entityType,
    entityId,
    action,
    payload,
    createdAt,
    retryCount,
    status,
    errorMessage,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueTableData &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.action == this.action &&
          other.payload == this.payload &&
          other.createdAt == this.createdAt &&
          other.retryCount == this.retryCount &&
          other.status == this.status &&
          other.errorMessage == this.errorMessage);
}

class SyncQueueTableCompanion extends UpdateCompanion<SyncQueueTableData> {
  final Value<String> id;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> action;
  final Value<String> payload;
  final Value<DateTime> createdAt;
  final Value<int> retryCount;
  final Value<String> status;
  final Value<String?> errorMessage;
  final Value<int> rowid;
  const SyncQueueTableCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.action = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.status = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncQueueTableCompanion.insert({
    required String id,
    required String entityType,
    required String entityId,
    required String action,
    required String payload,
    required DateTime createdAt,
    this.retryCount = const Value.absent(),
    this.status = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       entityType = Value(entityType),
       entityId = Value(entityId),
       action = Value(action),
       payload = Value(payload),
       createdAt = Value(createdAt);
  static Insertable<SyncQueueTableData> custom({
    Expression<String>? id,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? action,
    Expression<String>? payload,
    Expression<DateTime>? createdAt,
    Expression<int>? retryCount,
    Expression<String>? status,
    Expression<String>? errorMessage,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (action != null) 'action': action,
      if (payload != null) 'payload': payload,
      if (createdAt != null) 'created_at': createdAt,
      if (retryCount != null) 'retry_count': retryCount,
      if (status != null) 'status': status,
      if (errorMessage != null) 'error_message': errorMessage,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncQueueTableCompanion copyWith({
    Value<String>? id,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? action,
    Value<String>? payload,
    Value<DateTime>? createdAt,
    Value<int>? retryCount,
    Value<String>? status,
    Value<String?>? errorMessage,
    Value<int>? rowid,
  }) {
    return SyncQueueTableCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      action: action ?? this.action,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      retryCount: retryCount ?? this.retryCount,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueTableCompanion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('action: $action, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('status: $status, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ScreeningDraftsTableTable extends ScreeningDraftsTable
    with TableInfo<$ScreeningDraftsTableTable, ScreeningDraftsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScreeningDraftsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _patientIdMeta = const VerificationMeta(
    'patientId',
  );
  @override
  late final GeneratedColumn<String> patientId = GeneratedColumn<String>(
    'patient_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vhvIdMeta = const VerificationMeta('vhvId');
  @override
  late final GeneratedColumn<String> vhvId = GeneratedColumn<String>(
    'vhv_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [patientId, vhvId, payload, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'screening_drafts';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScreeningDraftsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('patient_id')) {
      context.handle(
        _patientIdMeta,
        patientId.isAcceptableOrUnknown(data['patient_id']!, _patientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_patientIdMeta);
    }
    if (data.containsKey('vhv_id')) {
      context.handle(
        _vhvIdMeta,
        vhvId.isAcceptableOrUnknown(data['vhv_id']!, _vhvIdMeta),
      );
    } else if (isInserting) {
      context.missing(_vhvIdMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {patientId, vhvId};
  @override
  ScreeningDraftsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScreeningDraftsTableData(
      patientId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}patient_id'],
          )!,
      vhvId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}vhv_id'],
          )!,
      payload:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}payload'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_at'],
          )!,
    );
  }

  @override
  $ScreeningDraftsTableTable createAlias(String alias) {
    return $ScreeningDraftsTableTable(attachedDatabase, alias);
  }
}

class ScreeningDraftsTableData extends DataClass
    implements Insertable<ScreeningDraftsTableData> {
  final String patientId;
  final String vhvId;
  final String payload;
  final DateTime updatedAt;
  const ScreeningDraftsTableData({
    required this.patientId,
    required this.vhvId,
    required this.payload,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['patient_id'] = Variable<String>(patientId);
    map['vhv_id'] = Variable<String>(vhvId);
    map['payload'] = Variable<String>(payload);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ScreeningDraftsTableCompanion toCompanion(bool nullToAbsent) {
    return ScreeningDraftsTableCompanion(
      patientId: Value(patientId),
      vhvId: Value(vhvId),
      payload: Value(payload),
      updatedAt: Value(updatedAt),
    );
  }

  factory ScreeningDraftsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScreeningDraftsTableData(
      patientId: serializer.fromJson<String>(json['patientId']),
      vhvId: serializer.fromJson<String>(json['vhvId']),
      payload: serializer.fromJson<String>(json['payload']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'patientId': serializer.toJson<String>(patientId),
      'vhvId': serializer.toJson<String>(vhvId),
      'payload': serializer.toJson<String>(payload),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ScreeningDraftsTableData copyWith({
    String? patientId,
    String? vhvId,
    String? payload,
    DateTime? updatedAt,
  }) => ScreeningDraftsTableData(
    patientId: patientId ?? this.patientId,
    vhvId: vhvId ?? this.vhvId,
    payload: payload ?? this.payload,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ScreeningDraftsTableData copyWithCompanion(
    ScreeningDraftsTableCompanion data,
  ) {
    return ScreeningDraftsTableData(
      patientId: data.patientId.present ? data.patientId.value : this.patientId,
      vhvId: data.vhvId.present ? data.vhvId.value : this.vhvId,
      payload: data.payload.present ? data.payload.value : this.payload,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScreeningDraftsTableData(')
          ..write('patientId: $patientId, ')
          ..write('vhvId: $vhvId, ')
          ..write('payload: $payload, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(patientId, vhvId, payload, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScreeningDraftsTableData &&
          other.patientId == this.patientId &&
          other.vhvId == this.vhvId &&
          other.payload == this.payload &&
          other.updatedAt == this.updatedAt);
}

class ScreeningDraftsTableCompanion
    extends UpdateCompanion<ScreeningDraftsTableData> {
  final Value<String> patientId;
  final Value<String> vhvId;
  final Value<String> payload;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ScreeningDraftsTableCompanion({
    this.patientId = const Value.absent(),
    this.vhvId = const Value.absent(),
    this.payload = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ScreeningDraftsTableCompanion.insert({
    required String patientId,
    required String vhvId,
    required String payload,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : patientId = Value(patientId),
       vhvId = Value(vhvId),
       payload = Value(payload),
       updatedAt = Value(updatedAt);
  static Insertable<ScreeningDraftsTableData> custom({
    Expression<String>? patientId,
    Expression<String>? vhvId,
    Expression<String>? payload,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (patientId != null) 'patient_id': patientId,
      if (vhvId != null) 'vhv_id': vhvId,
      if (payload != null) 'payload': payload,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ScreeningDraftsTableCompanion copyWith({
    Value<String>? patientId,
    Value<String>? vhvId,
    Value<String>? payload,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ScreeningDraftsTableCompanion(
      patientId: patientId ?? this.patientId,
      vhvId: vhvId ?? this.vhvId,
      payload: payload ?? this.payload,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (patientId.present) {
      map['patient_id'] = Variable<String>(patientId.value);
    }
    if (vhvId.present) {
      map['vhv_id'] = Variable<String>(vhvId.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScreeningDraftsTableCompanion(')
          ..write('patientId: $patientId, ')
          ..write('vhvId: $vhvId, ')
          ..write('payload: $payload, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $VillagesTableTable villagesTable = $VillagesTableTable(this);
  late final $NursesTableTable nursesTable = $NursesTableTable(this);
  late final $VhvsTableTable vhvsTable = $VhvsTableTable(this);
  late final $PatientsTableTable patientsTable = $PatientsTableTable(this);
  late final $ScreeningsTableTable screeningsTable = $ScreeningsTableTable(
    this,
  );
  late final $ScreeningHistoriesTableTable screeningHistoriesTable =
      $ScreeningHistoriesTableTable(this);
  late final $ScreeningResultsTableTable screeningResultsTable =
      $ScreeningResultsTableTable(this);
  late final $SyncQueueTableTable syncQueueTable = $SyncQueueTableTable(this);
  late final $ScreeningDraftsTableTable screeningDraftsTable =
      $ScreeningDraftsTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    villagesTable,
    nursesTable,
    vhvsTable,
    patientsTable,
    screeningsTable,
    screeningHistoriesTable,
    screeningResultsTable,
    syncQueueTable,
    screeningDraftsTable,
  ];
}

typedef $$VillagesTableTableCreateCompanionBuilder =
    VillagesTableCompanion Function({
      required String villageId,
      required String villageName,
      required String villageNumber,
      Value<String> subdistrictId,
      Value<String> subdistrictName,
      Value<String> districtName,
      Value<String> provinceName,
      Value<int> rowid,
    });
typedef $$VillagesTableTableUpdateCompanionBuilder =
    VillagesTableCompanion Function({
      Value<String> villageId,
      Value<String> villageName,
      Value<String> villageNumber,
      Value<String> subdistrictId,
      Value<String> subdistrictName,
      Value<String> districtName,
      Value<String> provinceName,
      Value<int> rowid,
    });

class $$VillagesTableTableFilterComposer
    extends Composer<_$AppDatabase, $VillagesTableTable> {
  $$VillagesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get villageId => $composableBuilder(
    column: $table.villageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get villageName => $composableBuilder(
    column: $table.villageName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get villageNumber => $composableBuilder(
    column: $table.villageNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subdistrictId => $composableBuilder(
    column: $table.subdistrictId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subdistrictName => $composableBuilder(
    column: $table.subdistrictName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get districtName => $composableBuilder(
    column: $table.districtName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get provinceName => $composableBuilder(
    column: $table.provinceName,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VillagesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $VillagesTableTable> {
  $$VillagesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get villageId => $composableBuilder(
    column: $table.villageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get villageName => $composableBuilder(
    column: $table.villageName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get villageNumber => $composableBuilder(
    column: $table.villageNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subdistrictId => $composableBuilder(
    column: $table.subdistrictId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subdistrictName => $composableBuilder(
    column: $table.subdistrictName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get districtName => $composableBuilder(
    column: $table.districtName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get provinceName => $composableBuilder(
    column: $table.provinceName,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VillagesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $VillagesTableTable> {
  $$VillagesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get villageId =>
      $composableBuilder(column: $table.villageId, builder: (column) => column);

  GeneratedColumn<String> get villageName => $composableBuilder(
    column: $table.villageName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get villageNumber => $composableBuilder(
    column: $table.villageNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get subdistrictId => $composableBuilder(
    column: $table.subdistrictId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get subdistrictName => $composableBuilder(
    column: $table.subdistrictName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get districtName => $composableBuilder(
    column: $table.districtName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get provinceName => $composableBuilder(
    column: $table.provinceName,
    builder: (column) => column,
  );
}

class $$VillagesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VillagesTableTable,
          VillagesTableData,
          $$VillagesTableTableFilterComposer,
          $$VillagesTableTableOrderingComposer,
          $$VillagesTableTableAnnotationComposer,
          $$VillagesTableTableCreateCompanionBuilder,
          $$VillagesTableTableUpdateCompanionBuilder,
          (
            VillagesTableData,
            BaseReferences<
              _$AppDatabase,
              $VillagesTableTable,
              VillagesTableData
            >,
          ),
          VillagesTableData,
          PrefetchHooks Function()
        > {
  $$VillagesTableTableTableManager(_$AppDatabase db, $VillagesTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$VillagesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$VillagesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$VillagesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> villageId = const Value.absent(),
                Value<String> villageName = const Value.absent(),
                Value<String> villageNumber = const Value.absent(),
                Value<String> subdistrictId = const Value.absent(),
                Value<String> subdistrictName = const Value.absent(),
                Value<String> districtName = const Value.absent(),
                Value<String> provinceName = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VillagesTableCompanion(
                villageId: villageId,
                villageName: villageName,
                villageNumber: villageNumber,
                subdistrictId: subdistrictId,
                subdistrictName: subdistrictName,
                districtName: districtName,
                provinceName: provinceName,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String villageId,
                required String villageName,
                required String villageNumber,
                Value<String> subdistrictId = const Value.absent(),
                Value<String> subdistrictName = const Value.absent(),
                Value<String> districtName = const Value.absent(),
                Value<String> provinceName = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VillagesTableCompanion.insert(
                villageId: villageId,
                villageName: villageName,
                villageNumber: villageNumber,
                subdistrictId: subdistrictId,
                subdistrictName: subdistrictName,
                districtName: districtName,
                provinceName: provinceName,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VillagesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VillagesTableTable,
      VillagesTableData,
      $$VillagesTableTableFilterComposer,
      $$VillagesTableTableOrderingComposer,
      $$VillagesTableTableAnnotationComposer,
      $$VillagesTableTableCreateCompanionBuilder,
      $$VillagesTableTableUpdateCompanionBuilder,
      (
        VillagesTableData,
        BaseReferences<_$AppDatabase, $VillagesTableTable, VillagesTableData>,
      ),
      VillagesTableData,
      PrefetchHooks Function()
    >;
typedef $$NursesTableTableCreateCompanionBuilder =
    NursesTableCompanion Function({
      required String nurseId,
      required String nurseTitle,
      required String nurseFname,
      required String nurseLname,
      required String nurseMobile,
      required String nurseEmail,
      required String nursePassword,
      required String nurseGender,
      required DateTime nurseBirthDate,
      Value<String?> nurseImg,
      Value<String> subdistrictId,
      Value<int> rowid,
    });
typedef $$NursesTableTableUpdateCompanionBuilder =
    NursesTableCompanion Function({
      Value<String> nurseId,
      Value<String> nurseTitle,
      Value<String> nurseFname,
      Value<String> nurseLname,
      Value<String> nurseMobile,
      Value<String> nurseEmail,
      Value<String> nursePassword,
      Value<String> nurseGender,
      Value<DateTime> nurseBirthDate,
      Value<String?> nurseImg,
      Value<String> subdistrictId,
      Value<int> rowid,
    });

class $$NursesTableTableFilterComposer
    extends Composer<_$AppDatabase, $NursesTableTable> {
  $$NursesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get nurseId => $composableBuilder(
    column: $table.nurseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nurseTitle => $composableBuilder(
    column: $table.nurseTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nurseFname => $composableBuilder(
    column: $table.nurseFname,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nurseLname => $composableBuilder(
    column: $table.nurseLname,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nurseMobile => $composableBuilder(
    column: $table.nurseMobile,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nurseEmail => $composableBuilder(
    column: $table.nurseEmail,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nursePassword => $composableBuilder(
    column: $table.nursePassword,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nurseGender => $composableBuilder(
    column: $table.nurseGender,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nurseBirthDate => $composableBuilder(
    column: $table.nurseBirthDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nurseImg => $composableBuilder(
    column: $table.nurseImg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subdistrictId => $composableBuilder(
    column: $table.subdistrictId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NursesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $NursesTableTable> {
  $$NursesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get nurseId => $composableBuilder(
    column: $table.nurseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nurseTitle => $composableBuilder(
    column: $table.nurseTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nurseFname => $composableBuilder(
    column: $table.nurseFname,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nurseLname => $composableBuilder(
    column: $table.nurseLname,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nurseMobile => $composableBuilder(
    column: $table.nurseMobile,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nurseEmail => $composableBuilder(
    column: $table.nurseEmail,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nursePassword => $composableBuilder(
    column: $table.nursePassword,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nurseGender => $composableBuilder(
    column: $table.nurseGender,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nurseBirthDate => $composableBuilder(
    column: $table.nurseBirthDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nurseImg => $composableBuilder(
    column: $table.nurseImg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subdistrictId => $composableBuilder(
    column: $table.subdistrictId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NursesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $NursesTableTable> {
  $$NursesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get nurseId =>
      $composableBuilder(column: $table.nurseId, builder: (column) => column);

  GeneratedColumn<String> get nurseTitle => $composableBuilder(
    column: $table.nurseTitle,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nurseFname => $composableBuilder(
    column: $table.nurseFname,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nurseLname => $composableBuilder(
    column: $table.nurseLname,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nurseMobile => $composableBuilder(
    column: $table.nurseMobile,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nurseEmail => $composableBuilder(
    column: $table.nurseEmail,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nursePassword => $composableBuilder(
    column: $table.nursePassword,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nurseGender => $composableBuilder(
    column: $table.nurseGender,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get nurseBirthDate => $composableBuilder(
    column: $table.nurseBirthDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nurseImg =>
      $composableBuilder(column: $table.nurseImg, builder: (column) => column);

  GeneratedColumn<String> get subdistrictId => $composableBuilder(
    column: $table.subdistrictId,
    builder: (column) => column,
  );
}

class $$NursesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NursesTableTable,
          NursesTableData,
          $$NursesTableTableFilterComposer,
          $$NursesTableTableOrderingComposer,
          $$NursesTableTableAnnotationComposer,
          $$NursesTableTableCreateCompanionBuilder,
          $$NursesTableTableUpdateCompanionBuilder,
          (
            NursesTableData,
            BaseReferences<_$AppDatabase, $NursesTableTable, NursesTableData>,
          ),
          NursesTableData,
          PrefetchHooks Function()
        > {
  $$NursesTableTableTableManager(_$AppDatabase db, $NursesTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$NursesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$NursesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () =>
                  $$NursesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> nurseId = const Value.absent(),
                Value<String> nurseTitle = const Value.absent(),
                Value<String> nurseFname = const Value.absent(),
                Value<String> nurseLname = const Value.absent(),
                Value<String> nurseMobile = const Value.absent(),
                Value<String> nurseEmail = const Value.absent(),
                Value<String> nursePassword = const Value.absent(),
                Value<String> nurseGender = const Value.absent(),
                Value<DateTime> nurseBirthDate = const Value.absent(),
                Value<String?> nurseImg = const Value.absent(),
                Value<String> subdistrictId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NursesTableCompanion(
                nurseId: nurseId,
                nurseTitle: nurseTitle,
                nurseFname: nurseFname,
                nurseLname: nurseLname,
                nurseMobile: nurseMobile,
                nurseEmail: nurseEmail,
                nursePassword: nursePassword,
                nurseGender: nurseGender,
                nurseBirthDate: nurseBirthDate,
                nurseImg: nurseImg,
                subdistrictId: subdistrictId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String nurseId,
                required String nurseTitle,
                required String nurseFname,
                required String nurseLname,
                required String nurseMobile,
                required String nurseEmail,
                required String nursePassword,
                required String nurseGender,
                required DateTime nurseBirthDate,
                Value<String?> nurseImg = const Value.absent(),
                Value<String> subdistrictId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NursesTableCompanion.insert(
                nurseId: nurseId,
                nurseTitle: nurseTitle,
                nurseFname: nurseFname,
                nurseLname: nurseLname,
                nurseMobile: nurseMobile,
                nurseEmail: nurseEmail,
                nursePassword: nursePassword,
                nurseGender: nurseGender,
                nurseBirthDate: nurseBirthDate,
                nurseImg: nurseImg,
                subdistrictId: subdistrictId,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NursesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NursesTableTable,
      NursesTableData,
      $$NursesTableTableFilterComposer,
      $$NursesTableTableOrderingComposer,
      $$NursesTableTableAnnotationComposer,
      $$NursesTableTableCreateCompanionBuilder,
      $$NursesTableTableUpdateCompanionBuilder,
      (
        NursesTableData,
        BaseReferences<_$AppDatabase, $NursesTableTable, NursesTableData>,
      ),
      NursesTableData,
      PrefetchHooks Function()
    >;
typedef $$VhvsTableTableCreateCompanionBuilder =
    VhvsTableCompanion Function({
      required String vhvId,
      required String vhvCitizenId,
      required String vhvTitle,
      required String vhvFname,
      required String vhvLname,
      required String vhvMobile,
      required String vhvEmail,
      required String vhvPassword,
      required DateTime vhvBirthDate,
      required String vhvGender,
      required String vhvAddress,
      Value<String?> vhvImg,
      required String villageId,
      Value<int> rowid,
    });
typedef $$VhvsTableTableUpdateCompanionBuilder =
    VhvsTableCompanion Function({
      Value<String> vhvId,
      Value<String> vhvCitizenId,
      Value<String> vhvTitle,
      Value<String> vhvFname,
      Value<String> vhvLname,
      Value<String> vhvMobile,
      Value<String> vhvEmail,
      Value<String> vhvPassword,
      Value<DateTime> vhvBirthDate,
      Value<String> vhvGender,
      Value<String> vhvAddress,
      Value<String?> vhvImg,
      Value<String> villageId,
      Value<int> rowid,
    });

class $$VhvsTableTableFilterComposer
    extends Composer<_$AppDatabase, $VhvsTableTable> {
  $$VhvsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get vhvId => $composableBuilder(
    column: $table.vhvId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vhvCitizenId => $composableBuilder(
    column: $table.vhvCitizenId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vhvTitle => $composableBuilder(
    column: $table.vhvTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vhvFname => $composableBuilder(
    column: $table.vhvFname,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vhvLname => $composableBuilder(
    column: $table.vhvLname,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vhvMobile => $composableBuilder(
    column: $table.vhvMobile,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vhvEmail => $composableBuilder(
    column: $table.vhvEmail,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vhvPassword => $composableBuilder(
    column: $table.vhvPassword,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get vhvBirthDate => $composableBuilder(
    column: $table.vhvBirthDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vhvGender => $composableBuilder(
    column: $table.vhvGender,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vhvAddress => $composableBuilder(
    column: $table.vhvAddress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vhvImg => $composableBuilder(
    column: $table.vhvImg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get villageId => $composableBuilder(
    column: $table.villageId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VhvsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $VhvsTableTable> {
  $$VhvsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get vhvId => $composableBuilder(
    column: $table.vhvId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vhvCitizenId => $composableBuilder(
    column: $table.vhvCitizenId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vhvTitle => $composableBuilder(
    column: $table.vhvTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vhvFname => $composableBuilder(
    column: $table.vhvFname,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vhvLname => $composableBuilder(
    column: $table.vhvLname,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vhvMobile => $composableBuilder(
    column: $table.vhvMobile,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vhvEmail => $composableBuilder(
    column: $table.vhvEmail,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vhvPassword => $composableBuilder(
    column: $table.vhvPassword,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get vhvBirthDate => $composableBuilder(
    column: $table.vhvBirthDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vhvGender => $composableBuilder(
    column: $table.vhvGender,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vhvAddress => $composableBuilder(
    column: $table.vhvAddress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vhvImg => $composableBuilder(
    column: $table.vhvImg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get villageId => $composableBuilder(
    column: $table.villageId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VhvsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $VhvsTableTable> {
  $$VhvsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get vhvId =>
      $composableBuilder(column: $table.vhvId, builder: (column) => column);

  GeneratedColumn<String> get vhvCitizenId => $composableBuilder(
    column: $table.vhvCitizenId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get vhvTitle =>
      $composableBuilder(column: $table.vhvTitle, builder: (column) => column);

  GeneratedColumn<String> get vhvFname =>
      $composableBuilder(column: $table.vhvFname, builder: (column) => column);

  GeneratedColumn<String> get vhvLname =>
      $composableBuilder(column: $table.vhvLname, builder: (column) => column);

  GeneratedColumn<String> get vhvMobile =>
      $composableBuilder(column: $table.vhvMobile, builder: (column) => column);

  GeneratedColumn<String> get vhvEmail =>
      $composableBuilder(column: $table.vhvEmail, builder: (column) => column);

  GeneratedColumn<String> get vhvPassword => $composableBuilder(
    column: $table.vhvPassword,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get vhvBirthDate => $composableBuilder(
    column: $table.vhvBirthDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get vhvGender =>
      $composableBuilder(column: $table.vhvGender, builder: (column) => column);

  GeneratedColumn<String> get vhvAddress => $composableBuilder(
    column: $table.vhvAddress,
    builder: (column) => column,
  );

  GeneratedColumn<String> get vhvImg =>
      $composableBuilder(column: $table.vhvImg, builder: (column) => column);

  GeneratedColumn<String> get villageId =>
      $composableBuilder(column: $table.villageId, builder: (column) => column);
}

class $$VhvsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VhvsTableTable,
          VhvsTableData,
          $$VhvsTableTableFilterComposer,
          $$VhvsTableTableOrderingComposer,
          $$VhvsTableTableAnnotationComposer,
          $$VhvsTableTableCreateCompanionBuilder,
          $$VhvsTableTableUpdateCompanionBuilder,
          (
            VhvsTableData,
            BaseReferences<_$AppDatabase, $VhvsTableTable, VhvsTableData>,
          ),
          VhvsTableData,
          PrefetchHooks Function()
        > {
  $$VhvsTableTableTableManager(_$AppDatabase db, $VhvsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$VhvsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$VhvsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$VhvsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> vhvId = const Value.absent(),
                Value<String> vhvCitizenId = const Value.absent(),
                Value<String> vhvTitle = const Value.absent(),
                Value<String> vhvFname = const Value.absent(),
                Value<String> vhvLname = const Value.absent(),
                Value<String> vhvMobile = const Value.absent(),
                Value<String> vhvEmail = const Value.absent(),
                Value<String> vhvPassword = const Value.absent(),
                Value<DateTime> vhvBirthDate = const Value.absent(),
                Value<String> vhvGender = const Value.absent(),
                Value<String> vhvAddress = const Value.absent(),
                Value<String?> vhvImg = const Value.absent(),
                Value<String> villageId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VhvsTableCompanion(
                vhvId: vhvId,
                vhvCitizenId: vhvCitizenId,
                vhvTitle: vhvTitle,
                vhvFname: vhvFname,
                vhvLname: vhvLname,
                vhvMobile: vhvMobile,
                vhvEmail: vhvEmail,
                vhvPassword: vhvPassword,
                vhvBirthDate: vhvBirthDate,
                vhvGender: vhvGender,
                vhvAddress: vhvAddress,
                vhvImg: vhvImg,
                villageId: villageId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String vhvId,
                required String vhvCitizenId,
                required String vhvTitle,
                required String vhvFname,
                required String vhvLname,
                required String vhvMobile,
                required String vhvEmail,
                required String vhvPassword,
                required DateTime vhvBirthDate,
                required String vhvGender,
                required String vhvAddress,
                Value<String?> vhvImg = const Value.absent(),
                required String villageId,
                Value<int> rowid = const Value.absent(),
              }) => VhvsTableCompanion.insert(
                vhvId: vhvId,
                vhvCitizenId: vhvCitizenId,
                vhvTitle: vhvTitle,
                vhvFname: vhvFname,
                vhvLname: vhvLname,
                vhvMobile: vhvMobile,
                vhvEmail: vhvEmail,
                vhvPassword: vhvPassword,
                vhvBirthDate: vhvBirthDate,
                vhvGender: vhvGender,
                vhvAddress: vhvAddress,
                vhvImg: vhvImg,
                villageId: villageId,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VhvsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VhvsTableTable,
      VhvsTableData,
      $$VhvsTableTableFilterComposer,
      $$VhvsTableTableOrderingComposer,
      $$VhvsTableTableAnnotationComposer,
      $$VhvsTableTableCreateCompanionBuilder,
      $$VhvsTableTableUpdateCompanionBuilder,
      (
        VhvsTableData,
        BaseReferences<_$AppDatabase, $VhvsTableTable, VhvsTableData>,
      ),
      VhvsTableData,
      PrefetchHooks Function()
    >;
typedef $$PatientsTableTableCreateCompanionBuilder =
    PatientsTableCompanion Function({
      required String patientId,
      required String patientCitizenId,
      required String patientTitle,
      required String patientFname,
      required String patientLname,
      required String patientGender,
      required DateTime patientBirthDate,
      required String patientAddress,
      Value<String> patientMobile,
      Value<String?> patientImg,
      required String villageId,
      Value<int> rowid,
    });
typedef $$PatientsTableTableUpdateCompanionBuilder =
    PatientsTableCompanion Function({
      Value<String> patientId,
      Value<String> patientCitizenId,
      Value<String> patientTitle,
      Value<String> patientFname,
      Value<String> patientLname,
      Value<String> patientGender,
      Value<DateTime> patientBirthDate,
      Value<String> patientAddress,
      Value<String> patientMobile,
      Value<String?> patientImg,
      Value<String> villageId,
      Value<int> rowid,
    });

class $$PatientsTableTableFilterComposer
    extends Composer<_$AppDatabase, $PatientsTableTable> {
  $$PatientsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get patientId => $composableBuilder(
    column: $table.patientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get patientCitizenId => $composableBuilder(
    column: $table.patientCitizenId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get patientTitle => $composableBuilder(
    column: $table.patientTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get patientFname => $composableBuilder(
    column: $table.patientFname,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get patientLname => $composableBuilder(
    column: $table.patientLname,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get patientGender => $composableBuilder(
    column: $table.patientGender,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get patientBirthDate => $composableBuilder(
    column: $table.patientBirthDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get patientAddress => $composableBuilder(
    column: $table.patientAddress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get patientMobile => $composableBuilder(
    column: $table.patientMobile,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get patientImg => $composableBuilder(
    column: $table.patientImg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get villageId => $composableBuilder(
    column: $table.villageId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PatientsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PatientsTableTable> {
  $$PatientsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get patientId => $composableBuilder(
    column: $table.patientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get patientCitizenId => $composableBuilder(
    column: $table.patientCitizenId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get patientTitle => $composableBuilder(
    column: $table.patientTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get patientFname => $composableBuilder(
    column: $table.patientFname,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get patientLname => $composableBuilder(
    column: $table.patientLname,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get patientGender => $composableBuilder(
    column: $table.patientGender,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get patientBirthDate => $composableBuilder(
    column: $table.patientBirthDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get patientAddress => $composableBuilder(
    column: $table.patientAddress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get patientMobile => $composableBuilder(
    column: $table.patientMobile,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get patientImg => $composableBuilder(
    column: $table.patientImg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get villageId => $composableBuilder(
    column: $table.villageId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PatientsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PatientsTableTable> {
  $$PatientsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get patientId =>
      $composableBuilder(column: $table.patientId, builder: (column) => column);

  GeneratedColumn<String> get patientCitizenId => $composableBuilder(
    column: $table.patientCitizenId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get patientTitle => $composableBuilder(
    column: $table.patientTitle,
    builder: (column) => column,
  );

  GeneratedColumn<String> get patientFname => $composableBuilder(
    column: $table.patientFname,
    builder: (column) => column,
  );

  GeneratedColumn<String> get patientLname => $composableBuilder(
    column: $table.patientLname,
    builder: (column) => column,
  );

  GeneratedColumn<String> get patientGender => $composableBuilder(
    column: $table.patientGender,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get patientBirthDate => $composableBuilder(
    column: $table.patientBirthDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get patientAddress => $composableBuilder(
    column: $table.patientAddress,
    builder: (column) => column,
  );

  GeneratedColumn<String> get patientMobile => $composableBuilder(
    column: $table.patientMobile,
    builder: (column) => column,
  );

  GeneratedColumn<String> get patientImg => $composableBuilder(
    column: $table.patientImg,
    builder: (column) => column,
  );

  GeneratedColumn<String> get villageId =>
      $composableBuilder(column: $table.villageId, builder: (column) => column);
}

class $$PatientsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PatientsTableTable,
          PatientsTableData,
          $$PatientsTableTableFilterComposer,
          $$PatientsTableTableOrderingComposer,
          $$PatientsTableTableAnnotationComposer,
          $$PatientsTableTableCreateCompanionBuilder,
          $$PatientsTableTableUpdateCompanionBuilder,
          (
            PatientsTableData,
            BaseReferences<
              _$AppDatabase,
              $PatientsTableTable,
              PatientsTableData
            >,
          ),
          PatientsTableData,
          PrefetchHooks Function()
        > {
  $$PatientsTableTableTableManager(_$AppDatabase db, $PatientsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$PatientsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$PatientsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$PatientsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> patientId = const Value.absent(),
                Value<String> patientCitizenId = const Value.absent(),
                Value<String> patientTitle = const Value.absent(),
                Value<String> patientFname = const Value.absent(),
                Value<String> patientLname = const Value.absent(),
                Value<String> patientGender = const Value.absent(),
                Value<DateTime> patientBirthDate = const Value.absent(),
                Value<String> patientAddress = const Value.absent(),
                Value<String> patientMobile = const Value.absent(),
                Value<String?> patientImg = const Value.absent(),
                Value<String> villageId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PatientsTableCompanion(
                patientId: patientId,
                patientCitizenId: patientCitizenId,
                patientTitle: patientTitle,
                patientFname: patientFname,
                patientLname: patientLname,
                patientGender: patientGender,
                patientBirthDate: patientBirthDate,
                patientAddress: patientAddress,
                patientMobile: patientMobile,
                patientImg: patientImg,
                villageId: villageId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String patientId,
                required String patientCitizenId,
                required String patientTitle,
                required String patientFname,
                required String patientLname,
                required String patientGender,
                required DateTime patientBirthDate,
                required String patientAddress,
                Value<String> patientMobile = const Value.absent(),
                Value<String?> patientImg = const Value.absent(),
                required String villageId,
                Value<int> rowid = const Value.absent(),
              }) => PatientsTableCompanion.insert(
                patientId: patientId,
                patientCitizenId: patientCitizenId,
                patientTitle: patientTitle,
                patientFname: patientFname,
                patientLname: patientLname,
                patientGender: patientGender,
                patientBirthDate: patientBirthDate,
                patientAddress: patientAddress,
                patientMobile: patientMobile,
                patientImg: patientImg,
                villageId: villageId,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PatientsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PatientsTableTable,
      PatientsTableData,
      $$PatientsTableTableFilterComposer,
      $$PatientsTableTableOrderingComposer,
      $$PatientsTableTableAnnotationComposer,
      $$PatientsTableTableCreateCompanionBuilder,
      $$PatientsTableTableUpdateCompanionBuilder,
      (
        PatientsTableData,
        BaseReferences<_$AppDatabase, $PatientsTableTable, PatientsTableData>,
      ),
      PatientsTableData,
      PrefetchHooks Function()
    >;
typedef $$ScreeningsTableTableCreateCompanionBuilder =
    ScreeningsTableCompanion Function({
      required String screenId,
      required String patientId,
      required String vhvId,
      required DateTime screeningDate,
      required int ageAtScreening,
      required DateTime createdAt,
      Value<String> reviewStatus,
      Value<String?> reviewedByNurseId,
      Value<DateTime?> reviewedAt,
      required double weight,
      required double height,
      required double bmi,
      required double waistCm,
      required double sbp,
      required double dbp,
      required double pulse,
      Value<double?> bloodSugar,
      Value<int> rowid,
    });
typedef $$ScreeningsTableTableUpdateCompanionBuilder =
    ScreeningsTableCompanion Function({
      Value<String> screenId,
      Value<String> patientId,
      Value<String> vhvId,
      Value<DateTime> screeningDate,
      Value<int> ageAtScreening,
      Value<DateTime> createdAt,
      Value<String> reviewStatus,
      Value<String?> reviewedByNurseId,
      Value<DateTime?> reviewedAt,
      Value<double> weight,
      Value<double> height,
      Value<double> bmi,
      Value<double> waistCm,
      Value<double> sbp,
      Value<double> dbp,
      Value<double> pulse,
      Value<double?> bloodSugar,
      Value<int> rowid,
    });

class $$ScreeningsTableTableFilterComposer
    extends Composer<_$AppDatabase, $ScreeningsTableTable> {
  $$ScreeningsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get screenId => $composableBuilder(
    column: $table.screenId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get patientId => $composableBuilder(
    column: $table.patientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vhvId => $composableBuilder(
    column: $table.vhvId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get screeningDate => $composableBuilder(
    column: $table.screeningDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ageAtScreening => $composableBuilder(
    column: $table.ageAtScreening,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reviewStatus => $composableBuilder(
    column: $table.reviewStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reviewedByNurseId => $composableBuilder(
    column: $table.reviewedByNurseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get bmi => $composableBuilder(
    column: $table.bmi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get waistCm => $composableBuilder(
    column: $table.waistCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sbp => $composableBuilder(
    column: $table.sbp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get dbp => $composableBuilder(
    column: $table.dbp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get pulse => $composableBuilder(
    column: $table.pulse,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get bloodSugar => $composableBuilder(
    column: $table.bloodSugar,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ScreeningsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ScreeningsTableTable> {
  $$ScreeningsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get screenId => $composableBuilder(
    column: $table.screenId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get patientId => $composableBuilder(
    column: $table.patientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vhvId => $composableBuilder(
    column: $table.vhvId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get screeningDate => $composableBuilder(
    column: $table.screeningDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ageAtScreening => $composableBuilder(
    column: $table.ageAtScreening,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reviewStatus => $composableBuilder(
    column: $table.reviewStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reviewedByNurseId => $composableBuilder(
    column: $table.reviewedByNurseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get bmi => $composableBuilder(
    column: $table.bmi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get waistCm => $composableBuilder(
    column: $table.waistCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sbp => $composableBuilder(
    column: $table.sbp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get dbp => $composableBuilder(
    column: $table.dbp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get pulse => $composableBuilder(
    column: $table.pulse,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get bloodSugar => $composableBuilder(
    column: $table.bloodSugar,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ScreeningsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScreeningsTableTable> {
  $$ScreeningsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get screenId =>
      $composableBuilder(column: $table.screenId, builder: (column) => column);

  GeneratedColumn<String> get patientId =>
      $composableBuilder(column: $table.patientId, builder: (column) => column);

  GeneratedColumn<String> get vhvId =>
      $composableBuilder(column: $table.vhvId, builder: (column) => column);

  GeneratedColumn<DateTime> get screeningDate => $composableBuilder(
    column: $table.screeningDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ageAtScreening => $composableBuilder(
    column: $table.ageAtScreening,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get reviewStatus => $composableBuilder(
    column: $table.reviewStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reviewedByNurseId => $composableBuilder(
    column: $table.reviewedByNurseId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
    builder: (column) => column,
  );

  GeneratedColumn<double> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);

  GeneratedColumn<double> get height =>
      $composableBuilder(column: $table.height, builder: (column) => column);

  GeneratedColumn<double> get bmi =>
      $composableBuilder(column: $table.bmi, builder: (column) => column);

  GeneratedColumn<double> get waistCm =>
      $composableBuilder(column: $table.waistCm, builder: (column) => column);

  GeneratedColumn<double> get sbp =>
      $composableBuilder(column: $table.sbp, builder: (column) => column);

  GeneratedColumn<double> get dbp =>
      $composableBuilder(column: $table.dbp, builder: (column) => column);

  GeneratedColumn<double> get pulse =>
      $composableBuilder(column: $table.pulse, builder: (column) => column);

  GeneratedColumn<double> get bloodSugar => $composableBuilder(
    column: $table.bloodSugar,
    builder: (column) => column,
  );
}

class $$ScreeningsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ScreeningsTableTable,
          ScreeningsTableData,
          $$ScreeningsTableTableFilterComposer,
          $$ScreeningsTableTableOrderingComposer,
          $$ScreeningsTableTableAnnotationComposer,
          $$ScreeningsTableTableCreateCompanionBuilder,
          $$ScreeningsTableTableUpdateCompanionBuilder,
          (
            ScreeningsTableData,
            BaseReferences<
              _$AppDatabase,
              $ScreeningsTableTable,
              ScreeningsTableData
            >,
          ),
          ScreeningsTableData,
          PrefetchHooks Function()
        > {
  $$ScreeningsTableTableTableManager(
    _$AppDatabase db,
    $ScreeningsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () =>
                  $$ScreeningsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$ScreeningsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$ScreeningsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> screenId = const Value.absent(),
                Value<String> patientId = const Value.absent(),
                Value<String> vhvId = const Value.absent(),
                Value<DateTime> screeningDate = const Value.absent(),
                Value<int> ageAtScreening = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> reviewStatus = const Value.absent(),
                Value<String?> reviewedByNurseId = const Value.absent(),
                Value<DateTime?> reviewedAt = const Value.absent(),
                Value<double> weight = const Value.absent(),
                Value<double> height = const Value.absent(),
                Value<double> bmi = const Value.absent(),
                Value<double> waistCm = const Value.absent(),
                Value<double> sbp = const Value.absent(),
                Value<double> dbp = const Value.absent(),
                Value<double> pulse = const Value.absent(),
                Value<double?> bloodSugar = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScreeningsTableCompanion(
                screenId: screenId,
                patientId: patientId,
                vhvId: vhvId,
                screeningDate: screeningDate,
                ageAtScreening: ageAtScreening,
                createdAt: createdAt,
                reviewStatus: reviewStatus,
                reviewedByNurseId: reviewedByNurseId,
                reviewedAt: reviewedAt,
                weight: weight,
                height: height,
                bmi: bmi,
                waistCm: waistCm,
                sbp: sbp,
                dbp: dbp,
                pulse: pulse,
                bloodSugar: bloodSugar,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String screenId,
                required String patientId,
                required String vhvId,
                required DateTime screeningDate,
                required int ageAtScreening,
                required DateTime createdAt,
                Value<String> reviewStatus = const Value.absent(),
                Value<String?> reviewedByNurseId = const Value.absent(),
                Value<DateTime?> reviewedAt = const Value.absent(),
                required double weight,
                required double height,
                required double bmi,
                required double waistCm,
                required double sbp,
                required double dbp,
                required double pulse,
                Value<double?> bloodSugar = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScreeningsTableCompanion.insert(
                screenId: screenId,
                patientId: patientId,
                vhvId: vhvId,
                screeningDate: screeningDate,
                ageAtScreening: ageAtScreening,
                createdAt: createdAt,
                reviewStatus: reviewStatus,
                reviewedByNurseId: reviewedByNurseId,
                reviewedAt: reviewedAt,
                weight: weight,
                height: height,
                bmi: bmi,
                waistCm: waistCm,
                sbp: sbp,
                dbp: dbp,
                pulse: pulse,
                bloodSugar: bloodSugar,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ScreeningsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ScreeningsTableTable,
      ScreeningsTableData,
      $$ScreeningsTableTableFilterComposer,
      $$ScreeningsTableTableOrderingComposer,
      $$ScreeningsTableTableAnnotationComposer,
      $$ScreeningsTableTableCreateCompanionBuilder,
      $$ScreeningsTableTableUpdateCompanionBuilder,
      (
        ScreeningsTableData,
        BaseReferences<
          _$AppDatabase,
          $ScreeningsTableTable,
          ScreeningsTableData
        >,
      ),
      ScreeningsTableData,
      PrefetchHooks Function()
    >;
typedef $$ScreeningHistoriesTableTableCreateCompanionBuilder =
    ScreeningHistoriesTableCompanion Function({
      required String historyId,
      required String screeningId,
      required String questionId,
      required String questionText,
      Value<double?> answerValue,
      required String answerText,
      Value<int> rowid,
    });
typedef $$ScreeningHistoriesTableTableUpdateCompanionBuilder =
    ScreeningHistoriesTableCompanion Function({
      Value<String> historyId,
      Value<String> screeningId,
      Value<String> questionId,
      Value<String> questionText,
      Value<double?> answerValue,
      Value<String> answerText,
      Value<int> rowid,
    });

class $$ScreeningHistoriesTableTableFilterComposer
    extends Composer<_$AppDatabase, $ScreeningHistoriesTableTable> {
  $$ScreeningHistoriesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get historyId => $composableBuilder(
    column: $table.historyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get screeningId => $composableBuilder(
    column: $table.screeningId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get questionText => $composableBuilder(
    column: $table.questionText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get answerValue => $composableBuilder(
    column: $table.answerValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get answerText => $composableBuilder(
    column: $table.answerText,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ScreeningHistoriesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ScreeningHistoriesTableTable> {
  $$ScreeningHistoriesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get historyId => $composableBuilder(
    column: $table.historyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get screeningId => $composableBuilder(
    column: $table.screeningId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get questionText => $composableBuilder(
    column: $table.questionText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get answerValue => $composableBuilder(
    column: $table.answerValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get answerText => $composableBuilder(
    column: $table.answerText,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ScreeningHistoriesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScreeningHistoriesTableTable> {
  $$ScreeningHistoriesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get historyId =>
      $composableBuilder(column: $table.historyId, builder: (column) => column);

  GeneratedColumn<String> get screeningId => $composableBuilder(
    column: $table.screeningId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get questionText => $composableBuilder(
    column: $table.questionText,
    builder: (column) => column,
  );

  GeneratedColumn<double> get answerValue => $composableBuilder(
    column: $table.answerValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get answerText => $composableBuilder(
    column: $table.answerText,
    builder: (column) => column,
  );
}

class $$ScreeningHistoriesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ScreeningHistoriesTableTable,
          ScreeningHistoriesTableData,
          $$ScreeningHistoriesTableTableFilterComposer,
          $$ScreeningHistoriesTableTableOrderingComposer,
          $$ScreeningHistoriesTableTableAnnotationComposer,
          $$ScreeningHistoriesTableTableCreateCompanionBuilder,
          $$ScreeningHistoriesTableTableUpdateCompanionBuilder,
          (
            ScreeningHistoriesTableData,
            BaseReferences<
              _$AppDatabase,
              $ScreeningHistoriesTableTable,
              ScreeningHistoriesTableData
            >,
          ),
          ScreeningHistoriesTableData,
          PrefetchHooks Function()
        > {
  $$ScreeningHistoriesTableTableTableManager(
    _$AppDatabase db,
    $ScreeningHistoriesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$ScreeningHistoriesTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer:
              () => $$ScreeningHistoriesTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$ScreeningHistoriesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> historyId = const Value.absent(),
                Value<String> screeningId = const Value.absent(),
                Value<String> questionId = const Value.absent(),
                Value<String> questionText = const Value.absent(),
                Value<double?> answerValue = const Value.absent(),
                Value<String> answerText = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScreeningHistoriesTableCompanion(
                historyId: historyId,
                screeningId: screeningId,
                questionId: questionId,
                questionText: questionText,
                answerValue: answerValue,
                answerText: answerText,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String historyId,
                required String screeningId,
                required String questionId,
                required String questionText,
                Value<double?> answerValue = const Value.absent(),
                required String answerText,
                Value<int> rowid = const Value.absent(),
              }) => ScreeningHistoriesTableCompanion.insert(
                historyId: historyId,
                screeningId: screeningId,
                questionId: questionId,
                questionText: questionText,
                answerValue: answerValue,
                answerText: answerText,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ScreeningHistoriesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ScreeningHistoriesTableTable,
      ScreeningHistoriesTableData,
      $$ScreeningHistoriesTableTableFilterComposer,
      $$ScreeningHistoriesTableTableOrderingComposer,
      $$ScreeningHistoriesTableTableAnnotationComposer,
      $$ScreeningHistoriesTableTableCreateCompanionBuilder,
      $$ScreeningHistoriesTableTableUpdateCompanionBuilder,
      (
        ScreeningHistoriesTableData,
        BaseReferences<
          _$AppDatabase,
          $ScreeningHistoriesTableTable,
          ScreeningHistoriesTableData
        >,
      ),
      ScreeningHistoriesTableData,
      PrefetchHooks Function()
    >;
typedef $$ScreeningResultsTableTableCreateCompanionBuilder =
    ScreeningResultsTableCompanion Function({
      required String resultId,
      required String screeningId,
      required String diseaseName,
      required String diseaseCode,
      required int score,
      required String riskLevel,
      required String adviceText,
      Value<String> criteriaText,
      Value<int> rowid,
    });
typedef $$ScreeningResultsTableTableUpdateCompanionBuilder =
    ScreeningResultsTableCompanion Function({
      Value<String> resultId,
      Value<String> screeningId,
      Value<String> diseaseName,
      Value<String> diseaseCode,
      Value<int> score,
      Value<String> riskLevel,
      Value<String> adviceText,
      Value<String> criteriaText,
      Value<int> rowid,
    });

class $$ScreeningResultsTableTableFilterComposer
    extends Composer<_$AppDatabase, $ScreeningResultsTableTable> {
  $$ScreeningResultsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get resultId => $composableBuilder(
    column: $table.resultId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get screeningId => $composableBuilder(
    column: $table.screeningId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get diseaseName => $composableBuilder(
    column: $table.diseaseName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get diseaseCode => $composableBuilder(
    column: $table.diseaseCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get riskLevel => $composableBuilder(
    column: $table.riskLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get adviceText => $composableBuilder(
    column: $table.adviceText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get criteriaText => $composableBuilder(
    column: $table.criteriaText,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ScreeningResultsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ScreeningResultsTableTable> {
  $$ScreeningResultsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get resultId => $composableBuilder(
    column: $table.resultId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get screeningId => $composableBuilder(
    column: $table.screeningId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get diseaseName => $composableBuilder(
    column: $table.diseaseName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get diseaseCode => $composableBuilder(
    column: $table.diseaseCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get riskLevel => $composableBuilder(
    column: $table.riskLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get adviceText => $composableBuilder(
    column: $table.adviceText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get criteriaText => $composableBuilder(
    column: $table.criteriaText,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ScreeningResultsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScreeningResultsTableTable> {
  $$ScreeningResultsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get resultId =>
      $composableBuilder(column: $table.resultId, builder: (column) => column);

  GeneratedColumn<String> get screeningId => $composableBuilder(
    column: $table.screeningId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get diseaseName => $composableBuilder(
    column: $table.diseaseName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get diseaseCode => $composableBuilder(
    column: $table.diseaseCode,
    builder: (column) => column,
  );

  GeneratedColumn<int> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<String> get riskLevel =>
      $composableBuilder(column: $table.riskLevel, builder: (column) => column);

  GeneratedColumn<String> get adviceText => $composableBuilder(
    column: $table.adviceText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get criteriaText => $composableBuilder(
    column: $table.criteriaText,
    builder: (column) => column,
  );
}

class $$ScreeningResultsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ScreeningResultsTableTable,
          ScreeningResultsTableData,
          $$ScreeningResultsTableTableFilterComposer,
          $$ScreeningResultsTableTableOrderingComposer,
          $$ScreeningResultsTableTableAnnotationComposer,
          $$ScreeningResultsTableTableCreateCompanionBuilder,
          $$ScreeningResultsTableTableUpdateCompanionBuilder,
          (
            ScreeningResultsTableData,
            BaseReferences<
              _$AppDatabase,
              $ScreeningResultsTableTable,
              ScreeningResultsTableData
            >,
          ),
          ScreeningResultsTableData,
          PrefetchHooks Function()
        > {
  $$ScreeningResultsTableTableTableManager(
    _$AppDatabase db,
    $ScreeningResultsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$ScreeningResultsTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer:
              () => $$ScreeningResultsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$ScreeningResultsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> resultId = const Value.absent(),
                Value<String> screeningId = const Value.absent(),
                Value<String> diseaseName = const Value.absent(),
                Value<String> diseaseCode = const Value.absent(),
                Value<int> score = const Value.absent(),
                Value<String> riskLevel = const Value.absent(),
                Value<String> adviceText = const Value.absent(),
                Value<String> criteriaText = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScreeningResultsTableCompanion(
                resultId: resultId,
                screeningId: screeningId,
                diseaseName: diseaseName,
                diseaseCode: diseaseCode,
                score: score,
                riskLevel: riskLevel,
                adviceText: adviceText,
                criteriaText: criteriaText,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String resultId,
                required String screeningId,
                required String diseaseName,
                required String diseaseCode,
                required int score,
                required String riskLevel,
                required String adviceText,
                Value<String> criteriaText = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScreeningResultsTableCompanion.insert(
                resultId: resultId,
                screeningId: screeningId,
                diseaseName: diseaseName,
                diseaseCode: diseaseCode,
                score: score,
                riskLevel: riskLevel,
                adviceText: adviceText,
                criteriaText: criteriaText,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ScreeningResultsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ScreeningResultsTableTable,
      ScreeningResultsTableData,
      $$ScreeningResultsTableTableFilterComposer,
      $$ScreeningResultsTableTableOrderingComposer,
      $$ScreeningResultsTableTableAnnotationComposer,
      $$ScreeningResultsTableTableCreateCompanionBuilder,
      $$ScreeningResultsTableTableUpdateCompanionBuilder,
      (
        ScreeningResultsTableData,
        BaseReferences<
          _$AppDatabase,
          $ScreeningResultsTableTable,
          ScreeningResultsTableData
        >,
      ),
      ScreeningResultsTableData,
      PrefetchHooks Function()
    >;
typedef $$SyncQueueTableTableCreateCompanionBuilder =
    SyncQueueTableCompanion Function({
      required String id,
      required String entityType,
      required String entityId,
      required String action,
      required String payload,
      required DateTime createdAt,
      Value<int> retryCount,
      Value<String> status,
      Value<String?> errorMessage,
      Value<int> rowid,
    });
typedef $$SyncQueueTableTableUpdateCompanionBuilder =
    SyncQueueTableCompanion Function({
      Value<String> id,
      Value<String> entityType,
      Value<String> entityId,
      Value<String> action,
      Value<String> payload,
      Value<DateTime> createdAt,
      Value<int> retryCount,
      Value<String> status,
      Value<String?> errorMessage,
      Value<int> rowid,
    });

class $$SyncQueueTableTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueueTableTable> {
  $$SyncQueueTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncQueueTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueueTableTable> {
  $$SyncQueueTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncQueueTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueueTableTable> {
  $$SyncQueueTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => column,
  );
}

class $$SyncQueueTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncQueueTableTable,
          SyncQueueTableData,
          $$SyncQueueTableTableFilterComposer,
          $$SyncQueueTableTableOrderingComposer,
          $$SyncQueueTableTableAnnotationComposer,
          $$SyncQueueTableTableCreateCompanionBuilder,
          $$SyncQueueTableTableUpdateCompanionBuilder,
          (
            SyncQueueTableData,
            BaseReferences<
              _$AppDatabase,
              $SyncQueueTableTable,
              SyncQueueTableData
            >,
          ),
          SyncQueueTableData,
          PrefetchHooks Function()
        > {
  $$SyncQueueTableTableTableManager(
    _$AppDatabase db,
    $SyncQueueTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$SyncQueueTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$SyncQueueTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$SyncQueueTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncQueueTableCompanion(
                id: id,
                entityType: entityType,
                entityId: entityId,
                action: action,
                payload: payload,
                createdAt: createdAt,
                retryCount: retryCount,
                status: status,
                errorMessage: errorMessage,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String entityType,
                required String entityId,
                required String action,
                required String payload,
                required DateTime createdAt,
                Value<int> retryCount = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncQueueTableCompanion.insert(
                id: id,
                entityType: entityType,
                entityId: entityId,
                action: action,
                payload: payload,
                createdAt: createdAt,
                retryCount: retryCount,
                status: status,
                errorMessage: errorMessage,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncQueueTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncQueueTableTable,
      SyncQueueTableData,
      $$SyncQueueTableTableFilterComposer,
      $$SyncQueueTableTableOrderingComposer,
      $$SyncQueueTableTableAnnotationComposer,
      $$SyncQueueTableTableCreateCompanionBuilder,
      $$SyncQueueTableTableUpdateCompanionBuilder,
      (
        SyncQueueTableData,
        BaseReferences<_$AppDatabase, $SyncQueueTableTable, SyncQueueTableData>,
      ),
      SyncQueueTableData,
      PrefetchHooks Function()
    >;
typedef $$ScreeningDraftsTableTableCreateCompanionBuilder =
    ScreeningDraftsTableCompanion Function({
      required String patientId,
      required String vhvId,
      required String payload,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$ScreeningDraftsTableTableUpdateCompanionBuilder =
    ScreeningDraftsTableCompanion Function({
      Value<String> patientId,
      Value<String> vhvId,
      Value<String> payload,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$ScreeningDraftsTableTableFilterComposer
    extends Composer<_$AppDatabase, $ScreeningDraftsTableTable> {
  $$ScreeningDraftsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get patientId => $composableBuilder(
    column: $table.patientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vhvId => $composableBuilder(
    column: $table.vhvId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ScreeningDraftsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ScreeningDraftsTableTable> {
  $$ScreeningDraftsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get patientId => $composableBuilder(
    column: $table.patientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vhvId => $composableBuilder(
    column: $table.vhvId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ScreeningDraftsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScreeningDraftsTableTable> {
  $$ScreeningDraftsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get patientId =>
      $composableBuilder(column: $table.patientId, builder: (column) => column);

  GeneratedColumn<String> get vhvId =>
      $composableBuilder(column: $table.vhvId, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ScreeningDraftsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ScreeningDraftsTableTable,
          ScreeningDraftsTableData,
          $$ScreeningDraftsTableTableFilterComposer,
          $$ScreeningDraftsTableTableOrderingComposer,
          $$ScreeningDraftsTableTableAnnotationComposer,
          $$ScreeningDraftsTableTableCreateCompanionBuilder,
          $$ScreeningDraftsTableTableUpdateCompanionBuilder,
          (
            ScreeningDraftsTableData,
            BaseReferences<
              _$AppDatabase,
              $ScreeningDraftsTableTable,
              ScreeningDraftsTableData
            >,
          ),
          ScreeningDraftsTableData,
          PrefetchHooks Function()
        > {
  $$ScreeningDraftsTableTableTableManager(
    _$AppDatabase db,
    $ScreeningDraftsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$ScreeningDraftsTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer:
              () => $$ScreeningDraftsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$ScreeningDraftsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> patientId = const Value.absent(),
                Value<String> vhvId = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScreeningDraftsTableCompanion(
                patientId: patientId,
                vhvId: vhvId,
                payload: payload,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String patientId,
                required String vhvId,
                required String payload,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ScreeningDraftsTableCompanion.insert(
                patientId: patientId,
                vhvId: vhvId,
                payload: payload,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ScreeningDraftsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ScreeningDraftsTableTable,
      ScreeningDraftsTableData,
      $$ScreeningDraftsTableTableFilterComposer,
      $$ScreeningDraftsTableTableOrderingComposer,
      $$ScreeningDraftsTableTableAnnotationComposer,
      $$ScreeningDraftsTableTableCreateCompanionBuilder,
      $$ScreeningDraftsTableTableUpdateCompanionBuilder,
      (
        ScreeningDraftsTableData,
        BaseReferences<
          _$AppDatabase,
          $ScreeningDraftsTableTable,
          ScreeningDraftsTableData
        >,
      ),
      ScreeningDraftsTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$VillagesTableTableTableManager get villagesTable =>
      $$VillagesTableTableTableManager(_db, _db.villagesTable);
  $$NursesTableTableTableManager get nursesTable =>
      $$NursesTableTableTableManager(_db, _db.nursesTable);
  $$VhvsTableTableTableManager get vhvsTable =>
      $$VhvsTableTableTableManager(_db, _db.vhvsTable);
  $$PatientsTableTableTableManager get patientsTable =>
      $$PatientsTableTableTableManager(_db, _db.patientsTable);
  $$ScreeningsTableTableTableManager get screeningsTable =>
      $$ScreeningsTableTableTableManager(_db, _db.screeningsTable);
  $$ScreeningHistoriesTableTableTableManager get screeningHistoriesTable =>
      $$ScreeningHistoriesTableTableTableManager(
        _db,
        _db.screeningHistoriesTable,
      );
  $$ScreeningResultsTableTableTableManager get screeningResultsTable =>
      $$ScreeningResultsTableTableTableManager(_db, _db.screeningResultsTable);
  $$SyncQueueTableTableTableManager get syncQueueTable =>
      $$SyncQueueTableTableTableManager(_db, _db.syncQueueTable);
  $$ScreeningDraftsTableTableTableManager get screeningDraftsTable =>
      $$ScreeningDraftsTableTableTableManager(_db, _db.screeningDraftsTable);
}
