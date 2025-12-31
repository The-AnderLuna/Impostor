import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../widgets/gradient_scaffold.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<GameProvider>();
    final civiliansWon = provider.gameWonByCivilians;
    final impostorIndices = provider.impostorIndices;
    final votedIndices = provider.impostorsFound;

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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  civiliansWon
                      ? Icons.emoji_events
                      : Icons.sentiment_very_dissatisfied,
                  size: 80,
                  color: civiliansWon ? Colors.green : Colors.red,
                ),
                const SizedBox(height: 24),
                Text(
                  civiliansWon ? '¡CIVILES GANAN!' : '¡IMPOSTORES GANAN!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: civiliansWon
                        ? Colors.green
                        : const Color(0xFFFF512F),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  impostorIndices.length > 1
                      ? 'Los impostores eran:'
                      : 'El impostor era:',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Wrap(
                  alignment: WrapAlignment.center,
                  children: impostorIndices
                      .map(
                        (i) => Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Chip(
                            label: Text('Jugador ${i + 1}'),
                            backgroundColor: Colors.red[100],
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 16),
                if (votedIndices.isNotEmpty) ...[
                  const Text(
                    'Votados:',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  Wrap(
                    alignment: WrapAlignment.center,
                    children: votedIndices
                        .map(
                          (i) => Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Chip(label: Text('Jugador ${i + 1}')),
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
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Palabra: ${provider.currentWord}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
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
                      backgroundColor: Colors.black87,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Volver al Menú',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
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
