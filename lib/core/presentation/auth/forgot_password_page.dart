import 'package:flutter/material.dart';
import 'package:note_app/core/constants/color_constant.dart';
import 'package:note_app/core/constants/font_constant.dart';
import 'package:note_app/core/constants/properties_constant.dart';
import 'package:note_app/core/data/services/custom_auth_service.dart';
import 'package:note_app/core/presentation/components/form_text_input.dart';
import 'package:note_app/core/presentation/widgets/components/toast_helper.dart';
import 'package:note_app/core/presentation/components/toast.dart';
import 'package:note_app/l10n/app_localizations.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await CustomAuthService.forgotPassword(email: email);
      Navigator.pop(context);
      setState(() => _submitted = true);
    } catch (e) {
      Navigator.pop(context);
      showToast(
        context,
        'Failed to send reset email: ${e.toString()}',
        type: ToastType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: _submitted ? _buildSuccessView(context, s) : _buildFormView(context, s),
        ),
      ),
    );
  }

  Widget _buildFormView(BuildContext context, AppLocalizations s) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          Icon(Icons.lock_reset, size: 72, color: AppColors.primary),
          const SizedBox(height: 24),
          Text(
            s.forgotPasswordQ,
            style: AppFonts.heading2.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            s.forgotPasswordDesc,
            style: AppFonts.bodyMedium.copyWith(
              color: AppColors.getTextSecondary(context).withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.spacingMedium),
          FormTextInput(
            label: s.email,
            hintText: s.enterYourEmail,
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.isEmpty) return s.pleaseEnterEmail;
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) {
                return s.pleaseEnterValidEmail;
              }
              return null;
            },
            prefixIcon: Icon(Icons.email, color: AppColors.primary),
            decoration: InputDecoration(
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.13),
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2.0,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingMedium),
          ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingMedium),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
              ),
              elevation: AppDimensions.elevationLow,
            ),
            child: Text(s.sendResetLink, style: AppFonts.labelLargeBold),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView(BuildContext context, AppLocalizations s) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(Icons.mark_email_read, size: 80, color: AppColors.primary),
        const SizedBox(height: 24),
        Text(
          s.checkYourEmail,
          style: AppFonts.heading2.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          '${s.resetEmailSent}\n${_emailController.text.trim()}',
          style: AppFonts.bodyMedium.copyWith(
            color: AppColors.getTextSecondary(context).withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.spacingLarge),
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: BorderSide(color: AppColors.primary),
            padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingMedium),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            ),
          ),
          child: Text(s.backToLogin, style: AppFonts.labelLargeBold),
        ),
      ],
    );
  }
}
