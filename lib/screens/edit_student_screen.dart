import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../core/database/database_provider.dart';
import '../core/auth/student_login.dart';
import '../data/repositories/offline_repositories.dart';
import '../models/batch_model.dart';
import '../models/course_model.dart';
import '../models/student_model.dart';
import '../services/user_service.dart';
import '../theme/app_theme.dart';
import 'access_denied_screen.dart';

class EditStudentScreen extends StatefulWidget {
  final StudentModel? student;

  const EditStudentScreen({super.key, this.student});

  @override
  State<EditStudentScreen> createState() => _EditStudentScreenState();
}

class _EditStudentScreenState extends State<EditStudentScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _parentNameController;
  late final TextEditingController _parentPhoneController;
  late final TextEditingController _dobController;
  late final TextEditingController _classController;
  late final TextEditingController _batchController;
  late final TextEditingController _courseController;
  late final TextEditingController _addressController;
  late final TextEditingController _notesController;
  late final TextEditingController _emailController;

  DateTime? _selectedDob;
  String _selectedStatus = 'active';
  String? _currentImageUrl;
  String? _selectedCourseId;
  String? _selectedBatchId;
  List<_LookupOption> _courses = const [];
  List<_LookupOption> _batches = const [];
  late final OfflineStudentsRepository _studentsRepository;
  late final CoursesRepositoryImpl _coursesRepository;
  late final BatchesRepositoryImpl _batchesRepository;
  bool _isSaving = false;
  bool _isUploadingPhoto = false;
  bool _isLoadingLookups = true;

  final String cloudName = "dxgqjsuny";
  final String uploadPreset = "student_pics";

  bool get _isEditing => widget.student != null;

  @override
  void initState() {
    super.initState();
    final database = OfflineDatabaseProvider.instance;
    _studentsRepository = OfflineStudentsRepository(database);
    _coursesRepository = CoursesRepositoryImpl(database);
    _batchesRepository = BatchesRepositoryImpl(database);
    final student = widget.student;
    _selectedDob = student?.dob;
    _selectedStatus = student?.status ?? 'active';
    _currentImageUrl = student?.profilePhoto;

    _nameController = TextEditingController(text: student?.name ?? '');
    _phoneController = TextEditingController(text: student?.phone ?? '');
    _parentNameController = TextEditingController(
      text: student?.parentName ?? student?.guardianName ?? '',
    );
    _parentPhoneController = TextEditingController(
      text: student?.parentPhone ?? student?.guardianPhone ?? '',
    );
    _dobController = TextEditingController(
      text: _selectedDob == null
          ? ''
          : DateFormat('dd MMM yyyy').format(_selectedDob!),
    );
    _classController = TextEditingController(text: student?.className ?? '');
    _batchController = TextEditingController(text: student?.batchName ?? '');
    _courseController = TextEditingController(text: student?.courseName ?? '');
    _selectedCourseId = student?.courseId;
    _selectedBatchId = student?.batchId;
    _addressController = TextEditingController(text: student?.address ?? '');
    _notesController = TextEditingController(text: student?.notes ?? '');
    _emailController = TextEditingController(text: student?.email ?? '');

    _loadCourseAndBatchLookups();
  }

  Future<void> _loadCourseAndBatchLookups() async {
    try {
      final results = await Future.wait([
        _coursesRepository.watchActiveCourses().first,
        _batchesRepository.watchActiveBatches().first,
      ]);

      final courses =
          (results[0] as List<CourseModel>)
              .map(_LookupOption.fromCourseModel)
              .where((option) => option.isActive)
              .toList()
            ..sort((a, b) => a.name.compareTo(b.name));
      final batches =
          (results[1] as List<BatchModel>)
              .map(_LookupOption.fromBatchModel)
              .where((option) => option.isActive)
              .toList()
            ..sort((a, b) => a.name.compareTo(b.name));

      if (!mounted) return;
      setState(() {
        _courses = courses;
        _batches = batches;
        _selectedCourseId = _resolveSelectedLookupId(
          currentId: _selectedCourseId,
          currentName: _courseController.text,
          options: courses,
        );
        _selectedBatchId = _resolveSelectedLookupId(
          currentId: _selectedBatchId,
          currentName: _batchController.text,
          options: batches,
        );
        _isLoadingLookups = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingLookups = false);
    }
  }

  String? _resolveSelectedLookupId({
    required String? currentId,
    required String currentName,
    required List<_LookupOption> options,
  }) {
    if (currentId != null && options.any((option) => option.id == currentId)) {
      return currentId;
    }
    final normalizedName = currentName.trim().toLowerCase();
    if (normalizedName.isEmpty) return null;
    for (final option in options) {
      if (option.name.toLowerCase() == normalizedName) return option.id;
    }
    return null;
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (image == null) return;

    setState(() => _isUploadingPhoto = true);
    try {
      final bytes = await image.readAsBytes();
      final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
      );
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(
          http.MultipartFile.fromBytes(
            'file',
            bytes,
            filename: image.name.isEmpty ? 'profile.jpg' : image.name,
          ),
        );

      final response = await request.send();
      if (response.statusCode != 200) throw Exception('Upload failed');

      final responseData = await response.stream.bytesToString();
      final jsonResult = json.decode(responseData) as Map<String, dynamic>;
      if (!mounted) return;
      setState(() => _currentImageUrl = jsonResult['secure_url']?.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Photo uploaded'),
          backgroundColor: AppTheme.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Upload failed: $e'),
          backgroundColor: AppTheme.danger,
        ),
      );
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  Future<void> _saveStudent() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final selectedCourse = _lookupById(_courses, _selectedCourseId);
      final selectedBatch = _lookupById(_batches, _selectedBatchId);
      final courseName = selectedCourse?.name ?? _courseController.text.trim();
      final batchName = selectedBatch?.name ?? _batchController.text.trim();
      final now = DateTime.now();

      final localStudent = StudentModel(
        id: widget.student?.id ?? '',
        numericId: widget.student?.numericId,
        studentId: widget.student?.studentId ?? '',
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        parentName: _parentNameController.text.trim(),
        parentPhone: _parentPhoneController.text.trim(),
        guardianName: _parentNameController.text.trim(),
        guardianPhone: _parentPhoneController.text.trim(),
        dob: _selectedDob,
        className: _classController.text.trim(),
        previousClass: _classController.text.trim(),
        batchId: selectedBatch?.id ?? _selectedBatchId,
        batchName: batchName,
        courseId: selectedCourse?.id ?? _selectedCourseId,
        courseName: courseName,
        address: _addressController.text.trim(),
        notes: _notesController.text.trim(),
        status: _selectedStatus,
        profilePhoto: _currentImageUrl,
        createdAt: widget.student?.createdAt ?? now,
        updatedAt: now,
      );
      StudentLoginCredentials? studentLogin;
      if (_isEditing) {
        await _studentsRepository.updateStudent(localStudent);
      } else {
        // Student login ID and first password are both the registered contact
        // number. Validate before saving so every newly enrolled student can
        // sign in immediately.
        StudentLogin.contactId(localStudent.primaryPhone);
        final savedStudent = await _studentsRepository.createStudent(
          localStudent,
        );
        await _studentsRepository.requestSync();
        final currentUser = await UserService.instance.getCurrentUserProfile();
        if (currentUser == null) {
          throw StateError('Your session has expired. Please sign in again.');
        }
        studentLogin = await UserService.instance.createStudentLogin(
          CreateStudentLoginInput(
            student: savedStudent,
            createdBy: currentUser,
          ),
        );
      }

      if (!mounted) return;
      if (studentLogin != null) {
        await _showStudentLoginCredentials(studentLogin);
      }
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Student updated successfully'
                : 'Student added and portal login created',
          ),
          backgroundColor: AppTheme.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Save failed: $e'),
          backgroundColor: AppTheme.danger,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  _LookupOption? _lookupById(List<_LookupOption> options, String? id) {
    if (id == null) return null;
    for (final option in options) {
      if (option.id == id) return option;
    }
    return null;
  }

  Future<void> _showStudentLoginCredentials(
    StudentLoginCredentials credentials,
  ) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Student portal login created'),
        content: Text(
          'Login ID: ${credentials.loginId}\n'
          'Temporary password: ${credentials.initialPassword}\n\n'
          'Share this securely with the student. They will be asked to change the password after their first login.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDob() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? DateTime(2010),
      firstDate: DateTime(1980),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primary,
              onPrimary: Colors.white,
              surface: AppTheme.surface,
              onSurface: AppTheme.text,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked == null) return;
    setState(() {
      _selectedDob = picked;
      _dobController.text = DateFormat('dd MMM yyyy').format(picked);
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: UserService.instance.streamCurrentUserProfile(),
      builder: (context, profileSnapshot) {
        if (profileSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppTheme.background,
            body: Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            ),
          );
        }

        final appUser = profileSnapshot.data;
        final allowed = _isEditing
            ? appUser?.canEditStudents == true
            : appUser?.canCreateStudents == true;
        if (!allowed) return const AccessDeniedScreen();

        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            title: Text(
              _isEditing ? 'Edit Student' : 'Add Student',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                border: const Border(top: BorderSide(color: AppTheme.border)),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.text.withValues(alpha: 0.06),
                    blurRadius: 18,
                    offset: const Offset(0, -8),
                  ),
                ],
              ),
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveStudent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.4,
                          ),
                        )
                      : Text(
                          _isEditing ? 'Save Changes' : 'Add Student',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                ),
              ),
            ),
          ),
          body: SafeArea(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _PhotoPicker(
                      imageUrl: _currentImageUrl,
                      isUploading: _isUploadingPhoto,
                      name: _nameController.text,
                      onTap: _isUploadingPhoto ? null : _pickAndUploadImage,
                    ),
                    const SizedBox(height: 20),
                    _section('Basic Info', Icons.person_rounded),
                    _field(
                      'Student Name',
                      _nameController,
                      Icons.badge_rounded,
                      requiredField: true,
                    ),
                    _field(
                      'Student Phone',
                      _phoneController,
                      Icons.phone_rounded,
                      keyboardType: TextInputType.phone,
                    ),
                    _field(
                      'Email',
                      _emailController,
                      Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    _dateField(),
                    _section('Parent Contact', Icons.family_restroom_rounded),
                    _field(
                      'Parent Name',
                      _parentNameController,
                      Icons.person_outline_rounded,
                    ),
                    _field(
                      'Parent Phone',
                      _parentPhoneController,
                      Icons.phone_in_talk_rounded,
                      keyboardType: TextInputType.phone,
                    ),
                    _section('Academic Info', Icons.school_rounded),
                    _field(
                      'Class / Standard',
                      _classController,
                      Icons.class_rounded,
                    ),
                    _lookupDropdown(
                      label: 'Course',
                      icon: Icons.menu_book_rounded,
                      value: _selectedCourseId,
                      options: _courses,
                      fallbackController: _courseController,
                      onChanged: (option) {
                        setState(() {
                          _selectedCourseId = option?.id;
                          _courseController.text = option?.name ?? '';
                          if (_classController.text.trim().isEmpty &&
                              option != null) {
                            _classController.text = option.name;
                          }
                        });
                      },
                    ),
                    _lookupDropdown(
                      label: 'Batch',
                      icon: Icons.groups_rounded,
                      value: _selectedBatchId,
                      options: _batches,
                      fallbackController: _batchController,
                      onChanged: (option) {
                        setState(() {
                          _selectedBatchId = option?.id;
                          _batchController.text = option?.name ?? '';
                        });
                      },
                    ),
                    _section('Other', Icons.notes_rounded),
                    _field(
                      'Address',
                      _addressController,
                      Icons.location_on_outlined,
                      maxLines: 2,
                    ),
                    _field(
                      'Notes',
                      _notesController,
                      Icons.sticky_note_2_outlined,
                      maxLines: 3,
                    ),
                    _statusDropdown(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _section(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 12),
      child: Row(
        children: [
          Container(
            height: 30,
            width: 30,
            decoration: BoxDecoration(
              color: AppTheme.primarySoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.primary, size: 17),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.text,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(child: Divider(color: AppTheme.border)),
        ],
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool requiredField = false,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(
          color: AppTheme.text,
          fontWeight: FontWeight.w700,
        ),
        validator: (value) {
          if (requiredField && (value ?? '').trim().isEmpty) {
            return '$label is required';
          }
          if (label == 'Student Name') {
            final hasContact =
                _phoneController.text.trim().isNotEmpty ||
                _parentPhoneController.text.trim().isNotEmpty;
            if (!hasContact) return 'Add student or parent phone';
          }
          return null;
        },
        decoration: _inputDecoration(label, icon),
      ),
    );
  }

  Widget _dateField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: _dobController,
        readOnly: true,
        onTap: _pickDob,
        style: const TextStyle(
          color: AppTheme.text,
          fontWeight: FontWeight.w700,
        ),
        decoration: _inputDecoration('Date of Birth', Icons.cake_rounded),
      ),
    );
  }

  Widget _lookupDropdown({
    required String label,
    required IconData icon,
    required String? value,
    required List<_LookupOption> options,
    required TextEditingController fallbackController,
    required ValueChanged<_LookupOption?> onChanged,
  }) {
    if (_isLoadingLookups) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.border),
            boxShadow: [
              BoxShadow(
                color: AppTheme.text.withValues(alpha: 0.03),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: AppTheme.muted, size: 20),
              const SizedBox(width: 12),
              Text(
                'Loading $label...',
                style: const TextStyle(color: AppTheme.muted),
              ),
              const Spacer(),
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  color: AppTheme.primary,
                  strokeWidth: 2,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (options.isEmpty) {
      return _field(label, fallbackController, icon);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String?>(
        isExpanded: true,
        key: ValueKey('$label-$value-${options.length}'),
        initialValue: options.any((option) => option.id == value)
            ? value
            : null,
        dropdownColor: AppTheme.surface,
        iconEnabledColor: AppTheme.muted,
        style: const TextStyle(
          color: AppTheme.text,
          fontWeight: FontWeight.w700,
        ),
        decoration: _inputDecoration(label, icon),
        items: [
          DropdownMenuItem<String?>(
            value: null,
            child: Text(
              'Select $label',
              style: const TextStyle(color: AppTheme.muted),
            ),
          ),
          ...options.map(
            (option) => DropdownMenuItem<String?>(
              value: option.id,
              child: Text(
                option.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
        onChanged: (selectedId) {
          onChanged(_lookupById(options, selectedId));
        },
      ),
    );
  }

  Widget _statusDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        isExpanded: true,
        initialValue: _selectedStatus,
        dropdownColor: AppTheme.surface,
        iconEnabledColor: AppTheme.muted,
        style: const TextStyle(
          color: AppTheme.text,
          fontWeight: FontWeight.w700,
        ),
        decoration: _inputDecoration('Status', Icons.toggle_on_rounded),
        items: const [
          DropdownMenuItem(value: 'active', child: Text('Active')),
          DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
        ],
        onChanged: (value) {
          if (value != null) setState(() => _selectedStatus = value);
        },
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        color: AppTheme.muted,
        fontWeight: FontWeight.w600,
      ),
      floatingLabelStyle: const TextStyle(
        color: AppTheme.primary,
        fontWeight: FontWeight.w800,
      ),
      prefixIcon: Icon(icon, color: AppTheme.muted, size: 20),
      filled: true,
      fillColor: AppTheme.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppTheme.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppTheme.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppTheme.primary, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppTheme.danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppTheme.danger, width: 1.4),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _parentNameController.dispose();
    _parentPhoneController.dispose();
    _dobController.dispose();
    _classController.dispose();
    _batchController.dispose();
    _courseController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}

class _PhotoPicker extends StatelessWidget {
  const _PhotoPicker({
    required this.imageUrl,
    required this.isUploading,
    required this.name,
    required this.onTap,
  });

  final String? imageUrl;
  final bool isUploading;
  final String name;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final initial = (name.trim().isEmpty ? 'S' : name.trim()[0]).toUpperCase();
    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.border),
          boxShadow: [
            BoxShadow(
              color: AppTheme.text.withValues(alpha: 0.04),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: onTap,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primarySoft,
                      border: Border.all(color: AppTheme.primary, width: 1.4),
                      image: imageUrl == null
                          ? null
                          : DecorationImage(
                              image: NetworkImage(imageUrl!),
                              fit: BoxFit.cover,
                            ),
                    ),
                    child: imageUrl == null
                        ? Center(
                            child: Text(
                              initial,
                              style: const TextStyle(
                                color: AppTheme.primary,
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          )
                        : null,
                  ),
                  if (isUploading)
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.72),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primary,
                          strokeWidth: 2.4,
                        ),
                      ),
                    ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppTheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Profile Photo',
                    style: TextStyle(
                      color: AppTheme.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Optional image',
                    style: TextStyle(color: AppTheme.muted, height: 1.35),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LookupOption {
  const _LookupOption({
    required this.id,
    required this.name,
    required this.isActive,
    this.numericId,
    this.detail,
  });

  final String id;
  final String name;
  final bool isActive;
  final int? numericId;
  final String? detail;

  String get label => detail == null ? name : '$name ($detail)';

  static _LookupOption fromCourseModel(CourseModel course) {
    return _LookupOption(
      id: course.legacyId ?? course.id,
      numericId: StudentModel.parseInt(course.legacyId),
      name: course.name,
      detail: course.code,
      isActive: course.isActive,
    );
  }

  static _LookupOption fromBatchModel(BatchModel batch) {
    return _LookupOption(
      id: batch.legacyId ?? batch.id,
      numericId: StudentModel.parseInt(batch.legacyId),
      name: batch.name,
      detail: batch.startTime,
      isActive: batch.isActive,
    );
  }
}
