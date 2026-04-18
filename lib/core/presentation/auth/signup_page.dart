import 'package:flutter/material.dart';
import 'package:note_app/core/constants/color_constant.dart';
import 'package:note_app/core/constants/font_constant.dart';
import 'package:note_app/core/constants/properties_constant.dart';
import 'package:note_app/core/data/services/custom_auth_service.dart';
import 'package:note_app/core/presentation/auth/complete_profile_page.dart';
import 'package:note_app/core/presentation/components/form_text_input.dart';
import 'package:note_app/core/presentation/components/toast.dart';
import 'package:note_app/core/presentation/widgets/components/toast_helper.dart';
import 'package:note_app/core/theme/app_context_ext.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
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
  late final Animation<double> _field3Opacity;
  late final Animation<Offset> _field3Slide;
  late final Animation<double> _btnOpacity;
  late final Animation<double> _btnScale;
  late final Animation<double> _footerOpacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));

    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.35, curve: Curves.elasticOut)));
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.2, curve: Curves.easeIn)));

    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.15, 0.38, curve: Curves.easeOut)));
    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.15, 0.38, curve: Curves.easeOutCubic)));

    _cardOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.25, 0.45, curve: Curves.easeOut)));
    _cardSlide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.25, 0.45, curve: Curves.easeOutCubic)));

    _field1Opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.35, 0.54, curve: Curves.easeOut)));
    _field1Slide = Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.35, 0.54, curve: Curves.easeOutCubic)));

    _field2Opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.46, 0.64, curve: Curves.easeOut)));
    _field2Slide = Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.46, 0.64, curve: Curves.easeOutCubic)));

    _field3Opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.57, 0.74, curve: Curves.easeOut)));
    _field3Slide = Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.57, 0.74, curve: Curves.easeOutCubic)));

    _btnOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.70, 0.85, curve: Curves.easeOut)));
    _btnScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.70, 0.85, curve: Curves.easeOutBack)));

    _footerOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.82, 1.0, curve: Curves.easeOut)));

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    // Use the part before '@' as a provisional display name.
    // The real name is set on the CompleteProfilePage.
    final provisionalName = _emailController.text.trim().split('@').first;

    try {
      final res = await CustomAuthService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: provisionalName,
      );
      if (!mounted) return;
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => CompleteProfilePage(
                    userId: res.userId,
                    email: res.email,
                    initialName: res.name ?? provisionalName,
                  )));
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      showToast(context, e.toString().replaceFirst('Exception: ', ''),
          type: ToastType.error);
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
          // ── Gradient header ──────────────────────────────────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            height: size.height * 0.32,
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
          // ── Decorative blobs ─────────────────────────────────────────────────
          Positioned(
            top: -size.width * 0.2,
            right: -size.width * 0.1,
            child: _Blob(size: size.width * 0.55, color: Colors.white.withValues(alpha: 0.07)),
          ),
          Positioned(
            top: size.height * 0.03,
            left: -size.width * 0.12,
            child: _Blob(size: size.width * 0.36, color: Colors.white.withValues(alpha: 0.06)),
          ),
          // ── Main content ─────────────────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // Header
                SizedBox(
                  height: size.height * 0.27,
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
                            AnimatedBuilder(
                              animation: _ctrl,
                              builder: (_, __) => FadeTransition(
                                opacity: _logoOpacity,
                                child: ScaleTransition(
                                  scale: _logoScale,
                                  child: Container(
                                    width: 68,
                                    height: 68,
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
                                        Icons.person_add_rounded, color: Colors.white, size: 34),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            AnimatedBuilder(
                              animation: _ctrl,
                              builder: (_, __) => FadeTransition(
                                opacity: _titleOpacity,
                                child: SlideTransition(
                                  position: _titleSlide,
                                  child: Column(
                                    children: [
                                      Text('Create Account',
                                          style: AppFonts.heading2.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: -0.5)),
                                      const SizedBox(height: 4),
                                      Text('Sign up to get started',
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
                        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
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
                                  validator: (v) {
                                    if (v == null || v.isEmpty) return 'Please enter your email';
                                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) {
                                      return 'Please enter a valid email';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(height: 14),

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
                                  validator: (v) {
                                    if (v == null || v.isEmpty) return 'Please enter a password';
                                    if (v.length < 6) return 'Password must be at least 6 characters';
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(height: 14),

                              // Confirm password field
                              AnimatedBuilder(
                                animation: _ctrl,
                                builder: (_, child) => FadeTransition(
                                    opacity: _field3Opacity,
                                    child: SlideTransition(position: _field3Slide, child: child)),
                                child: _AuthField(
                                  label: 'Confirm Password',
                                  hint: 'Re-enter your password',
                                  controller: _confirmController,
                                  icon: Icons.lock_reset_rounded,
                                  obscureText: true,
                                  validator: (v) {
                                    if (v == null || v.isEmpty) return 'Please confirm your password';
                                    if (v != _passwordController.text) return 'Passwords do not match';
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Sign up button
                              AnimatedBuilder(
                                animation: _ctrl,
                                builder: (_, child) => FadeTransition(
                                    opacity: _btnOpacity,
                                    child: ScaleTransition(scale: _btnScale, child: child)),
                                child: _AuthButton(
                                    label: 'Create Account',
                                    isLoading: _isLoading,
                                    onPressed: _submit),
                              ),
                              const SizedBox(height: 20),

                              // Login link
                              AnimatedBuilder(
                                animation: _ctrl,
                                builder: (_, child) =>
                                    FadeTransition(opacity: _footerOpacity, child: child),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Already have an account?',
                                        style: AppFonts.bodySmall.copyWith(
                                            color: AppColors.getTextSecondary(context)
                                                .withValues(alpha: 0.7))),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      style: TextButton.styleFrom(
                                          foregroundColor: primary,
                                          padding:
                                              const EdgeInsets.symmetric(horizontal: 6)),
                                      child: Text('Log In',
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

// ─── Shared widgets (duplicated for file independence) ─────────────────────────

class _AuthField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData icon;
  final bool obscureText;
  final TextInputType keyboardType;
  final FormFieldValidator<String>? validator;

  const _AuthField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.icon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
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
