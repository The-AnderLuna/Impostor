import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'unified_setup_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Full Screen Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/home_hero.jpg',
              fit: BoxFit.cover, // Fills the entire screen
            ),
          ),

          // 2. Buttons at the bottom
          SafeArea(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.end, // Push content to bottom
              children: [
                const Spacer(), // Push buttons down

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 20,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _HomeButton(
                        label: 'NUEVA PARTIDA',
                        icon: Icons.play_arrow_rounded,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const UnifiedSetupScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _HomeButton(
                        label: 'SALIR',
                        icon: Icons.exit_to_app_rounded,
                        isSecondary: true,
                        onTap: () {
                          SystemNavigator.pop();
                        },
                      ),
                    ],
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

class _HomeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isSecondary;

  const _HomeButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isSecondary = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: isSecondary
              ? const Color(0xFF00E676).withValues(alpha: 0.5)
              : Colors.white,
          shadowColor: const Color(0xFF00E676).withValues(alpha: 0.5),
          foregroundColor: isSecondary ? Colors.white : const Color(0xFFFF512F),
          elevation: isSecondary ? 0 : 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          side: isSecondary
              ? const BorderSide(color: Colors.white, width: 2)
              : BorderSide.none,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
