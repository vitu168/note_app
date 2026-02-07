import 'package:flutter/material.dart';
import 'package:note_app/core/presentation/components/item_gap.dart';
import 'package:note_app/core/presentation/pages/main_page.dart';
import 'package:note_app/core/constants/color_constant.dart';
import 'package:note_app/core/constants/font_constant.dart';
import 'package:note_app/core/constants/properties_constant.dart';
import 'package:note_app/core/presentation/components/form_text_input.dart';
import 'package:note_app/core/presentation/auth/signup_page.dart';
import 'package:note_app/core/data/supabase/auth_service.dart';
import 'package:note_app/core/presentation/widgets/components/toast_helper.dart';
import 'package:note_app/core/presentation/components/toast.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
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
                AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 800),
                  child: Text(
                    'Welcome Back!',
                    style: AppFonts.heading2.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                itemGap(height: 8),
                AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 1000),
                  child: Text(
                    'Log in to your Note App account',
                    style: AppFonts.bodyMedium.copyWith(color: AppColors.getTextSecondary(context).withOpacity(0.7)),
                    textAlign: TextAlign.center,
                  ),
                ),
                AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 1200),
                  child: FormTextInput(
                    label: 'Email',
                    hintText: 'Enter your email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Please enter a valid email';
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
                ),
                itemGap(),
                AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 1400),
                  child: FormTextInput(
                    label: 'Password',
                    hintText: 'Enter your password',
                    controller: _passwordController,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
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
                ),
                itemGap(),
                AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 1600),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Forgot password coming soon!')),
                        );
                      },
                      child: Text(
                        'Forgot Password?',
                        style: AppFonts.labelMedium.copyWith(color: AppColors.primary),
                      ),
                    ),
                  ),
                ),
                itemGap(),
                AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 1800),
                  child: ElevatedButton(
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) return;

                      final email = _emailController.text.trim();
                      final password = _passwordController.text;

                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => const Center(child: CircularProgressIndicator()),
                      );

                      try {
                        await AuthService.signIn(email, password);
                        Navigator.pop(context);
                        final user = AuthService.currentUser();
                        if (user != null) {
                          final meta = user.userMetadata;
                          final displayName = meta != null
                              ? (meta['name'] ?? meta['full_name'] ?? meta['preferred_username'] ?? meta['display_name'])?.toString()
                              : null;
                          final name = displayName ?? user.email?.split('@').first ?? 'there';

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const MainPage()),
                          );
                          showToast(
                            context,
                            'Welcome back, $name! 🎉',
                            type: ToastType.success,
                            duration: const Duration(seconds: 4),
                            icon: Icons.celebration,
                            withHaptic: true,
                          );
                        } else {
                          showToast(context, 'Login failed');
                        }
                      } catch (e) {
                        Navigator.pop(context);
                        showToast(context, 'Login error: $e');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingMedium),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
                      ),
                      elevation: AppDimensions.elevationLow,
                    ),
                    child: Text(
                      'Log In',
                      style: AppFonts.labelLargeBold,
                    ),
                  ),
                ),
                itemGap(),
                AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 2000),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Don’t have an account? ',
                        style: AppFonts.bodySmall.copyWith(color: AppColors.getTextSecondary(context).withOpacity(0.7)),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SignUpPage()),
                        );
                        },
                        child: Text(
                          'Sign Up',
                          style: AppFonts.labelMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
