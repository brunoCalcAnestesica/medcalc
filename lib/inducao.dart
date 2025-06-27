import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'shared_data.dart';
import 'condicao_clinica_page.dart';

class InducaoPage extends StatefulWidget {
  const InducaoPage({super.key});

  @override
  State<InducaoPage> createState() => _InducaoPageState();
}

class _InducaoPageState extends State<InducaoPage> {
  Map<String, dynamic> inducoes = {};
  List<MapEntry<String, dynamic>> filtradas = [];
  Set<String> favoritos = {};
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    carregarDados();
    carregarFavoritos();
    _searchController.addListener(_filtrarSituacoes);
  }

  Future<void> carregarDados() async {
    final String data = await rootBundle.loadString('assets/data/inducoes.json');
    final Map<String, dynamic> jsonMap = json.decode(data);
    setState(() {
      inducoes = jsonMap;
      _ordenarFiltradas();
    });
  }

  Future<void> carregarFavoritos() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      favoritos = prefs.getStringList('favoritos_inducao')?.toSet() ?? {};
      _ordenarFiltradas();
    });
  }

  Future<void> salvarFavoritos() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favoritos_inducao', favoritos.toList());
  }

  void alternarFavorito(String key) async {
    setState(() {
      if (favoritos.contains(key)) {
        favoritos.remove(key);
      } else {
        favoritos.add(key);
      }
      _ordenarFiltradas();
    });
    await salvarFavoritos();
  }

  void _filtrarSituacoes() {
    final query = _searchController.text.toLowerCase();
    final todos = inducoes.entries.toList();

    setState(() {
      filtradas = todos
          .where((entry) => entry.value['titulo'].toLowerCase().contains(query))
          .toList();

      filtradas.sort((a, b) {
        final aFav = favoritos.contains(a.key) ? 0 : 1;
        final bFav = favoritos.contains(b.key) ? 0 : 1;
        if (aFav != bFav) {
          return aFav.compareTo(bFav);
        } else {
          return a.value['titulo']
              .toLowerCase()
              .compareTo(b.value['titulo'].toLowerCase());
        }
      });
    });
  }

  void _ordenarFiltradas() {
    filtradas = inducoes.entries.toList();

    filtradas.sort((a, b) {
      final aFav = favoritos.contains(a.key) ? 0 : 1;
      final bFav = favoritos.contains(b.key) ? 0 : 1;
      if (aFav != bFav) {
        return aFav.compareTo(bFav);
      } else {
        return a.value['titulo']
            .toLowerCase()
            .compareTo(b.value['titulo'].toLowerCase());
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final peso = SharedData.peso ?? 70;

    return Column(
      children: [
        AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Buscar condição clínica...',
              border: InputBorder.none,
              hintStyle: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w500,
                fontSize: 18,
              ),
              icon: Icon(Icons.search, color: Colors.black),
            ),
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: filtradas.isEmpty ? _buildEmptyState() : _buildListView(),
          ),
        ),
      ],
    );
  }

  Widget _buildListView() {
    final peso = SharedData.peso ?? 70;
    return ListView.builder(
      itemCount: filtradas.length,
      itemBuilder: (context, index) {
        final key = filtradas[index].key;
        final dados = filtradas[index].value;
        final List medicamentos = dados['medicamentos'];

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        dados['titulo'],
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        favoritos.contains(key)
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        color: favoritos.contains(key)
                            ? Colors.amber[700]
                            : Colors.grey[400],
                        size: 22,
                      ),
                      tooltip: favoritos.contains(key)
                          ? 'Remover dos favoritos'
                          : 'Adicionar aos favoritos',
                      onPressed: () => alternarFavorito(key),
                      padding: EdgeInsets.zero,
                      constraints:
                          const BoxConstraints(minWidth: 24, minHeight: 24),
                      visualDensity: VisualDensity.compact,
                    ),
                    IconButton(
                      icon: const Icon(Icons.info_outline,
                          size: 22, color: Colors.blueGrey),
                      tooltip: 'Abrir detalhes clínicos',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                CondicaoClinicaPage(arquivoJson: key),
                          ),
                        );
                      },
                      padding: EdgeInsets.zero,
                      constraints:
                          const BoxConstraints(minWidth: 24, minHeight: 24),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...medicamentos.map((med) {
                  final nome = med['nome'];
                  final dose = med['dose_mg_kg'] * peso;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(nome, style: const TextStyle(fontSize: 16)),
                        Text(
                          "${dose.toStringAsFixed(2)} mg",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Nenhuma condição encontrada.',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 12),
          const Text('Ajude-nos a melhorar:', style: TextStyle(fontSize: 14)),
          TextButton(
            onPressed: () {
              final Uri emailUri = Uri(
                scheme: 'mailto',
                path: 'bhdaroz@gmail.com',
                query: 'subject=Feedback sobre o app MC Emergency',
              );
              launchUrl(emailUri);
            },
            child: const Text(
              'bhdaroz@gmail.com',
              style: TextStyle(
                fontSize: 14,
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}