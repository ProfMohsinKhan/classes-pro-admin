import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../models/app_user_model.dart';
import '../models/institute_settings_model.dart';
import '../services/institute_settings_service.dart';
import '../services/user_service.dart';
import '../theme/app_theme.dart';
import 'access_denied_screen.dart';

class InstituteSettingsScreen extends StatefulWidget {
  const InstituteSettingsScreen({super.key});

  @override
  State<InstituteSettingsScreen> createState() =>
      _InstituteSettingsScreenState();
}

class _InstituteSettingsScreenState extends State<InstituteSettingsScreen> {
  late final Stream<AppUserModel?> _profileStream;
  final _service = InstituteSettingsService.instance;

  final _instituteName = TextEditingController();
  final _ownerName = TextEditingController();
  final _address = TextEditingController();
  final _phone = TextEditingController();
  final _whatsapp = TextEditingController();
  final _email = TextEditingController();
  final _website = TextEditingController();
  final _logoUrl = TextEditingController();
  final _signatureUrl = TextEditingController();
  final _countryCode = TextEditingController();
  final _academicYear = TextEditingController();
  final _receiptPrefix = TextEditingController();
  final _receiptFooter = TextEditingController();
  final _reportFooter = TextEditingController();
  final _currencySymbol = TextEditingController();
  final _timezone = TextEditingController();
  final _feeReminderDays = TextEditingController();
  final _birthdayReminderDays = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isUploadingLogo = false;
  bool _isUploadingSignature = false;
  String _themeMode = 'light';
  String _primaryColorName = 'blue';
  InstituteSettingsModel? _loadedSettings;

  static const String _cloudName = 'dxgqjsuny';
  static const String _uploadPreset = 'student_pics';

