// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LocalStudentsTable extends LocalStudents
    with TableInfo<$LocalStudentsTable, LocalStudent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalStudentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<int> localId = GeneratedColumn<int>(
    'local_id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _cloudIdMeta = const VerificationMeta(
    'cloudId',
  );
  @override
  late final GeneratedColumn<String> cloudId = GeneratedColumn<String>(
    'cloud_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _studentIdLegacyMeta = const VerificationMeta(
    'studentIdLegacy',
  );
  @override
  late final GeneratedColumn<String> studentIdLegacy = GeneratedColumn<String>(
    'student_id_legacy',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _normalizedNameMeta = const VerificationMeta(
    'normalizedName',
  );
  @override
  late final GeneratedColumn<String> normalizedName = GeneratedColumn<String>(
    'normalized_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _parentNameMeta = const VerificationMeta(
    'parentName',
  );
  @override
  late final GeneratedColumn<String> parentName = GeneratedColumn<String>(
    'parent_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _parentPhoneMeta = const VerificationMeta(
    'parentPhone',
  );
  @override
  late final GeneratedColumn<String> parentPhone = GeneratedColumn<String>(
    'parent_phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dobMeta = const VerificationMeta('dob');
  @override
  late final GeneratedColumn<DateTime> dob = GeneratedColumn<DateTime>(
    'dob',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _classNameMeta = const VerificationMeta(
    'className',
  );
  @override
  late final GeneratedColumn<String> className = GeneratedColumn<String>(
    'class_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _courseIdMeta = const VerificationMeta(
    'courseId',
  );
  @override
  late final GeneratedColumn<String> courseId = GeneratedColumn<String>(
    'course_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _courseNameMeta = const VerificationMeta(
    'courseName',
  );
  @override
  late final GeneratedColumn<String> courseName = GeneratedColumn<String>(
    'course_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _batchIdMeta = const VerificationMeta(
    'batchId',
  );
  @override
  late final GeneratedColumn<String> batchId = GeneratedColumn<String>(
    'batch_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _batchNameMeta = const VerificationMeta(
    'batchName',
  );
  @override
  late final GeneratedColumn<String> batchName = GeneratedColumn<String>(
    'batch_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('active'),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _photoUrlMeta = const VerificationMeta(
    'photoUrl',
  );
  @override
  late final GeneratedColumn<String> photoUrl = GeneratedColumn<String>(
    'photo_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<LocalSyncStatus, String>
  syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<LocalSyncStatus>($LocalStudentsTable.$convertersyncStatus);
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    localId,
    cloudId,
    studentIdLegacy,
    name,
    normalizedName,
    phone,
    parentName,
    parentPhone,
    email,
    dob,
    address,
    className,
    courseId,
    courseName,
    batchId,
    batchName,
    status,
    notes,
    photoUrl,
    createdAt,
    updatedAt,
    deletedAt,
    syncStatus,
    lastSyncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_students';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalStudent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    }
    if (data.containsKey('cloud_id')) {
      context.handle(
        _cloudIdMeta,
        cloudId.isAcceptableOrUnknown(data['cloud_id']!, _cloudIdMeta),
      );
    }
    if (data.containsKey('student_id_legacy')) {
      context.handle(
        _studentIdLegacyMeta,
        studentIdLegacy.isAcceptableOrUnknown(
          data['student_id_legacy']!,
          _studentIdLegacyMeta,
        ),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('normalized_name')) {
      context.handle(
        _normalizedNameMeta,
        normalizedName.isAcceptableOrUnknown(
          data['normalized_name']!,
          _normalizedNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_normalizedNameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('parent_name')) {
      context.handle(
        _parentNameMeta,
        parentName.isAcceptableOrUnknown(data['parent_name']!, _parentNameMeta),
      );
    }
    if (data.containsKey('parent_phone')) {
      context.handle(
        _parentPhoneMeta,
        parentPhone.isAcceptableOrUnknown(
          data['parent_phone']!,
          _parentPhoneMeta,
        ),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('dob')) {
      context.handle(
        _dobMeta,
        dob.isAcceptableOrUnknown(data['dob']!, _dobMeta),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('class_name')) {
      context.handle(
        _classNameMeta,
        className.isAcceptableOrUnknown(data['class_name']!, _classNameMeta),
      );
    }
    if (data.containsKey('course_id')) {
      context.handle(
        _courseIdMeta,
        courseId.isAcceptableOrUnknown(data['course_id']!, _courseIdMeta),
      );
    }
    if (data.containsKey('course_name')) {
      context.handle(
        _courseNameMeta,
        courseName.isAcceptableOrUnknown(data['course_name']!, _courseNameMeta),
      );
    }
    if (data.containsKey('batch_id')) {
      context.handle(
        _batchIdMeta,
        batchId.isAcceptableOrUnknown(data['batch_id']!, _batchIdMeta),
      );
    }
    if (data.containsKey('batch_name')) {
      context.handle(
        _batchNameMeta,
        batchName.isAcceptableOrUnknown(data['batch_name']!, _batchNameMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('photo_url')) {
      context.handle(
        _photoUrlMeta,
        photoUrl.isAcceptableOrUnknown(data['photo_url']!, _photoUrlMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  LocalStudent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalStudent(
      localId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_id'],
      )!,
      cloudId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cloud_id'],
      ),
      studentIdLegacy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_id_legacy'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      normalizedName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_name'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      parentName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_name'],
      ),
      parentPhone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_phone'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      dob: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}dob'],
      ),
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      className: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}class_name'],
      ),
      courseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}course_id'],
      ),
      courseName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}course_name'],
      ),
      batchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}batch_id'],
      ),
      batchName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}batch_name'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      photoUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_url'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      syncStatus: $LocalStudentsTable.$convertersyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}sync_status'],
        )!,
      ),
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
    );
  }

  @override
  $LocalStudentsTable createAlias(String alias) {
    return $LocalStudentsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<LocalSyncStatus, String, String>
  $convertersyncStatus = const EnumNameConverter<LocalSyncStatus>(
    LocalSyncStatus.values,
  );
}

