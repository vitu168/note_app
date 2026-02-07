import 'package:flutter/material.dart';
import 'package:note_app/core/presentation/pages/main_page.dart';
import 'package:note_app/core/constants/color_constant.dart';
import 'package:note_app/core/constants/font_constant.dart';
import 'package:note_app/core/constants/properties_constant.dart';
import 'package:note_app/core/presentation/components/form_text_input.dart';
import 'package:note_app/core/data/supabase/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:note_app/core/presentation/widgets/components/toast_helper.dart';
import 'package:note_app/core/config/supabase_config.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  DateTime? _lastSignupAttempt; // simple client-side cooldown to avoid hammering the API

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(AppDimensions.spacing),
                        child: Icon(
                          Icons.note_alt,
                          size: AppDimensions.iconLarge * 2,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spacingSmall),
                  Text(
                    'Create an account',
                    style: AppFonts.heading2.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimensions.spacingSmall),
                  Text(
                    'Sign up to start using Note App',
                    style: AppFonts.bodyMedium.copyWith(color: AppColors.getTextSecondary(context).withValues(alpha: 0.7)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimensions.spacingMedium),
                  FormTextInput(
                    label: 'Full name',
                    hintText: 'Input your full name',
                    controller: _nameController,
                    validator: (v) => v == null || v.isEmpty ? 'Please enter your name' : null,
                    prefixIcon: const Icon(Icons.person),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingSmall),
                  FormTextInput(
                    label: 'Email',
                    hintText: 'Input your email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Please enter your email';
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) return 'Please enter a valid email';
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
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingSmall),
                  FormTextInput(
                    label: 'Password',
                    hintText: 'Input your password',
                    controller: _passwordController,
                    obscureText: true,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Please enter password';
                      if (v.length < 6) return 'Password must be at least 6 characters';
                      return null;
                    },
                    prefixIcon: Icon(Icons.lock, color: AppColors.primary),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingSmall),
                  FormTextInput(
                    label: 'Confirm Password',
                    hintText: 'Re-enter your password',
                    controller: _confirmController,
                    obscureText: true,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Please confirm password';
                      if (v != _passwordController.text) return 'Passwords do not match';
                      return null;
                    },
                    prefixIcon: Icon(Icons.lock_outline, color: AppColors.primary),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingMedium),
                  ElevatedButton(
                    onPressed: () async {
                      final now = DateTime.now();
                      if (_lastSignupAttempt != null && now.difference(_lastSignupAttempt!).inSeconds < 30) {
                        final wait = 30 - now.difference(_lastSignupAttempt!).inSeconds;
                        showToast(context, 'Please wait $wait seconds before trying again.');
                        return;
                      }

                      if (!_formKey.currentState!.validate()) return;

                      final email = _emailController.text.trim();
                      final password = _passwordController.text;

                      _lastSignupAttempt = DateTime.now();

                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => const Center(child: CircularProgressIndicator()),
                      );

                      try {
                        await AuthService.signUp(email, password, redirectTo: supabaseAuthRedirectTo);
                        Navigator.pop(context);
                        final user = AuthService.currentUser();
                        if (user != null) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const MainPage()),
                          );
                          showToast(context, 'Account created successfully!');
                        } else {
                          // Most Supabase setups require email verification: inform the user
                          showToast(context, 'Verification email sent. Please check your inbox. The link will redirect to $supabaseAuthRedirectTo');
                          // Return to login so the user can sign in after verification
                          Navigator.pop(context);
                        }
                      } on AuthApiException catch (ae) {
                        Navigator.pop(context);
                        var friendly = ae.message;
                        if (friendly.toLowerCase().contains('rate')) {
                          friendly = 'Too many requests — please wait a few minutes and try again.';
                        }
                        showToast(context, 'Sign up error: $friendly');
                      } catch (e) {
                        Navigator.pop(context);
                        showToast(context, 'Sign up error: $e');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingMedium),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusLarge)),
                      elevation: AppDimensions.elevationLow,
                    ),
                    child: Text('Sign Up', style: AppFonts.labelLargeBold),
                  ),
                  const SizedBox(height: AppDimensions.spacingSmall),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Already have an account? ', style: AppFonts.bodySmall.copyWith(color: AppColors.getTextSecondary(context).withOpacity(0.7))),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Log in', style: AppFonts.labelMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
