import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../widgets/gradient_scaffold.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final civiliansWon = provider.gameWonByCivilians;
    final impostorIds = provider.impostorIds;
    final votedIds = provider.impostorsFound;
    final players = provider.players;

    // Helper to get name by ID
    String getName(String id) {
      try {
        return players.firstWhere((p) => p.id == id).name;
      } catch (e) {
        return 'Desconocido';
      }
    }

    return GradientScaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: Colors.white12),
                boxShadow: const [
                  BoxShadow(color: Colors.black45, blurRadius: 30),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    civiliansWon
                        ? Icons.emoji_events
                        : Icons.sentiment_very_dissatisfied,
                    size: 80,
                    color: civiliansWon
                        ? const Color(0xFF00E676)
                        : const Color(0xFFFF5252),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    civiliansWon ? '¡CIVILES GANAN!' : '¡IMPOSTORES GANAN!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: civiliansWon
                          ? const Color(0xFF00E676)
                          : const Color(0xFFFF5252),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 16),
                  Text(
                    impostorIds.length > 1
                        ? 'Los impostores eran:'
                        : 'El impostor era:',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Wrap(
                    alignment: WrapAlignment.center,
                    children: impostorIds
                        .map(
                          (id) => Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Chip(
                              label: Text(
                                getName(id),
                                style: const TextStyle(color: Colors.white),
                              ),
                              backgroundColor: const Color(0xFF2E0512),
                              side: const BorderSide(color: Color(0xFFFF5252)),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  if (votedIds.isNotEmpty) ...[
                    const Text(
                      'Votados:',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    Wrap(
                      alignment: WrapAlignment.center,
                      children: votedIds
                          .map(
                            (id) => Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Chip(
                                label: Text(
                                  getName(id),
                                  style: const TextStyle(color: Colors.white),
                                ),
                                backgroundColor: const Color(0xFF2C2C2C),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 24),
                  if (provider.currentWord.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Text(
                        'Palabra: ${provider.currentWord}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        provider.resetGame();
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'VOLVER AL MENÚ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
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
