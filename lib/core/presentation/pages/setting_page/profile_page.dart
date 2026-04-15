import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:note_app/core/data/supabase/auth_service.dart';
import 'package:note_app/core/providers/user_profile_provider.dart';
import 'package:note_app/core/theme/app_context_ext.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.appTheme;
    final user = AuthService.currentUser();
    final profile = context.watch<UserProfileProvider>().profile;

    final name = profile?.name ?? user?.email ?? 'User';
    final email = user?.email ?? '';
    final avatarUrl = profile?.avatarUrl;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Scaffold(
      backgroundColor: t.surfaceElevated,
      appBar: AppBar(
        backgroundColor: t.surfaceElevated,
        elevation: 0,
        title: Text(
          'Profile',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: t.titleText,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: t.primary.withValues(alpha: 0.3), width: 3),
              ),
              child: ClipOval(
                child: avatarUrl != null && avatarUrl.isNotEmpty
                    ? Image.network(avatarUrl, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _fallback(t, initial))
                    : _fallback(t, initial),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              name,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: t.titleText,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              email,
              style: GoogleFonts.poppins(fontSize: 13, color: t.hintText),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallback(dynamic t, String initial) {
    return Container(
      color: t.primaryMuted,
      child: Center(
        child: Text(
          initial,
          style: GoogleFonts.poppins(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: t.primary,
          ),
        ),
      ),
    );
  }
}
