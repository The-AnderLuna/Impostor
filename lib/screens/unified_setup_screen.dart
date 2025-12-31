import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/local_categories.dart';
import '../providers/game_provider.dart';
import '../widgets/gradient_scaffold.dart';
import 'role_reveal_screen.dart';
import 'word_input_screen.dart';

class UnifiedSetupScreen extends StatefulWidget {
  const UnifiedSetupScreen({super.key});

  @override
  State<UnifiedSetupScreen> createState() => _UnifiedSetupScreenState();
}

class _UnifiedSetupScreenState extends State<UnifiedSetupScreen> {
  @override
  Widget build(BuildContext context) {
    // Watch provider for updates
    final provider = context.watch<GameProvider>();

    return GradientScaffold(
      appBar: AppBar(
        title: const Text(
          'Nueva Partida',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Configurar',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFFF512F),
                  ),
                ),
                const SizedBox(height: 32),

                // Jugadores
                _SettingItem(
                  icon: '👥',
                  title: 'Jugadores',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${provider.playerCount}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (_) => _ValuePicker(
                        title: 'Número de Jugadores',
                        value: provider.playerCount,
                        min: 3,
                        max: 20,
                        onChanged: (val) => provider.setPlayerCount(val),
                      ),
                    );
                  },
                ),
                const Divider(),

                // Impostores
                _SettingItem(
                  icon: '🕵️',
                  title: 'Impostores',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${provider.impostorCount}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (_) => _ValuePicker(
                        title: 'Número de Impostores',
                        value: provider.impostorCount,
                        min: 1,
                        max: (provider.playerCount - 1)
                            .toDouble(), // Max impostors < players
                        onChanged: (val) => provider.setImpostorCount(val),
                      ),
                    );
                  },
                ),
                const Divider(),

                // Categorias
                if (!provider.isCustomMode)
                  _SettingItem(
                    icon: provider.selectedCategory?.icon ?? '🎲',
                    title: 'Categoría',
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            provider.selectedCategory?.name ?? 'Seleccionar',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Colors.grey),
                      ],
                    ),
                    onTap: () {
                      _showCategoryPicker(context, provider);
                    },
                  ),

                if (provider.isCustomMode)
                  _SettingItem(
                    icon: '✏️',
                    title: 'Modo',
                    trailing: const Text(
                      'Personalizado',
                      style: TextStyle(
                        color: Colors.purple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () => provider.setCustomMode(false),
                  ),

                const SizedBox(height: 24),

                SwitchListTile(
                  title: const Text(
                    'Pistas para Impostores',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: const Text(
                    'Muestra la categoría al impostor para ayudarle',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  value: provider.impostorHintsEnabled,
                  activeTrackColor: const Color(0xFFFF512F),
                  activeThumbColor: Colors.white,
                  onChanged: (val) => provider.setImpostorHints(val),
                ),

                const SizedBox(height: 12),

                SwitchListTile(
                  title: const Text(
                    'Modo Palabras Personalizadas',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  value: provider.isCustomMode,
                  activeTrackColor: const Color(0xFFFF512F),
                  activeThumbColor: Colors.white,
                  onChanged: (val) => provider.setCustomMode(val),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              if (!provider.isCustomMode && provider.selectedCategory == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Selecciona una categoría')),
                );
                return;
              }
              provider.proceedToGameOrInput();
              if (provider.isCustomMode) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const InputWordsScreen()),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RoleRevealScreen()),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            child: const Text(
              'Comienza el juego',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  void _showCategoryPicker(BuildContext context, GameProvider provider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return SizedBox(
          height: 400,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: LocalCategories.categories.length,
            itemBuilder: (ctx, i) {
              final cat = LocalCategories.categories[i];
              return ListTile(
                leading: Text(cat.icon, style: const TextStyle(fontSize: 24)),
                title: Text(
                  cat.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  provider.selectCategory(cat);
                  Navigator.pop(context);
                },
              );
            },
          ),
        );
      },
    );
  }
}

class _SettingItem extends StatelessWidget {
  final String icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingItem({
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text(icon, style: const TextStyle(fontSize: 24)),
      title: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }
}

// Stateful Picker to ensure it rebuilds correctly during drag
class _ValuePicker extends StatefulWidget {
  final String title;
  final int value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  const _ValuePicker({
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  State<_ValuePicker> createState() => _ValuePickerState();
}

class _ValuePickerState extends State<_ValuePicker> {
  late double _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            widget.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Slider(
              value: _currentValue,
              min: widget.min,
              max: widget.max,
              divisions: (widget.max - widget.min).toInt(),
              label: '${_currentValue.toInt()}',
              activeColor: const Color(0xFFFF512F),
              onChanged: (val) {
                setState(() {
                  _currentValue = val;
                });
                widget.onChanged(val);
              },
            ),
          ),
          Text(
            '${_currentValue.toInt()}',
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF512F),
            ),
          ),
        ],
      ),
    );
  }
}
