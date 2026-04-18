import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:note_app/core/constants/color_constant.dart';
import 'package:note_app/core/constants/font_constant.dart';
import 'package:note_app/core/constants/properties_constant.dart';
import 'package:note_app/core/data/services/custom_auth_service.dart';
import 'package:note_app/core/presentation/auth/forgot_password_page.dart';
import 'package:note_app/core/presentation/auth/signup_page.dart';
import 'package:note_app/core/presentation/components/form_text_input.dart';
import 'package:note_app/core/presentation/components/toast.dart';
import 'package:note_app/core/presentation/pages/main_page.dart';
import 'package:note_app/core/presentation/widgets/components/toast_helper.dart';
import 'package:note_app/core/theme/app_context_ext.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _authError;
  bool _isLoading = false;

  late final AnimationController _ctrl;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _titleOpacity;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _cardOpacity;
  late final Animation<Offset> _cardSlide;
  late final Animation<double> _field1Opacity;
  late final Animation<Offset> _field1Slide;
  late final Animation<double> _field2Opacity;
  late final Animation<Offset> _field2Slide;
  late final Animation<double> _btnOpacity;
  late final Animation<double> _btnScale;
  late final Animation<double> _footerOpacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));

    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.4, curve: Curves.elasticOut)));
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.25, curve: Curves.easeIn)));

    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.2, 0.45, curve: Curves.easeOut)));
    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.2, 0.45, curve: Curves.easeOutCubic)));

    _cardOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.3, 0.55, curve: Curves.easeOut)));
    _cardSlide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.3, 0.55, curve: Curves.easeOutCubic)));

    _field1Opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.45, 0.65, curve: Curves.easeOut)));
    _field1Slide = Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.45, 0.65, curve: Curves.easeOutCubic)));

    _field2Opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.55, 0.75, curve: Curves.easeOut)));
    _field2Slide = Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.55, 0.75, curve: Curves.easeOutCubic)));

    _btnOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.65, 0.82, curve: Curves.easeOut)));
    _btnScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.65, 0.82, curve: Curves.easeOutBack)));

    _footerOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.78, 1.0, curve: Curves.easeOut)));

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _clearAuthError() {
    if (_authError != null) setState(() => _authError = null);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      // Request iOS notification permission so APNS token is registered before
      // calling getToken(). Errors are silently ignored — FCM token is optional.
      String? fcmToken;
      try {
        await FirebaseMessaging.instance.requestPermission();
        fcmToken = await FirebaseMessaging.instance.getToken();
      } catch (_) {
        // FCM token is best-effort; login proceeds without it.
      }
      final res = await CustomAuthService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fcmToken: fcmToken,
      );
      if (!mounted) return;

      final name = res.name ?? _emailController.text.split('@').first;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainPage()));
      showToast(context, 'Welcome back, $name! 🎉',
          type: ToastType.success, duration: const Duration(seconds: 4),
          icon: Icons.celebration, withHaptic: true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _authError = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
      _formKey.currentState!.validate();
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = context.primaryColor;
    final isDark = context.isDark;
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF111111) : const Color(0xFFF5F8FF),
      body: Stack(
        children: [
          // ── Gradient header background ──────────────────────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            height: size.height * 0.40,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    primary.withValues(alpha: 0.95),
                    primary,
                    Color.alphaBlend(Colors.white.withValues(alpha: 0.12), primary),
                  ],
                ),
              ),
            ),
          ),
          // ── Decorative blobs ────────────────────────────────────────────────
          Positioned(
            top: -size.width * 0.18,
            right: -size.width * 0.08,
            child: _Blob(size: size.width * 0.58, color: Colors.white.withValues(alpha: 0.07)),
          ),
          Positioned(
            top: size.height * 0.04,
            left: -size.width * 0.14,
            child: _Blob(size: size.width * 0.40, color: Colors.white.withValues(alpha: 0.06)),
          ),
          // ── Main content ─────────────────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // Header section
                SizedBox(
                  height: size.height * 0.35,
                  child: Stack(
                    children: [
                      Positioned(
                        top: 4, left: 4,
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Animated logo
                            AnimatedBuilder(
                              animation: _ctrl,
                              builder: (_, __) => FadeTransition(
                                opacity: _logoOpacity,
                                child: ScaleTransition(
                                  scale: _logoScale,
                                  child: Container(
                                    width: 76,
                                    height: 76,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.18),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.white.withValues(alpha: 0.35), width: 2),
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.18),
                                            blurRadius: 24,
                                            offset: const Offset(0, 8)),
                                      ],
                                    ),
                                    child: const Icon(
                                        Icons.note_alt_rounded, color: Colors.white, size: 38),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Animated title
                            AnimatedBuilder(
                              animation: _ctrl,
                              builder: (_, __) => FadeTransition(
                                opacity: _titleOpacity,
                                child: SlideTransition(
                                  position: _titleSlide,
                                  child: Column(
                                    children: [
                                      Text('Welcome Back',
                                          style: AppFonts.heading2.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: -0.5)),
                                      const SizedBox(height: 4),
                                      Text('Sign in to your account',
                                          style: AppFonts.bodyMedium.copyWith(
                                              color: Colors.white.withValues(alpha: 0.78))),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Form card ─────────────────────────────────────────────────
                Expanded(
                  child: AnimatedBuilder(
                    animation: _ctrl,
                    builder: (_, child) => FadeTransition(
                      opacity: _cardOpacity,
                      child: SlideTransition(position: _cardSlide, child: child),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(32),
                          topRight: Radius.circular(32),
                        ),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.07),
                              blurRadius: 24,
                              offset: const Offset(0, -4)),
                        ],
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Email field
                              AnimatedBuilder(
                                animation: _ctrl,
                                builder: (_, child) => FadeTransition(
                                    opacity: _field1Opacity,
                                    child: SlideTransition(position: _field1Slide, child: child)),
                                child: _AuthField(
                                  label: 'Email',
                                  hint: 'Enter your email',
                                  controller: _emailController,
                                  icon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  onChanged: (_) => _clearAuthError(),
                                  validator: (v) {
                                    if (v == null || v.isEmpty) return 'Please enter your email';
                                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) {
                                      return 'Please enter a valid email';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Password field
                              AnimatedBuilder(
                                animation: _ctrl,
                                builder: (_, child) => FadeTransition(
                                    opacity: _field2Opacity,
                                    child: SlideTransition(position: _field2Slide, child: child)),
                                child: _AuthField(
                                  label: 'Password',
                                  hint: 'Enter your password',
                                  controller: _passwordController,
                                  icon: Icons.lock_outline_rounded,
                                  obscureText: true,
                                  onChanged: (_) => _clearAuthError(),
                                  validator: (v) {
                                    if (v == null || v.isEmpty) return 'Please enter your password';
                                    if (_authError != null) return _authError;
                                    return null;
                                  },
                                ),
                              ),

                              // Forgot password link
                              AnimatedBuilder(
                                animation: _ctrl,
                                builder: (_, child) =>
                                    FadeTransition(opacity: _field2Opacity, child: child),
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () => Navigator.push(context,
                                        MaterialPageRoute(
                                            builder: (_) => const ForgotPasswordPage())),
                                    style: TextButton.styleFrom(
                                        foregroundColor: primary,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4, vertical: 8)),
                                    child: Text('Forgot Password?',
                                        style: AppFonts.bodySmall.copyWith(
                                            color: primary, fontWeight: FontWeight.w600)),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),

                              // Login button
                              AnimatedBuilder(
                                animation: _ctrl,
                                builder: (_, child) => FadeTransition(
                                    opacity: _btnOpacity,
                                    child: ScaleTransition(scale: _btnScale, child: child)),
                                child: _AuthButton(
                                    label: 'Log In',
                                    isLoading: _isLoading,
                                    onPressed: _submit),
                              ),
                              const SizedBox(height: 24),

                              // Sign up link
                              AnimatedBuilder(
                                animation: _ctrl,
                                builder: (_, child) =>
                                    FadeTransition(opacity: _footerOpacity, child: child),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("Don't have an account?",
                                        style: AppFonts.bodySmall.copyWith(
                                            color: AppColors.getTextSecondary(context)
                                                .withValues(alpha: 0.7))),
                                    TextButton(
                                      onPressed: () => Navigator.pushReplacement(context,
                                          MaterialPageRoute(
                                              builder: (_) => const SignUpPage())),
                                      style: TextButton.styleFrom(
                                          foregroundColor: primary,
                                          padding:
                                              const EdgeInsets.symmetric(horizontal: 6)),
                                      child: Text('Sign Up',
                                          style: AppFonts.bodySmall.copyWith(
                                              color: primary, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared widgets ────────────────────────────────────────────────────────────

class _AuthField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData icon;
  final bool obscureText;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;

  const _AuthField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.icon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final primary = context.primaryColor;
    final isDark = context.isDark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppFonts.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.getTextSecondary(context))),
        const SizedBox(height: 8),
        FormTextInput(
          controller: controller,
          hintText: hint,
          obscureText: obscureText,
          keyboardType: keyboardType,
          onChanged: onChanged,
          validator: validator,
          prefixIcon: Icon(icon, color: primary, size: 20),
          decoration: InputDecoration(
            filled: true,
            fillColor: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : primary.withValues(alpha: 0.04),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: primary.withValues(alpha: 0.15), width: 1.5)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: primary, width: 2)),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.error, width: 1.5)),
            focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.error, width: 2)),
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ],
    );
  }
}

class _AuthButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onPressed;

  const _AuthButton({required this.label, required this.isLoading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final primary = context.primaryColor;

    return SizedBox(
      height: AppDimensions.buttonHeight + 4,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: primary.withValues(alpha: 0.6),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
            : Text(label, style: AppFonts.labelLargeBold.copyWith(letterSpacing: 0.5)),
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  final double size;
  final Color color;

  const _Blob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
