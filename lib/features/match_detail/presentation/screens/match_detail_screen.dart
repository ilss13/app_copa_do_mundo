import 'package:flutter/material.dart';

class MatchDetailScreen extends StatelessWidget {
  const MatchDetailScreen({super.key, required this.matchId});

  final int matchId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhe do Jogo')),
      body: Center(child: Text('Jogo #$matchId — em breve')),
    );
  }
}