  @override
  void initState() {
    super.initState();
    _profileStream = UserService.instance.streamCurrentUserProfile();
    _loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppUserModel?>(
      stream: _profileStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppTheme.background,
            body: Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            ),
          );
        }
        final appUser = snapshot.data;
        if (appUser == null || !appUser.canManageInstituteSettings) {
          return const AccessDeniedScreen();
        }

        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            title: const Text(
              'Institute Settings',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          body: SafeArea(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppTheme.primary),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _Header(),
                        const SizedBox(height: 16),
                        _Section(
                          title: 'Institute Profile',
                          children: [
                            _Field('Institute Name', _instituteName),
                            _Field('Owner/Admin Name', _ownerName),
                            _Field(
                              'Phone',
                              _phone,
                              keyboardType: TextInputType.phone,
                            ),
                            _Field(
                              'WhatsApp Number',
                              _whatsapp,
                              keyboardType: TextInputType.phone,
                            ),
                            _Field(
                              'Email',
                              _email,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            _Field('Website', _website),
                            _ImageUploadField(
                              label: 'Receipt Logo',
                              url: _logoUrl.text,
                              isUploading: _isUploadingLogo,
                              onUpload: () => _pickAndUploadImage(
                                target: _BrandingUpload.logo,
                              ),
                              onClear: () => setState(() => _logoUrl.clear()),
                            ),
                            _ImageUploadField(
                              label: 'Authorized Signature',
                              url: _signatureUrl.text,
                              isUploading: _isUploadingSignature,
                              onUpload: () => _pickAndUploadImage(
                                target: _BrandingUpload.signature,
                              ),
                              onClear: () =>
                                  setState(() => _signatureUrl.clear()),
                            ),
                            _Field('Address', _address, maxLines: 3),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _Section(
                          title: 'Receipt & Report Settings',
                          children: [
                            _Field('Receipt Prefix', _receiptPrefix),
                            _Field(
                              'Receipt Footer',
                              _receiptFooter,
                              maxLines: 2,
                            ),
                            _Field('Report Footer', _reportFooter, maxLines: 2),
                            _Field('Currency Symbol', _currencySymbol),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _Section(
                          title: 'Academic Settings',
                          children: [
                            _Field('Academic Year', _academicYear),
                            _Field('Default Country Code', _countryCode),
                            _Field('Timezone', _timezone),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _Section(
                          title: 'Reminder Defaults',
                          children: [
                            _Field(
                              'Fee reminder days before',
                              _feeReminderDays,
                              keyboardType: TextInputType.number,
                            ),
                            _Field(
                              'Birthday reminder days before',
                              _birthdayReminderDays,
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _Section(
                          title: 'App Appearance',
                          children: [
                            DropdownButtonFormField<String>(
                              initialValue: _themeMode,
                              decoration: const InputDecoration(
                                labelText: 'Theme Mode',
                                prefixIcon: Icon(Icons.contrast_rounded),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'light',
                                  child: Text('Light'),
                                ),
                                DropdownMenuItem(
                                  value: 'dark',
                                  child: Text('Dark'),
                                ),
                                DropdownMenuItem(
                                  value: 'system',
                                  child: Text('System'),
                                ),
                              ],
                              onChanged: (value) =>
                                  setState(() => _themeMode = value ?? 'light'),
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              initialValue: _primaryColorName,
                              decoration: const InputDecoration(
                                labelText: 'Primary Color',
                                prefixIcon: Icon(Icons.palette_rounded),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'blue',
                                  child: Text('Blue'),
                                ),
                                DropdownMenuItem(
                                  value: 'green',
                                  child: Text('Green'),
                                ),
                                DropdownMenuItem(
                                  value: 'orange',
                                  child: Text('Orange'),
                                ),
                              ],
                              onChanged: (value) => setState(
                                () => _primaryColorName = value ?? 'blue',
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Theme is stored for future rollout. The app remains stable in light mode for now.',
                              style: TextStyle(color: AppTheme.muted),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton.icon(
                            onPressed: _isSaving ? null : _saveSettings,
                            icon: _isSaving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.save_rounded),
                            label: const Text(
                              'Save Settings',
                              style: TextStyle(fontWeight: FontWeight.w900),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    try {
      final settings = await _service.loadSettings(forceRefresh: true);
      _applySettings(settings);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applySettings(InstituteSettingsModel settings) {
    _loadedSettings = settings;
    _instituteName.text = settings.instituteName;
    _ownerName.text = settings.ownerName;
    _address.text = settings.address;
    _phone.text = settings.phone;
    _whatsapp.text = settings.whatsappNumber;
    _email.text = settings.email;
    _website.text = settings.website;
    _logoUrl.text = settings.logoUrl;
    _signatureUrl.text = settings.signatureUrl;
    _countryCode.text = settings.defaultCountryCode;
    _academicYear.text = settings.academicYear;
    _receiptPrefix.text = settings.receiptPrefix;
    _receiptFooter.text = settings.receiptFooter;
    _reportFooter.text = settings.reportFooter;
    _currencySymbol.text = settings.currencySymbol;
    _timezone.text = settings.timezone;
    _feeReminderDays.text = settings.feeReminderDaysBefore.toString();
    _birthdayReminderDays.text = settings.birthdayReminderDaysBefore.toString();
    _themeMode = settings.themeMode;
    _primaryColorName = settings.primaryColorName;
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);
    try {
      final base = _loadedSettings ?? _service.getDefaultSettings();
      final settings = base.copyWith(
        instituteName: _instituteName.text.trim().isEmpty
            ? 'Mak Tutorials'
            : _instituteName.text.trim(),
        ownerName: _ownerName.text.trim(),
        address: _address.text.trim(),
        phone: _phone.text.trim(),
        whatsappNumber: _whatsapp.text.trim(),
        email: _email.text.trim(),
        website: _website.text.trim(),
        logoUrl: _logoUrl.text.trim(),
        signatureUrl: _signatureUrl.text.trim(),
        defaultCountryCode: _countryCode.text.trim().isEmpty
            ? '91'
            : _countryCode.text.trim(),
        academicYear: _academicYear.text.trim(),
        receiptPrefix: _receiptPrefix.text.trim().isEmpty
            ? 'MT'
            : _receiptPrefix.text.trim(),
        receiptFooter: _receiptFooter.text.trim(),
        reportFooter: _reportFooter.text.trim(),
        currencySymbol: _currencySymbol.text.trim().isEmpty
            ? 'Rs'
            : _currencySymbol.text.trim(),
        timezone: _timezone.text.trim().isEmpty
            ? 'Asia/Kolkata'
            : _timezone.text.trim(),
        themeMode: _themeMode,
        primaryColorName: _primaryColorName,
        feeReminderDaysBefore: int.tryParse(_feeReminderDays.text) ?? 3,
        birthdayReminderDaysBefore:
            int.tryParse(_birthdayReminderDays.text) ?? 7,
      );
      await _service.saveSettings(settings);
      _loadedSettings = settings;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Institute settings saved.'),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Settings could not be saved: $e'),
          backgroundColor: AppTheme.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    for (final controller in [
      _instituteName,
      _ownerName,
      _address,
      _phone,
      _whatsapp,
      _email,
      _website,
      _logoUrl,
      _signatureUrl,
      _countryCode,
      _academicYear,
      _receiptPrefix,
      _receiptFooter,
      _reportFooter,
      _currencySymbol,
      _timezone,
      _feeReminderDays,
      _birthdayReminderDays,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickAndUploadImage({required _BrandingUpload target}) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: target == _BrandingUpload.logo ? 85 : 75,
    );
    if (image == null) return;

    setState(() {
      if (target == _BrandingUpload.logo) {
        _isUploadingLogo = true;
      } else {
        _isUploadingSignature = true;
      }
    });

    try {
      final bytes = await image.readAsBytes();
      final request =
          http.MultipartRequest(
              'POST',
              Uri.parse(
                'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
              ),
            )
            ..fields['upload_preset'] = _uploadPreset
            ..files.add(
              http.MultipartFile.fromBytes(
                'file',
                bytes,
                filename: image.name.isEmpty ? 'branding.png' : image.name,
              ),
            );

      final response = await request.send();
      if (response.statusCode != 200) throw Exception('Upload failed');

      final body = await response.stream.bytesToString();
      final data = json.decode(body) as Map<String, dynamic>;
      final uploadedUrl = data['secure_url']?.toString() ?? '';
      if (uploadedUrl.isEmpty) throw Exception('Upload URL missing');

      if (!mounted) return;
      setState(() {
        if (target == _BrandingUpload.logo) {
          _logoUrl.text = uploadedUrl;
        } else {
          _signatureUrl.text = uploadedUrl;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            target == _BrandingUpload.logo
                ? 'Receipt logo uploaded. Save settings to apply.'
                : 'Signature uploaded. Save settings to apply.',
          ),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Upload failed: $e'),
          backgroundColor: AppTheme.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          if (target == _BrandingUpload.logo) {
            _isUploadingLogo = false;
          } else {
            _isUploadingSignature = false;
          }
        });
      }
    }
  }
}

enum _BrandingUpload { logo, signature }

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Institute Settings',
          style: TextStyle(
            color: AppTheme.text,
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 5),
        Text(
          'Branding, receipts, reports and reminder defaults',
          style: TextStyle(color: AppTheme.muted),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.text,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field(
    this.label,
    this.controller, {
    this.keyboardType,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label),
    );
  }
}

class _ImageUploadField extends StatelessWidget {
  const _ImageUploadField({
    required this.label,
    required this.url,
    required this.isUploading,
    required this.onUpload,
    required this.onClear,
  });

  final String label;
  final String url;
  final bool isUploading;
  final VoidCallback onUpload;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final hasImage = url.trim().isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: hasImage
                ? Image.network(
                    url,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.broken_image_rounded),
                  )
                : const Icon(Icons.image_rounded, color: AppTheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppTheme.text,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hasImage ? 'Uploaded' : 'No image selected',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppTheme.muted, fontSize: 12),
                ),
              ],
            ),
          ),
          if (hasImage)
            IconButton(
              tooltip: 'Remove',
              onPressed: isUploading ? null : onClear,
              icon: const Icon(Icons.close_rounded),
            ),
          IconButton(
            tooltip: 'Upload',
            onPressed: isUploading ? null : onUpload,
            icon: isUploading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.cloud_upload_rounded),
          ),
        ],
      ),
    );
  }
}
