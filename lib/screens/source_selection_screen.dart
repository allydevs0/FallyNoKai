import 'package:flutter/material.dart';

class SourceSelectionScreen extends StatelessWidget {
  const SourceSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Selecionar Fonte')),
      body: const Center(child: Text('Tela de seleção de fonte aqui...')),
    );
  }
}
