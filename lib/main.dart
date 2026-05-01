import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/balabony_screen.dart';
import 'screens/stories_screen.dart';
import 'games/shared/games_hub_screen.dart';
import 'games/sudoku/sudoku_screen.dart';
import 'games/memory/memory_screen.dart';
import 'games/word_builder/word_builder_screen.dart';
import 'games/proverbs/proverbs_screen.dart';
import 'games/odd_one_out/odd_one_out_screen.dart';
import 'games/math_game/math_game_screen.dart';
import 'games/wordle/wordle_screen.dart';
import 'games/word_chain/word_chain_screen.dart';
import 'games/anagram/anagram_screen.dart';
import 'games/puzzle/puzzle_screen.dart';
import 'games/quiz/quiz_screen.dart';
import 'games/reaction/reaction_screen.dart';
import 'games/sequence/sequence_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF04060a),
    ),
  );
  runApp(const ProviderScope(child: BalabonyApp()));
}

class BalabonyApp extends StatelessWidget {
  const BalabonyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Balabony AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFef9f27),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF04060a),
        textTheme: GoogleFonts.robotoTextTheme(
          ThemeData.dark().textTheme,
        ),
      ),
      home: const GamesHubScreen(),
      routes: {
        '/balabony': (_) => const BalabonyScreen(),
        '/stories': (_) => const StoriesScreen(),
        '/games': (_) => const GamesHubScreen(),
        '/sudoku': (_) => const SudokuScreen(),
        '/memory': (_) => const MemoryScreen(),
        '/word-builder': (_) => const WordBuilderScreen(),
        '/proverbs': (_) => const ProverbsScreen(),
        '/odd-one-out': (_) => const OddOneOutScreen(),
        '/math-game': (_) => const MathGameScreen(),
        '/wordle': (_) => const WordleScreen(),
        '/word-chain': (_) => const WordChainScreen(),
        '/anagram': (_) => const AnagramScreen(),
        '/puzzle': (_) => const PuzzleScreen(),
        '/quiz': (_) => const QuizScreen(),
        '/reaction': (_) => const ReactionScreen(),
        '/sequence': (_) => const SequenceScreen(),
      },
    );
  }
}
