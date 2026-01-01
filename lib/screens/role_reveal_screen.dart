import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../widgets/gradient_scaffold.dart';
import 'voting_screen.dart';

class RoleRevealScreen extends StatefulWidget {
  const RoleRevealScreen({super.key});

  @override
  State<RoleRevealScreen> createState() => _RoleRevealScreenState();
}

class _RoleRevealScreenState extends State<RoleRevealScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, provider, child) {
        if (provider.status == GameStatus.playing) {
          return const _GameStartedView();
        }

        final currentPlayer = provider.currentPlayer;
        final isImpostor = provider.isCurrentPlayerImpostor();
        final isVisible = provider.isRoleVisible;

        // Visual Anti-cheat: Use specific color for this player instance
        final playerColor = currentPlayer.color;

        return Scaffold(
          backgroundColor: const Color(0xFF121212),
          body: SafeArea(
            child: Stack(
              children: [
                // Subtle random background accent
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 1.5,
                        colors: [
                          playerColor.withValues(alpha: 0.2),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 1.0],
                      ),
                    ),
                  ),
                ),

                Column(
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () {
                              provider.resetGame();
                              Navigator.popUntil(context, (r) => r.isFirst);
                            },
                          ),
                          Text(
                            currentPlayer.name.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                    ),

                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: isVisible
                                ? _RevealedCard(
                                    isImpostor: isImpostor,
                                    word: provider.currentWord,
                                    hintsEnabled:
                                        provider.impostorHintsEnabled &&
                                        !provider.isCustomMode,
                                    // Categories are now multiple, join names if few, or generic text
                                    // Categories are now multiple, join names if few, or generic text
                                    categoryName:
                                        provider.currentWordCategoryName ??
                                        'MIXTO',
                                    accentColor: playerColor,
                                  )
                                : Dismissible(
                                    key: ValueKey(
                                      'reveal_${provider.currentPlayerIndex}',
                                    ),
                                    direction: DismissDirection.up,
                                    onDismissed: (_) {
                                      provider.toggleRoleVisibility();
                                    },
                                    child: _CoverCard(accentColor: playerColor),
                                  ),
                          ),
                        ),
                      ),
                    ),

                    // Bottom Action
                    Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: isVisible
                            ? ElevatedButton(
                                onPressed: () => provider.nextPlayerReveal(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  elevation: 10,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: const Text(
                                  'PASAR AL SIGUIENTE',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                              )
                            : const Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.keyboard_arrow_up,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                  Text(
                                    'DESLIZA PARA REVELAR',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      letterSpacing: 2,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CoverCard extends StatelessWidget {
  final Color accentColor;
  const _CoverCard({required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300, // Reduced size
      height: 420,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            blurRadius: 40,
            spreadRadius: 5,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.black26,
              shape: BoxShape.circle,
              border: Border.all(color: accentColor.withValues(alpha: 0.3)),
            ),
            child: Icon(Icons.fingerprint, size: 80, color: accentColor),
          ),
          const SizedBox(height: 40),
          const Text(
            'CONFIDENCIAL',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Mantén tu identidad\nen secreto',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[400],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _RevealedCard extends StatelessWidget {
  final bool isImpostor;
  final String word;
  final bool hintsEnabled;
  final String categoryName;
  final Color accentColor;

  const _RevealedCard({
    required this.isImpostor,
    required this.word,
    required this.hintsEnabled,
    required this.categoryName,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Role Card
        Container(
          width: 300, // Reduced size
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.6),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.2),
                blurRadius: 30,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                isImpostor ? '🚫' : '✅',
                style: const TextStyle(fontSize: 60),
              ),
              const SizedBox(height: 16),
              Text(
                isImpostor ? 'ERES EL IMPOSTOR' : 'ERES CIVIL',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: isImpostor
                      ? const Color(0xFFFF5252)
                      : const Color(0xFF00E676),
                  letterSpacing: 1,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Use FittedBox for word/message
              if (isImpostor)
                _ImpostorInstruction(
                  hintsEnabled: hintsEnabled,
                  categoryName: categoryName,
                )
              else
                _CivilianInstruction(word: word),
            ],
          ),
        ),
      ],
    );
  }
}

class _ImpostorInstruction extends StatelessWidget {
  final bool hintsEnabled;
  final String categoryName;

  const _ImpostorInstruction({
    required this.hintsEnabled,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (hintsEnabled) ...[
          const Text(
            'CATEGORÍA:',
            style: TextStyle(
              color: Colors.white54,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            categoryName.toUpperCase(),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
        ],
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF2E0512),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Column(
            children: [
              Text(
                'NO TIENES PALABRA',
                style: TextStyle(
                  color: Color(0xFFFF5252),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Engaña a todos para ganar. Presta atención a las pistas de los demás.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CivilianInstruction extends StatelessWidget {
  final String word;

  const _CivilianInstruction({required this.word});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'TU PALABRA SECRETA:',
          style: TextStyle(
            color: Colors.white54,
            fontWeight: FontWeight.bold,
            fontSize: 12,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(100),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              word.toUpperCase(),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Describe tu palabra sin ser demasiado obvio.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white60, fontSize: 13),
        ),
      ],
    );
  }
}

class _GameStartedView extends StatelessWidget {
  const _GameStartedView();

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.white12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black45,
                  blurRadius: 30,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.psychology,
                  size: 80,
                  color: Color(0xFFDD2476),
                ),
                const SizedBox(height: 24),
                const Text(
                  '¡JUEGO EN CURSO!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Hagan preguntas por turnos y voten cuando estéis listos.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<GameProvider>().startVoting();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const VotingScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF512F),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                    child: const Text(
                      'VOTAR',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    context.read<GameProvider>().resetGame();
                    Navigator.popUntil(context, (r) => r.isFirst);
                  },
                  child: const Text(
                    'Abortar Partida',
                    style: TextStyle(color: Colors.white30),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
