import 'package:flutter/material.dart';
import 'shared_data.dart';

class PcrPage extends StatelessWidget {
  const PcrPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Idade: \${SharedData.idade ?? '-'} anos"),
            Text("Peso: \${SharedData.peso ?? '-'} kg"),
            Text("Altura: \${SharedData.altura ?? '-'} cm"),
            Text("Faixa Etária: \${SharedData.faixaEtaria}"),
            const SizedBox(height: 20),
            const Text('Conteúdo específico da tela.'),
          ],
        ),
      ),
    );
  }
}