import 'dart:math';
import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../models/player_model.dart';

enum GameStatus { setup, inputtingWords, revealing, playing, voting, results }

class GameProvider extends ChangeNotifier {
  // Game settings
  List<Player> _players = [];
  int _impostorCount = 1;
  final Set<GameCategory> _selectedCategories = {}; // Multi-category support
  bool _isCustomMode = false;
  bool _impostorHintsEnabled = true;

  // Game state
  GameStatus _status = GameStatus.setup;
  String _currentWord = '';
  final Set<String> _impostorIds = {}; // Store Impostor IDs instead of indices
  int _currentPlayerIndex = 0;
  bool _isRoleVisible = false;

  // Hints / Suggestions
  final List<String> _questionSuggestions = [
    "¿De qué material está hecho?",
    "¿Es algo que usamos todos los días?",
    "¿Se puede comer?",
    "¿Es un lugar real?",
    "¿Cabe en una caja de zapatos?",
    "¿Qué olor tiene?",
    "¿Cuál es su función principal?",
    "¿Lo usarías en invierno?",
    "¿Es peligroso?",
    "¿Es caro o barato?",
  ];
  String? _currentSuggestion;

  // Custom Words State
  final List<String> _customWordsPool = [];

  // Voting State
  final Map<String, int> _votes = {}; // playerId -> voteCount
  List<String> _impostorsFound = []; // IDs of players voted out
  bool _gameWonByCivilians = false;

  // Getters
  List<Player> get players => _players;
  int get playerCount => _players.length;
  int get impostorCount => _impostorCount;
  Set<GameCategory> get selectedCategories => _selectedCategories;
  bool get isCustomMode => _isCustomMode;
  bool get impostorHintsEnabled => _impostorHintsEnabled;

  GameStatus get status => _status;
  int get currentPlayerIndex => _currentPlayerIndex;
  // Helper to get current player safely
  Player get currentPlayer => _players[_currentPlayerIndex];

  bool get isRoleVisible => _isRoleVisible;
  Set<String> get impostorIds => _impostorIds;
  List<String> get impostorsFound => _impostorsFound;
  String get currentWord => _currentWord;
  bool get gameWonByCivilians => _gameWonByCivilians;
  String? get currentSuggestion => _currentSuggestion;

  // Backward compatibility for colors if needed, but better to use player.color
  List<Color> get playerColors => _players.map((p) => p.color).toList();

  String? _currentWordCategoryName;
  String? get currentWordCategoryName => _currentWordCategoryName;

  GameProvider() {
    _initializeDefaultPlayers();
  }

  void _initializeDefaultPlayers() {
    _players = [
      Player(id: '1', name: 'Jugador 1', color: _generateRandomColor()),
      Player(id: '2', name: 'Jugador 2', color: _generateRandomColor()),
      Player(id: '3', name: 'Jugador 3', color: _generateRandomColor()),
    ];
  }

  Color _generateRandomColor() {
    final random = Random();
    return HSVColor.fromAHSV(
      1.0,
      random.nextDouble() * 360, // Random Hue
      0.7 + random.nextDouble() * 0.3, // High Saturation
      0.6 + random.nextDouble() * 0.4, // Medium-High Value
    ).toColor();
  }

  // --- Player Management ---

  void addPlayer() {
    final nextId = (_players.length + 1).toString();
    _players.add(
      Player(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // Unique ID
        name: 'Jugador ${nextId}',
        color: _generateRandomColor(),
      ),
    );
    notifyListeners();
  }

  void removePlayer(int index) {
    if (_players.length > 3) {
      _players.removeAt(index);
      // Adjust impostor count if needed
      if (_impostorCount >= _players.length) {
        _impostorCount = max(1, _players.length - 1);
      }
      notifyListeners();
    }
  }

  void updatePlayerName(int index, String newName) {
    if (index >= 0 && index < _players.length) {
      _players[index].name = newName;
      notifyListeners();
    }
  }

  void setImpostorCount(double value) {
    int val = value.toInt();
    if (val < _players.length) {
      _impostorCount = val;
      notifyListeners();
    }
  }

  void setCustomMode(bool value) {
    _isCustomMode = value;
    notifyListeners();
  }

  void setImpostorHints(bool value) {
    _impostorHintsEnabled = value;
    notifyListeners();
  }

  void toggleCategory(GameCategory category) {
    if (_selectedCategories.any((c) => c.id == category.id)) {
      _selectedCategories.removeWhere((c) => c.id == category.id);
    } else {
      _selectedCategories.add(category);
    }
    notifyListeners();
  }

