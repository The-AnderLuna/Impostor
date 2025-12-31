import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../widgets/gradient_scaffold.dart';
import 'voting_screen.dart';

class RoleRevealScreen extends StatelessWidget {
  const RoleRevealScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, provider, child) {
        if (provider.status == GameStatus.playing) {
          return const _GameStartedView();
        }

        // Determine colors based on role (only if visible)
        // Hidden state always neutral or gradient
        final isImpostor = provider.isImpostor(provider.currentPlayerIndex);
        final isVisible = provider.isRoleVisible;

        final backgroundColor = isVisible
            ? (isImpostor
                  ? const Color(0xFF6A0C28)
                  : const Color(0xFFFFA000)) // Deep Red vs Orange/Yellow
            : const Color(0xFF2C3E50); // Neutral dark for hidden

        return Scaffold(
          backgroundColor: backgroundColor,
          body: SafeArea(
            child: Stack(
              children: [
                // Background Gradients/Shapes
                if (isVisible) ...[
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: isImpostor
                              ? [
                                  const Color(0xFF8E0E3B),
                                  const Color(0xFF2E0512),
                                ]
                              : [
                                  const Color(0xFFFFB300),
                                  const Color(0xFFFF6F00),
                                ],
                        ),
                      ),
                    ),
                  ),
                ],

                // Main Content
                Column(
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
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
                            'JUGADOR ${provider.currentPlayerIndex + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(width: 48), // Balance
                        ],
                      ),
                    ),

                    Expanded(
                      child: Center(
                        child: GestureDetector(
                          onTap: provider.toggleRoleVisibility,
                          child: _CardContent(
                            isVisible: isVisible,
                            isImpostor: isImpostor,
                            word: provider.currentWord,
                            playerIndex: provider.currentPlayerIndex,
                            hintsEnabled: provider.impostorHintsEnabled,
                            categoryName:
                                provider.selectedCategory?.name ?? 'General',
                          ),
                        ),
                      ),
                    ),

                    // Bottom Action
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: isVisible
                            ? ElevatedButton(
                                onPressed: () => provider.nextPlayerReveal(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  elevation: 8,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: const Text(
                                  'SIGUIENTE',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : const Text(
                                'TOCA LA CARTA',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white54,
                                  letterSpacing: 2,
                                  fontWeight: FontWeight.bold,
                                ),
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

class _CardContent extends StatelessWidget {
  final bool isVisible;
  final bool isImpostor;
  final String word;
  final int playerIndex;
  final bool hintsEnabled;
  final String categoryName;

  const _CardContent({
    required this.isVisible,
    required this.isImpostor,
    required this.word,
    required this.playerIndex,
    required this.hintsEnabled,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) {
      return Container(
        width: 300,
        height: 400,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 20)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.fingerprint, size: 80, color: Colors.grey),
            const SizedBox(height: 24),
            const Text(
              '¿Quién eres?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Toca para revelar',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    // VISIBLE CARD MATCHING REFERENCE
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // TOP CARD with Avatar
        Container(
          width: 300,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 15)],
          ),
          child: Column(
            children: [
              // Avatar Space
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: isImpostor
                      ? const Color(0xFF2E0512)
                      : const Color(0xFFFFF3E0),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _getAvatarEmoji(playerIndex),
                    style: const TextStyle(fontSize: 60),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'JUGADOR ${playerIndex + 1}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isImpostor ? '¡ERES IMPOSTOR!' : '¡ERES CIVIL!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: isImpostor
                      ? const Color(0xFF8E0E3B)
                      : const Color(0xFFFF6F00),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        const SizedBox(height: 24), // Gap
        // BOTTOM BUBBLE ("Palabra Secreta")
        Container(
          width: 300,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 15)],
          ),
          child: Column(
            children: [
              Text(
                (isImpostor && hintsEnabled)
                    ? 'TU PISTA (CATEGORÍA):'
                    : (isImpostor ? 'NO TIENES PALABRA' : 'PALABRA SECRETA:'),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 4),
              isImpostor
                  ? Text(
                      hintsEnabled ? categoryName.toUpperCase() : '¡DISIMULA!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF8E0E3B),
                      ),
                      textAlign: TextAlign.center,
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.lock,
                          size: 24,
                          color: Colors.orange,
                        ), // Decor
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            word.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ],
    );
  }

  String _getAvatarEmoji(int index) {
    const avatars = [
      '😎',
      '🤠',
      '🥳',
      '👻',
      '🤖',
      '👽',
      '💀',
      '🤡',
      '🐵',
      '🐶',
      '🦊',
      '🐱',
    ];
    return avatars[index % avatars.length];
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 20),
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
                    color: Colors.black87,
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
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<GameProvider>().startVoting();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const VotingScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF512F),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                        ),
                        child: const Text(
                          'VOTAR',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final provider = context.read<GameProvider>();
                          provider.generateSuggestion();
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              icon: const Text(
                                '💡',
                                style: TextStyle(fontSize: 40),
                              ),
                              title: const Text(
                                'PREGUNTA SUGERIDA',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              content: Consumer<GameProvider>(
                                builder: (context, p, _) => Text(
                                  p.currentSuggestion ?? 'Cargando...',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFFF512F),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              actionsAlignment: MainAxisAlignment.center,
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    provider.generateSuggestion();
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.grey,
                                  ),
                                  child: const Text('Otra'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Listo'),
                                ),
                              ],
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blueAccent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(
                              color: Colors.blueAccent,
                              width: 2,
                            ),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'PISTA',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    context.read<GameProvider>().resetGame();
                    Navigator.popUntil(context, (r) => r.isFirst);
                  },
                  child: const Text(
                    'Abortar Partida',
                    style: TextStyle(color: Colors.grey),
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
