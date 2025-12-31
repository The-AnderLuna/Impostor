import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../widgets/gradient_scaffold.dart';
import 'role_reveal_screen.dart';

class InputWordsScreen extends StatefulWidget {
  const InputWordsScreen({super.key});

  @override
  State<InputWordsScreen> createState() => _InputWordsScreenState();
}

class _InputWordsScreenState extends State<InputWordsScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  void _submitWord() {
    if (_controller.text.trim().isEmpty) return;

    final provider = context.read<GameProvider>();
    provider.addCustomWord(_controller.text.trim());
    _controller.clear();
    _focusNode.requestFocus();

    // If state changed to revealing, navigate
    if (provider.status == GameStatus.revealing) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const RoleRevealScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();

    return GradientScaffold(
      appBar: AppBar(
        title: const Text('Escribe una Palabra'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 10),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Jugador ${provider.currentPlayerIndex + 1}',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF512F),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Escribe una palabra secreta (Lugar, Objeto, etc).',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: 'Ej. "Jurasic Park"...',
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitWord,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: const Color(0xFFFF512F),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Siguiente',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
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
