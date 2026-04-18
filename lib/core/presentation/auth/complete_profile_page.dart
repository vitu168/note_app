import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:note_app/core/constants/color_constant.dart';
import 'package:note_app/core/constants/font_constant.dart';
import 'package:note_app/core/constants/properties_constant.dart';
import 'package:note_app/core/presentation/pages/main_page.dart';
import 'package:note_app/core/providers/user_profile_provider.dart';
import 'package:provider/provider.dart';
import 'package:note_app/core/presentation/components/form_text_input.dart';
import 'package:note_app/core/presentation/components/toast.dart';
import 'package:note_app/core/presentation/widgets/components/toast_helper.dart';
import 'package:note_app/core/services/storage_service.dart';
import 'package:note_app/core/services/user_profile_api_service.dart';
import 'package:note_app/core/theme/app_context_ext.dart';

/// Shown immediately after sign-up so the user can add a photo and
/// confirm their display name before their profile is saved to the
/// backend. After saving, the user is taken directly to the main dashboard.
class CompleteProfilePage extends StatefulWidget {
  final String userId;
  final String email;
  final String initialName;

  const CompleteProfilePage({
    super.key,
    required this.userId,
    required this.email,
    required this.initialName,
  });

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;

  final _profileService = UserProfileApiService();
  final _storageService = StorageService();
  final _picker = ImagePicker();

  XFile? _pickedImage;
  bool _isLoading = false;
  bool _avatarError = false;

