import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:note_app/core/presentation/auth/welcome_page.dart';
import 'package:note_app/core/theme/app_context_ext.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  // Logo: scale + fade in
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;

  // App name: slide up + fade in (delayed)
  late final Animation<double> _nameOpacity;
  late final Animation<Offset> _nameSlide;

  // Tagline: fade in (later)
  late final Animation<double> _taglineOpacity;

  // Dots loader at the bottom
  late final Animation<double> _dotsOpacity;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    // ── Logo ─────────────────────────────────────────────────────────────────
    _logoScale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.45, curve: Curves.elasticOut),
      ),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.25, curve: Curves.easeIn),
      ),
    );

    // ── App name ──────────────────────────────────────────────────────────────
    _nameOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.4, 0.65, curve: Curves.easeOut),
      ),
    );
    _nameSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.4, 0.65, curve: Curves.easeOutCubic),
      ),
    );

    // ── Tagline ───────────────────────────────────────────────────────────────
    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.60, 0.80, curve: Curves.easeOut),
      ),
    );

    // ── Loading dots ──────────────────────────────────────────────────────────
    _dotsOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.75, 0.95, curve: Curves.easeIn),
      ),
    );

    _ctrl.forward();

    // Navigate after animation ends + small pause
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 600),
          pageBuilder: (_, __, ___) => const WelcomePage(),
          transitionsBuilder: (_, anim, __, child) {
            return FadeTransition(opacity: anim, child: child);
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final primary = context.primaryColor;
    final isDark = context.isDark;
    final bgTop = isDark ? Color.alphaBlend(primary.withValues(alpha: 0.12), const Color(0xFF1A1A1A)) : Color.alphaBlend(primary.withValues(alpha: 0.08), const Color(0xFFFFFCF0));
    final bgMid = isDark ? Color.alphaBlend(primary.withValues(alpha: 0.08), const Color(0xFF111111)) : Color.alphaBlend(primary.withValues(alpha: 0.12), const Color(0xFFFFF8E1));
    final bgBot = isDark ? Color.alphaBlend(primary.withValues(alpha: 0.15), const Color(0xFF0D0D0D)) : Color.alphaBlend(primary.withValues(alpha: 0.20), const Color(0xFFFFEE88));
    final textColor = isDark ? Colors.white : Color.alphaBlend(primary.withValues(alpha: 0.85), const Color(0xFF3A1A00));
    final subColor = textColor.withValues(alpha: 0.55);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [bgTop, bgMid, bgBot],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // ── Decorative blurs ──────────────────────────────────────────
              Positioned(
                top: -size.height * 0.08,
                right: -size.width * 0.15,
                child: _Blob(size: size.width * 0.55, color: primary.withValues(alpha: 0.18)),
              ),
              Positioned(
                bottom: -size.height * 0.06,
                left: -size.width * 0.1,
                child: _Blob(size: size.width * 0.45, color: primary.withValues(alpha: 0.15)),
              ),

              // ── Main content ──────────────────────────────────────────────
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo
                    AnimatedBuilder(
                      animation: _ctrl,
                      builder: (_, __) {
                        return FadeTransition(
                          opacity: _logoOpacity,
                          child: ScaleTransition(
                            scale: _logoScale,
                            child: Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(32),
                                boxShadow: [
                                  BoxShadow(
                                    color: primary.withValues(alpha: 0.40),
                                    blurRadius: 40,
                                    spreadRadius: 4,
                                    offset: const Offset(0, 14),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(32),
                                child: Image.asset(
                                  'assets/app_logo.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    // App name
                    FadeTransition(
                      opacity: _nameOpacity,
                      child: SlideTransition(
                        position: _nameSlide,
                        child: Text(
                          'Note App',
                          style: GoogleFonts.poppins(
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            color: textColor,
                            letterSpacing: -0.5,
                            height: 1.1,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Tagline
                    FadeTransition(
                      opacity: _taglineOpacity,
                      child: Text(
                        'Capture every thought',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: subColor,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Loading dots at bottom ─────────────────────────────────────
              Positioned(
                bottom: 48,
                left: 0,
                right: 0,
                child: FadeTransition(
                  opacity: _dotsOpacity,
                  child: const _LoadingDots(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Decorative blob ───────────────────────────────────────────────────────────

class _Blob extends StatelessWidget {
  const _Blob({required this.size, required this.color});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}

// ── Animated loading dots ─────────────────────────────────────────────────────

class _LoadingDots extends StatefulWidget {
  const _LoadingDots();

  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = context.primaryColor;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) {
            final delay = i * 0.28;
            final t = ((_ctrl.value - delay) % 1.0).clamp(0.0, 1.0);
            final bounce = t < 0.5
                ? Curves.easeOut.transform(t * 2)
                : 1.0 - Curves.easeIn.transform((t - 0.5) * 2);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primary.withValues(
                  alpha: 0.4 + bounce * 0.6,
                ),
              ),
              transform: Matrix4.translationValues(0, -bounce * 8, 0),
            );
          },
        );
      }),
    );
  }
}
