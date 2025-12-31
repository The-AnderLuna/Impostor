import 'dart:math';
import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../data/local_categories.dart'; // Ensure this is imported for suggestions if needed.

enum GameStatus { setup, inputtingWords, revealing, playing, voting, results }

class GameProvider extends ChangeNotifier {
  // Game settings
  int _playerCount = 4; // Default to 4
  int _impostorCount = 1;
  GameCategory? _selectedCategory;
  bool _isCustomMode = false;
  bool _impostorHintsEnabled = true;

  // Game state
  GameStatus _status = GameStatus.setup;
  String _currentWord = '';
  final Set<int> _impostorIndices = {}; // Support multiple impostors
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
  final Map<int, int> _votes = {}; // playerIndex -> voteCount
  List<int> _impostorsFound = []; // Indices of players voted out
  bool _gameWonByCivilians = false;

  // Getters
  int get playerCount => _playerCount;
  int get impostorCount => _impostorCount;
  GameCategory? get selectedCategory => _selectedCategory;
  bool get isCustomMode => _isCustomMode;
  bool get impostorHintsEnabled => _impostorHintsEnabled;

  GameStatus get status => _status;
  int get currentPlayerIndex => _currentPlayerIndex;
  bool get isRoleVisible => _isRoleVisible;
  Set<int> get impostorIndices => _impostorIndices;
  List<int> get impostorsFound => _impostorsFound;
  String get currentWord => _currentWord;
  bool get gameWonByCivilians => _gameWonByCivilians;
  String? get currentSuggestion => _currentSuggestion;

  void setPlayerCount(double value) {
    _playerCount = value.toInt();
    // Validate impostor count
    if (_impostorCount >= _playerCount) {
      _impostorCount = max(1, _playerCount - 1);
    }
    notifyListeners();
  }

  void setImpostorCount(double value) {
    int val = value.toInt();
    if (val < _playerCount) {
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

  void selectCategory(GameCategory? category) {
    _selectedCategory = category;
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
      if (_selectedCategory == null) return;
      _pickWordAndAssignRoles(_selectedCategory!.words);
    }
    notifyListeners();
  }

  // --- Custom Words Logic ---

  void addCustomWord(String word) {
    _customWordsPool.add(word);
    if (_currentPlayerIndex < _playerCount - 1) {
      _currentPlayerIndex++;
    } else {
      // All players input words. Now pick one.
      _pickWordAndAssignRoles(_customWordsPool);
    }
    notifyListeners();
  }

  void _pickWordAndAssignRoles(List<String> pool) {
    final random = Random();
    if (pool.isEmpty) {
      _currentWord = "Error";
    } else {
      _currentWord = pool[random.nextInt(pool.length)];
    }

    // Assign multiple impostors
    _impostorIndices.clear();
    while (_impostorIndices.length < _impostorCount) {
      int idx = random.nextInt(_playerCount);
      _impostorIndices.add(idx);
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
    if (_currentPlayerIndex < _playerCount - 1) {
      _currentPlayerIndex++;
      notifyListeners();
      return true;
    } else {
      _status = GameStatus.playing;
      notifyListeners();
      return false;
    }
  }

  bool isImpostor(int index) => _impostorIndices.contains(index);

  // --- Default Game Action ---

  void startVoting() {
    _votes.clear();
    _status = GameStatus.voting;
    notifyListeners();
  }

  // --- Voting Logic ---

  void voteFor(int candidateIndex) {
    // Logic: In a multi-impostor game, usually finding ONE is enough, or finding ALL.
    // Let's assume Spyfall standard: You vote for ONE person. If a majority votes for an impostor, civilians win.
    _votes[candidateIndex] = (_votes[candidateIndex] ?? 0) + 1;
    notifyListeners();
  }

  int getVoteCount(int index) => _votes[index] ?? 0;

  void finalizeVoting() {
    if (_votes.isEmpty) return;

    // Find candidate with max votes
    int maxVotes = 0;
    int candidate = -1;

    _votes.forEach((key, value) {
      if (value > maxVotes) {
        maxVotes = value;
        candidate = key;
      }
    });

    _impostorsFound = [candidate]; // Store who was voted out
    _gameWonByCivilians = isImpostor(
      candidate,
    ); // Win if the voted person IS an impostor

    _status = GameStatus.results;
    notifyListeners();
  }

  void resetGame() {
    startSetup();
  }
}