  // ── Animations ─────────────────────────────────────────────────────────────
  late final AnimationController _ctrl;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _titleOpacity;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _cardOpacity;
  late final Animation<Offset> _cardSlide;
  late final Animation<double> _avatarOpacity;
  late final Animation<Offset> _avatarSlide;
  late final Animation<double> _field1Opacity;
  late final Animation<Offset> _field1Slide;
  late final Animation<double> _btnOpacity;
  late final Animation<double> _btnScale;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);

    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400));

    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.4, curve: Curves.elasticOut)));
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _ctrl,
            curve: const Interval(0.0, 0.25, curve: Curves.easeIn)));

    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _ctrl,
            curve: const Interval(0.2, 0.45, curve: Curves.easeOut)));
    _titleSlide =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
            CurvedAnimation(
                parent: _ctrl,
                curve:
                    const Interval(0.2, 0.45, curve: Curves.easeOutCubic)));

    _cardOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _ctrl,
            curve: const Interval(0.3, 0.55, curve: Curves.easeOut)));
    _cardSlide =
        Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
            CurvedAnimation(
                parent: _ctrl,
                curve:
                    const Interval(0.3, 0.55, curve: Curves.easeOutCubic)));

    _avatarOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _ctrl,
            curve: const Interval(0.45, 0.65, curve: Curves.easeOut)));
    _avatarSlide =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
            CurvedAnimation(
                parent: _ctrl,
                curve:
                    const Interval(0.45, 0.65, curve: Curves.easeOutCubic)));

    _field1Opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _ctrl,
            curve: const Interval(0.55, 0.72, curve: Curves.easeOut)));
    _field1Slide =
        Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero).animate(
            CurvedAnimation(
                parent: _ctrl,
                curve:
                    const Interval(0.55, 0.72, curve: Curves.easeOutCubic)));

    _btnOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _ctrl,
            curve: const Interval(0.68, 0.85, curve: Curves.easeOut)));
    _btnScale = Tween<double>(begin: 0.85, end: 1.0).animate(CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.68, 0.85, curve: Curves.easeOutBack)));

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // ── Image picker ────────────────────────────────────────────────────────────

  Future<void> _pickImage() async {
    final choice = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = ctx.isDark;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12, bottom: 16),
                  decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2)),
                ),
                Text('Choose Photo',
                    style: AppFonts.bodyMedium
                        .copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(Icons.camera_alt_rounded),
                  title: Text('Camera', style: AppFonts.bodyMedium),
                  onTap: () => Navigator.pop(ctx, ImageSource.camera),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_rounded),
                  title: Text('Photo Library', style: AppFonts.bodyMedium),
                  onTap: () => Navigator.pop(ctx, ImageSource.gallery),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );

    if (choice == null) return;
    final xFile = await _picker.pickImage(
      source: choice,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (xFile != null) {
      setState(() {
        _pickedImage = xFile;
        _avatarError = false;
      });
    }
  }

  // ── Submit ──────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    final hasAvatar = _pickedImage != null;
    setState(() => _avatarError = !hasAvatar);

    if (!_formKey.currentState!.validate() || !hasAvatar) return;
    setState(() => _isLoading = true);

    try {
      // 1. Upload avatar to Supabase Storage
      final avatarUrl = await _storageService.uploadAvatar(
        imageFile: File(_pickedImage!.path),
        userId: widget.userId,
      );

      final name = _nameController.text.trim();

      // 2. Create or update the userinfo record
      final existing = await _profileService.getProfileById(widget.userId);
      if (existing == null) {
        await _profileService.createProfile(
          id: widget.userId,
          email: widget.email,
          name: name,
          avatarUrl: avatarUrl,
        );
      } else {
        await _profileService.updateProfile(
          id: widget.userId,
          name: name,
          avatarUrl: avatarUrl,
          email: widget.email,
          isNote: existing.isNote ?? false,
        );
      }

      // 3. Go directly to the home dashboard — no sign-out needed.
      if (!mounted) return;
      // Refresh the provider so the new profile is available immediately.
      await context.read<UserProfileProvider>().syncOnLogin();

      if (!mounted) return;
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const MainPage()));
      showToast(context, 'Welcome! Your profile is all set. 🎉',
          type: ToastType.success,
          duration: const Duration(seconds: 4),
          icon: Icons.celebration,
          withHaptic: true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      showToast(context, e.toString().replaceFirst('Exception: ', ''),
          type: ToastType.error);
    }
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final primary = context.primaryColor;
    final isDark = context.isDark;
    final size = MediaQuery.sizeOf(context);

    return PopScope(
      // Prevent back navigation — user must complete profile setup
      canPop: false,
      child: Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF111111) : const Color(0xFFF5F8FF),
        body: Stack(
          children: [
            // ── Gradient header ─────────────────────────────────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: size.height * 0.38,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primary.withValues(alpha: 0.95),
                      primary,
                      Color.alphaBlend(
                          Colors.white.withValues(alpha: 0.12), primary),
                    ],
                  ),
                ),
              ),
            ),
            // ── Decorative blobs ─────────────────────────────────────────────
            Positioned(
              top: -size.width * 0.18,
              right: -size.width * 0.08,
              child: _Blob(
                  size: size.width * 0.55,
                  color: Colors.white.withValues(alpha: 0.07)),
            ),
            Positioned(
              top: size.height * 0.04,
              left: -size.width * 0.12,
              child: _Blob(
                  size: size.width * 0.38,
                  color: Colors.white.withValues(alpha: 0.06)),
            ),
            // ── Main content ─────────────────────────────────────────────────
            SafeArea(
              child: Column(
                children: [
                  // ── Header ─────────────────────────────────────────────────
                  SizedBox(
                    height: size.height * 0.33,
                    child: Center(
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
                                  width: 72,
                                  height: 72,
                                  decoration: BoxDecoration(
                                    color:
                                        Colors.white.withValues(alpha: 0.18),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white
                                            .withValues(alpha: 0.35),
                                        width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.15),
                                          blurRadius: 24,
                                          offset: const Offset(0, 8)),
                                    ],
                                  ),
                                  child: const Icon(Icons.person_pin_rounded,
                                      color: Colors.white, size: 36),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          AnimatedBuilder(
                            animation: _ctrl,
                            builder: (_, __) => FadeTransition(
                              opacity: _titleOpacity,
                              child: SlideTransition(
                                position: _titleSlide,
                                child: Column(
                                  children: [
                                    Text('Set Up Your Profile',
                                        style: AppFonts.heading2.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: -0.5)),
                                    const SizedBox(height: 4),
                                    Text('Add a photo and confirm your name',
                                        style: AppFonts.bodyMedium.copyWith(
                                            color: Colors.white
                                                .withValues(alpha: 0.78))),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Form card ───────────────────────────────────────────────
                  Expanded(
                    child: AnimatedBuilder(
                      animation: _ctrl,
                      builder: (_, child) => FadeTransition(
                          opacity: _cardOpacity,
                          child:
                              SlideTransition(position: _cardSlide, child: child)),
                      child: Container(
                        decoration: BoxDecoration(
                          color:
                              isDark ? const Color(0xFF1E1E1E) : Colors.white,
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
                          padding:
                              const EdgeInsets.fromLTRB(24, 32, 24, 32),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // ── Avatar picker ──────────────────────────
                                AnimatedBuilder(
                                  animation: _ctrl,
                                  builder: (_, child) => FadeTransition(
                                      opacity: _avatarOpacity,
                                      child: SlideTransition(
                                          position: _avatarSlide,
                                          child: child)),
                                  child: Center(
                                    child: Column(
                                      children: [
                                        GestureDetector(
                                          onTap: _isLoading
                                              ? null
                                              : _pickImage,
                                          child: Stack(
                                            children: [
                                              Container(
                                                width: 108,
                                                height: 108,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: _avatarError
                                                      ? AppColors.error
                                                          .withValues(
                                                              alpha: 0.08)
                                                      : primary.withValues(
                                                          alpha: 0.08),
                                                  border: Border.all(
                                                    color: _avatarError
                                                        ? AppColors.error
                                                        : primary.withValues(
                                                            alpha: 0.25),
                                                    width: 2.5,
                                                  ),
                                                ),
                                                child: _pickedImage != null
                                                    ? ClipOval(
                                                        child: Image.file(
                                                          File(_pickedImage!
                                                              .path),
                                                          fit: BoxFit.cover,
                                                        ),
                                                      )
                                                    : Icon(
                                                        Icons.person_rounded,
                                                        size: 52,
                                                        color: _avatarError
                                                            ? AppColors.error
                                                                .withValues(
                                                                    alpha:
                                                                        0.5)
                                                            : primary
                                                                .withValues(
                                                                    alpha:
                                                                        0.35)),
                                              ),
                                              Positioned(
                                                bottom: 2,
                                                right: 2,
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(7),
                                                  decoration: BoxDecoration(
                                                    color: primary,
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                        color: isDark
                                                            ? const Color(
                                                                0xFF1E1E1E)
                                                            : Colors.white,
                                                        width: 2.5),
                                                    boxShadow: [
                                                      BoxShadow(
                                                          color: primary
                                                              .withValues(
                                                                  alpha: 0.3),
                                                          blurRadius: 8,
                                                          offset: const Offset(
                                                              0, 2)),
                                                    ],
                                                  ),
                                                  child: const Icon(
                                                      Icons
                                                          .camera_alt_rounded,
                                                      color: Colors.white,
                                                      size: 16),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        if (_avatarError)
                                          Text(
                                              'A profile photo is required',
                                              style: AppFonts.bodySmall
                                                  .copyWith(
                                                      color: AppColors.error))
                                        else
                                          Text(
                                              _pickedImage != null
                                                  ? 'Tap to change photo'
                                                  : 'Tap to add photo  •  Required',
                                              style: AppFonts.bodySmall
                                                  .copyWith(
                                                      color: AppColors
                                                          .getTextSecondary(
                                                              context)
                                                          .withValues(
                                                              alpha: 0.6))),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 28),

                                // ── Display name field ─────────────────────
                                AnimatedBuilder(
                                  animation: _ctrl,
                                  builder: (_, child) => FadeTransition(
                                      opacity: _field1Opacity,
                                      child: SlideTransition(
                                          position: _field1Slide,
                                          child: child)),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Display Name',
                                          style: AppFonts.bodySmall.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.getTextSecondary(
                                                  context))),
                                      const SizedBox(height: 8),
                                      FormTextInput(
                                        controller: _nameController,
                                        hintText: 'Your display name',
                                        prefixIcon: Icon(
                                            Icons.person_outline_rounded,
                                            color: primary,
                                            size: 20),
                                        validator: (v) {
                                          if (v == null ||
                                              v.trim().isEmpty) {
                                            return 'Please enter your display name';
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: isDark
                                              ? Colors.white
                                                  .withValues(alpha: 0.06)
                                              : primary
                                                  .withValues(alpha: 0.04),
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              borderSide: BorderSide.none),
                                          enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              borderSide: BorderSide(
                                                  color: primary.withValues(
                                                      alpha: 0.15),
                                                  width: 1.5)),
                                          focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              borderSide: BorderSide(
                                                  color: primary, width: 2)),
                                          errorBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              borderSide: const BorderSide(
                                                  color: AppColors.error,
                                                  width: 1.5)),
                                          focusedErrorBorder:
                                              OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          14),
                                                  borderSide:
                                                      const BorderSide(
                                                          color:
                                                              AppColors.error,
                                                          width: 2)),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 14),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 32),

                                // ── Continue button ────────────────────────
                                AnimatedBuilder(
                                  animation: _ctrl,
                                  builder: (_, child) => FadeTransition(
                                      opacity: _btnOpacity,
                                      child: ScaleTransition(
                                          scale: _btnScale, child: child)),
                                  child: SizedBox(
                                    height: AppDimensions.buttonHeight + 4,
                                    child: ElevatedButton(
                                      onPressed:
                                          _isLoading ? null : _submit,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primary,
                                        foregroundColor: Colors.white,
                                        disabledBackgroundColor:
                                            primary.withValues(alpha: 0.6),
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(14)),
                                      ),
                                      child: _isLoading
                                          ? const SizedBox(
                                              width: 22,
                                              height: 22,
                                              child: CircularProgressIndicator(
                                                  strokeWidth: 2.5,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                              Color>(
                                                          Colors.white)))
                                          : Text('Save & Continue',
                                              style: AppFonts.labelLargeBold
                                                  .copyWith(
                                                      letterSpacing: 0.5)),
                                    ),
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
      ),
    );
  }
}

// ── Decorative blob ────────────────────────────────────────────────────────────

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
