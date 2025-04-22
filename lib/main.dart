// main.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:flutter/services.dart';

void main() {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(const PokemonApp());
}

class PokemonApp extends StatelessWidget {
  const PokemonApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pokemon Memory Game',
      theme: ThemeData(
        primarySwatch: Colors.red,
        fontFamily: 'Quicksand',
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          bodyLarge: TextStyle(
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
      ),
      home: const WelcomeScreen(),
    );
  }
}

class BreathingPokeball extends StatefulWidget {
  final double baseSize;
  const BreathingPokeball({Key? key, this.baseSize = 150}) : super(key: key);

  @override
  State<BreathingPokeball> createState() => _BreathingPokeballState();
}

class _BreathingPokeballState extends State<BreathingPokeball>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: Image.asset(
            'assets/images/pokeball.png',
            height: widget.baseSize,
          ),
        );
      },
    );
  }
}

class BouncingText extends StatefulWidget {
  final String text;
  final TextStyle style;

  const BouncingText({
    Key? key,
    required this.text,
    required this.style,
  }) : super(key: key);

  @override
  State<BouncingText> createState() => _BouncingTextState();
}

class _BouncingTextState extends State<BouncingText>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.text.length,
      (index) => AnimationController(
        duration: Duration(milliseconds: 500 + (index * 40 % 400)),
        vsync: this,
      ),
    );

    _animations = _controllers
        .map((controller) => Tween<double>(begin: 0, end: 1).animate(
              CurvedAnimation(
                parent: controller,
                curve: Curves.elasticOut,
              ),
            ))
        .toList();

    for (var i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: 100 * i), () {
        if (mounted)
          _controllers[i]
              .repeat(reverse: true, period: const Duration(seconds: 3));
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.text.length, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, -5 * _animations[index].value),
              child: Text(
                widget.text[index],
                style: widget.style,
              ),
            );
          },
        );
      }),
    );
  }
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _buttonController;
  late Animation<double> _buttonAnimation;

  @override
  void initState() {
    super.initState();
    _buttonController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _buttonAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _buttonController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFF1A1A), Color(0xFFFFCC00)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Floating Pokeballs in background
              Positioned(
                top: 50,
                right: 20,
                child: Opacity(
                  opacity: 0.3,
                  child: BreathingPokeball(baseSize: 80),
                ),
              ),
              Positioned(
                bottom: 70,
                left: 30,
                child: Opacity(
                  opacity: 0.3,
                  child: BreathingPokeball(baseSize: 60),
                ),
              ),

              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated title
                    const BouncingText(
                      text: 'Pokemon Memory',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 5.0,
                            color: Colors.black38,
                            offset: Offset(2.0, 2.0),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Animated Pokeball
                    const BreathingPokeball(),

                    const SizedBox(height: 40),
                    const Text(
                      'Match the Pokemon!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        'Flip the cards and find the matching Pokemon pairs. Can you catch them all?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 60),

                    // Animated Button
                    AnimatedBuilder(
                      animation: _buttonAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _buttonAnimation.value,
                          child: ElevatedButton(
                            onPressed: () {
                              HapticFeedback.mediumImpact();
                              Navigator.of(context).push(
                                PageRouteBuilder(
                                  pageBuilder: (context, animation,
                                          secondaryAnimation) =>
                                      const GameScreen(),
                                  transitionsBuilder: (context, animation,
                                      secondaryAnimation, child) {
                                    var begin = const Offset(1.0, 0.0);
                                    var end = Offset.zero;
                                    var curve = Curves.easeInOut;
                                    var tween = Tween(begin: begin, end: end)
                                        .chain(CurveTween(curve: curve));
                                    return SlideTransition(
                                      position: animation.drive(tween),
                                      child: child,
                                    );
                                  },
                                  transitionDuration:
                                      const Duration(milliseconds: 600),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 15),
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 8,
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Start Game',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Icon(
                                  Icons.play_arrow_rounded,
                                  color: Colors.red,
                                  size: 28,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  List<Map<String, dynamic>> cards = [];
  List<int> selectedCards = [];
  int matchedPairs = 0;
  int attempts = 0;
  bool isProcessing = false;

  // Animation controllers
  late AnimationController _scoreController;
  late AnimationController _backgroundController;
  late Animation<Color?> _backgroundAnimation;

  // *** ADD: Timer references ***
  Timer? _flipBackTimer;
  Timer? _matchCheckTimer;

  final List<String> pokemonNames = [
    'Pikachu',
    'Bulbasaur',
    'Charmander',
    'Squirtle',
    'Eevee',
    'Jigglypuff',
    'Meowth',
    'Psyduck',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize controllers first
    _scoreController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _backgroundController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat(reverse: true); // Added reverse: true for smoother looping

    _backgroundAnimation = ColorTween(
      begin: Colors.blue[100],
      end: Colors.blue[300],
    ).animate(
      CurvedAnimation(
        parent: _backgroundController,
        curve: Curves.easeInOut,
      ),
    );

    // Then initialize the game state
    initializeGame();
  }

  @override
  void dispose() {
    // *** ADD: Cancel timers on dispose ***
    _flipBackTimer?.cancel();
    _matchCheckTimer?.cancel();

    _scoreController.dispose();
    _backgroundController.dispose();

    // Dispose card animation controllers
    for (var card in cards) {
      if (card.containsKey('controller') && card['controller'] != null) {
        (card['controller'] as AnimationController).dispose();
      }
    }
    super.dispose();
  }

  void initializeGame() {
    // *** ADD: Cancel any pending timers before resetting ***
    _flipBackTimer?.cancel();
    _matchCheckTimer?.cancel();

    // Clean up previous card animation controllers if they exist
    for (var card in cards) {
      if (card.containsKey('controller') && card['controller'] != null) {
        (card['controller'] as AnimationController).dispose();
      }
    }

    // Create pairs of Pokemon cards
    cards = [];
    for (int i = 0; i < pokemonNames.length; i++) {
      // Create two cards for each Pokemon name
      for (int j = 0; j < 2; j++) {
        cards.add({
          // Use a unique ID combining name index and pair index (0 or 1)
          'id': (i * 2) + j,
          'name': pokemonNames[i],
          'isFlipped': false,
          'isMatched': false,
          // Create a new controller for each card
          'controller': AnimationController(
            duration: const Duration(milliseconds: 300), // Faster animation
            vsync: this,
          ),
        });
      }
    }

    // Shuffle the cards using the Fisher-Yates algorithm (more robust shuffle)
    final random = Random();
    for (int i = cards.length - 1; i > 0; i--) {
      int n = random.nextInt(i + 1);
      var temp = cards[i];
      cards[i] = cards[n];
      cards[n] = temp;
    }

    // Reset game state variables AFTER creating cards
    selectedCards = [];
    matchedPairs = 0;
    attempts = 0;
    isProcessing = false; // Ensure processing is false

    // Reset score animation controller
    _scoreController.reset();

    // Important: Trigger a rebuild if initializeGame is called while mounted
    if (mounted) {
      setState(() {}); // Update the UI with the new game state
    }
  }

  void flipCard(int index) {
    // Prevent flipping if processing, card already flipped, or card matched
    if (isProcessing ||
        cards[index]['isFlipped'] ||
        cards[index]['isMatched']) {
      return;
    }

    // Play haptic feedback
    HapticFeedback.selectionClick();

    // Trigger flip animation forward
    (cards[index]['controller'] as AnimationController).forward();

    // Update state: card is now flipped, add to selected
    setState(() {
      cards[index]['isFlipped'] = true;
      selectedCards.add(index);
    });

    // Check if two cards are selected
    if (selectedCards.length == 2) {
      isProcessing = true; // Start processing the pair
      attempts++; // Increment attempts count

      final firstCardIndex = selectedCards[0];
      final secondCardIndex = selectedCards[1];
      final firstCard = cards[firstCardIndex];
      final secondCard = cards[secondCardIndex];

      // Check if the names match
      if (firstCard['name'] == secondCard['name']) {
        // Matched Pair
        // *** FIX: Store the timer ***
        _matchCheckTimer = Timer(const Duration(milliseconds: 400), () {
          // Slightly longer delay for match visibility
          if (!mounted) return; // Check if widget is still mounted

          // Animate score change
          _scoreController.forward(from: 0.0);
          HapticFeedback.mediumImpact(); // Success feedback

          setState(() {
            firstCard['isMatched'] = true;
            secondCard['isMatched'] = true;
            matchedPairs++;
            // Only reset selectedCards and isProcessing *after* state update for match
            selectedCards = [];
            isProcessing = false;
          });

          // Check if all pairs are matched (Game Over)
          if (matchedPairs == pokemonNames.length) {
            // Use another timer to show the game complete dialog shortly after match is set
            Timer(const Duration(milliseconds: 300), () {
              if (mounted) {
                // Check mounted again before showing dialog
                showGameCompleteDialog();
              }
            });
          }
        });
      } else {
        // Not Matched
        // *** FIX: Store the timer ***
        _flipBackTimer = Timer(const Duration(milliseconds: 800), () {
          // Slightly longer delay to see the non-match
          if (!mounted) return; // Check if widget is still mounted

          // Reverse flip animation for both cards
          (firstCard['controller'] as AnimationController).reverse();
          (secondCard['controller'] as AnimationController).reverse();

          setState(() {
            firstCard['isFlipped'] = false;
            secondCard['isFlipped'] = false;
            // Only reset selectedCards and isProcessing *after* state update for non-match
            selectedCards = [];
            isProcessing = false;
          });
        });
      }
      // Update attempts immediately in the UI after selecting the second card
      setState(() {});
    }
  }

  // showGameCompleteDialog method remains the same...
  void showGameCompleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 24),
                const BouncingText(
                  text: 'Congratulations!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 5.0,
                        color: Colors.black38,
                        offset: Offset(1.0, 1.0),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const BreathingPokeball(baseSize: 100),
                const SizedBox(height: 16),
                Text(
                  'You found all the Pokemon pairs in $attempts attempts!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        Navigator.of(context).pop(); // Close Dialog
                        Navigator.of(context)
                            .pop(); // Go back to Welcome Screen
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.3),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                      ),
                      child: const Text(
                        'Main Menu',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        Navigator.of(context).pop(); // Close Dialog
                        // Reset the game by calling initializeGame
                        initializeGame();
                        // No need for setState here as initializeGame handles it if mounted
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white, // Ensure text is white
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Play Again',
                            style: TextStyle(
                              // color: Colors.white, // Already set by foregroundColor
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(width: 5),
                          Icon(
                            Icons.replay,
                            // color: Colors.white, // Already set by foregroundColor
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  // build method remains largely the same, just ensure GridView rebuilds
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pokemon Memory Game',
          style: TextStyle(
              // Use theme font implicitly or specify: fontFamily: 'Quicksand',
              fontWeight: FontWeight.bold,
              fontSize: 25, // Slightly larger title
              color: Colors.white,
              shadows: [
                // Add a subtle shadow to the text
                Shadow(
                  blurRadius: 2.0,
                  color: Colors.black38,
                  offset: Offset(1.0, 1.0),
                ),
              ]),
        ),
        backgroundColor: Colors.red.shade500, // Use a specific shade of red
        centerTitle: true, // Center the title
        elevation: 0, // Keep it flat
        
      ),
      body: Column(
        children: [
          // Animated score display (no changes needed here)
          AnimatedBuilder(
            animation: _scoreController,
            builder: (context, child) {
              // Calculate scale factor based on animation value (e.g., bounce effect)
              final scale = 1.0 + (_scoreController.value * 0.2);
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.red.shade400,
                      Colors.orange.shade300,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      // Pairs Score
                      children: [
                        const Text('Pairs',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        Transform.scale(
                          // Apply scale animation to the score text
                          scale: scale,
                          child: Text(
                            '$matchedPairs/${pokemonNames.length}',
                            style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      // Attempts Score
                      children: [
                        const Text('Attempts',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        Text(
                          '$attempts',
                          style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),

          // Animated game board background
          Expanded(
            child: AnimatedBuilder(
              animation: _backgroundAnimation,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        _backgroundAnimation.value ??
                            Colors.blue.shade100, // Use null check
                        Colors.blue.shade200,
                      ],
                    ),
                  ),
                  child: child,
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                // *** Use a Key based on a value that changes on reset (like attempts or a dedicated reset counter) ***
                // This forces GridView to rebuild its children completely when reset happens.
                // Using matchedPairs + attempts as a simple key trigger.
                child: GridView.builder(
                  key: ValueKey(
                      '$matchedPairs-$attempts'), // Force rebuild on reset
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio:
                        0.85, // Adjust aspect ratio slightly if needed
                  ),
                  itemCount: cards.length,
                  itemBuilder: (context, index) {
                    // Ensure card data exists before building
                    if (index >= cards.length ||
                        !cards[index].containsKey('controller') ||
                        cards[index]['controller'] == null) {
                      return const SizedBox
                          .shrink(); // Return empty widget if data is missing
                    }
                    return GestureDetector(
                      onTap: () => flipCard(index),
                      child: FlipCard(
                        // Pass the specific controller for this card
                        controller:
                            cards[index]['controller'] as AnimationController,
                        name: cards[index]['name'],
                        isFlipped: cards[index]['isFlipped'],
                        isMatched: cards[index]['isMatched'],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          HapticFeedback.mediumImpact();
          // Call initializeGame directly. It handles setState if mounted.
          initializeGame();
        },
        backgroundColor: Colors.red,
        foregroundColor: Colors.white, // Ensure icon is white
        child: const Icon(Icons.refresh),
        elevation: 8,
        tooltip: 'Restart Game', // Add tooltip for accessibility
      ),
    );
  }
}

class FlipCard extends StatefulWidget {
  final String name;
  final bool isFlipped;
  final bool isMatched;
  final AnimationController controller;

  const FlipCard({
    Key? key,
    required this.name,
    required this.isFlipped,
    required this.isMatched,
    required this.controller,
  }) : super(key: key);

  @override
  State<FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<FlipCard> {
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _flipAnimation = Tween<double>(begin: 0, end: pi).animate(
      CurvedAnimation(
        parent: widget.controller,
        curve: Curves.easeOutQuad, // Smoother curve for better performance
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _flipAnimation,
      builder: (context, child) {
        // Determine if the card should show the back or front based on animation value
        final isCardShowingBack = _flipAnimation.value < (pi / 2);

        // Calculate the rotation angle. Apply rotation up to pi/2, then reverse it
        // to avoid flipping the content backward internally.
        final rotationValue = isCardShowingBack
            ? _flipAnimation.value
            : pi - _flipAnimation.value;

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001) // Add perspective
            ..rotateY(rotationValue), // Apply the calculated rotation
          child: isCardShowingBack
              ? _buildCardBack() // Show back if angle < pi/2
              // *** FIX: Removed the extra Transform.rotateY(pi) here ***
              : _buildCardFront(), // Show front otherwise
        );
      },
    );
  }

  Widget _buildCardFront() {
    // Front side of card (Pokemon) - No changes needed here
    return Container(
      decoration: BoxDecoration(
        color: widget.isMatched ? Colors.green[100] : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: widget.isMatched ? Colors.green : Colors.grey.shade300,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          children: [
            Expanded(
              child: Image.asset(
                'assets/images/${widget.name}.png',
                fit: BoxFit.contain,
              ),
            ),
            Text(
              widget.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey[800],
                fontSize: 10, // Adjusted for potentially better fit
              ),
              overflow:
                  TextOverflow.ellipsis, // Prevent overflow if name is long
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardBack() {
    // Back side of card (Pokeball) - No changes needed here
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.red.shade600, Colors.red.shade400],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: const Offset(1, 1),
          ),
        ],
      ),
      child: Center(
        child: Image.asset(
          'assets/images/pokeball.png',
          width: 45,
        ),
      ),
    );
  }
}