class LocalStudent extends DataClass implements Insertable<LocalStudent> {
  final int localId;
  final String? cloudId;
  final String? studentIdLegacy;
  final String name;
  final String normalizedName;
  final String? phone;
  final String? parentName;
  final String? parentPhone;
  final String? email;
  final DateTime? dob;
  final String? address;
  final String? className;
  final String? courseId;
  final String? courseName;
  final String? batchId;
  final String? batchName;
  final String status;
  final String? notes;
  final String? photoUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final LocalSyncStatus syncStatus;
  final DateTime? lastSyncedAt;
  const LocalStudent({
    required this.localId,
    this.cloudId,
    this.studentIdLegacy,
    required this.name,
    required this.normalizedName,
    this.phone,
    this.parentName,
    this.parentPhone,
    this.email,
    this.dob,
    this.address,
    this.className,
    this.courseId,
    this.courseName,
    this.batchId,
    this.batchName,
    required this.status,
    this.notes,
    this.photoUrl,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    required this.syncStatus,
    this.lastSyncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<int>(localId);
    if (!nullToAbsent || cloudId != null) {
      map['cloud_id'] = Variable<String>(cloudId);
    }
    if (!nullToAbsent || studentIdLegacy != null) {
      map['student_id_legacy'] = Variable<String>(studentIdLegacy);
    }
    map['name'] = Variable<String>(name);
    map['normalized_name'] = Variable<String>(normalizedName);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || parentName != null) {
      map['parent_name'] = Variable<String>(parentName);
    }
    if (!nullToAbsent || parentPhone != null) {
      map['parent_phone'] = Variable<String>(parentPhone);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || dob != null) {
      map['dob'] = Variable<DateTime>(dob);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || className != null) {
      map['class_name'] = Variable<String>(className);
    }
    if (!nullToAbsent || courseId != null) {
      map['course_id'] = Variable<String>(courseId);
    }
    if (!nullToAbsent || courseName != null) {
      map['course_name'] = Variable<String>(courseName);
    }
    if (!nullToAbsent || batchId != null) {
      map['batch_id'] = Variable<String>(batchId);
    }
    if (!nullToAbsent || batchName != null) {
      map['batch_name'] = Variable<String>(batchName);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || photoUrl != null) {
      map['photo_url'] = Variable<String>(photoUrl);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    {
      map['sync_status'] = Variable<String>(
        $LocalStudentsTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  LocalStudentsCompanion toCompanion(bool nullToAbsent) {
    return LocalStudentsCompanion(
      localId: Value(localId),
      cloudId: cloudId == null && nullToAbsent
          ? const Value.absent()
          : Value(cloudId),
      studentIdLegacy: studentIdLegacy == null && nullToAbsent
          ? const Value.absent()
          : Value(studentIdLegacy),
      name: Value(name),
      normalizedName: Value(normalizedName),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      parentName: parentName == null && nullToAbsent
          ? const Value.absent()
          : Value(parentName),
      parentPhone: parentPhone == null && nullToAbsent
          ? const Value.absent()
          : Value(parentPhone),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      dob: dob == null && nullToAbsent ? const Value.absent() : Value(dob),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      className: className == null && nullToAbsent
          ? const Value.absent()
          : Value(className),
      courseId: courseId == null && nullToAbsent
          ? const Value.absent()
          : Value(courseId),
      courseName: courseName == null && nullToAbsent
          ? const Value.absent()
          : Value(courseName),
      batchId: batchId == null && nullToAbsent
          ? const Value.absent()
          : Value(batchId),
      batchName: batchName == null && nullToAbsent
          ? const Value.absent()
          : Value(batchName),
      status: Value(status),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      photoUrl: photoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(photoUrl),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncStatus: Value(syncStatus),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory LocalStudent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalStudent(
      localId: serializer.fromJson<int>(json['localId']),
      cloudId: serializer.fromJson<String?>(json['cloudId']),
      studentIdLegacy: serializer.fromJson<String?>(json['studentIdLegacy']),
      name: serializer.fromJson<String>(json['name']),
      normalizedName: serializer.fromJson<String>(json['normalizedName']),
      phone: serializer.fromJson<String?>(json['phone']),
      parentName: serializer.fromJson<String?>(json['parentName']),
      parentPhone: serializer.fromJson<String?>(json['parentPhone']),
      email: serializer.fromJson<String?>(json['email']),
      dob: serializer.fromJson<DateTime?>(json['dob']),
      address: serializer.fromJson<String?>(json['address']),
      className: serializer.fromJson<String?>(json['className']),
      courseId: serializer.fromJson<String?>(json['courseId']),
      courseName: serializer.fromJson<String?>(json['courseName']),
      batchId: serializer.fromJson<String?>(json['batchId']),
      batchName: serializer.fromJson<String?>(json['batchName']),
      status: serializer.fromJson<String>(json['status']),
      notes: serializer.fromJson<String?>(json['notes']),
      photoUrl: serializer.fromJson<String?>(json['photoUrl']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncStatus: $LocalStudentsTable.$convertersyncStatus.fromJson(
        serializer.fromJson<String>(json['syncStatus']),
      ),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<int>(localId),
      'cloudId': serializer.toJson<String?>(cloudId),
      'studentIdLegacy': serializer.toJson<String?>(studentIdLegacy),
      'name': serializer.toJson<String>(name),
      'normalizedName': serializer.toJson<String>(normalizedName),
      'phone': serializer.toJson<String?>(phone),
      'parentName': serializer.toJson<String?>(parentName),
      'parentPhone': serializer.toJson<String?>(parentPhone),
      'email': serializer.toJson<String?>(email),
      'dob': serializer.toJson<DateTime?>(dob),
      'address': serializer.toJson<String?>(address),
      'className': serializer.toJson<String?>(className),
      'courseId': serializer.toJson<String?>(courseId),
      'courseName': serializer.toJson<String?>(courseName),
      'batchId': serializer.toJson<String?>(batchId),
      'batchName': serializer.toJson<String?>(batchName),
      'status': serializer.toJson<String>(status),
      'notes': serializer.toJson<String?>(notes),
      'photoUrl': serializer.toJson<String?>(photoUrl),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncStatus': serializer.toJson<String>(
        $LocalStudentsTable.$convertersyncStatus.toJson(syncStatus),
      ),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  LocalStudent copyWith({
    int? localId,
    Value<String?> cloudId = const Value.absent(),
    Value<String?> studentIdLegacy = const Value.absent(),
    String? name,
    String? normalizedName,
    Value<String?> phone = const Value.absent(),
    Value<String?> parentName = const Value.absent(),
    Value<String?> parentPhone = const Value.absent(),
    Value<String?> email = const Value.absent(),
    Value<DateTime?> dob = const Value.absent(),
    Value<String?> address = const Value.absent(),
    Value<String?> className = const Value.absent(),
    Value<String?> courseId = const Value.absent(),
    Value<String?> courseName = const Value.absent(),
    Value<String?> batchId = const Value.absent(),
    Value<String?> batchName = const Value.absent(),
    String? status,
    Value<String?> notes = const Value.absent(),
    Value<String?> photoUrl = const Value.absent(),
    Value<DateTime?> createdAt = const Value.absent(),
    Value<DateTime?> updatedAt = const Value.absent(),
    Value<DateTime?> deletedAt = const Value.absent(),
    LocalSyncStatus? syncStatus,
    Value<DateTime?> lastSyncedAt = const Value.absent(),
  }) => LocalStudent(
    localId: localId ?? this.localId,
    cloudId: cloudId.present ? cloudId.value : this.cloudId,
    studentIdLegacy: studentIdLegacy.present
        ? studentIdLegacy.value
        : this.studentIdLegacy,
    name: name ?? this.name,
    normalizedName: normalizedName ?? this.normalizedName,
    phone: phone.present ? phone.value : this.phone,
    parentName: parentName.present ? parentName.value : this.parentName,
    parentPhone: parentPhone.present ? parentPhone.value : this.parentPhone,
    email: email.present ? email.value : this.email,
    dob: dob.present ? dob.value : this.dob,
    address: address.present ? address.value : this.address,
    className: className.present ? className.value : this.className,
    courseId: courseId.present ? courseId.value : this.courseId,
    courseName: courseName.present ? courseName.value : this.courseName,
    batchId: batchId.present ? batchId.value : this.batchId,
    batchName: batchName.present ? batchName.value : this.batchName,
    status: status ?? this.status,
    notes: notes.present ? notes.value : this.notes,
    photoUrl: photoUrl.present ? photoUrl.value : this.photoUrl,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncStatus: syncStatus ?? this.syncStatus,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
  );
  LocalStudent copyWithCompanion(LocalStudentsCompanion data) {
    return LocalStudent(
      localId: data.localId.present ? data.localId.value : this.localId,
      cloudId: data.cloudId.present ? data.cloudId.value : this.cloudId,
      studentIdLegacy: data.studentIdLegacy.present
          ? data.studentIdLegacy.value
          : this.studentIdLegacy,
      name: data.name.present ? data.name.value : this.name,
      normalizedName: data.normalizedName.present
          ? data.normalizedName.value
          : this.normalizedName,
      phone: data.phone.present ? data.phone.value : this.phone,
      parentName: data.parentName.present
          ? data.parentName.value
          : this.parentName,
      parentPhone: data.parentPhone.present
          ? data.parentPhone.value
          : this.parentPhone,
      email: data.email.present ? data.email.value : this.email,
      dob: data.dob.present ? data.dob.value : this.dob,
      address: data.address.present ? data.address.value : this.address,
      className: data.className.present ? data.className.value : this.className,
      courseId: data.courseId.present ? data.courseId.value : this.courseId,
      courseName: data.courseName.present
          ? data.courseName.value
          : this.courseName,
      batchId: data.batchId.present ? data.batchId.value : this.batchId,
      batchName: data.batchName.present ? data.batchName.value : this.batchName,
      status: data.status.present ? data.status.value : this.status,
      notes: data.notes.present ? data.notes.value : this.notes,
      photoUrl: data.photoUrl.present ? data.photoUrl.value : this.photoUrl,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalStudent(')
          ..write('localId: $localId, ')
          ..write('cloudId: $cloudId, ')
          ..write('studentIdLegacy: $studentIdLegacy, ')
          ..write('name: $name, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('phone: $phone, ')
          ..write('parentName: $parentName, ')
          ..write('parentPhone: $parentPhone, ')
          ..write('email: $email, ')
          ..write('dob: $dob, ')
          ..write('address: $address, ')
          ..write('className: $className, ')
          ..write('courseId: $courseId, ')
          ..write('courseName: $courseName, ')
          ..write('batchId: $batchId, ')
          ..write('batchName: $batchName, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    localId,
    cloudId,
    studentIdLegacy,
    name,
    normalizedName,
    phone,
    parentName,
    parentPhone,
    email,
    dob,
    address,
    className,
    courseId,
    courseName,
    batchId,
    batchName,
    status,
    notes,
    photoUrl,
    createdAt,
    updatedAt,
    deletedAt,
    syncStatus,
    lastSyncedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalStudent &&
          other.localId == this.localId &&
          other.cloudId == this.cloudId &&
          other.studentIdLegacy == this.studentIdLegacy &&
          other.name == this.name &&
          other.normalizedName == this.normalizedName &&
          other.phone == this.phone &&
          other.parentName == this.parentName &&
          other.parentPhone == this.parentPhone &&
          other.email == this.email &&
          other.dob == this.dob &&
          other.address == this.address &&
          other.className == this.className &&
          other.courseId == this.courseId &&
          other.courseName == this.courseName &&
          other.batchId == this.batchId &&
          other.batchName == this.batchName &&
          other.status == this.status &&
          other.notes == this.notes &&
          other.photoUrl == this.photoUrl &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncStatus == this.syncStatus &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class LocalStudentsCompanion extends UpdateCompanion<LocalStudent> {
  final Value<int> localId;
  final Value<String?> cloudId;
  final Value<String?> studentIdLegacy;
  final Value<String> name;
  final Value<String> normalizedName;
  final Value<String?> phone;
  final Value<String?> parentName;
  final Value<String?> parentPhone;
  final Value<String?> email;
  final Value<DateTime?> dob;
  final Value<String?> address;
  final Value<String?> className;
  final Value<String?> courseId;
  final Value<String?> courseName;
  final Value<String?> batchId;
  final Value<String?> batchName;
  final Value<String> status;
  final Value<String?> notes;
  final Value<String?> photoUrl;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<LocalSyncStatus> syncStatus;
  final Value<DateTime?> lastSyncedAt;
  const LocalStudentsCompanion({
    this.localId = const Value.absent(),
    this.cloudId = const Value.absent(),
    this.studentIdLegacy = const Value.absent(),
    this.name = const Value.absent(),
    this.normalizedName = const Value.absent(),
    this.phone = const Value.absent(),
    this.parentName = const Value.absent(),
    this.parentPhone = const Value.absent(),
    this.email = const Value.absent(),
    this.dob = const Value.absent(),
    this.address = const Value.absent(),
    this.className = const Value.absent(),
    this.courseId = const Value.absent(),
    this.courseName = const Value.absent(),
    this.batchId = const Value.absent(),
    this.batchName = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.photoUrl = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
  });
  LocalStudentsCompanion.insert({
    this.localId = const Value.absent(),
    this.cloudId = const Value.absent(),
    this.studentIdLegacy = const Value.absent(),
    required String name,
    required String normalizedName,
    this.phone = const Value.absent(),
    this.parentName = const Value.absent(),
    this.parentPhone = const Value.absent(),
    this.email = const Value.absent(),
    this.dob = const Value.absent(),
    this.address = const Value.absent(),
    this.className = const Value.absent(),
    this.courseId = const Value.absent(),
    this.courseName = const Value.absent(),
    this.batchId = const Value.absent(),
    this.batchName = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.photoUrl = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required LocalSyncStatus syncStatus,
    this.lastSyncedAt = const Value.absent(),
  }) : name = Value(name),
       normalizedName = Value(normalizedName),
       syncStatus = Value(syncStatus);
  static Insertable<LocalStudent> custom({
    Expression<int>? localId,
    Expression<String>? cloudId,
    Expression<String>? studentIdLegacy,
    Expression<String>? name,
    Expression<String>? normalizedName,
    Expression<String>? phone,
    Expression<String>? parentName,
    Expression<String>? parentPhone,
    Expression<String>? email,
    Expression<DateTime>? dob,
    Expression<String>? address,
    Expression<String>? className,
    Expression<String>? courseId,
    Expression<String>? courseName,
    Expression<String>? batchId,
    Expression<String>? batchName,
    Expression<String>? status,
    Expression<String>? notes,
    Expression<String>? photoUrl,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? syncStatus,
    Expression<DateTime>? lastSyncedAt,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (cloudId != null) 'cloud_id': cloudId,
      if (studentIdLegacy != null) 'student_id_legacy': studentIdLegacy,
      if (name != null) 'name': name,
      if (normalizedName != null) 'normalized_name': normalizedName,
      if (phone != null) 'phone': phone,
      if (parentName != null) 'parent_name': parentName,
      if (parentPhone != null) 'parent_phone': parentPhone,
      if (email != null) 'email': email,
      if (dob != null) 'dob': dob,
      if (address != null) 'address': address,
      if (className != null) 'class_name': className,
      if (courseId != null) 'course_id': courseId,
      if (courseName != null) 'course_name': courseName,
      if (batchId != null) 'batch_id': batchId,
      if (batchName != null) 'batch_name': batchName,
      if (status != null) 'status': status,
      if (notes != null) 'notes': notes,
      if (photoUrl != null) 'photo_url': photoUrl,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
    });
  }

  LocalStudentsCompanion copyWith({
    Value<int>? localId,
    Value<String?>? cloudId,
    Value<String?>? studentIdLegacy,
    Value<String>? name,
    Value<String>? normalizedName,
    Value<String?>? phone,
    Value<String?>? parentName,
    Value<String?>? parentPhone,
    Value<String?>? email,
    Value<DateTime?>? dob,
    Value<String?>? address,
    Value<String?>? className,
    Value<String?>? courseId,
    Value<String?>? courseName,
    Value<String?>? batchId,
    Value<String?>? batchName,
    Value<String>? status,
    Value<String?>? notes,
    Value<String?>? photoUrl,
    Value<DateTime?>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<LocalSyncStatus>? syncStatus,
    Value<DateTime?>? lastSyncedAt,
  }) {
    return LocalStudentsCompanion(
      localId: localId ?? this.localId,
      cloudId: cloudId ?? this.cloudId,
      studentIdLegacy: studentIdLegacy ?? this.studentIdLegacy,
      name: name ?? this.name,
      normalizedName: normalizedName ?? this.normalizedName,
      phone: phone ?? this.phone,
      parentName: parentName ?? this.parentName,
      parentPhone: parentPhone ?? this.parentPhone,
      email: email ?? this.email,
      dob: dob ?? this.dob,
      address: address ?? this.address,
      className: className ?? this.className,
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
      batchId: batchId ?? this.batchId,
      batchName: batchName ?? this.batchName,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<int>(localId.value);
    }
    if (cloudId.present) {
      map['cloud_id'] = Variable<String>(cloudId.value);
    }
    if (studentIdLegacy.present) {
      map['student_id_legacy'] = Variable<String>(studentIdLegacy.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (normalizedName.present) {
      map['normalized_name'] = Variable<String>(normalizedName.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (parentName.present) {
      map['parent_name'] = Variable<String>(parentName.value);
    }
    if (parentPhone.present) {
      map['parent_phone'] = Variable<String>(parentPhone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (dob.present) {
      map['dob'] = Variable<DateTime>(dob.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (className.present) {
      map['class_name'] = Variable<String>(className.value);
    }
    if (courseId.present) {
      map['course_id'] = Variable<String>(courseId.value);
    }
    if (courseName.present) {
      map['course_name'] = Variable<String>(courseName.value);
    }
    if (batchId.present) {
      map['batch_id'] = Variable<String>(batchId.value);
    }
    if (batchName.present) {
      map['batch_name'] = Variable<String>(batchName.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (photoUrl.present) {
      map['photo_url'] = Variable<String>(photoUrl.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(
        $LocalStudentsTable.$convertersyncStatus.toSql(syncStatus.value),
      );
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalStudentsCompanion(')
          ..write('localId: $localId, ')
          ..write('cloudId: $cloudId, ')
          ..write('studentIdLegacy: $studentIdLegacy, ')
          ..write('name: $name, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('phone: $phone, ')
          ..write('parentName: $parentName, ')
          ..write('parentPhone: $parentPhone, ')
          ..write('email: $email, ')
          ..write('dob: $dob, ')
          ..write('address: $address, ')
          ..write('className: $className, ')
          ..write('courseId: $courseId, ')
          ..write('courseName: $courseName, ')
          ..write('batchId: $batchId, ')
          ..write('batchName: $batchName, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }
}

class $LocalCoursesTable extends LocalCourses
    with TableInfo<$LocalCoursesTable, LocalCourse> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalCoursesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<int> localId = GeneratedColumn<int>(
    'local_id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _cloudIdMeta = const VerificationMeta(
    'cloudId',
  );
  @override
  late final GeneratedColumn<String> cloudId = GeneratedColumn<String>(
    'cloud_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _legacyIdMeta = const VerificationMeta(
    'legacyId',
  );
  @override
  late final GeneratedColumn<String> legacyId = GeneratedColumn<String>(
    'legacy_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _feesAmountMeta = const VerificationMeta(
    'feesAmount',
  );
  @override
  late final GeneratedColumn<double> feesAmount = GeneratedColumn<double>(
    'fees_amount',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _feesFrequencyMeta = const VerificationMeta(
    'feesFrequency',
  );
  @override
  late final GeneratedColumn<String> feesFrequency = GeneratedColumn<String>(
    'fees_frequency',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _monthlyFeesMeta = const VerificationMeta(
    'monthlyFees',
  );
  @override
  late final GeneratedColumn<double> monthlyFees = GeneratedColumn<double>(
    'monthly_fees',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _yearlyFeesMeta = const VerificationMeta(
    'yearlyFees',
  );
  @override
  late final GeneratedColumn<double> yearlyFees = GeneratedColumn<double>(
    'yearly_fees',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationMonthsMeta = const VerificationMeta(
    'durationMonths',
  );
  @override
  late final GeneratedColumn<int> durationMonths = GeneratedColumn<int>(
    'duration_months',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _subjectsMeta = const VerificationMeta(
    'subjects',
  );
  @override
  late final GeneratedColumn<String> subjects = GeneratedColumn<String>(
    'subjects',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _maxStudentsMeta = const VerificationMeta(
    'maxStudents',
  );
  @override
  late final GeneratedColumn<int> maxStudents = GeneratedColumn<int>(
    'max_students',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<LocalSyncStatus, String>
  syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<LocalSyncStatus>($LocalCoursesTable.$convertersyncStatus);
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    localId,
    cloudId,
    legacyId,
    code,
    name,
    category,
    description,
    feesAmount,
    feesFrequency,
    monthlyFees,
    yearlyFees,
    durationMonths,
    subjects,
    maxStudents,
    isActive,
    createdAt,
    updatedAt,
    deletedAt,
    syncStatus,
    lastSyncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_courses';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalCourse> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    }
    if (data.containsKey('cloud_id')) {
      context.handle(
        _cloudIdMeta,
        cloudId.isAcceptableOrUnknown(data['cloud_id']!, _cloudIdMeta),
      );
    }
    if (data.containsKey('legacy_id')) {
      context.handle(
        _legacyIdMeta,
        legacyId.isAcceptableOrUnknown(data['legacy_id']!, _legacyIdMeta),
      );
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('fees_amount')) {
      context.handle(
        _feesAmountMeta,
        feesAmount.isAcceptableOrUnknown(data['fees_amount']!, _feesAmountMeta),
      );
    }
    if (data.containsKey('fees_frequency')) {
      context.handle(
        _feesFrequencyMeta,
        feesFrequency.isAcceptableOrUnknown(
          data['fees_frequency']!,
          _feesFrequencyMeta,
        ),
      );
    }
    if (data.containsKey('monthly_fees')) {
      context.handle(
        _monthlyFeesMeta,
        monthlyFees.isAcceptableOrUnknown(
          data['monthly_fees']!,
          _monthlyFeesMeta,
        ),
      );
    }
    if (data.containsKey('yearly_fees')) {
      context.handle(
        _yearlyFeesMeta,
        yearlyFees.isAcceptableOrUnknown(data['yearly_fees']!, _yearlyFeesMeta),
      );
    }
    if (data.containsKey('duration_months')) {
      context.handle(
        _durationMonthsMeta,
        durationMonths.isAcceptableOrUnknown(
          data['duration_months']!,
          _durationMonthsMeta,
        ),
      );
    }
    if (data.containsKey('subjects')) {
      context.handle(
        _subjectsMeta,
        subjects.isAcceptableOrUnknown(data['subjects']!, _subjectsMeta),
      );
    }
    if (data.containsKey('max_students')) {
      context.handle(
        _maxStudentsMeta,
        maxStudents.isAcceptableOrUnknown(
          data['max_students']!,
          _maxStudentsMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  LocalCourse map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalCourse(
      localId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_id'],
      )!,
      cloudId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cloud_id'],
      ),
      legacyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}legacy_id'],
      ),
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      feesAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fees_amount'],
      ),
      feesFrequency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fees_frequency'],
      ),
      monthlyFees: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}monthly_fees'],
      ),
      yearlyFees: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}yearly_fees'],
      ),
      durationMonths: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_months'],
      ),
      subjects: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subjects'],
      ),
      maxStudents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_students'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      syncStatus: $LocalCoursesTable.$convertersyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}sync_status'],
        )!,
      ),
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
    );
  }

  @override
  $LocalCoursesTable createAlias(String alias) {
    return $LocalCoursesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<LocalSyncStatus, String, String>
  $convertersyncStatus = const EnumNameConverter<LocalSyncStatus>(
    LocalSyncStatus.values,
  );
}

class LocalCourse extends DataClass implements Insertable<LocalCourse> {
  final int localId;
  final String? cloudId;
  final String? legacyId;
  final String? code;
  final String name;
  final String? category;
  final String? description;
  final double? feesAmount;
  final String? feesFrequency;
  final double? monthlyFees;
  final double? yearlyFees;
  final int? durationMonths;
  final String? subjects;
  final int? maxStudents;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final LocalSyncStatus syncStatus;
  final DateTime? lastSyncedAt;
  const LocalCourse({
    required this.localId,
    this.cloudId,
    this.legacyId,
    this.code,
    required this.name,
    this.category,
    this.description,
    this.feesAmount,
    this.feesFrequency,
    this.monthlyFees,
    this.yearlyFees,
    this.durationMonths,
    this.subjects,
    this.maxStudents,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    required this.syncStatus,
    this.lastSyncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<int>(localId);
    if (!nullToAbsent || cloudId != null) {
      map['cloud_id'] = Variable<String>(cloudId);
    }
    if (!nullToAbsent || legacyId != null) {
      map['legacy_id'] = Variable<String>(legacyId);
    }
    if (!nullToAbsent || code != null) {
      map['code'] = Variable<String>(code);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || feesAmount != null) {
      map['fees_amount'] = Variable<double>(feesAmount);
    }
    if (!nullToAbsent || feesFrequency != null) {
      map['fees_frequency'] = Variable<String>(feesFrequency);
    }
    if (!nullToAbsent || monthlyFees != null) {
      map['monthly_fees'] = Variable<double>(monthlyFees);
    }
    if (!nullToAbsent || yearlyFees != null) {
      map['yearly_fees'] = Variable<double>(yearlyFees);
    }
    if (!nullToAbsent || durationMonths != null) {
      map['duration_months'] = Variable<int>(durationMonths);
    }
    if (!nullToAbsent || subjects != null) {
      map['subjects'] = Variable<String>(subjects);
    }
    if (!nullToAbsent || maxStudents != null) {
      map['max_students'] = Variable<int>(maxStudents);
    }
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    {
      map['sync_status'] = Variable<String>(
        $LocalCoursesTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  LocalCoursesCompanion toCompanion(bool nullToAbsent) {
    return LocalCoursesCompanion(
      localId: Value(localId),
      cloudId: cloudId == null && nullToAbsent
          ? const Value.absent()
          : Value(cloudId),
      legacyId: legacyId == null && nullToAbsent
          ? const Value.absent()
          : Value(legacyId),
      code: code == null && nullToAbsent ? const Value.absent() : Value(code),
      name: Value(name),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      feesAmount: feesAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(feesAmount),
      feesFrequency: feesFrequency == null && nullToAbsent
          ? const Value.absent()
          : Value(feesFrequency),
      monthlyFees: monthlyFees == null && nullToAbsent
          ? const Value.absent()
          : Value(monthlyFees),
      yearlyFees: yearlyFees == null && nullToAbsent
          ? const Value.absent()
          : Value(yearlyFees),
      durationMonths: durationMonths == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMonths),
      subjects: subjects == null && nullToAbsent
          ? const Value.absent()
          : Value(subjects),
      maxStudents: maxStudents == null && nullToAbsent
          ? const Value.absent()
          : Value(maxStudents),
      isActive: Value(isActive),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncStatus: Value(syncStatus),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory LocalCourse.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalCourse(
      localId: serializer.fromJson<int>(json['localId']),
      cloudId: serializer.fromJson<String?>(json['cloudId']),
      legacyId: serializer.fromJson<String?>(json['legacyId']),
      code: serializer.fromJson<String?>(json['code']),
      name: serializer.fromJson<String>(json['name']),
      category: serializer.fromJson<String?>(json['category']),
      description: serializer.fromJson<String?>(json['description']),
      feesAmount: serializer.fromJson<double?>(json['feesAmount']),
      feesFrequency: serializer.fromJson<String?>(json['feesFrequency']),
      monthlyFees: serializer.fromJson<double?>(json['monthlyFees']),
      yearlyFees: serializer.fromJson<double?>(json['yearlyFees']),
      durationMonths: serializer.fromJson<int?>(json['durationMonths']),
      subjects: serializer.fromJson<String?>(json['subjects']),
      maxStudents: serializer.fromJson<int?>(json['maxStudents']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncStatus: $LocalCoursesTable.$convertersyncStatus.fromJson(
        serializer.fromJson<String>(json['syncStatus']),
      ),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<int>(localId),
      'cloudId': serializer.toJson<String?>(cloudId),
      'legacyId': serializer.toJson<String?>(legacyId),
      'code': serializer.toJson<String?>(code),
      'name': serializer.toJson<String>(name),
      'category': serializer.toJson<String?>(category),
      'description': serializer.toJson<String?>(description),
      'feesAmount': serializer.toJson<double?>(feesAmount),
      'feesFrequency': serializer.toJson<String?>(feesFrequency),
      'monthlyFees': serializer.toJson<double?>(monthlyFees),
      'yearlyFees': serializer.toJson<double?>(yearlyFees),
      'durationMonths': serializer.toJson<int?>(durationMonths),
      'subjects': serializer.toJson<String?>(subjects),
      'maxStudents': serializer.toJson<int?>(maxStudents),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncStatus': serializer.toJson<String>(
        $LocalCoursesTable.$convertersyncStatus.toJson(syncStatus),
      ),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  LocalCourse copyWith({
    int? localId,
    Value<String?> cloudId = const Value.absent(),
    Value<String?> legacyId = const Value.absent(),
    Value<String?> code = const Value.absent(),
    String? name,
    Value<String?> category = const Value.absent(),
    Value<String?> description = const Value.absent(),
    Value<double?> feesAmount = const Value.absent(),
    Value<String?> feesFrequency = const Value.absent(),
    Value<double?> monthlyFees = const Value.absent(),
    Value<double?> yearlyFees = const Value.absent(),
    Value<int?> durationMonths = const Value.absent(),
    Value<String?> subjects = const Value.absent(),
    Value<int?> maxStudents = const Value.absent(),
    bool? isActive,
    Value<DateTime?> createdAt = const Value.absent(),
    Value<DateTime?> updatedAt = const Value.absent(),
    Value<DateTime?> deletedAt = const Value.absent(),
    LocalSyncStatus? syncStatus,
    Value<DateTime?> lastSyncedAt = const Value.absent(),
  }) => LocalCourse(
    localId: localId ?? this.localId,
    cloudId: cloudId.present ? cloudId.value : this.cloudId,
    legacyId: legacyId.present ? legacyId.value : this.legacyId,
    code: code.present ? code.value : this.code,
    name: name ?? this.name,
    category: category.present ? category.value : this.category,
    description: description.present ? description.value : this.description,
    feesAmount: feesAmount.present ? feesAmount.value : this.feesAmount,
    feesFrequency: feesFrequency.present
        ? feesFrequency.value
        : this.feesFrequency,
    monthlyFees: monthlyFees.present ? monthlyFees.value : this.monthlyFees,
    yearlyFees: yearlyFees.present ? yearlyFees.value : this.yearlyFees,
    durationMonths: durationMonths.present
        ? durationMonths.value
        : this.durationMonths,
    subjects: subjects.present ? subjects.value : this.subjects,
    maxStudents: maxStudents.present ? maxStudents.value : this.maxStudents,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncStatus: syncStatus ?? this.syncStatus,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
  );
  LocalCourse copyWithCompanion(LocalCoursesCompanion data) {
    return LocalCourse(
      localId: data.localId.present ? data.localId.value : this.localId,
      cloudId: data.cloudId.present ? data.cloudId.value : this.cloudId,
      legacyId: data.legacyId.present ? data.legacyId.value : this.legacyId,
      code: data.code.present ? data.code.value : this.code,
      name: data.name.present ? data.name.value : this.name,
      category: data.category.present ? data.category.value : this.category,
      description: data.description.present
          ? data.description.value
          : this.description,
      feesAmount: data.feesAmount.present
          ? data.feesAmount.value
          : this.feesAmount,
      feesFrequency: data.feesFrequency.present
          ? data.feesFrequency.value
          : this.feesFrequency,
      monthlyFees: data.monthlyFees.present
          ? data.monthlyFees.value
          : this.monthlyFees,
      yearlyFees: data.yearlyFees.present
          ? data.yearlyFees.value
          : this.yearlyFees,
      durationMonths: data.durationMonths.present
          ? data.durationMonths.value
          : this.durationMonths,
      subjects: data.subjects.present ? data.subjects.value : this.subjects,
      maxStudents: data.maxStudents.present
          ? data.maxStudents.value
          : this.maxStudents,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalCourse(')
          ..write('localId: $localId, ')
          ..write('cloudId: $cloudId, ')
          ..write('legacyId: $legacyId, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('description: $description, ')
          ..write('feesAmount: $feesAmount, ')
          ..write('feesFrequency: $feesFrequency, ')
          ..write('monthlyFees: $monthlyFees, ')
          ..write('yearlyFees: $yearlyFees, ')
          ..write('durationMonths: $durationMonths, ')
          ..write('subjects: $subjects, ')
          ..write('maxStudents: $maxStudents, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    localId,
    cloudId,
    legacyId,
    code,
    name,
    category,
    description,
    feesAmount,
    feesFrequency,
    monthlyFees,
    yearlyFees,
    durationMonths,
    subjects,
    maxStudents,
    isActive,
    createdAt,
    updatedAt,
    deletedAt,
    syncStatus,
    lastSyncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalCourse &&
          other.localId == this.localId &&
          other.cloudId == this.cloudId &&
          other.legacyId == this.legacyId &&
          other.code == this.code &&
          other.name == this.name &&
          other.category == this.category &&
          other.description == this.description &&
          other.feesAmount == this.feesAmount &&
          other.feesFrequency == this.feesFrequency &&
          other.monthlyFees == this.monthlyFees &&
          other.yearlyFees == this.yearlyFees &&
          other.durationMonths == this.durationMonths &&
          other.subjects == this.subjects &&
          other.maxStudents == this.maxStudents &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncStatus == this.syncStatus &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class LocalCoursesCompanion extends UpdateCompanion<LocalCourse> {
  final Value<int> localId;
  final Value<String?> cloudId;
  final Value<String?> legacyId;
  final Value<String?> code;
  final Value<String> name;
  final Value<String?> category;
  final Value<String?> description;
  final Value<double?> feesAmount;
  final Value<String?> feesFrequency;
  final Value<double?> monthlyFees;
  final Value<double?> yearlyFees;
  final Value<int?> durationMonths;
  final Value<String?> subjects;
  final Value<int?> maxStudents;
  final Value<bool> isActive;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<LocalSyncStatus> syncStatus;
  final Value<DateTime?> lastSyncedAt;
  const LocalCoursesCompanion({
    this.localId = const Value.absent(),
    this.cloudId = const Value.absent(),
    this.legacyId = const Value.absent(),
    this.code = const Value.absent(),
    this.name = const Value.absent(),
    this.category = const Value.absent(),
    this.description = const Value.absent(),
    this.feesAmount = const Value.absent(),
    this.feesFrequency = const Value.absent(),
    this.monthlyFees = const Value.absent(),
    this.yearlyFees = const Value.absent(),
    this.durationMonths = const Value.absent(),
    this.subjects = const Value.absent(),
    this.maxStudents = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
  });
  LocalCoursesCompanion.insert({
    this.localId = const Value.absent(),
    this.cloudId = const Value.absent(),
    this.legacyId = const Value.absent(),
    this.code = const Value.absent(),
    required String name,
    this.category = const Value.absent(),
    this.description = const Value.absent(),
    this.feesAmount = const Value.absent(),
    this.feesFrequency = const Value.absent(),
    this.monthlyFees = const Value.absent(),
    this.yearlyFees = const Value.absent(),
    this.durationMonths = const Value.absent(),
    this.subjects = const Value.absent(),
    this.maxStudents = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required LocalSyncStatus syncStatus,
    this.lastSyncedAt = const Value.absent(),
  }) : name = Value(name),
       syncStatus = Value(syncStatus);
  static Insertable<LocalCourse> custom({
    Expression<int>? localId,
    Expression<String>? cloudId,
    Expression<String>? legacyId,
    Expression<String>? code,
    Expression<String>? name,
    Expression<String>? category,
    Expression<String>? description,
    Expression<double>? feesAmount,
    Expression<String>? feesFrequency,
    Expression<double>? monthlyFees,
    Expression<double>? yearlyFees,
    Expression<int>? durationMonths,
    Expression<String>? subjects,
    Expression<int>? maxStudents,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? syncStatus,
    Expression<DateTime>? lastSyncedAt,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (cloudId != null) 'cloud_id': cloudId,
      if (legacyId != null) 'legacy_id': legacyId,
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (category != null) 'category': category,
      if (description != null) 'description': description,
      if (feesAmount != null) 'fees_amount': feesAmount,
      if (feesFrequency != null) 'fees_frequency': feesFrequency,
      if (monthlyFees != null) 'monthly_fees': monthlyFees,
      if (yearlyFees != null) 'yearly_fees': yearlyFees,
      if (durationMonths != null) 'duration_months': durationMonths,
      if (subjects != null) 'subjects': subjects,
      if (maxStudents != null) 'max_students': maxStudents,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
    });
  }

  LocalCoursesCompanion copyWith({
    Value<int>? localId,
    Value<String?>? cloudId,
    Value<String?>? legacyId,
    Value<String?>? code,
    Value<String>? name,
    Value<String?>? category,
    Value<String?>? description,
    Value<double?>? feesAmount,
    Value<String?>? feesFrequency,
    Value<double?>? monthlyFees,
    Value<double?>? yearlyFees,
    Value<int?>? durationMonths,
    Value<String?>? subjects,
    Value<int?>? maxStudents,
    Value<bool>? isActive,
    Value<DateTime?>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<LocalSyncStatus>? syncStatus,
    Value<DateTime?>? lastSyncedAt,
  }) {
    return LocalCoursesCompanion(
      localId: localId ?? this.localId,
      cloudId: cloudId ?? this.cloudId,
      legacyId: legacyId ?? this.legacyId,
      code: code ?? this.code,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      feesAmount: feesAmount ?? this.feesAmount,
      feesFrequency: feesFrequency ?? this.feesFrequency,
      monthlyFees: monthlyFees ?? this.monthlyFees,
      yearlyFees: yearlyFees ?? this.yearlyFees,
      durationMonths: durationMonths ?? this.durationMonths,
      subjects: subjects ?? this.subjects,
      maxStudents: maxStudents ?? this.maxStudents,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<int>(localId.value);
    }
    if (cloudId.present) {
      map['cloud_id'] = Variable<String>(cloudId.value);
    }
    if (legacyId.present) {
      map['legacy_id'] = Variable<String>(legacyId.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (feesAmount.present) {
      map['fees_amount'] = Variable<double>(feesAmount.value);
    }
    if (feesFrequency.present) {
      map['fees_frequency'] = Variable<String>(feesFrequency.value);
    }
    if (monthlyFees.present) {
      map['monthly_fees'] = Variable<double>(monthlyFees.value);
    }
    if (yearlyFees.present) {
      map['yearly_fees'] = Variable<double>(yearlyFees.value);
    }
    if (durationMonths.present) {
      map['duration_months'] = Variable<int>(durationMonths.value);
    }
    if (subjects.present) {
      map['subjects'] = Variable<String>(subjects.value);
    }
    if (maxStudents.present) {
      map['max_students'] = Variable<int>(maxStudents.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(
        $LocalCoursesTable.$convertersyncStatus.toSql(syncStatus.value),
      );
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalCoursesCompanion(')
          ..write('localId: $localId, ')
          ..write('cloudId: $cloudId, ')
          ..write('legacyId: $legacyId, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('description: $description, ')
          ..write('feesAmount: $feesAmount, ')
          ..write('feesFrequency: $feesFrequency, ')
          ..write('monthlyFees: $monthlyFees, ')
          ..write('yearlyFees: $yearlyFees, ')
          ..write('durationMonths: $durationMonths, ')
          ..write('subjects: $subjects, ')
          ..write('maxStudents: $maxStudents, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }
}

class $LocalBatchesTable extends LocalBatches
    with TableInfo<$LocalBatchesTable, LocalBatch> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalBatchesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<int> localId = GeneratedColumn<int>(
    'local_id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _cloudIdMeta = const VerificationMeta(
    'cloudId',
  );
  @override
  late final GeneratedColumn<String> cloudId = GeneratedColumn<String>(
    'cloud_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _legacyIdMeta = const VerificationMeta(
    'legacyId',
  );
  @override
  late final GeneratedColumn<String> legacyId = GeneratedColumn<String>(
    'legacy_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _courseIdMeta = const VerificationMeta(
    'courseId',
  );
  @override
  late final GeneratedColumn<String> courseId = GeneratedColumn<String>(
    'course_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _courseNameMeta = const VerificationMeta(
    'courseName',
  );
  @override
  late final GeneratedColumn<String> courseName = GeneratedColumn<String>(
    'course_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _daysJsonMeta = const VerificationMeta(
    'daysJson',
  );
  @override
  late final GeneratedColumn<String> daysJson = GeneratedColumn<String>(
    'days_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
    'end_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startTimeMeta = const VerificationMeta(
    'startTime',
  );
  @override
  late final GeneratedColumn<String> startTime = GeneratedColumn<String>(
    'start_time',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endTimeMeta = const VerificationMeta(
    'endTime',
  );
  @override
  late final GeneratedColumn<String> endTime = GeneratedColumn<String>(
    'end_time',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _maxStudentsMeta = const VerificationMeta(
    'maxStudents',
  );
  @override
  late final GeneratedColumn<int> maxStudents = GeneratedColumn<int>(
    'max_students',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<LocalSyncStatus, String>
  syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<LocalSyncStatus>($LocalBatchesTable.$convertersyncStatus);
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    localId,
    cloudId,
    legacyId,
    name,
    courseId,
    courseName,
    daysJson,
    startDate,
    endDate,
    startTime,
    endTime,
    maxStudents,
    isActive,
    createdAt,
    updatedAt,
    deletedAt,
    syncStatus,
    lastSyncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_batches';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalBatch> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    }
    if (data.containsKey('cloud_id')) {
      context.handle(
        _cloudIdMeta,
        cloudId.isAcceptableOrUnknown(data['cloud_id']!, _cloudIdMeta),
      );
    }
    if (data.containsKey('legacy_id')) {
      context.handle(
        _legacyIdMeta,
        legacyId.isAcceptableOrUnknown(data['legacy_id']!, _legacyIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('course_id')) {
      context.handle(
        _courseIdMeta,
        courseId.isAcceptableOrUnknown(data['course_id']!, _courseIdMeta),
      );
    }
    if (data.containsKey('course_name')) {
      context.handle(
        _courseNameMeta,
        courseName.isAcceptableOrUnknown(data['course_name']!, _courseNameMeta),
      );
    }
    if (data.containsKey('days_json')) {
      context.handle(
        _daysJsonMeta,
        daysJson.isAcceptableOrUnknown(data['days_json']!, _daysJsonMeta),
      );
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    }
    if (data.containsKey('start_time')) {
      context.handle(
        _startTimeMeta,
        startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta),
      );
    }
    if (data.containsKey('end_time')) {
      context.handle(
        _endTimeMeta,
        endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta),
      );
    }
    if (data.containsKey('max_students')) {
      context.handle(
        _maxStudentsMeta,
        maxStudents.isAcceptableOrUnknown(
          data['max_students']!,
          _maxStudentsMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  LocalBatch map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalBatch(
      localId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_id'],
      )!,
      cloudId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cloud_id'],
      ),
      legacyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}legacy_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      courseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}course_id'],
      ),
      courseName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}course_name'],
      ),
      daysJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}days_json'],
      ),
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      ),
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_date'],
      ),
      startTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start_time'],
      ),
      endTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}end_time'],
      ),
      maxStudents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_students'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      syncStatus: $LocalBatchesTable.$convertersyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}sync_status'],
        )!,
      ),
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
    );
  }

  @override
  $LocalBatchesTable createAlias(String alias) {
    return $LocalBatchesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<LocalSyncStatus, String, String>
  $convertersyncStatus = const EnumNameConverter<LocalSyncStatus>(
    LocalSyncStatus.values,
  );
}

class LocalBatch extends DataClass implements Insertable<LocalBatch> {
  final int localId;
  final String? cloudId;
  final String? legacyId;
  final String name;
  final String? courseId;
  final String? courseName;
  final String? daysJson;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? startTime;
  final String? endTime;
  final int? maxStudents;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final LocalSyncStatus syncStatus;
  final DateTime? lastSyncedAt;
  const LocalBatch({
    required this.localId,
    this.cloudId,
    this.legacyId,
    required this.name,
    this.courseId,
    this.courseName,
    this.daysJson,
    this.startDate,
    this.endDate,
    this.startTime,
    this.endTime,
    this.maxStudents,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    required this.syncStatus,
    this.lastSyncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<int>(localId);
    if (!nullToAbsent || cloudId != null) {
      map['cloud_id'] = Variable<String>(cloudId);
    }
    if (!nullToAbsent || legacyId != null) {
      map['legacy_id'] = Variable<String>(legacyId);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || courseId != null) {
      map['course_id'] = Variable<String>(courseId);
    }
    if (!nullToAbsent || courseName != null) {
      map['course_name'] = Variable<String>(courseName);
    }
    if (!nullToAbsent || daysJson != null) {
      map['days_json'] = Variable<String>(daysJson);
    }
    if (!nullToAbsent || startDate != null) {
      map['start_date'] = Variable<DateTime>(startDate);
    }
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    if (!nullToAbsent || startTime != null) {
      map['start_time'] = Variable<String>(startTime);
    }
    if (!nullToAbsent || endTime != null) {
      map['end_time'] = Variable<String>(endTime);
    }
    if (!nullToAbsent || maxStudents != null) {
      map['max_students'] = Variable<int>(maxStudents);
    }
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    {
      map['sync_status'] = Variable<String>(
        $LocalBatchesTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  LocalBatchesCompanion toCompanion(bool nullToAbsent) {
    return LocalBatchesCompanion(
      localId: Value(localId),
      cloudId: cloudId == null && nullToAbsent
          ? const Value.absent()
          : Value(cloudId),
      legacyId: legacyId == null && nullToAbsent
          ? const Value.absent()
          : Value(legacyId),
      name: Value(name),
      courseId: courseId == null && nullToAbsent
          ? const Value.absent()
          : Value(courseId),
      courseName: courseName == null && nullToAbsent
          ? const Value.absent()
          : Value(courseName),
      daysJson: daysJson == null && nullToAbsent
          ? const Value.absent()
          : Value(daysJson),
      startDate: startDate == null && nullToAbsent
          ? const Value.absent()
          : Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      startTime: startTime == null && nullToAbsent
          ? const Value.absent()
          : Value(startTime),
      endTime: endTime == null && nullToAbsent
          ? const Value.absent()
          : Value(endTime),
      maxStudents: maxStudents == null && nullToAbsent
          ? const Value.absent()
          : Value(maxStudents),
      isActive: Value(isActive),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncStatus: Value(syncStatus),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory LocalBatch.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalBatch(
      localId: serializer.fromJson<int>(json['localId']),
      cloudId: serializer.fromJson<String?>(json['cloudId']),
      legacyId: serializer.fromJson<String?>(json['legacyId']),
      name: serializer.fromJson<String>(json['name']),
      courseId: serializer.fromJson<String?>(json['courseId']),
      courseName: serializer.fromJson<String?>(json['courseName']),
      daysJson: serializer.fromJson<String?>(json['daysJson']),
      startDate: serializer.fromJson<DateTime?>(json['startDate']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      startTime: serializer.fromJson<String?>(json['startTime']),
      endTime: serializer.fromJson<String?>(json['endTime']),
      maxStudents: serializer.fromJson<int?>(json['maxStudents']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncStatus: $LocalBatchesTable.$convertersyncStatus.fromJson(
        serializer.fromJson<String>(json['syncStatus']),
      ),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<int>(localId),
      'cloudId': serializer.toJson<String?>(cloudId),
      'legacyId': serializer.toJson<String?>(legacyId),
      'name': serializer.toJson<String>(name),
      'courseId': serializer.toJson<String?>(courseId),
      'courseName': serializer.toJson<String?>(courseName),
      'daysJson': serializer.toJson<String?>(daysJson),
      'startDate': serializer.toJson<DateTime?>(startDate),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'startTime': serializer.toJson<String?>(startTime),
      'endTime': serializer.toJson<String?>(endTime),
      'maxStudents': serializer.toJson<int?>(maxStudents),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncStatus': serializer.toJson<String>(
        $LocalBatchesTable.$convertersyncStatus.toJson(syncStatus),
      ),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  LocalBatch copyWith({
    int? localId,
    Value<String?> cloudId = const Value.absent(),
    Value<String?> legacyId = const Value.absent(),
    String? name,
    Value<String?> courseId = const Value.absent(),
    Value<String?> courseName = const Value.absent(),
    Value<String?> daysJson = const Value.absent(),
    Value<DateTime?> startDate = const Value.absent(),
    Value<DateTime?> endDate = const Value.absent(),
    Value<String?> startTime = const Value.absent(),
    Value<String?> endTime = const Value.absent(),
    Value<int?> maxStudents = const Value.absent(),
    bool? isActive,
    Value<DateTime?> createdAt = const Value.absent(),
    Value<DateTime?> updatedAt = const Value.absent(),
    Value<DateTime?> deletedAt = const Value.absent(),
    LocalSyncStatus? syncStatus,
    Value<DateTime?> lastSyncedAt = const Value.absent(),
  }) => LocalBatch(
    localId: localId ?? this.localId,
    cloudId: cloudId.present ? cloudId.value : this.cloudId,
    legacyId: legacyId.present ? legacyId.value : this.legacyId,
    name: name ?? this.name,
    courseId: courseId.present ? courseId.value : this.courseId,
    courseName: courseName.present ? courseName.value : this.courseName,
    daysJson: daysJson.present ? daysJson.value : this.daysJson,
    startDate: startDate.present ? startDate.value : this.startDate,
    endDate: endDate.present ? endDate.value : this.endDate,
    startTime: startTime.present ? startTime.value : this.startTime,
    endTime: endTime.present ? endTime.value : this.endTime,
    maxStudents: maxStudents.present ? maxStudents.value : this.maxStudents,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncStatus: syncStatus ?? this.syncStatus,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
  );
  LocalBatch copyWithCompanion(LocalBatchesCompanion data) {
    return LocalBatch(
      localId: data.localId.present ? data.localId.value : this.localId,
      cloudId: data.cloudId.present ? data.cloudId.value : this.cloudId,
      legacyId: data.legacyId.present ? data.legacyId.value : this.legacyId,
      name: data.name.present ? data.name.value : this.name,
      courseId: data.courseId.present ? data.courseId.value : this.courseId,
      courseName: data.courseName.present
          ? data.courseName.value
          : this.courseName,
      daysJson: data.daysJson.present ? data.daysJson.value : this.daysJson,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      maxStudents: data.maxStudents.present
          ? data.maxStudents.value
          : this.maxStudents,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalBatch(')
          ..write('localId: $localId, ')
          ..write('cloudId: $cloudId, ')
          ..write('legacyId: $legacyId, ')
          ..write('name: $name, ')
          ..write('courseId: $courseId, ')
          ..write('courseName: $courseName, ')
          ..write('daysJson: $daysJson, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('maxStudents: $maxStudents, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    localId,
    cloudId,
    legacyId,
    name,
    courseId,
    courseName,
    daysJson,
    startDate,
    endDate,
    startTime,
    endTime,
    maxStudents,
    isActive,
    createdAt,
    updatedAt,
    deletedAt,
    syncStatus,
    lastSyncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalBatch &&
          other.localId == this.localId &&
          other.cloudId == this.cloudId &&
          other.legacyId == this.legacyId &&
          other.name == this.name &&
          other.courseId == this.courseId &&
          other.courseName == this.courseName &&
          other.daysJson == this.daysJson &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.maxStudents == this.maxStudents &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncStatus == this.syncStatus &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class LocalBatchesCompanion extends UpdateCompanion<LocalBatch> {
  final Value<int> localId;
  final Value<String?> cloudId;
  final Value<String?> legacyId;
  final Value<String> name;
  final Value<String?> courseId;
  final Value<String?> courseName;
  final Value<String?> daysJson;
  final Value<DateTime?> startDate;
  final Value<DateTime?> endDate;
  final Value<String?> startTime;
  final Value<String?> endTime;
  final Value<int?> maxStudents;
  final Value<bool> isActive;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<LocalSyncStatus> syncStatus;
  final Value<DateTime?> lastSyncedAt;
  const LocalBatchesCompanion({
    this.localId = const Value.absent(),
    this.cloudId = const Value.absent(),
    this.legacyId = const Value.absent(),
    this.name = const Value.absent(),
    this.courseId = const Value.absent(),
    this.courseName = const Value.absent(),
    this.daysJson = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.maxStudents = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
  });
  LocalBatchesCompanion.insert({
    this.localId = const Value.absent(),
    this.cloudId = const Value.absent(),
    this.legacyId = const Value.absent(),
    required String name,
    this.courseId = const Value.absent(),
    this.courseName = const Value.absent(),
    this.daysJson = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.maxStudents = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required LocalSyncStatus syncStatus,
    this.lastSyncedAt = const Value.absent(),
  }) : name = Value(name),
       syncStatus = Value(syncStatus);
  static Insertable<LocalBatch> custom({
    Expression<int>? localId,
    Expression<String>? cloudId,
    Expression<String>? legacyId,
    Expression<String>? name,
    Expression<String>? courseId,
    Expression<String>? courseName,
    Expression<String>? daysJson,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<String>? startTime,
    Expression<String>? endTime,
    Expression<int>? maxStudents,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? syncStatus,
    Expression<DateTime>? lastSyncedAt,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (cloudId != null) 'cloud_id': cloudId,
      if (legacyId != null) 'legacy_id': legacyId,
      if (name != null) 'name': name,
      if (courseId != null) 'course_id': courseId,
      if (courseName != null) 'course_name': courseName,
      if (daysJson != null) 'days_json': daysJson,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (maxStudents != null) 'max_students': maxStudents,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
    });
  }

  LocalBatchesCompanion copyWith({
    Value<int>? localId,
    Value<String?>? cloudId,
    Value<String?>? legacyId,
    Value<String>? name,
    Value<String?>? courseId,
    Value<String?>? courseName,
    Value<String?>? daysJson,
    Value<DateTime?>? startDate,
    Value<DateTime?>? endDate,
    Value<String?>? startTime,
    Value<String?>? endTime,
    Value<int?>? maxStudents,
    Value<bool>? isActive,
    Value<DateTime?>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<LocalSyncStatus>? syncStatus,
    Value<DateTime?>? lastSyncedAt,
  }) {
    return LocalBatchesCompanion(
      localId: localId ?? this.localId,
      cloudId: cloudId ?? this.cloudId,
      legacyId: legacyId ?? this.legacyId,
      name: name ?? this.name,
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
      daysJson: daysJson ?? this.daysJson,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      maxStudents: maxStudents ?? this.maxStudents,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<int>(localId.value);
    }
    if (cloudId.present) {
      map['cloud_id'] = Variable<String>(cloudId.value);
    }
    if (legacyId.present) {
      map['legacy_id'] = Variable<String>(legacyId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (courseId.present) {
      map['course_id'] = Variable<String>(courseId.value);
    }
    if (courseName.present) {
      map['course_name'] = Variable<String>(courseName.value);
    }
    if (daysJson.present) {
      map['days_json'] = Variable<String>(daysJson.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<String>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<String>(endTime.value);
    }
    if (maxStudents.present) {
      map['max_students'] = Variable<int>(maxStudents.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(
        $LocalBatchesTable.$convertersyncStatus.toSql(syncStatus.value),
      );
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalBatchesCompanion(')
          ..write('localId: $localId, ')
          ..write('cloudId: $cloudId, ')
          ..write('legacyId: $legacyId, ')
          ..write('name: $name, ')
          ..write('courseId: $courseId, ')
          ..write('courseName: $courseName, ')
          ..write('daysJson: $daysJson, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('maxStudents: $maxStudents, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }
}

class $LocalEnquiriesTable extends LocalEnquiries
    with TableInfo<$LocalEnquiriesTable, LocalEnquiry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalEnquiriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<int> localId = GeneratedColumn<int>(
    'local_id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _cloudIdMeta = const VerificationMeta(
    'cloudId',
  );
  @override
  late final GeneratedColumn<String> cloudId = GeneratedColumn<String>(
    'cloud_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _legacyIdMeta = const VerificationMeta(
    'legacyId',
  );
  @override
  late final GeneratedColumn<String> legacyId = GeneratedColumn<String>(
    'legacy_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _studentNameMeta = const VerificationMeta(
    'studentName',
  );
  @override
  late final GeneratedColumn<String> studentName = GeneratedColumn<String>(
    'student_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parentNameMeta = const VerificationMeta(
    'parentName',
  );
  @override
  late final GeneratedColumn<String> parentName = GeneratedColumn<String>(
    'parent_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _alternatePhoneMeta = const VerificationMeta(
    'alternatePhone',
  );
  @override
  late final GeneratedColumn<String> alternatePhone = GeneratedColumn<String>(
    'alternate_phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dobMeta = const VerificationMeta('dob');
  @override
  late final GeneratedColumn<DateTime> dob = GeneratedColumn<DateTime>(
    'dob',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _interestedCourseIdMeta =
      const VerificationMeta('interestedCourseId');
  @override
  late final GeneratedColumn<String> interestedCourseId =
      GeneratedColumn<String>(
        'interested_course_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _interestedCourseNameMeta =
      const VerificationMeta('interestedCourseName');
  @override
  late final GeneratedColumn<String> interestedCourseName =
      GeneratedColumn<String>(
        'interested_course_name',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _interestedBatchIdMeta = const VerificationMeta(
    'interestedBatchId',
  );
  @override
  late final GeneratedColumn<String> interestedBatchId =
      GeneratedColumn<String>(
        'interested_batch_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _interestedBatchNameMeta =
      const VerificationMeta('interestedBatchName');
  @override
  late final GeneratedColumn<String> interestedBatchName =
      GeneratedColumn<String>(
        'interested_batch_name',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _currentClassMeta = const VerificationMeta(
    'currentClass',
  );
  @override
  late final GeneratedColumn<String> currentClass = GeneratedColumn<String>(
    'current_class',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _schoolNameMeta = const VerificationMeta(
    'schoolName',
  );
  @override
  late final GeneratedColumn<String> schoolName = GeneratedColumn<String>(
    'school_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _enquiryStatusMeta = const VerificationMeta(
    'enquiryStatus',
  );
  @override
  late final GeneratedColumn<String> enquiryStatus = GeneratedColumn<String>(
    'enquiry_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('new'),
  );
  static const VerificationMeta _followUpDateMeta = const VerificationMeta(
    'followUpDate',
  );
  @override
  late final GeneratedColumn<DateTime> followUpDate = GeneratedColumn<DateTime>(
    'follow_up_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _messageMeta = const VerificationMeta(
    'message',
  );
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
    'message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _followUpNotesMeta = const VerificationMeta(
    'followUpNotes',
  );
  @override
  late final GeneratedColumn<String> followUpNotes = GeneratedColumn<String>(
    'follow_up_notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _assignedToMeta = const VerificationMeta(
    'assignedTo',
  );
  @override
  late final GeneratedColumn<String> assignedTo = GeneratedColumn<String>(
    'assigned_to',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _assignedToNameMeta = const VerificationMeta(
    'assignedToName',
  );
  @override
  late final GeneratedColumn<String> assignedToName = GeneratedColumn<String>(
    'assigned_to_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<LocalSyncStatus, String>
  syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<LocalSyncStatus>($LocalEnquiriesTable.$convertersyncStatus);
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    localId,
    cloudId,
    legacyId,
    studentName,
    parentName,
    phone,
    alternatePhone,
    email,
    dob,
    interestedCourseId,
    interestedCourseName,
    interestedBatchId,
    interestedBatchName,
    currentClass,
    schoolName,
    source,
    enquiryStatus,
    followUpDate,
    message,
    followUpNotes,
    notes,
    assignedTo,
    assignedToName,
    createdAt,
    updatedAt,
    deletedAt,
    syncStatus,
    lastSyncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_enquiries';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalEnquiry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    }
    if (data.containsKey('cloud_id')) {
      context.handle(
        _cloudIdMeta,
        cloudId.isAcceptableOrUnknown(data['cloud_id']!, _cloudIdMeta),
      );
    }
    if (data.containsKey('legacy_id')) {
      context.handle(
        _legacyIdMeta,
        legacyId.isAcceptableOrUnknown(data['legacy_id']!, _legacyIdMeta),
      );
    }
    if (data.containsKey('student_name')) {
      context.handle(
        _studentNameMeta,
        studentName.isAcceptableOrUnknown(
          data['student_name']!,
          _studentNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_studentNameMeta);
    }
    if (data.containsKey('parent_name')) {
      context.handle(
        _parentNameMeta,
        parentName.isAcceptableOrUnknown(data['parent_name']!, _parentNameMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('alternate_phone')) {
      context.handle(
        _alternatePhoneMeta,
        alternatePhone.isAcceptableOrUnknown(
          data['alternate_phone']!,
          _alternatePhoneMeta,
        ),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('dob')) {
      context.handle(
        _dobMeta,
        dob.isAcceptableOrUnknown(data['dob']!, _dobMeta),
      );
    }
    if (data.containsKey('interested_course_id')) {
      context.handle(
        _interestedCourseIdMeta,
        interestedCourseId.isAcceptableOrUnknown(
          data['interested_course_id']!,
          _interestedCourseIdMeta,
        ),
      );
    }
    if (data.containsKey('interested_course_name')) {
      context.handle(
        _interestedCourseNameMeta,
        interestedCourseName.isAcceptableOrUnknown(
          data['interested_course_name']!,
          _interestedCourseNameMeta,
        ),
      );
    }
    if (data.containsKey('interested_batch_id')) {
      context.handle(
        _interestedBatchIdMeta,
        interestedBatchId.isAcceptableOrUnknown(
          data['interested_batch_id']!,
          _interestedBatchIdMeta,
        ),
      );
    }
    if (data.containsKey('interested_batch_name')) {
      context.handle(
        _interestedBatchNameMeta,
        interestedBatchName.isAcceptableOrUnknown(
          data['interested_batch_name']!,
          _interestedBatchNameMeta,
        ),
      );
    }
    if (data.containsKey('current_class')) {
      context.handle(
        _currentClassMeta,
        currentClass.isAcceptableOrUnknown(
          data['current_class']!,
          _currentClassMeta,
        ),
      );
    }
    if (data.containsKey('school_name')) {
      context.handle(
        _schoolNameMeta,
        schoolName.isAcceptableOrUnknown(data['school_name']!, _schoolNameMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('enquiry_status')) {
      context.handle(
        _enquiryStatusMeta,
        enquiryStatus.isAcceptableOrUnknown(
          data['enquiry_status']!,
          _enquiryStatusMeta,
        ),
      );
    }
    if (data.containsKey('follow_up_date')) {
      context.handle(
        _followUpDateMeta,
        followUpDate.isAcceptableOrUnknown(
          data['follow_up_date']!,
          _followUpDateMeta,
        ),
      );
    }
    if (data.containsKey('message')) {
      context.handle(
        _messageMeta,
        message.isAcceptableOrUnknown(data['message']!, _messageMeta),
      );
    }
    if (data.containsKey('follow_up_notes')) {
      context.handle(
        _followUpNotesMeta,
        followUpNotes.isAcceptableOrUnknown(
          data['follow_up_notes']!,
          _followUpNotesMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('assigned_to')) {
      context.handle(
        _assignedToMeta,
        assignedTo.isAcceptableOrUnknown(data['assigned_to']!, _assignedToMeta),
      );
    }
    if (data.containsKey('assigned_to_name')) {
      context.handle(
        _assignedToNameMeta,
        assignedToName.isAcceptableOrUnknown(
          data['assigned_to_name']!,
          _assignedToNameMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  LocalEnquiry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalEnquiry(
      localId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_id'],
      )!,
      cloudId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cloud_id'],
      ),
      legacyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}legacy_id'],
      ),
      studentName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_name'],
      )!,
      parentName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_name'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      alternatePhone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alternate_phone'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      dob: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}dob'],
      ),
      interestedCourseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}interested_course_id'],
      ),
      interestedCourseName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}interested_course_name'],
      ),
      interestedBatchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}interested_batch_id'],
      ),
      interestedBatchName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}interested_batch_name'],
      ),
      currentClass: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}current_class'],
      ),
      schoolName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}school_name'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      ),
      enquiryStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}enquiry_status'],
      )!,
      followUpDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}follow_up_date'],
      ),
      message: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message'],
      ),
      followUpNotes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}follow_up_notes'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      assignedTo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assigned_to'],
      ),
      assignedToName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assigned_to_name'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      syncStatus: $LocalEnquiriesTable.$convertersyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}sync_status'],
        )!,
      ),
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
    );
  }

  @override
  $LocalEnquiriesTable createAlias(String alias) {
    return $LocalEnquiriesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<LocalSyncStatus, String, String>
  $convertersyncStatus = const EnumNameConverter<LocalSyncStatus>(
    LocalSyncStatus.values,
  );
}

class LocalEnquiry extends DataClass implements Insertable<LocalEnquiry> {
  final int localId;
  final String? cloudId;
  final String? legacyId;
  final String studentName;
  final String? parentName;
  final String? phone;
  final String? alternatePhone;
  final String? email;
  final DateTime? dob;
  final String? interestedCourseId;
  final String? interestedCourseName;
  final String? interestedBatchId;
  final String? interestedBatchName;
  final String? currentClass;
  final String? schoolName;
  final String? source;
  final String enquiryStatus;
  final DateTime? followUpDate;
  final String? message;
  final String? followUpNotes;
  final String? notes;
  final String? assignedTo;
  final String? assignedToName;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final LocalSyncStatus syncStatus;
  final DateTime? lastSyncedAt;
  const LocalEnquiry({
    required this.localId,
    this.cloudId,
    this.legacyId,
    required this.studentName,
    this.parentName,
    this.phone,
    this.alternatePhone,
    this.email,
    this.dob,
    this.interestedCourseId,
    this.interestedCourseName,
    this.interestedBatchId,
    this.interestedBatchName,
    this.currentClass,
    this.schoolName,
    this.source,
    required this.enquiryStatus,
    this.followUpDate,
    this.message,
    this.followUpNotes,
    this.notes,
    this.assignedTo,
    this.assignedToName,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    required this.syncStatus,
    this.lastSyncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<int>(localId);
    if (!nullToAbsent || cloudId != null) {
      map['cloud_id'] = Variable<String>(cloudId);
    }
    if (!nullToAbsent || legacyId != null) {
      map['legacy_id'] = Variable<String>(legacyId);
    }
    map['student_name'] = Variable<String>(studentName);
    if (!nullToAbsent || parentName != null) {
      map['parent_name'] = Variable<String>(parentName);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || alternatePhone != null) {
      map['alternate_phone'] = Variable<String>(alternatePhone);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || dob != null) {
      map['dob'] = Variable<DateTime>(dob);
    }
    if (!nullToAbsent || interestedCourseId != null) {
      map['interested_course_id'] = Variable<String>(interestedCourseId);
    }
    if (!nullToAbsent || interestedCourseName != null) {
      map['interested_course_name'] = Variable<String>(interestedCourseName);
    }
    if (!nullToAbsent || interestedBatchId != null) {
      map['interested_batch_id'] = Variable<String>(interestedBatchId);
    }
    if (!nullToAbsent || interestedBatchName != null) {
      map['interested_batch_name'] = Variable<String>(interestedBatchName);
    }
    if (!nullToAbsent || currentClass != null) {
      map['current_class'] = Variable<String>(currentClass);
    }
    if (!nullToAbsent || schoolName != null) {
      map['school_name'] = Variable<String>(schoolName);
    }
    if (!nullToAbsent || source != null) {
      map['source'] = Variable<String>(source);
    }
    map['enquiry_status'] = Variable<String>(enquiryStatus);
    if (!nullToAbsent || followUpDate != null) {
      map['follow_up_date'] = Variable<DateTime>(followUpDate);
    }
    if (!nullToAbsent || message != null) {
      map['message'] = Variable<String>(message);
    }
    if (!nullToAbsent || followUpNotes != null) {
      map['follow_up_notes'] = Variable<String>(followUpNotes);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || assignedTo != null) {
      map['assigned_to'] = Variable<String>(assignedTo);
    }
    if (!nullToAbsent || assignedToName != null) {
      map['assigned_to_name'] = Variable<String>(assignedToName);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    {
      map['sync_status'] = Variable<String>(
        $LocalEnquiriesTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  LocalEnquiriesCompanion toCompanion(bool nullToAbsent) {
    return LocalEnquiriesCompanion(
      localId: Value(localId),
      cloudId: cloudId == null && nullToAbsent
          ? const Value.absent()
          : Value(cloudId),
      legacyId: legacyId == null && nullToAbsent
          ? const Value.absent()
          : Value(legacyId),
      studentName: Value(studentName),
      parentName: parentName == null && nullToAbsent
          ? const Value.absent()
          : Value(parentName),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      alternatePhone: alternatePhone == null && nullToAbsent
          ? const Value.absent()
          : Value(alternatePhone),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      dob: dob == null && nullToAbsent ? const Value.absent() : Value(dob),
      interestedCourseId: interestedCourseId == null && nullToAbsent
          ? const Value.absent()
          : Value(interestedCourseId),
      interestedCourseName: interestedCourseName == null && nullToAbsent
          ? const Value.absent()
          : Value(interestedCourseName),
      interestedBatchId: interestedBatchId == null && nullToAbsent
          ? const Value.absent()
          : Value(interestedBatchId),
      interestedBatchName: interestedBatchName == null && nullToAbsent
          ? const Value.absent()
          : Value(interestedBatchName),
      currentClass: currentClass == null && nullToAbsent
          ? const Value.absent()
          : Value(currentClass),
      schoolName: schoolName == null && nullToAbsent
          ? const Value.absent()
          : Value(schoolName),
      source: source == null && nullToAbsent
          ? const Value.absent()
          : Value(source),
      enquiryStatus: Value(enquiryStatus),
      followUpDate: followUpDate == null && nullToAbsent
          ? const Value.absent()
          : Value(followUpDate),
      message: message == null && nullToAbsent
          ? const Value.absent()
          : Value(message),
      followUpNotes: followUpNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(followUpNotes),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      assignedTo: assignedTo == null && nullToAbsent
          ? const Value.absent()
          : Value(assignedTo),
      assignedToName: assignedToName == null && nullToAbsent
          ? const Value.absent()
          : Value(assignedToName),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncStatus: Value(syncStatus),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory LocalEnquiry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalEnquiry(
      localId: serializer.fromJson<int>(json['localId']),
      cloudId: serializer.fromJson<String?>(json['cloudId']),
      legacyId: serializer.fromJson<String?>(json['legacyId']),
      studentName: serializer.fromJson<String>(json['studentName']),
      parentName: serializer.fromJson<String?>(json['parentName']),
      phone: serializer.fromJson<String?>(json['phone']),
      alternatePhone: serializer.fromJson<String?>(json['alternatePhone']),
      email: serializer.fromJson<String?>(json['email']),
      dob: serializer.fromJson<DateTime?>(json['dob']),
      interestedCourseId: serializer.fromJson<String?>(
        json['interestedCourseId'],
      ),
      interestedCourseName: serializer.fromJson<String?>(
        json['interestedCourseName'],
      ),
      interestedBatchId: serializer.fromJson<String?>(
        json['interestedBatchId'],
      ),
      interestedBatchName: serializer.fromJson<String?>(
        json['interestedBatchName'],
      ),
      currentClass: serializer.fromJson<String?>(json['currentClass']),
      schoolName: serializer.fromJson<String?>(json['schoolName']),
      source: serializer.fromJson<String?>(json['source']),
      enquiryStatus: serializer.fromJson<String>(json['enquiryStatus']),
      followUpDate: serializer.fromJson<DateTime?>(json['followUpDate']),
      message: serializer.fromJson<String?>(json['message']),
      followUpNotes: serializer.fromJson<String?>(json['followUpNotes']),
      notes: serializer.fromJson<String?>(json['notes']),
      assignedTo: serializer.fromJson<String?>(json['assignedTo']),
      assignedToName: serializer.fromJson<String?>(json['assignedToName']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncStatus: $LocalEnquiriesTable.$convertersyncStatus.fromJson(
        serializer.fromJson<String>(json['syncStatus']),
      ),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<int>(localId),
      'cloudId': serializer.toJson<String?>(cloudId),
      'legacyId': serializer.toJson<String?>(legacyId),
      'studentName': serializer.toJson<String>(studentName),
      'parentName': serializer.toJson<String?>(parentName),
      'phone': serializer.toJson<String?>(phone),
      'alternatePhone': serializer.toJson<String?>(alternatePhone),
      'email': serializer.toJson<String?>(email),
      'dob': serializer.toJson<DateTime?>(dob),
      'interestedCourseId': serializer.toJson<String?>(interestedCourseId),
      'interestedCourseName': serializer.toJson<String?>(interestedCourseName),
      'interestedBatchId': serializer.toJson<String?>(interestedBatchId),
      'interestedBatchName': serializer.toJson<String?>(interestedBatchName),
      'currentClass': serializer.toJson<String?>(currentClass),
      'schoolName': serializer.toJson<String?>(schoolName),
      'source': serializer.toJson<String?>(source),
      'enquiryStatus': serializer.toJson<String>(enquiryStatus),
      'followUpDate': serializer.toJson<DateTime?>(followUpDate),
      'message': serializer.toJson<String?>(message),
      'followUpNotes': serializer.toJson<String?>(followUpNotes),
      'notes': serializer.toJson<String?>(notes),
      'assignedTo': serializer.toJson<String?>(assignedTo),
      'assignedToName': serializer.toJson<String?>(assignedToName),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncStatus': serializer.toJson<String>(
        $LocalEnquiriesTable.$convertersyncStatus.toJson(syncStatus),
      ),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  LocalEnquiry copyWith({
    int? localId,
    Value<String?> cloudId = const Value.absent(),
    Value<String?> legacyId = const Value.absent(),
    String? studentName,
    Value<String?> parentName = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    Value<String?> alternatePhone = const Value.absent(),
    Value<String?> email = const Value.absent(),
    Value<DateTime?> dob = const Value.absent(),
    Value<String?> interestedCourseId = const Value.absent(),
    Value<String?> interestedCourseName = const Value.absent(),
    Value<String?> interestedBatchId = const Value.absent(),
    Value<String?> interestedBatchName = const Value.absent(),
    Value<String?> currentClass = const Value.absent(),
    Value<String?> schoolName = const Value.absent(),
    Value<String?> source = const Value.absent(),
    String? enquiryStatus,
    Value<DateTime?> followUpDate = const Value.absent(),
    Value<String?> message = const Value.absent(),
    Value<String?> followUpNotes = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<String?> assignedTo = const Value.absent(),
    Value<String?> assignedToName = const Value.absent(),
    Value<DateTime?> createdAt = const Value.absent(),
    Value<DateTime?> updatedAt = const Value.absent(),
    Value<DateTime?> deletedAt = const Value.absent(),
    LocalSyncStatus? syncStatus,
    Value<DateTime?> lastSyncedAt = const Value.absent(),
  }) => LocalEnquiry(
    localId: localId ?? this.localId,
    cloudId: cloudId.present ? cloudId.value : this.cloudId,
    legacyId: legacyId.present ? legacyId.value : this.legacyId,
    studentName: studentName ?? this.studentName,
    parentName: parentName.present ? parentName.value : this.parentName,
    phone: phone.present ? phone.value : this.phone,
    alternatePhone: alternatePhone.present
        ? alternatePhone.value
        : this.alternatePhone,
    email: email.present ? email.value : this.email,
    dob: dob.present ? dob.value : this.dob,
    interestedCourseId: interestedCourseId.present
        ? interestedCourseId.value
        : this.interestedCourseId,
    interestedCourseName: interestedCourseName.present
        ? interestedCourseName.value
        : this.interestedCourseName,
    interestedBatchId: interestedBatchId.present
        ? interestedBatchId.value
        : this.interestedBatchId,
    interestedBatchName: interestedBatchName.present
        ? interestedBatchName.value
        : this.interestedBatchName,
    currentClass: currentClass.present ? currentClass.value : this.currentClass,
    schoolName: schoolName.present ? schoolName.value : this.schoolName,
    source: source.present ? source.value : this.source,
    enquiryStatus: enquiryStatus ?? this.enquiryStatus,
    followUpDate: followUpDate.present ? followUpDate.value : this.followUpDate,
    message: message.present ? message.value : this.message,
    followUpNotes: followUpNotes.present
        ? followUpNotes.value
        : this.followUpNotes,
    notes: notes.present ? notes.value : this.notes,
    assignedTo: assignedTo.present ? assignedTo.value : this.assignedTo,
    assignedToName: assignedToName.present
        ? assignedToName.value
        : this.assignedToName,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncStatus: syncStatus ?? this.syncStatus,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
  );
  LocalEnquiry copyWithCompanion(LocalEnquiriesCompanion data) {
    return LocalEnquiry(
      localId: data.localId.present ? data.localId.value : this.localId,
      cloudId: data.cloudId.present ? data.cloudId.value : this.cloudId,
      legacyId: data.legacyId.present ? data.legacyId.value : this.legacyId,
      studentName: data.studentName.present
          ? data.studentName.value
          : this.studentName,
      parentName: data.parentName.present
          ? data.parentName.value
          : this.parentName,
      phone: data.phone.present ? data.phone.value : this.phone,
      alternatePhone: data.alternatePhone.present
          ? data.alternatePhone.value
          : this.alternatePhone,
      email: data.email.present ? data.email.value : this.email,
      dob: data.dob.present ? data.dob.value : this.dob,
      interestedCourseId: data.interestedCourseId.present
          ? data.interestedCourseId.value
          : this.interestedCourseId,
      interestedCourseName: data.interestedCourseName.present
          ? data.interestedCourseName.value
          : this.interestedCourseName,
      interestedBatchId: data.interestedBatchId.present
          ? data.interestedBatchId.value
          : this.interestedBatchId,
      interestedBatchName: data.interestedBatchName.present
          ? data.interestedBatchName.value
          : this.interestedBatchName,
      currentClass: data.currentClass.present
          ? data.currentClass.value
          : this.currentClass,
      schoolName: data.schoolName.present
          ? data.schoolName.value
          : this.schoolName,
      source: data.source.present ? data.source.value : this.source,
      enquiryStatus: data.enquiryStatus.present
          ? data.enquiryStatus.value
          : this.enquiryStatus,
      followUpDate: data.followUpDate.present
          ? data.followUpDate.value
          : this.followUpDate,
      message: data.message.present ? data.message.value : this.message,
      followUpNotes: data.followUpNotes.present
          ? data.followUpNotes.value
          : this.followUpNotes,
      notes: data.notes.present ? data.notes.value : this.notes,
      assignedTo: data.assignedTo.present
          ? data.assignedTo.value
          : this.assignedTo,
      assignedToName: data.assignedToName.present
          ? data.assignedToName.value
          : this.assignedToName,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalEnquiry(')
          ..write('localId: $localId, ')
          ..write('cloudId: $cloudId, ')
          ..write('legacyId: $legacyId, ')
          ..write('studentName: $studentName, ')
          ..write('parentName: $parentName, ')
          ..write('phone: $phone, ')
          ..write('alternatePhone: $alternatePhone, ')
          ..write('email: $email, ')
          ..write('dob: $dob, ')
          ..write('interestedCourseId: $interestedCourseId, ')
          ..write('interestedCourseName: $interestedCourseName, ')
          ..write('interestedBatchId: $interestedBatchId, ')
          ..write('interestedBatchName: $interestedBatchName, ')
          ..write('currentClass: $currentClass, ')
          ..write('schoolName: $schoolName, ')
          ..write('source: $source, ')
          ..write('enquiryStatus: $enquiryStatus, ')
          ..write('followUpDate: $followUpDate, ')
          ..write('message: $message, ')
          ..write('followUpNotes: $followUpNotes, ')
          ..write('notes: $notes, ')
          ..write('assignedTo: $assignedTo, ')
          ..write('assignedToName: $assignedToName, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    localId,
    cloudId,
    legacyId,
    studentName,
    parentName,
    phone,
    alternatePhone,
    email,
    dob,
    interestedCourseId,
    interestedCourseName,
    interestedBatchId,
    interestedBatchName,
    currentClass,
    schoolName,
    source,
    enquiryStatus,
    followUpDate,
    message,
    followUpNotes,
    notes,
    assignedTo,
    assignedToName,
    createdAt,
    updatedAt,
    deletedAt,
    syncStatus,
    lastSyncedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalEnquiry &&
          other.localId == this.localId &&
          other.cloudId == this.cloudId &&
          other.legacyId == this.legacyId &&
          other.studentName == this.studentName &&
          other.parentName == this.parentName &&
          other.phone == this.phone &&
          other.alternatePhone == this.alternatePhone &&
          other.email == this.email &&
          other.dob == this.dob &&
          other.interestedCourseId == this.interestedCourseId &&
          other.interestedCourseName == this.interestedCourseName &&
          other.interestedBatchId == this.interestedBatchId &&
          other.interestedBatchName == this.interestedBatchName &&
          other.currentClass == this.currentClass &&
          other.schoolName == this.schoolName &&
          other.source == this.source &&
          other.enquiryStatus == this.enquiryStatus &&
          other.followUpDate == this.followUpDate &&
          other.message == this.message &&
          other.followUpNotes == this.followUpNotes &&
          other.notes == this.notes &&
          other.assignedTo == this.assignedTo &&
          other.assignedToName == this.assignedToName &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncStatus == this.syncStatus &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class LocalEnquiriesCompanion extends UpdateCompanion<LocalEnquiry> {
  final Value<int> localId;
  final Value<String?> cloudId;
  final Value<String?> legacyId;
  final Value<String> studentName;
  final Value<String?> parentName;
  final Value<String?> phone;
  final Value<String?> alternatePhone;
  final Value<String?> email;
  final Value<DateTime?> dob;
  final Value<String?> interestedCourseId;
  final Value<String?> interestedCourseName;
  final Value<String?> interestedBatchId;
  final Value<String?> interestedBatchName;
  final Value<String?> currentClass;
  final Value<String?> schoolName;
  final Value<String?> source;
  final Value<String> enquiryStatus;
  final Value<DateTime?> followUpDate;
  final Value<String?> message;
  final Value<String?> followUpNotes;
  final Value<String?> notes;
  final Value<String?> assignedTo;
  final Value<String?> assignedToName;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<LocalSyncStatus> syncStatus;
  final Value<DateTime?> lastSyncedAt;
  const LocalEnquiriesCompanion({
    this.localId = const Value.absent(),
    this.cloudId = const Value.absent(),
    this.legacyId = const Value.absent(),
    this.studentName = const Value.absent(),
    this.parentName = const Value.absent(),
    this.phone = const Value.absent(),
    this.alternatePhone = const Value.absent(),
    this.email = const Value.absent(),
    this.dob = const Value.absent(),
    this.interestedCourseId = const Value.absent(),
    this.interestedCourseName = const Value.absent(),
    this.interestedBatchId = const Value.absent(),
    this.interestedBatchName = const Value.absent(),
    this.currentClass = const Value.absent(),
    this.schoolName = const Value.absent(),
    this.source = const Value.absent(),
    this.enquiryStatus = const Value.absent(),
    this.followUpDate = const Value.absent(),
    this.message = const Value.absent(),
    this.followUpNotes = const Value.absent(),
    this.notes = const Value.absent(),
    this.assignedTo = const Value.absent(),
    this.assignedToName = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
  });
  LocalEnquiriesCompanion.insert({
    this.localId = const Value.absent(),
    this.cloudId = const Value.absent(),
    this.legacyId = const Value.absent(),
    required String studentName,
    this.parentName = const Value.absent(),
    this.phone = const Value.absent(),
    this.alternatePhone = const Value.absent(),
    this.email = const Value.absent(),
    this.dob = const Value.absent(),
    this.interestedCourseId = const Value.absent(),
    this.interestedCourseName = const Value.absent(),
    this.interestedBatchId = const Value.absent(),
    this.interestedBatchName = const Value.absent(),
    this.currentClass = const Value.absent(),
    this.schoolName = const Value.absent(),
    this.source = const Value.absent(),
    this.enquiryStatus = const Value.absent(),
    this.followUpDate = const Value.absent(),
    this.message = const Value.absent(),
    this.followUpNotes = const Value.absent(),
    this.notes = const Value.absent(),
    this.assignedTo = const Value.absent(),
    this.assignedToName = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required LocalSyncStatus syncStatus,
    this.lastSyncedAt = const Value.absent(),
  }) : studentName = Value(studentName),
       syncStatus = Value(syncStatus);
  static Insertable<LocalEnquiry> custom({
    Expression<int>? localId,
    Expression<String>? cloudId,
    Expression<String>? legacyId,
    Expression<String>? studentName,
    Expression<String>? parentName,
    Expression<String>? phone,
    Expression<String>? alternatePhone,
    Expression<String>? email,
    Expression<DateTime>? dob,
    Expression<String>? interestedCourseId,
    Expression<String>? interestedCourseName,
    Expression<String>? interestedBatchId,
    Expression<String>? interestedBatchName,
    Expression<String>? currentClass,
    Expression<String>? schoolName,
    Expression<String>? source,
    Expression<String>? enquiryStatus,
    Expression<DateTime>? followUpDate,
    Expression<String>? message,
    Expression<String>? followUpNotes,
    Expression<String>? notes,
    Expression<String>? assignedTo,
    Expression<String>? assignedToName,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? syncStatus,
    Expression<DateTime>? lastSyncedAt,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (cloudId != null) 'cloud_id': cloudId,
      if (legacyId != null) 'legacy_id': legacyId,
      if (studentName != null) 'student_name': studentName,
      if (parentName != null) 'parent_name': parentName,
      if (phone != null) 'phone': phone,
      if (alternatePhone != null) 'alternate_phone': alternatePhone,
      if (email != null) 'email': email,
      if (dob != null) 'dob': dob,
      if (interestedCourseId != null)
        'interested_course_id': interestedCourseId,
      if (interestedCourseName != null)
        'interested_course_name': interestedCourseName,
      if (interestedBatchId != null) 'interested_batch_id': interestedBatchId,
      if (interestedBatchName != null)
        'interested_batch_name': interestedBatchName,
      if (currentClass != null) 'current_class': currentClass,
      if (schoolName != null) 'school_name': schoolName,
      if (source != null) 'source': source,
      if (enquiryStatus != null) 'enquiry_status': enquiryStatus,
      if (followUpDate != null) 'follow_up_date': followUpDate,
      if (message != null) 'message': message,
      if (followUpNotes != null) 'follow_up_notes': followUpNotes,
      if (notes != null) 'notes': notes,
      if (assignedTo != null) 'assigned_to': assignedTo,
      if (assignedToName != null) 'assigned_to_name': assignedToName,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
    });
  }

  LocalEnquiriesCompanion copyWith({
    Value<int>? localId,
    Value<String?>? cloudId,
    Value<String?>? legacyId,
    Value<String>? studentName,
    Value<String?>? parentName,
    Value<String?>? phone,
    Value<String?>? alternatePhone,
    Value<String?>? email,
    Value<DateTime?>? dob,
    Value<String?>? interestedCourseId,
    Value<String?>? interestedCourseName,
    Value<String?>? interestedBatchId,
    Value<String?>? interestedBatchName,
    Value<String?>? currentClass,
    Value<String?>? schoolName,
    Value<String?>? source,
    Value<String>? enquiryStatus,
    Value<DateTime?>? followUpDate,
    Value<String?>? message,
    Value<String?>? followUpNotes,
    Value<String?>? notes,
    Value<String?>? assignedTo,
    Value<String?>? assignedToName,
    Value<DateTime?>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<LocalSyncStatus>? syncStatus,
    Value<DateTime?>? lastSyncedAt,
  }) {
    return LocalEnquiriesCompanion(
      localId: localId ?? this.localId,
      cloudId: cloudId ?? this.cloudId,
      legacyId: legacyId ?? this.legacyId,
      studentName: studentName ?? this.studentName,
      parentName: parentName ?? this.parentName,
      phone: phone ?? this.phone,
      alternatePhone: alternatePhone ?? this.alternatePhone,
      email: email ?? this.email,
      dob: dob ?? this.dob,
      interestedCourseId: interestedCourseId ?? this.interestedCourseId,
      interestedCourseName: interestedCourseName ?? this.interestedCourseName,
      interestedBatchId: interestedBatchId ?? this.interestedBatchId,
      interestedBatchName: interestedBatchName ?? this.interestedBatchName,
      currentClass: currentClass ?? this.currentClass,
      schoolName: schoolName ?? this.schoolName,
      source: source ?? this.source,
      enquiryStatus: enquiryStatus ?? this.enquiryStatus,
      followUpDate: followUpDate ?? this.followUpDate,
      message: message ?? this.message,
      followUpNotes: followUpNotes ?? this.followUpNotes,
      notes: notes ?? this.notes,
      assignedTo: assignedTo ?? this.assignedTo,
      assignedToName: assignedToName ?? this.assignedToName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<int>(localId.value);
    }
    if (cloudId.present) {
      map['cloud_id'] = Variable<String>(cloudId.value);
    }
    if (legacyId.present) {
      map['legacy_id'] = Variable<String>(legacyId.value);
    }
    if (studentName.present) {
      map['student_name'] = Variable<String>(studentName.value);
    }
    if (parentName.present) {
      map['parent_name'] = Variable<String>(parentName.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (alternatePhone.present) {
      map['alternate_phone'] = Variable<String>(alternatePhone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (dob.present) {
      map['dob'] = Variable<DateTime>(dob.value);
    }
    if (interestedCourseId.present) {
      map['interested_course_id'] = Variable<String>(interestedCourseId.value);
    }
    if (interestedCourseName.present) {
      map['interested_course_name'] = Variable<String>(
        interestedCourseName.value,
      );
    }
    if (interestedBatchId.present) {
      map['interested_batch_id'] = Variable<String>(interestedBatchId.value);
    }
    if (interestedBatchName.present) {
      map['interested_batch_name'] = Variable<String>(
        interestedBatchName.value,
      );
    }
    if (currentClass.present) {
      map['current_class'] = Variable<String>(currentClass.value);
    }
    if (schoolName.present) {
      map['school_name'] = Variable<String>(schoolName.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (enquiryStatus.present) {
      map['enquiry_status'] = Variable<String>(enquiryStatus.value);
    }
    if (followUpDate.present) {
      map['follow_up_date'] = Variable<DateTime>(followUpDate.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (followUpNotes.present) {
      map['follow_up_notes'] = Variable<String>(followUpNotes.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (assignedTo.present) {
      map['assigned_to'] = Variable<String>(assignedTo.value);
    }
    if (assignedToName.present) {
      map['assigned_to_name'] = Variable<String>(assignedToName.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(
        $LocalEnquiriesTable.$convertersyncStatus.toSql(syncStatus.value),
      );
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalEnquiriesCompanion(')
          ..write('localId: $localId, ')
          ..write('cloudId: $cloudId, ')
          ..write('legacyId: $legacyId, ')
          ..write('studentName: $studentName, ')
          ..write('parentName: $parentName, ')
          ..write('phone: $phone, ')
          ..write('alternatePhone: $alternatePhone, ')
          ..write('email: $email, ')
          ..write('dob: $dob, ')
          ..write('interestedCourseId: $interestedCourseId, ')
          ..write('interestedCourseName: $interestedCourseName, ')
          ..write('interestedBatchId: $interestedBatchId, ')
          ..write('interestedBatchName: $interestedBatchName, ')
          ..write('currentClass: $currentClass, ')
          ..write('schoolName: $schoolName, ')
          ..write('source: $source, ')
          ..write('enquiryStatus: $enquiryStatus, ')
          ..write('followUpDate: $followUpDate, ')
          ..write('message: $message, ')
          ..write('followUpNotes: $followUpNotes, ')
          ..write('notes: $notes, ')
          ..write('assignedTo: $assignedTo, ')
          ..write('assignedToName: $assignedToName, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }
}

class $LocalAttendancesTable extends LocalAttendances
    with TableInfo<$LocalAttendancesTable, LocalAttendance> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalAttendancesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<int> localId = GeneratedColumn<int>(
    'local_id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _cloudIdMeta = const VerificationMeta(
    'cloudId',
  );
  @override
  late final GeneratedColumn<String> cloudId = GeneratedColumn<String>(
    'cloud_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _attendanceKeyMeta = const VerificationMeta(
    'attendanceKey',
  );
  @override
  late final GeneratedColumn<String> attendanceKey = GeneratedColumn<String>(
    'attendance_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  @override
  late final GeneratedColumn<String> studentId = GeneratedColumn<String>(
    'student_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _studentNameMeta = const VerificationMeta(
    'studentName',
  );
  @override
  late final GeneratedColumn<String> studentName = GeneratedColumn<String>(
    'student_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateKeyMeta = const VerificationMeta(
    'dateKey',
  );
  @override
  late final GeneratedColumn<String> dateKey = GeneratedColumn<String>(
    'date_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attendanceDateMeta = const VerificationMeta(
    'attendanceDate',
  );
  @override
  late final GeneratedColumn<DateTime> attendanceDate =
      GeneratedColumn<DateTime>(
        'attendance_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _batchIdMeta = const VerificationMeta(
    'batchId',
  );
  @override
  late final GeneratedColumn<String> batchId = GeneratedColumn<String>(
    'batch_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _batchNameMeta = const VerificationMeta(
    'batchName',
  );
  @override
  late final GeneratedColumn<String> batchName = GeneratedColumn<String>(
    'batch_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _courseIdMeta = const VerificationMeta(
    'courseId',
  );
  @override
  late final GeneratedColumn<String> courseId = GeneratedColumn<String>(
    'course_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _courseNameMeta = const VerificationMeta(
    'courseName',
  );
  @override
  late final GeneratedColumn<String> courseName = GeneratedColumn<String>(
    'course_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _markedByMeta = const VerificationMeta(
    'markedBy',
  );
  @override
  late final GeneratedColumn<String> markedBy = GeneratedColumn<String>(
    'marked_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _markedByNameMeta = const VerificationMeta(
    'markedByName',
  );
  @override
  late final GeneratedColumn<String> markedByName = GeneratedColumn<String>(
    'marked_by_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<LocalSyncStatus, String>
  syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<LocalSyncStatus>($LocalAttendancesTable.$convertersyncStatus);
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    localId,
    cloudId,
    attendanceKey,
    studentId,
    studentName,
    dateKey,
    attendanceDate,
    batchId,
    batchName,
    courseId,
    courseName,
    status,
    markedBy,
    markedByName,
    createdAt,
    updatedAt,
    deletedAt,
    syncStatus,
    lastSyncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_attendances';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalAttendance> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    }
    if (data.containsKey('cloud_id')) {
      context.handle(
        _cloudIdMeta,
        cloudId.isAcceptableOrUnknown(data['cloud_id']!, _cloudIdMeta),
      );
    }
    if (data.containsKey('attendance_key')) {
      context.handle(
        _attendanceKeyMeta,
        attendanceKey.isAcceptableOrUnknown(
          data['attendance_key']!,
          _attendanceKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_attendanceKeyMeta);
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('student_name')) {
      context.handle(
        _studentNameMeta,
        studentName.isAcceptableOrUnknown(
          data['student_name']!,
          _studentNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_studentNameMeta);
    }
    if (data.containsKey('date_key')) {
      context.handle(
        _dateKeyMeta,
        dateKey.isAcceptableOrUnknown(data['date_key']!, _dateKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_dateKeyMeta);
    }
    if (data.containsKey('attendance_date')) {
      context.handle(
        _attendanceDateMeta,
        attendanceDate.isAcceptableOrUnknown(
          data['attendance_date']!,
          _attendanceDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_attendanceDateMeta);
    }
    if (data.containsKey('batch_id')) {
      context.handle(
        _batchIdMeta,
        batchId.isAcceptableOrUnknown(data['batch_id']!, _batchIdMeta),
      );
    }
    if (data.containsKey('batch_name')) {
      context.handle(
        _batchNameMeta,
        batchName.isAcceptableOrUnknown(data['batch_name']!, _batchNameMeta),
      );
    }
    if (data.containsKey('course_id')) {
      context.handle(
        _courseIdMeta,
        courseId.isAcceptableOrUnknown(data['course_id']!, _courseIdMeta),
      );
    }
    if (data.containsKey('course_name')) {
      context.handle(
        _courseNameMeta,
        courseName.isAcceptableOrUnknown(data['course_name']!, _courseNameMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('marked_by')) {
      context.handle(
        _markedByMeta,
        markedBy.isAcceptableOrUnknown(data['marked_by']!, _markedByMeta),
      );
    }
    if (data.containsKey('marked_by_name')) {
      context.handle(
        _markedByNameMeta,
        markedByName.isAcceptableOrUnknown(
          data['marked_by_name']!,
          _markedByNameMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  LocalAttendance map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalAttendance(
      localId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_id'],
      )!,
      cloudId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cloud_id'],
      ),
      attendanceKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}attendance_key'],
      )!,
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_id'],
      )!,
      studentName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_name'],
      )!,
      dateKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date_key'],
      )!,
      attendanceDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}attendance_date'],
      )!,
      batchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}batch_id'],
      ),
      batchName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}batch_name'],
      ),
      courseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}course_id'],
      ),
      courseName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}course_name'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      markedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}marked_by'],
      ),
      markedByName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}marked_by_name'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      syncStatus: $LocalAttendancesTable.$convertersyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}sync_status'],
        )!,
      ),
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
    );
  }

  @override
  $LocalAttendancesTable createAlias(String alias) {
    return $LocalAttendancesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<LocalSyncStatus, String, String>
  $convertersyncStatus = const EnumNameConverter<LocalSyncStatus>(
    LocalSyncStatus.values,
  );
}

class LocalAttendance extends DataClass implements Insertable<LocalAttendance> {
  final int localId;
  final String? cloudId;
  final String attendanceKey;
  final String studentId;
  final String studentName;
  final String dateKey;
  final DateTime attendanceDate;
  final String? batchId;
  final String? batchName;
  final String? courseId;
  final String? courseName;
  final String status;
  final String? markedBy;
  final String? markedByName;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final LocalSyncStatus syncStatus;
  final DateTime? lastSyncedAt;
  const LocalAttendance({
    required this.localId,
    this.cloudId,
    required this.attendanceKey,
    required this.studentId,
    required this.studentName,
    required this.dateKey,
    required this.attendanceDate,
    this.batchId,
    this.batchName,
    this.courseId,
    this.courseName,
    required this.status,
    this.markedBy,
    this.markedByName,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    required this.syncStatus,
    this.lastSyncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<int>(localId);
    if (!nullToAbsent || cloudId != null) {
      map['cloud_id'] = Variable<String>(cloudId);
    }
    map['attendance_key'] = Variable<String>(attendanceKey);
    map['student_id'] = Variable<String>(studentId);
    map['student_name'] = Variable<String>(studentName);
    map['date_key'] = Variable<String>(dateKey);
    map['attendance_date'] = Variable<DateTime>(attendanceDate);
    if (!nullToAbsent || batchId != null) {
      map['batch_id'] = Variable<String>(batchId);
    }
    if (!nullToAbsent || batchName != null) {
      map['batch_name'] = Variable<String>(batchName);
    }
    if (!nullToAbsent || courseId != null) {
      map['course_id'] = Variable<String>(courseId);
    }
    if (!nullToAbsent || courseName != null) {
      map['course_name'] = Variable<String>(courseName);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || markedBy != null) {
      map['marked_by'] = Variable<String>(markedBy);
    }
    if (!nullToAbsent || markedByName != null) {
      map['marked_by_name'] = Variable<String>(markedByName);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    {
      map['sync_status'] = Variable<String>(
        $LocalAttendancesTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  LocalAttendancesCompanion toCompanion(bool nullToAbsent) {
    return LocalAttendancesCompanion(
      localId: Value(localId),
      cloudId: cloudId == null && nullToAbsent
          ? const Value.absent()
          : Value(cloudId),
      attendanceKey: Value(attendanceKey),
      studentId: Value(studentId),
      studentName: Value(studentName),
      dateKey: Value(dateKey),
      attendanceDate: Value(attendanceDate),
      batchId: batchId == null && nullToAbsent
          ? const Value.absent()
          : Value(batchId),
      batchName: batchName == null && nullToAbsent
          ? const Value.absent()
          : Value(batchName),
      courseId: courseId == null && nullToAbsent
          ? const Value.absent()
          : Value(courseId),
      courseName: courseName == null && nullToAbsent
          ? const Value.absent()
          : Value(courseName),
      status: Value(status),
      markedBy: markedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(markedBy),
      markedByName: markedByName == null && nullToAbsent
          ? const Value.absent()
          : Value(markedByName),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncStatus: Value(syncStatus),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory LocalAttendance.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalAttendance(
      localId: serializer.fromJson<int>(json['localId']),
      cloudId: serializer.fromJson<String?>(json['cloudId']),
      attendanceKey: serializer.fromJson<String>(json['attendanceKey']),
      studentId: serializer.fromJson<String>(json['studentId']),
      studentName: serializer.fromJson<String>(json['studentName']),
      dateKey: serializer.fromJson<String>(json['dateKey']),
      attendanceDate: serializer.fromJson<DateTime>(json['attendanceDate']),
      batchId: serializer.fromJson<String?>(json['batchId']),
      batchName: serializer.fromJson<String?>(json['batchName']),
      courseId: serializer.fromJson<String?>(json['courseId']),
      courseName: serializer.fromJson<String?>(json['courseName']),
      status: serializer.fromJson<String>(json['status']),
      markedBy: serializer.fromJson<String?>(json['markedBy']),
      markedByName: serializer.fromJson<String?>(json['markedByName']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncStatus: $LocalAttendancesTable.$convertersyncStatus.fromJson(
        serializer.fromJson<String>(json['syncStatus']),
      ),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<int>(localId),
      'cloudId': serializer.toJson<String?>(cloudId),
      'attendanceKey': serializer.toJson<String>(attendanceKey),
      'studentId': serializer.toJson<String>(studentId),
      'studentName': serializer.toJson<String>(studentName),
      'dateKey': serializer.toJson<String>(dateKey),
      'attendanceDate': serializer.toJson<DateTime>(attendanceDate),
      'batchId': serializer.toJson<String?>(batchId),
      'batchName': serializer.toJson<String?>(batchName),
      'courseId': serializer.toJson<String?>(courseId),
      'courseName': serializer.toJson<String?>(courseName),
      'status': serializer.toJson<String>(status),
      'markedBy': serializer.toJson<String?>(markedBy),
      'markedByName': serializer.toJson<String?>(markedByName),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncStatus': serializer.toJson<String>(
        $LocalAttendancesTable.$convertersyncStatus.toJson(syncStatus),
      ),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  LocalAttendance copyWith({
    int? localId,
    Value<String?> cloudId = const Value.absent(),
    String? attendanceKey,
    String? studentId,
    String? studentName,
    String? dateKey,
    DateTime? attendanceDate,
    Value<String?> batchId = const Value.absent(),
    Value<String?> batchName = const Value.absent(),
    Value<String?> courseId = const Value.absent(),
    Value<String?> courseName = const Value.absent(),
    String? status,
    Value<String?> markedBy = const Value.absent(),
    Value<String?> markedByName = const Value.absent(),
    Value<DateTime?> createdAt = const Value.absent(),
    Value<DateTime?> updatedAt = const Value.absent(),
    Value<DateTime?> deletedAt = const Value.absent(),
    LocalSyncStatus? syncStatus,
    Value<DateTime?> lastSyncedAt = const Value.absent(),
  }) => LocalAttendance(
    localId: localId ?? this.localId,
    cloudId: cloudId.present ? cloudId.value : this.cloudId,
    attendanceKey: attendanceKey ?? this.attendanceKey,
    studentId: studentId ?? this.studentId,
    studentName: studentName ?? this.studentName,
    dateKey: dateKey ?? this.dateKey,
    attendanceDate: attendanceDate ?? this.attendanceDate,
    batchId: batchId.present ? batchId.value : this.batchId,
    batchName: batchName.present ? batchName.value : this.batchName,
    courseId: courseId.present ? courseId.value : this.courseId,
    courseName: courseName.present ? courseName.value : this.courseName,
    status: status ?? this.status,
    markedBy: markedBy.present ? markedBy.value : this.markedBy,
    markedByName: markedByName.present ? markedByName.value : this.markedByName,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncStatus: syncStatus ?? this.syncStatus,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
  );
  LocalAttendance copyWithCompanion(LocalAttendancesCompanion data) {
    return LocalAttendance(
      localId: data.localId.present ? data.localId.value : this.localId,
      cloudId: data.cloudId.present ? data.cloudId.value : this.cloudId,
      attendanceKey: data.attendanceKey.present
          ? data.attendanceKey.value
          : this.attendanceKey,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      studentName: data.studentName.present
          ? data.studentName.value
          : this.studentName,
      dateKey: data.dateKey.present ? data.dateKey.value : this.dateKey,
      attendanceDate: data.attendanceDate.present
          ? data.attendanceDate.value
          : this.attendanceDate,
      batchId: data.batchId.present ? data.batchId.value : this.batchId,
      batchName: data.batchName.present ? data.batchName.value : this.batchName,
      courseId: data.courseId.present ? data.courseId.value : this.courseId,
      courseName: data.courseName.present
          ? data.courseName.value
          : this.courseName,
      status: data.status.present ? data.status.value : this.status,
      markedBy: data.markedBy.present ? data.markedBy.value : this.markedBy,
      markedByName: data.markedByName.present
          ? data.markedByName.value
          : this.markedByName,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalAttendance(')
          ..write('localId: $localId, ')
          ..write('cloudId: $cloudId, ')
          ..write('attendanceKey: $attendanceKey, ')
          ..write('studentId: $studentId, ')
          ..write('studentName: $studentName, ')
          ..write('dateKey: $dateKey, ')
          ..write('attendanceDate: $attendanceDate, ')
          ..write('batchId: $batchId, ')
          ..write('batchName: $batchName, ')
          ..write('courseId: $courseId, ')
          ..write('courseName: $courseName, ')
          ..write('status: $status, ')
          ..write('markedBy: $markedBy, ')
          ..write('markedByName: $markedByName, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    localId,
    cloudId,
    attendanceKey,
    studentId,
    studentName,
    dateKey,
    attendanceDate,
    batchId,
    batchName,
    courseId,
    courseName,
    status,
    markedBy,
    markedByName,
    createdAt,
    updatedAt,
    deletedAt,
    syncStatus,
    lastSyncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalAttendance &&
          other.localId == this.localId &&
          other.cloudId == this.cloudId &&
          other.attendanceKey == this.attendanceKey &&
          other.studentId == this.studentId &&
          other.studentName == this.studentName &&
          other.dateKey == this.dateKey &&
          other.attendanceDate == this.attendanceDate &&
          other.batchId == this.batchId &&
          other.batchName == this.batchName &&
          other.courseId == this.courseId &&
          other.courseName == this.courseName &&
          other.status == this.status &&
          other.markedBy == this.markedBy &&
          other.markedByName == this.markedByName &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncStatus == this.syncStatus &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class LocalAttendancesCompanion extends UpdateCompanion<LocalAttendance> {
  final Value<int> localId;
  final Value<String?> cloudId;
  final Value<String> attendanceKey;
  final Value<String> studentId;
  final Value<String> studentName;
  final Value<String> dateKey;
  final Value<DateTime> attendanceDate;
  final Value<String?> batchId;
  final Value<String?> batchName;
  final Value<String?> courseId;
  final Value<String?> courseName;
  final Value<String> status;
  final Value<String?> markedBy;
  final Value<String?> markedByName;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<LocalSyncStatus> syncStatus;
  final Value<DateTime?> lastSyncedAt;
  const LocalAttendancesCompanion({
    this.localId = const Value.absent(),
    this.cloudId = const Value.absent(),
    this.attendanceKey = const Value.absent(),
    this.studentId = const Value.absent(),
    this.studentName = const Value.absent(),
    this.dateKey = const Value.absent(),
    this.attendanceDate = const Value.absent(),
    this.batchId = const Value.absent(),
    this.batchName = const Value.absent(),
    this.courseId = const Value.absent(),
    this.courseName = const Value.absent(),
    this.status = const Value.absent(),
    this.markedBy = const Value.absent(),
    this.markedByName = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
  });
  LocalAttendancesCompanion.insert({
    this.localId = const Value.absent(),
    this.cloudId = const Value.absent(),
    required String attendanceKey,
    required String studentId,
    required String studentName,
    required String dateKey,
    required DateTime attendanceDate,
    this.batchId = const Value.absent(),
    this.batchName = const Value.absent(),
    this.courseId = const Value.absent(),
    this.courseName = const Value.absent(),
    required String status,
    this.markedBy = const Value.absent(),
    this.markedByName = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required LocalSyncStatus syncStatus,
    this.lastSyncedAt = const Value.absent(),
  }) : attendanceKey = Value(attendanceKey),
       studentId = Value(studentId),
       studentName = Value(studentName),
       dateKey = Value(dateKey),
       attendanceDate = Value(attendanceDate),
       status = Value(status),
       syncStatus = Value(syncStatus);
  static Insertable<LocalAttendance> custom({
    Expression<int>? localId,
    Expression<String>? cloudId,
    Expression<String>? attendanceKey,
    Expression<String>? studentId,
    Expression<String>? studentName,
    Expression<String>? dateKey,
    Expression<DateTime>? attendanceDate,
    Expression<String>? batchId,
    Expression<String>? batchName,
    Expression<String>? courseId,
    Expression<String>? courseName,
    Expression<String>? status,
    Expression<String>? markedBy,
    Expression<String>? markedByName,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? syncStatus,
    Expression<DateTime>? lastSyncedAt,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (cloudId != null) 'cloud_id': cloudId,
      if (attendanceKey != null) 'attendance_key': attendanceKey,
      if (studentId != null) 'student_id': studentId,
      if (studentName != null) 'student_name': studentName,
      if (dateKey != null) 'date_key': dateKey,
      if (attendanceDate != null) 'attendance_date': attendanceDate,
      if (batchId != null) 'batch_id': batchId,
      if (batchName != null) 'batch_name': batchName,
      if (courseId != null) 'course_id': courseId,
      if (courseName != null) 'course_name': courseName,
      if (status != null) 'status': status,
      if (markedBy != null) 'marked_by': markedBy,
      if (markedByName != null) 'marked_by_name': markedByName,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
    });
  }

  LocalAttendancesCompanion copyWith({
    Value<int>? localId,
    Value<String?>? cloudId,
    Value<String>? attendanceKey,
    Value<String>? studentId,
    Value<String>? studentName,
    Value<String>? dateKey,
    Value<DateTime>? attendanceDate,
    Value<String?>? batchId,
    Value<String?>? batchName,
    Value<String?>? courseId,
    Value<String?>? courseName,
    Value<String>? status,
    Value<String?>? markedBy,
    Value<String?>? markedByName,
    Value<DateTime?>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<LocalSyncStatus>? syncStatus,
    Value<DateTime?>? lastSyncedAt,
  }) {
    return LocalAttendancesCompanion(
      localId: localId ?? this.localId,
      cloudId: cloudId ?? this.cloudId,
      attendanceKey: attendanceKey ?? this.attendanceKey,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      dateKey: dateKey ?? this.dateKey,
      attendanceDate: attendanceDate ?? this.attendanceDate,
      batchId: batchId ?? this.batchId,
      batchName: batchName ?? this.batchName,
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
      status: status ?? this.status,
      markedBy: markedBy ?? this.markedBy,
      markedByName: markedByName ?? this.markedByName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<int>(localId.value);
    }
    if (cloudId.present) {
      map['cloud_id'] = Variable<String>(cloudId.value);
    }
    if (attendanceKey.present) {
      map['attendance_key'] = Variable<String>(attendanceKey.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<String>(studentId.value);
    }
    if (studentName.present) {
      map['student_name'] = Variable<String>(studentName.value);
    }
    if (dateKey.present) {
      map['date_key'] = Variable<String>(dateKey.value);
    }
    if (attendanceDate.present) {
      map['attendance_date'] = Variable<DateTime>(attendanceDate.value);
    }
    if (batchId.present) {
      map['batch_id'] = Variable<String>(batchId.value);
    }
    if (batchName.present) {
      map['batch_name'] = Variable<String>(batchName.value);
    }
    if (courseId.present) {
      map['course_id'] = Variable<String>(courseId.value);
    }
    if (courseName.present) {
      map['course_name'] = Variable<String>(courseName.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (markedBy.present) {
      map['marked_by'] = Variable<String>(markedBy.value);
    }
    if (markedByName.present) {
      map['marked_by_name'] = Variable<String>(markedByName.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(
        $LocalAttendancesTable.$convertersyncStatus.toSql(syncStatus.value),
      );
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalAttendancesCompanion(')
          ..write('localId: $localId, ')
          ..write('cloudId: $cloudId, ')
          ..write('attendanceKey: $attendanceKey, ')
          ..write('studentId: $studentId, ')
          ..write('studentName: $studentName, ')
          ..write('dateKey: $dateKey, ')
          ..write('attendanceDate: $attendanceDate, ')
          ..write('batchId: $batchId, ')
          ..write('batchName: $batchName, ')
          ..write('courseId: $courseId, ')
          ..write('courseName: $courseName, ')
          ..write('status: $status, ')
          ..write('markedBy: $markedBy, ')
          ..write('markedByName: $markedByName, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueTable extends SyncQueue
    with TableInfo<$SyncQueueTable, SyncQueueData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _operationIdMeta = const VerificationMeta(
    'operationId',
  );
  @override
  late final GeneratedColumn<String> operationId = GeneratedColumn<String>(
    'operation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncEntityType, String>
  entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<SyncEntityType>($SyncQueueTable.$converterentityType);
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
  @override
  late final GeneratedColumnWithTypeConverter<SyncOperationType, String>
  operationType = GeneratedColumn<String>(
    'operation_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<SyncOperationType>($SyncQueueTable.$converteroperationType);
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _nextRetryAtMeta = const VerificationMeta(
    'nextRetryAt',
  );
  @override
  late final GeneratedColumn<DateTime> nextRetryAt = GeneratedColumn<DateTime>(
    'next_retry_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncOperationStatus, String>
  status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<SyncOperationStatus>($SyncQueueTable.$converterstatus);
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    operationId,
    entityType,
    entityId,
    operationType,
    payloadJson,
    createdAt,
    updatedAt,
    retryCount,
    nextRetryAt,
    status,
    lastError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncQueueData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('operation_id')) {
      context.handle(
        _operationIdMeta,
        operationId.isAcceptableOrUnknown(
          data['operation_id']!,
          _operationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_operationIdMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    if (data.containsKey('next_retry_at')) {
      context.handle(
        _nextRetryAtMeta,
        nextRetryAt.isAcceptableOrUnknown(
          data['next_retry_at']!,
          _nextRetryAtMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      operationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation_id'],
      )!,
      entityType: $SyncQueueTable.$converterentityType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}entity_type'],
        )!,
      ),
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      operationType: $SyncQueueTable.$converteroperationType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}operation_type'],
        )!,
      ),
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      retryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retry_count'],
      )!,
      nextRetryAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_retry_at'],
      ),
      status: $SyncQueueTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
    );
  }

  @override
  $SyncQueueTable createAlias(String alias) {
    return $SyncQueueTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncEntityType, String, String>
  $converterentityType = const EnumNameConverter<SyncEntityType>(
    SyncEntityType.values,
  );
  static JsonTypeConverter2<SyncOperationType, String, String>
  $converteroperationType = const EnumNameConverter<SyncOperationType>(
    SyncOperationType.values,
  );
  static JsonTypeConverter2<SyncOperationStatus, String, String>
  $converterstatus = const EnumNameConverter<SyncOperationStatus>(
    SyncOperationStatus.values,
  );
}

class SyncQueueData extends DataClass implements Insertable<SyncQueueData> {
  final int id;
  final String operationId;
  final SyncEntityType entityType;
  final String entityId;
  final SyncOperationType operationType;
  final String? payloadJson;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int retryCount;
  final DateTime? nextRetryAt;
  final SyncOperationStatus status;
  final String? lastError;
  const SyncQueueData({
    required this.id,
    required this.operationId,
    required this.entityType,
    required this.entityId,
    required this.operationType,
    this.payloadJson,
    required this.createdAt,
    required this.updatedAt,
    required this.retryCount,
    this.nextRetryAt,
    required this.status,
    this.lastError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['operation_id'] = Variable<String>(operationId);
    {
      map['entity_type'] = Variable<String>(
        $SyncQueueTable.$converterentityType.toSql(entityType),
      );
    }
    map['entity_id'] = Variable<String>(entityId);
    {
      map['operation_type'] = Variable<String>(
        $SyncQueueTable.$converteroperationType.toSql(operationType),
      );
    }
    if (!nullToAbsent || payloadJson != null) {
      map['payload_json'] = Variable<String>(payloadJson);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['retry_count'] = Variable<int>(retryCount);
    if (!nullToAbsent || nextRetryAt != null) {
      map['next_retry_at'] = Variable<DateTime>(nextRetryAt);
    }
    {
      map['status'] = Variable<String>(
        $SyncQueueTable.$converterstatus.toSql(status),
      );
    }
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  SyncQueueCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueCompanion(
      id: Value(id),
      operationId: Value(operationId),
      entityType: Value(entityType),
      entityId: Value(entityId),
      operationType: Value(operationType),
      payloadJson: payloadJson == null && nullToAbsent
          ? const Value.absent()
          : Value(payloadJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      retryCount: Value(retryCount),
      nextRetryAt: nextRetryAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextRetryAt),
      status: Value(status),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory SyncQueueData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueData(
      id: serializer.fromJson<int>(json['id']),
      operationId: serializer.fromJson<String>(json['operationId']),
      entityType: $SyncQueueTable.$converterentityType.fromJson(
        serializer.fromJson<String>(json['entityType']),
      ),
      entityId: serializer.fromJson<String>(json['entityId']),
      operationType: $SyncQueueTable.$converteroperationType.fromJson(
        serializer.fromJson<String>(json['operationType']),
      ),
      payloadJson: serializer.fromJson<String?>(json['payloadJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      nextRetryAt: serializer.fromJson<DateTime?>(json['nextRetryAt']),
      status: $SyncQueueTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'operationId': serializer.toJson<String>(operationId),
      'entityType': serializer.toJson<String>(
        $SyncQueueTable.$converterentityType.toJson(entityType),
      ),
      'entityId': serializer.toJson<String>(entityId),
      'operationType': serializer.toJson<String>(
        $SyncQueueTable.$converteroperationType.toJson(operationType),
      ),
      'payloadJson': serializer.toJson<String?>(payloadJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'retryCount': serializer.toJson<int>(retryCount),
      'nextRetryAt': serializer.toJson<DateTime?>(nextRetryAt),
      'status': serializer.toJson<String>(
        $SyncQueueTable.$converterstatus.toJson(status),
      ),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  SyncQueueData copyWith({
    int? id,
    String? operationId,
    SyncEntityType? entityType,
    String? entityId,
    SyncOperationType? operationType,
    Value<String?> payloadJson = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    int? retryCount,
    Value<DateTime?> nextRetryAt = const Value.absent(),
    SyncOperationStatus? status,
    Value<String?> lastError = const Value.absent(),
  }) => SyncQueueData(
    id: id ?? this.id,
    operationId: operationId ?? this.operationId,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    operationType: operationType ?? this.operationType,
    payloadJson: payloadJson.present ? payloadJson.value : this.payloadJson,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    retryCount: retryCount ?? this.retryCount,
    nextRetryAt: nextRetryAt.present ? nextRetryAt.value : this.nextRetryAt,
    status: status ?? this.status,
    lastError: lastError.present ? lastError.value : this.lastError,
  );
  SyncQueueData copyWithCompanion(SyncQueueCompanion data) {
    return SyncQueueData(
      id: data.id.present ? data.id.value : this.id,
      operationId: data.operationId.present
          ? data.operationId.value
          : this.operationId,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      operationType: data.operationType.present
          ? data.operationType.value
          : this.operationType,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      retryCount: data.retryCount.present
          ? data.retryCount.value
          : this.retryCount,
      nextRetryAt: data.nextRetryAt.present
          ? data.nextRetryAt.value
          : this.nextRetryAt,
      status: data.status.present ? data.status.value : this.status,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueData(')
          ..write('id: $id, ')
          ..write('operationId: $operationId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operationType: $operationType, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('nextRetryAt: $nextRetryAt, ')
          ..write('status: $status, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    operationId,
    entityType,
    entityId,
    operationType,
    payloadJson,
    createdAt,
    updatedAt,
    retryCount,
    nextRetryAt,
    status,
    lastError,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueData &&
          other.id == this.id &&
          other.operationId == this.operationId &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.operationType == this.operationType &&
          other.payloadJson == this.payloadJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.retryCount == this.retryCount &&
          other.nextRetryAt == this.nextRetryAt &&
          other.status == this.status &&
          other.lastError == this.lastError);
}

class SyncQueueCompanion extends UpdateCompanion<SyncQueueData> {
  final Value<int> id;
  final Value<String> operationId;
  final Value<SyncEntityType> entityType;
  final Value<String> entityId;
  final Value<SyncOperationType> operationType;
  final Value<String?> payloadJson;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> retryCount;
  final Value<DateTime?> nextRetryAt;
  final Value<SyncOperationStatus> status;
  final Value<String?> lastError;
  const SyncQueueCompanion({
    this.id = const Value.absent(),
    this.operationId = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.operationType = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.nextRetryAt = const Value.absent(),
    this.status = const Value.absent(),
    this.lastError = const Value.absent(),
  });
  SyncQueueCompanion.insert({
    this.id = const Value.absent(),
    required String operationId,
    required SyncEntityType entityType,
    required String entityId,
    required SyncOperationType operationType,
    this.payloadJson = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.retryCount = const Value.absent(),
    this.nextRetryAt = const Value.absent(),
    required SyncOperationStatus status,
    this.lastError = const Value.absent(),
  }) : operationId = Value(operationId),
       entityType = Value(entityType),
       entityId = Value(entityId),
       operationType = Value(operationType),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       status = Value(status);
  static Insertable<SyncQueueData> custom({
    Expression<int>? id,
    Expression<String>? operationId,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? operationType,
    Expression<String>? payloadJson,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? retryCount,
    Expression<DateTime>? nextRetryAt,
    Expression<String>? status,
    Expression<String>? lastError,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (operationId != null) 'operation_id': operationId,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (operationType != null) 'operation_type': operationType,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (retryCount != null) 'retry_count': retryCount,
      if (nextRetryAt != null) 'next_retry_at': nextRetryAt,
      if (status != null) 'status': status,
      if (lastError != null) 'last_error': lastError,
    });
  }

  SyncQueueCompanion copyWith({
    Value<int>? id,
    Value<String>? operationId,
    Value<SyncEntityType>? entityType,
    Value<String>? entityId,
    Value<SyncOperationType>? operationType,
    Value<String?>? payloadJson,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? retryCount,
    Value<DateTime?>? nextRetryAt,
    Value<SyncOperationStatus>? status,
    Value<String?>? lastError,
  }) {
    return SyncQueueCompanion(
      id: id ?? this.id,
      operationId: operationId ?? this.operationId,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      operationType: operationType ?? this.operationType,
      payloadJson: payloadJson ?? this.payloadJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      retryCount: retryCount ?? this.retryCount,
      nextRetryAt: nextRetryAt ?? this.nextRetryAt,
      status: status ?? this.status,
      lastError: lastError ?? this.lastError,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (operationId.present) {
      map['operation_id'] = Variable<String>(operationId.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(
        $SyncQueueTable.$converterentityType.toSql(entityType.value),
      );
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (operationType.present) {
      map['operation_type'] = Variable<String>(
        $SyncQueueTable.$converteroperationType.toSql(operationType.value),
      );
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (nextRetryAt.present) {
      map['next_retry_at'] = Variable<DateTime>(nextRetryAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $SyncQueueTable.$converterstatus.toSql(status.value),
      );
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueCompanion(')
          ..write('id: $id, ')
          ..write('operationId: $operationId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operationType: $operationType, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('nextRetryAt: $nextRetryAt, ')
          ..write('status: $status, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }
}

class $SyncMetadataTable extends SyncMetadata
    with TableInfo<$SyncMetadataTable, SyncMetadataData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncMetadataTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<SyncEntityType, String>
  entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<SyncEntityType>($SyncMetadataTable.$converterentityType);
  static const VerificationMeta _lastPullAtMeta = const VerificationMeta(
    'lastPullAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastPullAt = GeneratedColumn<DateTime>(
    'last_pull_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSuccessfulSyncAtMeta =
      const VerificationMeta('lastSuccessfulSyncAt');
  @override
  late final GeneratedColumn<DateTime> lastSuccessfulSyncAt =
      GeneratedColumn<DateTime>(
        'last_successful_sync_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  List<GeneratedColumn> get $columns => [
    entityType,
    lastPullAt,
    lastSuccessfulSyncAt,
    lastError,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_metadata';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncMetadataData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('last_pull_at')) {
      context.handle(
        _lastPullAtMeta,
        lastPullAt.isAcceptableOrUnknown(
          data['last_pull_at']!,
          _lastPullAtMeta,
        ),
      );
    }
    if (data.containsKey('last_successful_sync_at')) {
      context.handle(
        _lastSuccessfulSyncAtMeta,
        lastSuccessfulSyncAt.isAcceptableOrUnknown(
          data['last_successful_sync_at']!,
          _lastSuccessfulSyncAtMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
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
  Set<GeneratedColumn> get $primaryKey => {entityType};
  @override
  SyncMetadataData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncMetadataData(
      entityType: $SyncMetadataTable.$converterentityType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}entity_type'],
        )!,
      ),
      lastPullAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_pull_at'],
      ),
      lastSuccessfulSyncAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_successful_sync_at'],
      ),
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SyncMetadataTable createAlias(String alias) {
    return $SyncMetadataTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncEntityType, String, String>
  $converterentityType = const EnumNameConverter<SyncEntityType>(
    SyncEntityType.values,
  );
}

class SyncMetadataData extends DataClass
    implements Insertable<SyncMetadataData> {
  final SyncEntityType entityType;
  final DateTime? lastPullAt;
  final DateTime? lastSuccessfulSyncAt;
  final String? lastError;
  final DateTime updatedAt;
  const SyncMetadataData({
    required this.entityType,
    this.lastPullAt,
    this.lastSuccessfulSyncAt,
    this.lastError,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['entity_type'] = Variable<String>(
        $SyncMetadataTable.$converterentityType.toSql(entityType),
      );
    }
    if (!nullToAbsent || lastPullAt != null) {
      map['last_pull_at'] = Variable<DateTime>(lastPullAt);
    }
    if (!nullToAbsent || lastSuccessfulSyncAt != null) {
      map['last_successful_sync_at'] = Variable<DateTime>(lastSuccessfulSyncAt);
    }
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SyncMetadataCompanion toCompanion(bool nullToAbsent) {
    return SyncMetadataCompanion(
      entityType: Value(entityType),
      lastPullAt: lastPullAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPullAt),
      lastSuccessfulSyncAt: lastSuccessfulSyncAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSuccessfulSyncAt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      updatedAt: Value(updatedAt),
    );
  }

  factory SyncMetadataData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncMetadataData(
      entityType: $SyncMetadataTable.$converterentityType.fromJson(
        serializer.fromJson<String>(json['entityType']),
      ),
      lastPullAt: serializer.fromJson<DateTime?>(json['lastPullAt']),
      lastSuccessfulSyncAt: serializer.fromJson<DateTime?>(
        json['lastSuccessfulSyncAt'],
      ),
      lastError: serializer.fromJson<String?>(json['lastError']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'entityType': serializer.toJson<String>(
        $SyncMetadataTable.$converterentityType.toJson(entityType),
      ),
      'lastPullAt': serializer.toJson<DateTime?>(lastPullAt),
      'lastSuccessfulSyncAt': serializer.toJson<DateTime?>(
        lastSuccessfulSyncAt,
      ),
      'lastError': serializer.toJson<String?>(lastError),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SyncMetadataData copyWith({
    SyncEntityType? entityType,
    Value<DateTime?> lastPullAt = const Value.absent(),
    Value<DateTime?> lastSuccessfulSyncAt = const Value.absent(),
    Value<String?> lastError = const Value.absent(),
    DateTime? updatedAt,
  }) => SyncMetadataData(
    entityType: entityType ?? this.entityType,
    lastPullAt: lastPullAt.present ? lastPullAt.value : this.lastPullAt,
    lastSuccessfulSyncAt: lastSuccessfulSyncAt.present
        ? lastSuccessfulSyncAt.value
        : this.lastSuccessfulSyncAt,
    lastError: lastError.present ? lastError.value : this.lastError,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SyncMetadataData copyWithCompanion(SyncMetadataCompanion data) {
    return SyncMetadataData(
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      lastPullAt: data.lastPullAt.present
          ? data.lastPullAt.value
          : this.lastPullAt,
      lastSuccessfulSyncAt: data.lastSuccessfulSyncAt.present
          ? data.lastSuccessfulSyncAt.value
          : this.lastSuccessfulSyncAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetadataData(')
          ..write('entityType: $entityType, ')
          ..write('lastPullAt: $lastPullAt, ')
          ..write('lastSuccessfulSyncAt: $lastSuccessfulSyncAt, ')
          ..write('lastError: $lastError, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    entityType,
    lastPullAt,
    lastSuccessfulSyncAt,
    lastError,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncMetadataData &&
          other.entityType == this.entityType &&
          other.lastPullAt == this.lastPullAt &&
          other.lastSuccessfulSyncAt == this.lastSuccessfulSyncAt &&
          other.lastError == this.lastError &&
          other.updatedAt == this.updatedAt);
}

class SyncMetadataCompanion extends UpdateCompanion<SyncMetadataData> {
  final Value<SyncEntityType> entityType;
  final Value<DateTime?> lastPullAt;
  final Value<DateTime?> lastSuccessfulSyncAt;
  final Value<String?> lastError;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SyncMetadataCompanion({
    this.entityType = const Value.absent(),
    this.lastPullAt = const Value.absent(),
    this.lastSuccessfulSyncAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncMetadataCompanion.insert({
    required SyncEntityType entityType,
    this.lastPullAt = const Value.absent(),
    this.lastSuccessfulSyncAt = const Value.absent(),
    this.lastError = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : entityType = Value(entityType),
       updatedAt = Value(updatedAt);
  static Insertable<SyncMetadataData> custom({
    Expression<String>? entityType,
    Expression<DateTime>? lastPullAt,
    Expression<DateTime>? lastSuccessfulSyncAt,
    Expression<String>? lastError,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (entityType != null) 'entity_type': entityType,
      if (lastPullAt != null) 'last_pull_at': lastPullAt,
      if (lastSuccessfulSyncAt != null)
        'last_successful_sync_at': lastSuccessfulSyncAt,
      if (lastError != null) 'last_error': lastError,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncMetadataCompanion copyWith({
    Value<SyncEntityType>? entityType,
    Value<DateTime?>? lastPullAt,
    Value<DateTime?>? lastSuccessfulSyncAt,
    Value<String?>? lastError,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return SyncMetadataCompanion(
      entityType: entityType ?? this.entityType,
      lastPullAt: lastPullAt ?? this.lastPullAt,
      lastSuccessfulSyncAt: lastSuccessfulSyncAt ?? this.lastSuccessfulSyncAt,
      lastError: lastError ?? this.lastError,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (entityType.present) {
      map['entity_type'] = Variable<String>(
        $SyncMetadataTable.$converterentityType.toSql(entityType.value),
      );
    }
    if (lastPullAt.present) {
      map['last_pull_at'] = Variable<DateTime>(lastPullAt.value);
    }
    if (lastSuccessfulSyncAt.present) {
      map['last_successful_sync_at'] = Variable<DateTime>(
        lastSuccessfulSyncAt.value,
      );
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
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
    return (StringBuffer('SyncMetadataCompanion(')
          ..write('entityType: $entityType, ')
          ..write('lastPullAt: $lastPullAt, ')
          ..write('lastSuccessfulSyncAt: $lastSuccessfulSyncAt, ')
          ..write('lastError: $lastError, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LocalStudentsTable localStudents = $LocalStudentsTable(this);
  late final $LocalCoursesTable localCourses = $LocalCoursesTable(this);
  late final $LocalBatchesTable localBatches = $LocalBatchesTable(this);
  late final $LocalEnquiriesTable localEnquiries = $LocalEnquiriesTable(this);
  late final $LocalAttendancesTable localAttendances = $LocalAttendancesTable(
    this,
  );
  late final $SyncQueueTable syncQueue = $SyncQueueTable(this);
  late final $SyncMetadataTable syncMetadata = $SyncMetadataTable(this);
  late final StudentsDao studentsDao = StudentsDao(this as AppDatabase);
  late final CoursesDao coursesDao = CoursesDao(this as AppDatabase);
  late final BatchesDao batchesDao = BatchesDao(this as AppDatabase);
  late final EnquiriesDao enquiriesDao = EnquiriesDao(this as AppDatabase);
  late final AttendanceDao attendanceDao = AttendanceDao(this as AppDatabase);
  late final SyncQueueDao syncQueueDao = SyncQueueDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    localStudents,
    localCourses,
    localBatches,
    localEnquiries,
    localAttendances,
    syncQueue,
    syncMetadata,
  ];
}

typedef $$LocalStudentsTableCreateCompanionBuilder =
    LocalStudentsCompanion Function({
      Value<int> localId,
      Value<String?> cloudId,
      Value<String?> studentIdLegacy,
      required String name,
      required String normalizedName,
      Value<String?> phone,
      Value<String?> parentName,
      Value<String?> parentPhone,
      Value<String?> email,
      Value<DateTime?> dob,
      Value<String?> address,
      Value<String?> className,
      Value<String?> courseId,
      Value<String?> courseName,
      Value<String?> batchId,
      Value<String?> batchName,
      Value<String> status,
      Value<String?> notes,
      Value<String?> photoUrl,
      Value<DateTime?> createdAt,
      Value<DateTime?> updatedAt,
      Value<DateTime?> deletedAt,
      required LocalSyncStatus syncStatus,
      Value<DateTime?> lastSyncedAt,
    });
typedef $$LocalStudentsTableUpdateCompanionBuilder =
    LocalStudentsCompanion Function({
      Value<int> localId,
      Value<String?> cloudId,
      Value<String?> studentIdLegacy,
      Value<String> name,
      Value<String> normalizedName,
      Value<String?> phone,
      Value<String?> parentName,
      Value<String?> parentPhone,
      Value<String?> email,
      Value<DateTime?> dob,
      Value<String?> address,
      Value<String?> className,
      Value<String?> courseId,
      Value<String?> courseName,
      Value<String?> batchId,
      Value<String?> batchName,
      Value<String> status,
      Value<String?> notes,
      Value<String?> photoUrl,
      Value<DateTime?> createdAt,
      Value<DateTime?> updatedAt,
      Value<DateTime?> deletedAt,
      Value<LocalSyncStatus> syncStatus,
      Value<DateTime?> lastSyncedAt,
    });

class $$LocalStudentsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalStudentsTable> {
  $$LocalStudentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cloudId => $composableBuilder(
    column: $table.cloudId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get studentIdLegacy => $composableBuilder(
    column: $table.studentIdLegacy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentName => $composableBuilder(
    column: $table.parentName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentPhone => $composableBuilder(
    column: $table.parentPhone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dob => $composableBuilder(
    column: $table.dob,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get className => $composableBuilder(
    column: $table.className,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get courseId => $composableBuilder(
    column: $table.courseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get courseName => $composableBuilder(
    column: $table.courseName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get batchName => $composableBuilder(
    column: $table.batchName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoUrl => $composableBuilder(
    column: $table.photoUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<LocalSyncStatus, LocalSyncStatus, String>
  get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalStudentsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalStudentsTable> {
  $$LocalStudentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cloudId => $composableBuilder(
    column: $table.cloudId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get studentIdLegacy => $composableBuilder(
    column: $table.studentIdLegacy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentName => $composableBuilder(
    column: $table.parentName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentPhone => $composableBuilder(
    column: $table.parentPhone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dob => $composableBuilder(
    column: $table.dob,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get className => $composableBuilder(
    column: $table.className,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get courseId => $composableBuilder(
    column: $table.courseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get courseName => $composableBuilder(
    column: $table.courseName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get batchName => $composableBuilder(
    column: $table.batchName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoUrl => $composableBuilder(
    column: $table.photoUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalStudentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalStudentsTable> {
  $$LocalStudentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<String> get cloudId =>
      $composableBuilder(column: $table.cloudId, builder: (column) => column);

  GeneratedColumn<String> get studentIdLegacy => $composableBuilder(
    column: $table.studentIdLegacy,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get parentName => $composableBuilder(
    column: $table.parentName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get parentPhone => $composableBuilder(
    column: $table.parentPhone,
    builder: (column) => column,
  );

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<DateTime> get dob =>
      $composableBuilder(column: $table.dob, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get className =>
      $composableBuilder(column: $table.className, builder: (column) => column);

  GeneratedColumn<String> get courseId =>
      $composableBuilder(column: $table.courseId, builder: (column) => column);

  GeneratedColumn<String> get courseName => $composableBuilder(
    column: $table.courseName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get batchId =>
      $composableBuilder(column: $table.batchId, builder: (column) => column);

  GeneratedColumn<String> get batchName =>
      $composableBuilder(column: $table.batchName, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get photoUrl =>
      $composableBuilder(column: $table.photoUrl, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LocalSyncStatus, String> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );
}

class $$LocalStudentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalStudentsTable,
          LocalStudent,
          $$LocalStudentsTableFilterComposer,
          $$LocalStudentsTableOrderingComposer,
          $$LocalStudentsTableAnnotationComposer,
          $$LocalStudentsTableCreateCompanionBuilder,
          $$LocalStudentsTableUpdateCompanionBuilder,
          (
            LocalStudent,
            BaseReferences<_$AppDatabase, $LocalStudentsTable, LocalStudent>,
          ),
          LocalStudent,
          PrefetchHooks Function()
        > {
  $$LocalStudentsTableTableManager(_$AppDatabase db, $LocalStudentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalStudentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalStudentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalStudentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> localId = const Value.absent(),
                Value<String?> cloudId = const Value.absent(),
                Value<String?> studentIdLegacy = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> normalizedName = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> parentName = const Value.absent(),
                Value<String?> parentPhone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<DateTime?> dob = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> className = const Value.absent(),
                Value<String?> courseId = const Value.absent(),
                Value<String?> courseName = const Value.absent(),
                Value<String?> batchId = const Value.absent(),
                Value<String?> batchName = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> photoUrl = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<LocalSyncStatus> syncStatus = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
              }) => LocalStudentsCompanion(
                localId: localId,
                cloudId: cloudId,
                studentIdLegacy: studentIdLegacy,
                name: name,
                normalizedName: normalizedName,
                phone: phone,
                parentName: parentName,
                parentPhone: parentPhone,
                email: email,
                dob: dob,
                address: address,
                className: className,
                courseId: courseId,
                courseName: courseName,
                batchId: batchId,
                batchName: batchName,
                status: status,
                notes: notes,
                photoUrl: photoUrl,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                lastSyncedAt: lastSyncedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> localId = const Value.absent(),
                Value<String?> cloudId = const Value.absent(),
                Value<String?> studentIdLegacy = const Value.absent(),
                required String name,
                required String normalizedName,
                Value<String?> phone = const Value.absent(),
                Value<String?> parentName = const Value.absent(),
                Value<String?> parentPhone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<DateTime?> dob = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> className = const Value.absent(),
                Value<String?> courseId = const Value.absent(),
                Value<String?> courseName = const Value.absent(),
                Value<String?> batchId = const Value.absent(),
                Value<String?> batchName = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> photoUrl = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                required LocalSyncStatus syncStatus,
                Value<DateTime?> lastSyncedAt = const Value.absent(),
              }) => LocalStudentsCompanion.insert(
                localId: localId,
                cloudId: cloudId,
                studentIdLegacy: studentIdLegacy,
                name: name,
                normalizedName: normalizedName,
                phone: phone,
                parentName: parentName,
                parentPhone: parentPhone,
                email: email,
                dob: dob,
                address: address,
                className: className,
                courseId: courseId,
                courseName: courseName,
                batchId: batchId,
                batchName: batchName,
                status: status,
                notes: notes,
                photoUrl: photoUrl,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                lastSyncedAt: lastSyncedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalStudentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalStudentsTable,
      LocalStudent,
      $$LocalStudentsTableFilterComposer,
      $$LocalStudentsTableOrderingComposer,
      $$LocalStudentsTableAnnotationComposer,
      $$LocalStudentsTableCreateCompanionBuilder,
      $$LocalStudentsTableUpdateCompanionBuilder,
      (
        LocalStudent,
        BaseReferences<_$AppDatabase, $LocalStudentsTable, LocalStudent>,
      ),
      LocalStudent,
      PrefetchHooks Function()
    >;
typedef $$LocalCoursesTableCreateCompanionBuilder =
    LocalCoursesCompanion Function({
      Value<int> localId,
      Value<String?> cloudId,
      Value<String?> legacyId,
      Value<String?> code,
      required String name,
      Value<String?> category,
      Value<String?> description,
      Value<double?> feesAmount,
      Value<String?> feesFrequency,
      Value<double?> monthlyFees,
      Value<double?> yearlyFees,
      Value<int?> durationMonths,
      Value<String?> subjects,
      Value<int?> maxStudents,
      Value<bool> isActive,
      Value<DateTime?> createdAt,
      Value<DateTime?> updatedAt,
      Value<DateTime?> deletedAt,
      required LocalSyncStatus syncStatus,
      Value<DateTime?> lastSyncedAt,
    });
typedef $$LocalCoursesTableUpdateCompanionBuilder =
    LocalCoursesCompanion Function({
      Value<int> localId,
      Value<String?> cloudId,
      Value<String?> legacyId,
      Value<String?> code,
      Value<String> name,
      Value<String?> category,
      Value<String?> description,
      Value<double?> feesAmount,
      Value<String?> feesFrequency,
      Value<double?> monthlyFees,
      Value<double?> yearlyFees,
      Value<int?> durationMonths,
      Value<String?> subjects,
      Value<int?> maxStudents,
      Value<bool> isActive,
      Value<DateTime?> createdAt,
      Value<DateTime?> updatedAt,
      Value<DateTime?> deletedAt,
      Value<LocalSyncStatus> syncStatus,
      Value<DateTime?> lastSyncedAt,
    });

class $$LocalCoursesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalCoursesTable> {
  $$LocalCoursesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cloudId => $composableBuilder(
    column: $table.cloudId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get legacyId => $composableBuilder(
    column: $table.legacyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get feesAmount => $composableBuilder(
    column: $table.feesAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get feesFrequency => $composableBuilder(
    column: $table.feesFrequency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get monthlyFees => $composableBuilder(
    column: $table.monthlyFees,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get yearlyFees => $composableBuilder(
    column: $table.yearlyFees,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMonths => $composableBuilder(
    column: $table.durationMonths,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subjects => $composableBuilder(
    column: $table.subjects,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxStudents => $composableBuilder(
    column: $table.maxStudents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<LocalSyncStatus, LocalSyncStatus, String>
  get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalCoursesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalCoursesTable> {
  $$LocalCoursesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cloudId => $composableBuilder(
    column: $table.cloudId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get legacyId => $composableBuilder(
    column: $table.legacyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get feesAmount => $composableBuilder(
    column: $table.feesAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get feesFrequency => $composableBuilder(
    column: $table.feesFrequency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get monthlyFees => $composableBuilder(
    column: $table.monthlyFees,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get yearlyFees => $composableBuilder(
    column: $table.yearlyFees,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMonths => $composableBuilder(
    column: $table.durationMonths,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subjects => $composableBuilder(
    column: $table.subjects,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxStudents => $composableBuilder(
    column: $table.maxStudents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalCoursesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalCoursesTable> {
  $$LocalCoursesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<String> get cloudId =>
      $composableBuilder(column: $table.cloudId, builder: (column) => column);

  GeneratedColumn<String> get legacyId =>
      $composableBuilder(column: $table.legacyId, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<double> get feesAmount => $composableBuilder(
    column: $table.feesAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get feesFrequency => $composableBuilder(
    column: $table.feesFrequency,
    builder: (column) => column,
  );

  GeneratedColumn<double> get monthlyFees => $composableBuilder(
    column: $table.monthlyFees,
    builder: (column) => column,
  );

  GeneratedColumn<double> get yearlyFees => $composableBuilder(
    column: $table.yearlyFees,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMonths => $composableBuilder(
    column: $table.durationMonths,
    builder: (column) => column,
  );

  GeneratedColumn<String> get subjects =>
      $composableBuilder(column: $table.subjects, builder: (column) => column);

  GeneratedColumn<int> get maxStudents => $composableBuilder(
    column: $table.maxStudents,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LocalSyncStatus, String> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );
}

class $$LocalCoursesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalCoursesTable,
          LocalCourse,
          $$LocalCoursesTableFilterComposer,
          $$LocalCoursesTableOrderingComposer,
          $$LocalCoursesTableAnnotationComposer,
          $$LocalCoursesTableCreateCompanionBuilder,
          $$LocalCoursesTableUpdateCompanionBuilder,
          (
            LocalCourse,
            BaseReferences<_$AppDatabase, $LocalCoursesTable, LocalCourse>,
          ),
          LocalCourse,
          PrefetchHooks Function()
        > {
  $$LocalCoursesTableTableManager(_$AppDatabase db, $LocalCoursesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalCoursesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalCoursesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalCoursesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> localId = const Value.absent(),
                Value<String?> cloudId = const Value.absent(),
                Value<String?> legacyId = const Value.absent(),
                Value<String?> code = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<double?> feesAmount = const Value.absent(),
                Value<String?> feesFrequency = const Value.absent(),
                Value<double?> monthlyFees = const Value.absent(),
                Value<double?> yearlyFees = const Value.absent(),
                Value<int?> durationMonths = const Value.absent(),
                Value<String?> subjects = const Value.absent(),
                Value<int?> maxStudents = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<LocalSyncStatus> syncStatus = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
              }) => LocalCoursesCompanion(
                localId: localId,
                cloudId: cloudId,
                legacyId: legacyId,
                code: code,
                name: name,
                category: category,
                description: description,
                feesAmount: feesAmount,
                feesFrequency: feesFrequency,
                monthlyFees: monthlyFees,
                yearlyFees: yearlyFees,
                durationMonths: durationMonths,
                subjects: subjects,
                maxStudents: maxStudents,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                lastSyncedAt: lastSyncedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> localId = const Value.absent(),
                Value<String?> cloudId = const Value.absent(),
                Value<String?> legacyId = const Value.absent(),
                Value<String?> code = const Value.absent(),
                required String name,
                Value<String?> category = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<double?> feesAmount = const Value.absent(),
                Value<String?> feesFrequency = const Value.absent(),
                Value<double?> monthlyFees = const Value.absent(),
                Value<double?> yearlyFees = const Value.absent(),
                Value<int?> durationMonths = const Value.absent(),
                Value<String?> subjects = const Value.absent(),
                Value<int?> maxStudents = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                required LocalSyncStatus syncStatus,
                Value<DateTime?> lastSyncedAt = const Value.absent(),
              }) => LocalCoursesCompanion.insert(
                localId: localId,
                cloudId: cloudId,
                legacyId: legacyId,
                code: code,
                name: name,
                category: category,
                description: description,
                feesAmount: feesAmount,
                feesFrequency: feesFrequency,
                monthlyFees: monthlyFees,
                yearlyFees: yearlyFees,
                durationMonths: durationMonths,
                subjects: subjects,
                maxStudents: maxStudents,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                lastSyncedAt: lastSyncedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalCoursesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalCoursesTable,
      LocalCourse,
      $$LocalCoursesTableFilterComposer,
      $$LocalCoursesTableOrderingComposer,
      $$LocalCoursesTableAnnotationComposer,
      $$LocalCoursesTableCreateCompanionBuilder,
      $$LocalCoursesTableUpdateCompanionBuilder,
      (
        LocalCourse,
        BaseReferences<_$AppDatabase, $LocalCoursesTable, LocalCourse>,
      ),
      LocalCourse,
      PrefetchHooks Function()
    >;
typedef $$LocalBatchesTableCreateCompanionBuilder =
    LocalBatchesCompanion Function({
      Value<int> localId,
      Value<String?> cloudId,
      Value<String?> legacyId,
      required String name,
      Value<String?> courseId,
      Value<String?> courseName,
      Value<String?> daysJson,
      Value<DateTime?> startDate,
      Value<DateTime?> endDate,
      Value<String?> startTime,
      Value<String?> endTime,
      Value<int?> maxStudents,
      Value<bool> isActive,
      Value<DateTime?> createdAt,
      Value<DateTime?> updatedAt,
      Value<DateTime?> deletedAt,
      required LocalSyncStatus syncStatus,
      Value<DateTime?> lastSyncedAt,
    });
typedef $$LocalBatchesTableUpdateCompanionBuilder =
    LocalBatchesCompanion Function({
      Value<int> localId,
      Value<String?> cloudId,
      Value<String?> legacyId,
      Value<String> name,
      Value<String?> courseId,
      Value<String?> courseName,
      Value<String?> daysJson,
      Value<DateTime?> startDate,
      Value<DateTime?> endDate,
      Value<String?> startTime,
      Value<String?> endTime,
      Value<int?> maxStudents,
      Value<bool> isActive,
      Value<DateTime?> createdAt,
      Value<DateTime?> updatedAt,
      Value<DateTime?> deletedAt,
      Value<LocalSyncStatus> syncStatus,
      Value<DateTime?> lastSyncedAt,
    });

class $$LocalBatchesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalBatchesTable> {
  $$LocalBatchesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cloudId => $composableBuilder(
    column: $table.cloudId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get legacyId => $composableBuilder(
    column: $table.legacyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get courseId => $composableBuilder(
    column: $table.courseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get courseName => $composableBuilder(
    column: $table.courseName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get daysJson => $composableBuilder(
    column: $table.daysJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxStudents => $composableBuilder(
    column: $table.maxStudents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<LocalSyncStatus, LocalSyncStatus, String>
  get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalBatchesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalBatchesTable> {
  $$LocalBatchesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cloudId => $composableBuilder(
    column: $table.cloudId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get legacyId => $composableBuilder(
    column: $table.legacyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get courseId => $composableBuilder(
    column: $table.courseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get courseName => $composableBuilder(
    column: $table.courseName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get daysJson => $composableBuilder(
    column: $table.daysJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxStudents => $composableBuilder(
    column: $table.maxStudents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalBatchesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalBatchesTable> {
  $$LocalBatchesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<String> get cloudId =>
      $composableBuilder(column: $table.cloudId, builder: (column) => column);

  GeneratedColumn<String> get legacyId =>
      $composableBuilder(column: $table.legacyId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get courseId =>
      $composableBuilder(column: $table.courseId, builder: (column) => column);

  GeneratedColumn<String> get courseName => $composableBuilder(
    column: $table.courseName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get daysJson =>
      $composableBuilder(column: $table.daysJson, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<String> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<String> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<int> get maxStudents => $composableBuilder(
    column: $table.maxStudents,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LocalSyncStatus, String> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );
}

class $$LocalBatchesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalBatchesTable,
          LocalBatch,
          $$LocalBatchesTableFilterComposer,
          $$LocalBatchesTableOrderingComposer,
          $$LocalBatchesTableAnnotationComposer,
          $$LocalBatchesTableCreateCompanionBuilder,
          $$LocalBatchesTableUpdateCompanionBuilder,
          (
            LocalBatch,
            BaseReferences<_$AppDatabase, $LocalBatchesTable, LocalBatch>,
          ),
          LocalBatch,
          PrefetchHooks Function()
        > {
  $$LocalBatchesTableTableManager(_$AppDatabase db, $LocalBatchesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalBatchesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalBatchesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalBatchesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> localId = const Value.absent(),
                Value<String?> cloudId = const Value.absent(),
                Value<String?> legacyId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> courseId = const Value.absent(),
                Value<String?> courseName = const Value.absent(),
                Value<String?> daysJson = const Value.absent(),
                Value<DateTime?> startDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<String?> startTime = const Value.absent(),
                Value<String?> endTime = const Value.absent(),
                Value<int?> maxStudents = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<LocalSyncStatus> syncStatus = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
              }) => LocalBatchesCompanion(
                localId: localId,
                cloudId: cloudId,
                legacyId: legacyId,
                name: name,
                courseId: courseId,
                courseName: courseName,
                daysJson: daysJson,
                startDate: startDate,
                endDate: endDate,
                startTime: startTime,
                endTime: endTime,
                maxStudents: maxStudents,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                lastSyncedAt: lastSyncedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> localId = const Value.absent(),
                Value<String?> cloudId = const Value.absent(),
                Value<String?> legacyId = const Value.absent(),
                required String name,
                Value<String?> courseId = const Value.absent(),
                Value<String?> courseName = const Value.absent(),
                Value<String?> daysJson = const Value.absent(),
                Value<DateTime?> startDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<String?> startTime = const Value.absent(),
                Value<String?> endTime = const Value.absent(),
                Value<int?> maxStudents = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                required LocalSyncStatus syncStatus,
                Value<DateTime?> lastSyncedAt = const Value.absent(),
              }) => LocalBatchesCompanion.insert(
                localId: localId,
                cloudId: cloudId,
                legacyId: legacyId,
                name: name,
                courseId: courseId,
                courseName: courseName,
                daysJson: daysJson,
                startDate: startDate,
                endDate: endDate,
                startTime: startTime,
                endTime: endTime,
                maxStudents: maxStudents,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                lastSyncedAt: lastSyncedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalBatchesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalBatchesTable,
      LocalBatch,
      $$LocalBatchesTableFilterComposer,
      $$LocalBatchesTableOrderingComposer,
      $$LocalBatchesTableAnnotationComposer,
      $$LocalBatchesTableCreateCompanionBuilder,
      $$LocalBatchesTableUpdateCompanionBuilder,
      (
        LocalBatch,
        BaseReferences<_$AppDatabase, $LocalBatchesTable, LocalBatch>,
      ),
      LocalBatch,
      PrefetchHooks Function()
    >;
typedef $$LocalEnquiriesTableCreateCompanionBuilder =
    LocalEnquiriesCompanion Function({
      Value<int> localId,
      Value<String?> cloudId,
      Value<String?> legacyId,
      required String studentName,
      Value<String?> parentName,
      Value<String?> phone,
      Value<String?> alternatePhone,
      Value<String?> email,
      Value<DateTime?> dob,
      Value<String?> interestedCourseId,
      Value<String?> interestedCourseName,
      Value<String?> interestedBatchId,
      Value<String?> interestedBatchName,
      Value<String?> currentClass,
      Value<String?> schoolName,
      Value<String?> source,
      Value<String> enquiryStatus,
      Value<DateTime?> followUpDate,
      Value<String?> message,
      Value<String?> followUpNotes,
      Value<String?> notes,
      Value<String?> assignedTo,
      Value<String?> assignedToName,
      Value<DateTime?> createdAt,
      Value<DateTime?> updatedAt,
      Value<DateTime?> deletedAt,
      required LocalSyncStatus syncStatus,
      Value<DateTime?> lastSyncedAt,
    });
typedef $$LocalEnquiriesTableUpdateCompanionBuilder =
    LocalEnquiriesCompanion Function({
      Value<int> localId,
      Value<String?> cloudId,
      Value<String?> legacyId,
      Value<String> studentName,
      Value<String?> parentName,
      Value<String?> phone,
      Value<String?> alternatePhone,
      Value<String?> email,
      Value<DateTime?> dob,
      Value<String?> interestedCourseId,
      Value<String?> interestedCourseName,
      Value<String?> interestedBatchId,
      Value<String?> interestedBatchName,
      Value<String?> currentClass,
      Value<String?> schoolName,
      Value<String?> source,
      Value<String> enquiryStatus,
      Value<DateTime?> followUpDate,
      Value<String?> message,
      Value<String?> followUpNotes,
      Value<String?> notes,
      Value<String?> assignedTo,
      Value<String?> assignedToName,
      Value<DateTime?> createdAt,
      Value<DateTime?> updatedAt,
      Value<DateTime?> deletedAt,
      Value<LocalSyncStatus> syncStatus,
      Value<DateTime?> lastSyncedAt,
    });

class $$LocalEnquiriesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalEnquiriesTable> {
  $$LocalEnquiriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cloudId => $composableBuilder(
    column: $table.cloudId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get legacyId => $composableBuilder(
    column: $table.legacyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get studentName => $composableBuilder(
    column: $table.studentName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentName => $composableBuilder(
    column: $table.parentName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get alternatePhone => $composableBuilder(
    column: $table.alternatePhone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dob => $composableBuilder(
    column: $table.dob,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get interestedCourseId => $composableBuilder(
    column: $table.interestedCourseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get interestedCourseName => $composableBuilder(
    column: $table.interestedCourseName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get interestedBatchId => $composableBuilder(
    column: $table.interestedBatchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get interestedBatchName => $composableBuilder(
    column: $table.interestedBatchName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currentClass => $composableBuilder(
    column: $table.currentClass,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schoolName => $composableBuilder(
    column: $table.schoolName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get enquiryStatus => $composableBuilder(
    column: $table.enquiryStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get followUpDate => $composableBuilder(
    column: $table.followUpDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get followUpNotes => $composableBuilder(
    column: $table.followUpNotes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assignedTo => $composableBuilder(
    column: $table.assignedTo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assignedToName => $composableBuilder(
    column: $table.assignedToName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<LocalSyncStatus, LocalSyncStatus, String>
  get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalEnquiriesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalEnquiriesTable> {
  $$LocalEnquiriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cloudId => $composableBuilder(
    column: $table.cloudId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get legacyId => $composableBuilder(
    column: $table.legacyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get studentName => $composableBuilder(
    column: $table.studentName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentName => $composableBuilder(
    column: $table.parentName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get alternatePhone => $composableBuilder(
    column: $table.alternatePhone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dob => $composableBuilder(
    column: $table.dob,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get interestedCourseId => $composableBuilder(
    column: $table.interestedCourseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get interestedCourseName => $composableBuilder(
    column: $table.interestedCourseName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get interestedBatchId => $composableBuilder(
    column: $table.interestedBatchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get interestedBatchName => $composableBuilder(
    column: $table.interestedBatchName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currentClass => $composableBuilder(
    column: $table.currentClass,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schoolName => $composableBuilder(
    column: $table.schoolName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get enquiryStatus => $composableBuilder(
    column: $table.enquiryStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get followUpDate => $composableBuilder(
    column: $table.followUpDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get followUpNotes => $composableBuilder(
    column: $table.followUpNotes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assignedTo => $composableBuilder(
    column: $table.assignedTo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assignedToName => $composableBuilder(
    column: $table.assignedToName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalEnquiriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalEnquiriesTable> {
  $$LocalEnquiriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<String> get cloudId =>
      $composableBuilder(column: $table.cloudId, builder: (column) => column);

  GeneratedColumn<String> get legacyId =>
      $composableBuilder(column: $table.legacyId, builder: (column) => column);

  GeneratedColumn<String> get studentName => $composableBuilder(
    column: $table.studentName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get parentName => $composableBuilder(
    column: $table.parentName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get alternatePhone => $composableBuilder(
    column: $table.alternatePhone,
    builder: (column) => column,
  );

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<DateTime> get dob =>
      $composableBuilder(column: $table.dob, builder: (column) => column);

  GeneratedColumn<String> get interestedCourseId => $composableBuilder(
    column: $table.interestedCourseId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get interestedCourseName => $composableBuilder(
    column: $table.interestedCourseName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get interestedBatchId => $composableBuilder(
    column: $table.interestedBatchId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get interestedBatchName => $composableBuilder(
    column: $table.interestedBatchName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currentClass => $composableBuilder(
    column: $table.currentClass,
    builder: (column) => column,
  );

  GeneratedColumn<String> get schoolName => $composableBuilder(
    column: $table.schoolName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get enquiryStatus => $composableBuilder(
    column: $table.enquiryStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get followUpDate => $composableBuilder(
    column: $table.followUpDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);

  GeneratedColumn<String> get followUpNotes => $composableBuilder(
    column: $table.followUpNotes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get assignedTo => $composableBuilder(
    column: $table.assignedTo,
    builder: (column) => column,
  );

  GeneratedColumn<String> get assignedToName => $composableBuilder(
    column: $table.assignedToName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LocalSyncStatus, String> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );
}

class $$LocalEnquiriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalEnquiriesTable,
          LocalEnquiry,
          $$LocalEnquiriesTableFilterComposer,
          $$LocalEnquiriesTableOrderingComposer,
          $$LocalEnquiriesTableAnnotationComposer,
          $$LocalEnquiriesTableCreateCompanionBuilder,
          $$LocalEnquiriesTableUpdateCompanionBuilder,
          (
            LocalEnquiry,
            BaseReferences<_$AppDatabase, $LocalEnquiriesTable, LocalEnquiry>,
          ),
          LocalEnquiry,
          PrefetchHooks Function()
        > {
  $$LocalEnquiriesTableTableManager(
    _$AppDatabase db,
    $LocalEnquiriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalEnquiriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalEnquiriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalEnquiriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> localId = const Value.absent(),
                Value<String?> cloudId = const Value.absent(),
                Value<String?> legacyId = const Value.absent(),
                Value<String> studentName = const Value.absent(),
                Value<String?> parentName = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> alternatePhone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<DateTime?> dob = const Value.absent(),
                Value<String?> interestedCourseId = const Value.absent(),
                Value<String?> interestedCourseName = const Value.absent(),
                Value<String?> interestedBatchId = const Value.absent(),
                Value<String?> interestedBatchName = const Value.absent(),
                Value<String?> currentClass = const Value.absent(),
                Value<String?> schoolName = const Value.absent(),
                Value<String?> source = const Value.absent(),
                Value<String> enquiryStatus = const Value.absent(),
                Value<DateTime?> followUpDate = const Value.absent(),
                Value<String?> message = const Value.absent(),
                Value<String?> followUpNotes = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> assignedTo = const Value.absent(),
                Value<String?> assignedToName = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<LocalSyncStatus> syncStatus = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
              }) => LocalEnquiriesCompanion(
                localId: localId,
                cloudId: cloudId,
                legacyId: legacyId,
                studentName: studentName,
                parentName: parentName,
                phone: phone,
                alternatePhone: alternatePhone,
                email: email,
                dob: dob,
                interestedCourseId: interestedCourseId,
                interestedCourseName: interestedCourseName,
                interestedBatchId: interestedBatchId,
                interestedBatchName: interestedBatchName,
                currentClass: currentClass,
                schoolName: schoolName,
                source: source,
                enquiryStatus: enquiryStatus,
                followUpDate: followUpDate,
                message: message,
                followUpNotes: followUpNotes,
                notes: notes,
                assignedTo: assignedTo,
                assignedToName: assignedToName,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                lastSyncedAt: lastSyncedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> localId = const Value.absent(),
                Value<String?> cloudId = const Value.absent(),
                Value<String?> legacyId = const Value.absent(),
                required String studentName,
                Value<String?> parentName = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> alternatePhone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<DateTime?> dob = const Value.absent(),
                Value<String?> interestedCourseId = const Value.absent(),
                Value<String?> interestedCourseName = const Value.absent(),
                Value<String?> interestedBatchId = const Value.absent(),
                Value<String?> interestedBatchName = const Value.absent(),
                Value<String?> currentClass = const Value.absent(),
                Value<String?> schoolName = const Value.absent(),
                Value<String?> source = const Value.absent(),
                Value<String> enquiryStatus = const Value.absent(),
                Value<DateTime?> followUpDate = const Value.absent(),
                Value<String?> message = const Value.absent(),
                Value<String?> followUpNotes = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> assignedTo = const Value.absent(),
                Value<String?> assignedToName = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                required LocalSyncStatus syncStatus,
                Value<DateTime?> lastSyncedAt = const Value.absent(),
              }) => LocalEnquiriesCompanion.insert(
                localId: localId,
                cloudId: cloudId,
                legacyId: legacyId,
                studentName: studentName,
                parentName: parentName,
                phone: phone,
                alternatePhone: alternatePhone,
                email: email,
                dob: dob,
                interestedCourseId: interestedCourseId,
                interestedCourseName: interestedCourseName,
                interestedBatchId: interestedBatchId,
                interestedBatchName: interestedBatchName,
                currentClass: currentClass,
                schoolName: schoolName,
                source: source,
                enquiryStatus: enquiryStatus,
                followUpDate: followUpDate,
                message: message,
                followUpNotes: followUpNotes,
                notes: notes,
                assignedTo: assignedTo,
                assignedToName: assignedToName,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                lastSyncedAt: lastSyncedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalEnquiriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalEnquiriesTable,
      LocalEnquiry,
      $$LocalEnquiriesTableFilterComposer,
      $$LocalEnquiriesTableOrderingComposer,
      $$LocalEnquiriesTableAnnotationComposer,
      $$LocalEnquiriesTableCreateCompanionBuilder,
      $$LocalEnquiriesTableUpdateCompanionBuilder,
      (
        LocalEnquiry,
        BaseReferences<_$AppDatabase, $LocalEnquiriesTable, LocalEnquiry>,
      ),
      LocalEnquiry,
      PrefetchHooks Function()
    >;
typedef $$LocalAttendancesTableCreateCompanionBuilder =
    LocalAttendancesCompanion Function({
      Value<int> localId,
      Value<String?> cloudId,
      required String attendanceKey,
      required String studentId,
      required String studentName,
      required String dateKey,
      required DateTime attendanceDate,
      Value<String?> batchId,
      Value<String?> batchName,
      Value<String?> courseId,
      Value<String?> courseName,
      required String status,
      Value<String?> markedBy,
      Value<String?> markedByName,
      Value<DateTime?> createdAt,
      Value<DateTime?> updatedAt,
      Value<DateTime?> deletedAt,
      required LocalSyncStatus syncStatus,
      Value<DateTime?> lastSyncedAt,
    });
typedef $$LocalAttendancesTableUpdateCompanionBuilder =
    LocalAttendancesCompanion Function({
      Value<int> localId,
      Value<String?> cloudId,
      Value<String> attendanceKey,
      Value<String> studentId,
      Value<String> studentName,
      Value<String> dateKey,
      Value<DateTime> attendanceDate,
      Value<String?> batchId,
      Value<String?> batchName,
      Value<String?> courseId,
      Value<String?> courseName,
      Value<String> status,
      Value<String?> markedBy,
      Value<String?> markedByName,
      Value<DateTime?> createdAt,
      Value<DateTime?> updatedAt,
      Value<DateTime?> deletedAt,
      Value<LocalSyncStatus> syncStatus,
      Value<DateTime?> lastSyncedAt,
    });

class $$LocalAttendancesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalAttendancesTable> {
  $$LocalAttendancesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cloudId => $composableBuilder(
    column: $table.cloudId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get attendanceKey => $composableBuilder(
    column: $table.attendanceKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get studentName => $composableBuilder(
    column: $table.studentName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dateKey => $composableBuilder(
    column: $table.dateKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get attendanceDate => $composableBuilder(
    column: $table.attendanceDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get batchName => $composableBuilder(
    column: $table.batchName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get courseId => $composableBuilder(
    column: $table.courseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get courseName => $composableBuilder(
    column: $table.courseName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get markedBy => $composableBuilder(
    column: $table.markedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get markedByName => $composableBuilder(
    column: $table.markedByName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<LocalSyncStatus, LocalSyncStatus, String>
  get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalAttendancesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalAttendancesTable> {
  $$LocalAttendancesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cloudId => $composableBuilder(
    column: $table.cloudId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get attendanceKey => $composableBuilder(
    column: $table.attendanceKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get studentName => $composableBuilder(
    column: $table.studentName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dateKey => $composableBuilder(
    column: $table.dateKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get attendanceDate => $composableBuilder(
    column: $table.attendanceDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get batchName => $composableBuilder(
    column: $table.batchName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get courseId => $composableBuilder(
    column: $table.courseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get courseName => $composableBuilder(
    column: $table.courseName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get markedBy => $composableBuilder(
    column: $table.markedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get markedByName => $composableBuilder(
    column: $table.markedByName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalAttendancesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalAttendancesTable> {
  $$LocalAttendancesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<String> get cloudId =>
      $composableBuilder(column: $table.cloudId, builder: (column) => column);

  GeneratedColumn<String> get attendanceKey => $composableBuilder(
    column: $table.attendanceKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get studentId =>
      $composableBuilder(column: $table.studentId, builder: (column) => column);

  GeneratedColumn<String> get studentName => $composableBuilder(
    column: $table.studentName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dateKey =>
      $composableBuilder(column: $table.dateKey, builder: (column) => column);

  GeneratedColumn<DateTime> get attendanceDate => $composableBuilder(
    column: $table.attendanceDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get batchId =>
      $composableBuilder(column: $table.batchId, builder: (column) => column);

  GeneratedColumn<String> get batchName =>
      $composableBuilder(column: $table.batchName, builder: (column) => column);

  GeneratedColumn<String> get courseId =>
      $composableBuilder(column: $table.courseId, builder: (column) => column);

  GeneratedColumn<String> get courseName => $composableBuilder(
    column: $table.courseName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get markedBy =>
      $composableBuilder(column: $table.markedBy, builder: (column) => column);

  GeneratedColumn<String> get markedByName => $composableBuilder(
    column: $table.markedByName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LocalSyncStatus, String> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );
}

class $$LocalAttendancesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalAttendancesTable,
          LocalAttendance,
          $$LocalAttendancesTableFilterComposer,
          $$LocalAttendancesTableOrderingComposer,
          $$LocalAttendancesTableAnnotationComposer,
          $$LocalAttendancesTableCreateCompanionBuilder,
          $$LocalAttendancesTableUpdateCompanionBuilder,
          (
            LocalAttendance,
            BaseReferences<
              _$AppDatabase,
              $LocalAttendancesTable,
              LocalAttendance
            >,
          ),
          LocalAttendance,
          PrefetchHooks Function()
        > {
  $$LocalAttendancesTableTableManager(
    _$AppDatabase db,
    $LocalAttendancesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalAttendancesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalAttendancesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalAttendancesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> localId = const Value.absent(),
                Value<String?> cloudId = const Value.absent(),
                Value<String> attendanceKey = const Value.absent(),
                Value<String> studentId = const Value.absent(),
                Value<String> studentName = const Value.absent(),
                Value<String> dateKey = const Value.absent(),
                Value<DateTime> attendanceDate = const Value.absent(),
                Value<String?> batchId = const Value.absent(),
                Value<String?> batchName = const Value.absent(),
                Value<String?> courseId = const Value.absent(),
                Value<String?> courseName = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> markedBy = const Value.absent(),
                Value<String?> markedByName = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<LocalSyncStatus> syncStatus = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
              }) => LocalAttendancesCompanion(
                localId: localId,
                cloudId: cloudId,
                attendanceKey: attendanceKey,
                studentId: studentId,
                studentName: studentName,
                dateKey: dateKey,
                attendanceDate: attendanceDate,
                batchId: batchId,
                batchName: batchName,
                courseId: courseId,
                courseName: courseName,
                status: status,
                markedBy: markedBy,
                markedByName: markedByName,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                lastSyncedAt: lastSyncedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> localId = const Value.absent(),
                Value<String?> cloudId = const Value.absent(),
                required String attendanceKey,
                required String studentId,
                required String studentName,
                required String dateKey,
                required DateTime attendanceDate,
                Value<String?> batchId = const Value.absent(),
                Value<String?> batchName = const Value.absent(),
                Value<String?> courseId = const Value.absent(),
                Value<String?> courseName = const Value.absent(),
                required String status,
                Value<String?> markedBy = const Value.absent(),
                Value<String?> markedByName = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                required LocalSyncStatus syncStatus,
                Value<DateTime?> lastSyncedAt = const Value.absent(),
              }) => LocalAttendancesCompanion.insert(
                localId: localId,
                cloudId: cloudId,
                attendanceKey: attendanceKey,
                studentId: studentId,
                studentName: studentName,
                dateKey: dateKey,
                attendanceDate: attendanceDate,
                batchId: batchId,
                batchName: batchName,
                courseId: courseId,
                courseName: courseName,
                status: status,
                markedBy: markedBy,
                markedByName: markedByName,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                lastSyncedAt: lastSyncedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalAttendancesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalAttendancesTable,
      LocalAttendance,
      $$LocalAttendancesTableFilterComposer,
      $$LocalAttendancesTableOrderingComposer,
      $$LocalAttendancesTableAnnotationComposer,
      $$LocalAttendancesTableCreateCompanionBuilder,
      $$LocalAttendancesTableUpdateCompanionBuilder,
      (
        LocalAttendance,
        BaseReferences<_$AppDatabase, $LocalAttendancesTable, LocalAttendance>,
      ),
      LocalAttendance,
      PrefetchHooks Function()
    >;
typedef $$SyncQueueTableCreateCompanionBuilder =
    SyncQueueCompanion Function({
      Value<int> id,
      required String operationId,
      required SyncEntityType entityType,
      required String entityId,
      required SyncOperationType operationType,
      Value<String?> payloadJson,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> retryCount,
      Value<DateTime?> nextRetryAt,
      required SyncOperationStatus status,
      Value<String?> lastError,
    });
typedef $$SyncQueueTableUpdateCompanionBuilder =
    SyncQueueCompanion Function({
      Value<int> id,
      Value<String> operationId,
      Value<SyncEntityType> entityType,
      Value<String> entityId,
      Value<SyncOperationType> operationType,
      Value<String?> payloadJson,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> retryCount,
      Value<DateTime?> nextRetryAt,
      Value<SyncOperationStatus> status,
      Value<String?> lastError,
    });

class $$SyncQueueTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operationId => $composableBuilder(
    column: $table.operationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncEntityType, SyncEntityType, String>
  get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncOperationType, SyncOperationType, String>
  get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextRetryAt => $composableBuilder(
    column: $table.nextRetryAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    SyncOperationStatus,
    SyncOperationStatus,
    String
  >
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operationId => $composableBuilder(
    column: $table.operationId,
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

  ColumnOrderings<String> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextRetryAt => $composableBuilder(
    column: $table.nextRetryAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get operationId => $composableBuilder(
    column: $table.operationId,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<SyncEntityType, String> get entityType =>
      $composableBuilder(
        column: $table.entityType,
        builder: (column) => column,
      );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncOperationType, String>
  get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get nextRetryAt => $composableBuilder(
    column: $table.nextRetryAt,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<SyncOperationStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);
}

class $$SyncQueueTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncQueueTable,
          SyncQueueData,
          $$SyncQueueTableFilterComposer,
          $$SyncQueueTableOrderingComposer,
          $$SyncQueueTableAnnotationComposer,
          $$SyncQueueTableCreateCompanionBuilder,
          $$SyncQueueTableUpdateCompanionBuilder,
          (
            SyncQueueData,
            BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueData>,
          ),
          SyncQueueData,
          PrefetchHooks Function()
        > {
  $$SyncQueueTableTableManager(_$AppDatabase db, $SyncQueueTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> operationId = const Value.absent(),
                Value<SyncEntityType> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<SyncOperationType> operationType = const Value.absent(),
                Value<String?> payloadJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<DateTime?> nextRetryAt = const Value.absent(),
                Value<SyncOperationStatus> status = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
              }) => SyncQueueCompanion(
                id: id,
                operationId: operationId,
                entityType: entityType,
                entityId: entityId,
                operationType: operationType,
                payloadJson: payloadJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                retryCount: retryCount,
                nextRetryAt: nextRetryAt,
                status: status,
                lastError: lastError,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String operationId,
                required SyncEntityType entityType,
                required String entityId,
                required SyncOperationType operationType,
                Value<String?> payloadJson = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> retryCount = const Value.absent(),
                Value<DateTime?> nextRetryAt = const Value.absent(),
                required SyncOperationStatus status,
                Value<String?> lastError = const Value.absent(),
              }) => SyncQueueCompanion.insert(
                id: id,
                operationId: operationId,
                entityType: entityType,
                entityId: entityId,
                operationType: operationType,
                payloadJson: payloadJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                retryCount: retryCount,
                nextRetryAt: nextRetryAt,
                status: status,
                lastError: lastError,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncQueueTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncQueueTable,
      SyncQueueData,
      $$SyncQueueTableFilterComposer,
      $$SyncQueueTableOrderingComposer,
      $$SyncQueueTableAnnotationComposer,
      $$SyncQueueTableCreateCompanionBuilder,
      $$SyncQueueTableUpdateCompanionBuilder,
      (
        SyncQueueData,
        BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueData>,
      ),
      SyncQueueData,
      PrefetchHooks Function()
    >;
typedef $$SyncMetadataTableCreateCompanionBuilder =
    SyncMetadataCompanion Function({
      required SyncEntityType entityType,
      Value<DateTime?> lastPullAt,
      Value<DateTime?> lastSuccessfulSyncAt,
      Value<String?> lastError,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$SyncMetadataTableUpdateCompanionBuilder =
    SyncMetadataCompanion Function({
      Value<SyncEntityType> entityType,
      Value<DateTime?> lastPullAt,
      Value<DateTime?> lastSuccessfulSyncAt,
      Value<String?> lastError,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$SyncMetadataTableFilterComposer
    extends Composer<_$AppDatabase, $SyncMetadataTable> {
  $$SyncMetadataTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<SyncEntityType, SyncEntityType, String>
  get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get lastPullAt => $composableBuilder(
    column: $table.lastPullAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSuccessfulSyncAt => $composableBuilder(
    column: $table.lastSuccessfulSyncAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncMetadataTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncMetadataTable> {
  $$SyncMetadataTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastPullAt => $composableBuilder(
    column: $table.lastPullAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSuccessfulSyncAt => $composableBuilder(
    column: $table.lastSuccessfulSyncAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncMetadataTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncMetadataTable> {
  $$SyncMetadataTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<SyncEntityType, String> get entityType =>
      $composableBuilder(
        column: $table.entityType,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get lastPullAt => $composableBuilder(
    column: $table.lastPullAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSuccessfulSyncAt => $composableBuilder(
    column: $table.lastSuccessfulSyncAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SyncMetadataTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncMetadataTable,
          SyncMetadataData,
          $$SyncMetadataTableFilterComposer,
          $$SyncMetadataTableOrderingComposer,
          $$SyncMetadataTableAnnotationComposer,
          $$SyncMetadataTableCreateCompanionBuilder,
          $$SyncMetadataTableUpdateCompanionBuilder,
          (
            SyncMetadataData,
            BaseReferences<_$AppDatabase, $SyncMetadataTable, SyncMetadataData>,
          ),
          SyncMetadataData,
          PrefetchHooks Function()
        > {
  $$SyncMetadataTableTableManager(_$AppDatabase db, $SyncMetadataTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncMetadataTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncMetadataTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncMetadataTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<SyncEntityType> entityType = const Value.absent(),
                Value<DateTime?> lastPullAt = const Value.absent(),
                Value<DateTime?> lastSuccessfulSyncAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncMetadataCompanion(
                entityType: entityType,
                lastPullAt: lastPullAt,
                lastSuccessfulSyncAt: lastSuccessfulSyncAt,
                lastError: lastError,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required SyncEntityType entityType,
                Value<DateTime?> lastPullAt = const Value.absent(),
                Value<DateTime?> lastSuccessfulSyncAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => SyncMetadataCompanion.insert(
                entityType: entityType,
                lastPullAt: lastPullAt,
                lastSuccessfulSyncAt: lastSuccessfulSyncAt,
                lastError: lastError,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncMetadataTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncMetadataTable,
      SyncMetadataData,
      $$SyncMetadataTableFilterComposer,
      $$SyncMetadataTableOrderingComposer,
      $$SyncMetadataTableAnnotationComposer,
      $$SyncMetadataTableCreateCompanionBuilder,
      $$SyncMetadataTableUpdateCompanionBuilder,
      (
        SyncMetadataData,
        BaseReferences<_$AppDatabase, $SyncMetadataTable, SyncMetadataData>,
      ),
      SyncMetadataData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocalStudentsTableTableManager get localStudents =>
      $$LocalStudentsTableTableManager(_db, _db.localStudents);
  $$LocalCoursesTableTableManager get localCourses =>
      $$LocalCoursesTableTableManager(_db, _db.localCourses);
  $$LocalBatchesTableTableManager get localBatches =>
      $$LocalBatchesTableTableManager(_db, _db.localBatches);
  $$LocalEnquiriesTableTableManager get localEnquiries =>
      $$LocalEnquiriesTableTableManager(_db, _db.localEnquiries);
  $$LocalAttendancesTableTableManager get localAttendances =>
      $$LocalAttendancesTableTableManager(_db, _db.localAttendances);
  $$SyncQueueTableTableManager get syncQueue =>
      $$SyncQueueTableTableManager(_db, _db.syncQueue);
  $$SyncMetadataTableTableManager get syncMetadata =>
      $$SyncMetadataTableTableManager(_db, _db.syncMetadata);
}

mixin _$StudentsDaoMixin on DatabaseAccessor<AppDatabase> {
  $LocalStudentsTable get localStudents => attachedDatabase.localStudents;
  StudentsDaoManager get managers => StudentsDaoManager(this);
}

class StudentsDaoManager {
  final _$StudentsDaoMixin _db;
  StudentsDaoManager(this._db);
  $$LocalStudentsTableTableManager get localStudents =>
      $$LocalStudentsTableTableManager(_db.attachedDatabase, _db.localStudents);
}

mixin _$CoursesDaoMixin on DatabaseAccessor<AppDatabase> {
  $LocalCoursesTable get localCourses => attachedDatabase.localCourses;
  CoursesDaoManager get managers => CoursesDaoManager(this);
}

class CoursesDaoManager {
  final _$CoursesDaoMixin _db;
  CoursesDaoManager(this._db);
  $$LocalCoursesTableTableManager get localCourses =>
      $$LocalCoursesTableTableManager(_db.attachedDatabase, _db.localCourses);
}

mixin _$BatchesDaoMixin on DatabaseAccessor<AppDatabase> {
  $LocalBatchesTable get localBatches => attachedDatabase.localBatches;
  BatchesDaoManager get managers => BatchesDaoManager(this);
}

class BatchesDaoManager {
  final _$BatchesDaoMixin _db;
  BatchesDaoManager(this._db);
  $$LocalBatchesTableTableManager get localBatches =>
      $$LocalBatchesTableTableManager(_db.attachedDatabase, _db.localBatches);
}

mixin _$EnquiriesDaoMixin on DatabaseAccessor<AppDatabase> {
  $LocalEnquiriesTable get localEnquiries => attachedDatabase.localEnquiries;
  EnquiriesDaoManager get managers => EnquiriesDaoManager(this);
}

class EnquiriesDaoManager {
  final _$EnquiriesDaoMixin _db;
  EnquiriesDaoManager(this._db);
  $$LocalEnquiriesTableTableManager get localEnquiries =>
      $$LocalEnquiriesTableTableManager(
        _db.attachedDatabase,
        _db.localEnquiries,
      );
}

mixin _$AttendanceDaoMixin on DatabaseAccessor<AppDatabase> {
  $LocalAttendancesTable get localAttendances =>
      attachedDatabase.localAttendances;
  AttendanceDaoManager get managers => AttendanceDaoManager(this);
}

class AttendanceDaoManager {
  final _$AttendanceDaoMixin _db;
  AttendanceDaoManager(this._db);
  $$LocalAttendancesTableTableManager get localAttendances =>
      $$LocalAttendancesTableTableManager(
        _db.attachedDatabase,
        _db.localAttendances,
      );
}

mixin _$SyncQueueDaoMixin on DatabaseAccessor<AppDatabase> {
  $SyncQueueTable get syncQueue => attachedDatabase.syncQueue;
  SyncQueueDaoManager get managers => SyncQueueDaoManager(this);
}

class SyncQueueDaoManager {
  final _$SyncQueueDaoMixin _db;
  SyncQueueDaoManager(this._db);
  $$SyncQueueTableTableManager get syncQueue =>
      $$SyncQueueTableTableManager(_db.attachedDatabase, _db.syncQueue);
}
