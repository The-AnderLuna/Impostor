import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'unified_setup_screen.dart';
import '../data/local_categories.dart';

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
                        label: 'CATEGORÍAS',
                        icon: Icons.grid_view_rounded,
                        isSecondary: true,
                        onTap: () {
                          _showCategoriesDialog(context);
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

  void _showCategoriesDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'Categorías Disponibles',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                ),
                itemCount: LocalCategories.categories.length,
                itemBuilder: (context, index) {
                  final cat = LocalCategories.categories[index];
                  return Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          cat.icon,
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        cat.name,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
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
              ? Colors.white.withOpacity(0.2)
              : Colors.white,
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