  void generateSuggestion() {
    final random = Random();
    _currentSuggestion =
        _questionSuggestions[random.nextInt(_questionSuggestions.length)];
    notifyListeners();
  }

  // --- Game Flow Control ---

  void startSetup() {
    _status = GameStatus.setup;
    _customWordsPool.clear();
    _votes.clear();
    _impostorsFound.clear();
    _gameWonByCivilians = false;
    _currentSuggestion = null;
    notifyListeners();
  }

  void proceedToGameOrInput() {
    if (_isCustomMode) {
      _status = GameStatus.inputtingWords;
      _currentPlayerIndex = 0;
      _customWordsPool.clear();
    } else {
      if (_selectedCategories.isEmpty) return;
      // Combine all words from selected categories
      final allWords = _selectedCategories.expand((c) => c.words).toList();
      _pickWordAndAssignRoles(allWords);
    }
    notifyListeners();
  }

  // --- Custom Words Logic ---

  void addCustomWord(String word) {
    _customWordsPool.add(word);
    if (_currentPlayerIndex < playerCount - 1) {
      _currentPlayerIndex++;
    } else {
      // All players input words. Now pick one.
      _pickWordAndAssignRoles(_customWordsPool);
    }
    notifyListeners();
  }

  void _pickWordAndAssignRoles(List<String> pool) {
    final random = Random();

    // Logic: Pick a random category from the selected ones to ensure consistency
    if (_selectedCategories.isNotEmpty) {
      final categoryList = _selectedCategories.toList();
      final selectedCat = categoryList[random.nextInt(categoryList.length)];
      _currentWordCategoryName = selectedCat.name;

      // Override pool to use only words from this specific category
      if (selectedCat.words.isNotEmpty) {
        _currentWord =
            selectedCat.words[random.nextInt(selectedCat.words.length)];
      } else {
        _currentWord = "Error";
      }
    } else if (pool.isNotEmpty) {
      // Fallback for custom words or unexpected empty categories
      _currentWord = pool[random.nextInt(pool.length)];
      _currentWordCategoryName = "Personalizado";
    } else {
      _currentWord = "Error";
      _currentWordCategoryName = "Error";
    }

    // Assign multiple impostors
    _impostorIds.clear();
    final List<Player> availablePlayers = List.from(_players);
    // Shuffle to pick random impostors
    availablePlayers.shuffle();

    for (int i = 0; i < _impostorCount; i++) {
      if (i < availablePlayers.length) {
        _impostorIds.add(availablePlayers[i].id);
      }
    }

    // Regenerate color is not strictly needed if we want persistent colors,
    // but the user might expect new colors every game.
    // Let's Refresh colors to keep things fresh.
    for (var player in _players) {
      player.color = _generateRandomColor();
    }

    // Prepare for revealing
    _currentPlayerIndex = 0;
    _isRoleVisible = false;
    _status = GameStatus.revealing;

    notifyListeners();
  }

  // --- Revealing Logic ---

  void toggleRoleVisibility() {
    _isRoleVisible = !_isRoleVisible;
    notifyListeners();
  }

  bool nextPlayerReveal() {
    _isRoleVisible = false;
    if (_currentPlayerIndex < playerCount - 1) {
      _currentPlayerIndex++;
      notifyListeners();
      return true;
    } else {
      _status = GameStatus.playing;
      notifyListeners();
      return false;
    }
  }

  bool isImpostor(Player player) => _impostorIds.contains(player.id);
  bool isCurrentPlayerImpostor() => _impostorIds.contains(currentPlayer.id);

  // --- Default Game Action ---

  void startVoting() {
    _votes.clear();
    _status = GameStatus.voting;
    notifyListeners();
  }

  // --- Voting Logic ---

  void voteFor(String candidateId) {
    _votes[candidateId] = (_votes[candidateId] ?? 0) + 1;
    notifyListeners();
  }

  int getVoteCount(String id) => _votes[id] ?? 0;

  void finalizeVoting() {
    if (_votes.isEmpty) return;

    // Find candidate with max votes
    int maxVotes = 0;
    String candidateId = '';

    _votes.forEach((key, value) {
      if (value > maxVotes) {
        maxVotes = value;
        candidateId = key;
      }
    });

    _impostorsFound = [candidateId]; // Store who was voted out

    // Check if the candidate is an impostor
    _gameWonByCivilians = _impostorIds.contains(candidateId);

    _status = GameStatus.results;
    notifyListeners();
  }

  void resetGame() {
    startSetup();
  }
}
