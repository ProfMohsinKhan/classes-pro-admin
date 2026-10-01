import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _loginIdController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _rememberMe = true;
  bool _isLoading = false;
  bool _isAutoLoggingIn = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initSavedCredentials();
  }

  @override
  void dispose() {
    _loginIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _initSavedCredentials() async {
    final creds = await AuthService.instance.loadSavedCredentials();
    if (!mounted) return;

    setState(() {
      _rememberMe = creds.rememberMe;
      if (creds.loginId != null && creds.loginId!.isNotEmpty) {
        _loginIdController.text = creds.loginId!;
      }
      if (creds.password != null && creds.password!.isNotEmpty) {
        _passwordController.text = creds.password!;
      }
    });

    if (creds.justLoggedOut) {
      await AuthService.instance.clearJustLoggedOutFlag();
      return;
    }

    // Auto-login if rememberMe is enabled and credentials are saved
    if (_rememberMe &&
        _loginIdController.text.trim().isNotEmpty &&
        _passwordController.text.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _performSignIn(isAutoLogin: true);
        }
      });
    }
  }

  Future<void> _performSignIn({bool isAutoLogin = false}) async {
    FocusScope.of(context).unfocus();

    if (!isAutoLogin && !_formKey.currentState!.validate()) return;

    final loginId = _loginIdController.text.trim();
    final password = _passwordController.text;

    if (loginId.isEmpty || password.isEmpty) return;

    setState(() {
      _isLoading = true;
      _isAutoLoggingIn = isAutoLogin;
      _errorMessage = null;
    });

    try {
      await AuthService.instance.signInWithIdentifier(
        identifier: loginId,
        password: password,
      );

      // Persist or clear credentials based on Remember Me preference
      await AuthService.instance.saveSavedCredentials(
        loginId: loginId,
        password: password,
        rememberMe: _rememberMe,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = _friendlyAuthError(e);
        _isAutoLoggingIn = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Something went wrong. Please check your details.';
        _isAutoLoggingIn = false;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _cancelAutoLogin() {
    setState(() {
      _isAutoLoggingIn = false;
      _isLoading = false;
    });
  }

  String _friendlyAuthError(FirebaseAuthException error) {
    switch (error.code) {
      case 'user-not-found':
      case 'invalid-credential':
      case 'wrong-password':
        return 'Login ID or password is incorrect.';
      case 'invalid-email':
        return 'Please enter a valid email or contact number.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact Admin.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      case 'too-many-requests':
        return 'Too many login attempts. Please wait a moment and try again.';
      default:
        return 'Login failed. Please verify your credentials and try again.';
    }
  }

  void _showForgotPasswordSheet() {
    final resetEmailController = TextEditingController(
      text: _loginIdController.text.contains('@')
          ? _loginIdController.text.trim()
          : '',
    );
    bool isSending = false;
    String? resetError;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppTheme.border,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.primarySoft,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.lock_reset_rounded,
                          color: AppTheme.primary,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Reset Password',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.text,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Enter your registered email address',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: resetEmailController,
                    keyboardType: TextInputType.emailAddress,
                    autofocus: true,
                    style: const TextStyle(color: AppTheme.text),
                    decoration: InputDecoration(
                      labelText: 'Registered Email',
                      hintText: 'e.g. yourname@gmail.com',
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                        color: AppTheme.muted,
                        size: 20,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppTheme.border),
                      ),
                    ),
                  ),
                  if (resetError != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      resetError!,
                      style: const TextStyle(
                        color: AppTheme.danger,
                        fontSize: 13,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isSending
                          ? null
                          : () async {
                              final email = resetEmailController.text.trim();
                              if (email.isEmpty || !email.contains('@')) {
                                setSheetState(() {
                                  resetError =
                                      'Please enter a valid email address.';
                                });
                                return;
                              }

                              setSheetState(() {
                                isSending = true;
                                resetError = null;
                              });

                              final messenger = ScaffoldMessenger.of(context);
                              try {
                                await UserService.instance
                                    .sendPasswordResetEmail(email);
                                if (!context.mounted) return;
                                Navigator.pop(sheetContext);
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Password reset email sent to $email. Please check your inbox.',
                                    ),
                                    backgroundColor: AppTheme.success,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              } catch (e) {

                                setSheetState(() {
                                  isSending = false;
                                  resetError =
                                      'Could not send reset email. Verify email and try again.';
                                });
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: isSending
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Send Reset Link',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // Background ambient gradient layer
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFEFF6FF), // Soft primary blue tint
                    Color(0xFFF8FAFC),
                    Color(0xFFF1F5F9),
                  ],
                ),
              ),
            ),
          ),

          // Decorative subtle ambient glow at top
          Positioned(
            top: -90,
            left: -50,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primary.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF38BDF8).withValues(alpha: 0.07),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 28,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildBrandHeader(),
                      const SizedBox(height: 28),
                      _buildMainCard(),
                      const SizedBox(height: 24),
                      _buildFooterNote(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandHeader() {
    return Column(
      children: [
        // Real Mak Tutorials Logo
        Container(
          width: 90,
          height: 90,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppTheme.border,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.14),
                blurRadius: 26,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Image.asset(
            'assets/icon/logo.png',
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Mak Tutorials',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppTheme.text,
            fontSize: 32,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.primarySoft,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.primary.withValues(alpha: 0.18),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.verified_user_rounded,
                color: AppTheme.primary,
                size: 15,
              ),
              SizedBox(width: 6),
              Text(
                'Admin & Student Portal',
                style: TextStyle(
                  color: AppTheme.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMainCard() {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.06),
            blurRadius: 32,
            offset: const Offset(0, 14),
          ),
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Sign In',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppTheme.text,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Enter your credentials to access your dashboard',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.muted,
              ),
            ),
            const SizedBox(height: 22),

            // Auto-login active notice banner
            if (_isAutoLoggingIn) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primarySoft,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.primary.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Signing you in automatically...',
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: _cancelAutoLogin,
                      borderRadius: BorderRadius.circular(6),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: AppTheme.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            _buildLoginIdField(),
            const SizedBox(height: 16),
            _buildPasswordField(),
            const SizedBox(height: 12),
            _buildOptionsRow(),

            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              _buildErrorBox(_errorMessage!),
            ],

            const SizedBox(height: 22),
            _buildLoginButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginIdField() {
    return TextFormField(
      controller: _loginIdController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autocorrect: false,
      enabled: !_isLoading,
      style: const TextStyle(
        color: AppTheme.text,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      validator: (value) {
        final loginId = value?.trim() ?? '';
        if (loginId.isEmpty) return 'Email or Contact Number is required';
        if (loginId.contains('@') && !loginId.contains('.')) {
          return 'Enter a valid email address';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: 'Email or Student Contact Number',
        hintText: 'e.g. admin@gmail.com or 9876543210',
        prefixIcon: Container(
          margin: const EdgeInsets.only(left: 12, right: 10),
          child: const Icon(
            Icons.person_outline_rounded,
            color: AppTheme.primary,
            size: 22,
          ),
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 44,
          minHeight: 44,
        ),
        suffixIcon: _loginIdController.text.isNotEmpty && !_isLoading
            ? IconButton(
                icon: const Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: AppTheme.mutedLight,
                ),
                onPressed: () {
                  setState(() => _loginIdController.clear());
                },
              )
            : null,
      ),
      onChanged: (_) {
        if (mounted) setState(() {});
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.done,
      enabled: !_isLoading,
      onFieldSubmitted: (_) => _isLoading ? null : _performSignIn(),
      style: const TextStyle(
        color: AppTheme.text,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      validator: (value) {
        if ((value ?? '').isEmpty) return 'Password is required';
        if ((value ?? '').length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: 'Password',
        hintText: 'Enter your password',
        prefixIcon: Container(
          margin: const EdgeInsets.only(left: 12, right: 10),
          child: const Icon(
            Icons.lock_outline_rounded,
            color: AppTheme.primary,
            size: 22,
          ),
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 44,
          minHeight: 44,
        ),
        suffixIcon: IconButton(
          onPressed: () {
            setState(() => _obscurePassword = !_obscurePassword);
          },
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: AppTheme.muted,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildOptionsRow() {
    return Row(
      children: [
        InkWell(
          onTap: _isLoading
              ? null
              : () {
                  setState(() => _rememberMe = !_rememberMe);
                },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 22,
                  height: 22,
                  child: Checkbox(
                    value: _rememberMe,
                    activeColor: AppTheme.primary,
                    checkColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    side: const BorderSide(color: AppTheme.border, width: 1.5),
                    visualDensity: VisualDensity.compact,
                    onChanged: _isLoading
                        ? null
                        : (value) =>
                            setState(() => _rememberMe = value ?? false),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Remember me',
                  style: TextStyle(
                    color: AppTheme.text,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const Spacer(),
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: AppTheme.primary,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            minimumSize: const Size(0, 36),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          onPressed: _isLoading ? null : _showForgotPasswordSheet,
          child: const Text(
            'Forgot password?',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorBox(String message) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.dangerSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppTheme.danger.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppTheme.danger,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFFB91C1C),
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: _isLoading
              ? [
                  AppTheme.primary.withValues(alpha: 0.65),
                  AppTheme.primary.withValues(alpha: 0.65),
                ]
              : const [
                  Color(0xFF2563EB),
                  Color(0xFF1D4ED8),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: _isLoading
            ? null
            : [
                BoxShadow(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : () => _performSignIn(),
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: _isLoading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _isAutoLoggingIn ? 'Signing In...' : 'Authenticating...',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Sign In',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 19,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooterNote() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.support_agent_rounded,
              size: 16,
              color: AppTheme.mutedLight,
            ),
            const SizedBox(width: 6),
            const Text(
              'Need an account? Contact Admin',
              style: TextStyle(
                color: AppTheme.muted,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_rounded,
              size: 13,
              color: AppTheme.mutedLight,
            ),
            const SizedBox(width: 5),
            const Text(
              '256-bit Secure Session Persistence',
              style: TextStyle(
                color: AppTheme.mutedLight,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
