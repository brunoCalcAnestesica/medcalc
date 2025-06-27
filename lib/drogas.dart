import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'shared_data.dart';
import 'bulario_page.dart';
import 'package:shared_preferences/shared_preferences.dart';



//CONFIGURAÇÕES//
/**/Widget buildMedicamentoExpansivel({required BuildContext context, required String nome, required String idBulario, required bool isFavorito, required VoidCallback onToggleFavorito, required Widget conteudo,
})
{return Card(
  margin: const EdgeInsets.symmetric(vertical: 6),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  elevation: 2,
  child: ExpansionTile(
    tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    iconColor: Colors.indigo,
    collapsedIconColor: Colors.grey,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    title: Row(
      children: [
        Expanded(
          child: Text(
            nome,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: Icon(
                isFavorito ? Icons.star_rounded : Icons.star_border_rounded,
                color: isFavorito ? Colors.amber[700] : Colors.grey[400],
                size: 24,
              ),
              tooltip: isFavorito ? 'Remover dos favoritos' : 'Adicionar aos favoritos',
              onPressed: onToggleFavorito,
              visualDensity: VisualDensity.compact,
            ),
            IconButton(
              icon: const Icon(Icons.medical_information_rounded, size: 24, color: Colors.blueGrey),
              tooltip: 'Abrir bulário',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BularioPage(principioAtivo: idBulario),
                  ),
                );
              },
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ],
    ),
    children: [
      conteudo,
    ],
  ),
);}
/**/ class FavoritosManager {
  static const _key = 'medicamentosFavoritos';

  static Future<Set<String>> obterFavoritos() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key)?.toSet() ?? {};
  }

  static Future<void> salvarFavorito(
      String nomeMedicamento, bool favorito) async {
    final prefs = await SharedPreferences.getInstance();
    final favoritos = prefs.getStringList(_key)?.toSet() ?? {};

    if (favorito) {
      favoritos.add(nomeMedicamento);
    } else {
      favoritos.remove(nomeMedicamento);
    }

    await prefs.setStringList(_key, favoritos.toList());
  }
}
/**/ class DrogasPage extends StatefulWidget {
  const DrogasPage({super.key});

  @override
  State<DrogasPage> createState() => _DrogasPageState();
}
/**/ class ConversaoInfusaoSlider extends StatefulWidget {
  final double peso;
  final Map<String, double> opcoesConcentracoes;
  final double doseMin;
  final double doseMax;
  final String unidade;

  const ConversaoInfusaoSlider({
    Key? key,
    required this.peso,
    required this.opcoesConcentracoes,
    required this.doseMin,
    required this.doseMax,
    required this.unidade,
  }) : super(key: key);

  @override
  State<ConversaoInfusaoSlider> createState() => _ConversaoInfusaoSliderState();
}
/**/ class _ConversaoInfusaoSliderState extends State<ConversaoInfusaoSlider> {
  late String concentracaoSelecionada;
  late double dose;
  late double mlHora;

  @override
  void initState() {
    super.initState();
    concentracaoSelecionada = widget.opcoesConcentracoes.keys.firstWhere(
          (key) => key != null && key.trim().isNotEmpty,
      orElse: () => '',
    );
    dose = widget.doseMin.clamp(widget.doseMin, widget.doseMax);
    mlHora = _calcularMlHora();
  }

  double _calcularMlHora() {
    final conc = widget.opcoesConcentracoes[concentracaoSelecionada] ?? 1;
    final unidade = widget.unidade.toLowerCase();

    final isMg = unidade.contains('mg');
    final isPerMin = unidade.contains('/min');

    final fatorPeso = widget.peso;
    final fatorTempo = isPerMin ? 60 : 1;
    final fatorUnidade = isMg ? 1000 : 1; // se for mg, converte para mcg

    final doseConvertida = dose * fatorUnidade;

    return (doseConvertida * fatorPeso * fatorTempo) / conc;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: widget.opcoesConcentracoes.keys.contains(concentracaoSelecionada)
              ? concentracaoSelecionada
              : null,
          items: widget.opcoesConcentracoes.keys.map((opcao) {
            return DropdownMenuItem(
              value: opcao,
              child: Text(opcao, style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: (valor) {
            if (valor != null) {
              setState(() {
                concentracaoSelecionada = valor;
                mlHora = _calcularMlHora();
              });
            }
          },
          decoration: const InputDecoration(
            labelText: 'Selecionar Solução',
            border: OutlineInputBorder(),
            isDense: true,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Text('${dose.toStringAsFixed(1)} ${widget.unidade}',
                style: const TextStyle(fontSize: 14)),
            const Spacer(),
            Text(
              '${mlHora.toStringAsFixed(1)} mL/h',
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo),
            ),
          ],
        ),
        Slider(
          value: dose.clamp(widget.doseMin, widget.doseMax),
          min: widget.doseMin,
          max: widget.doseMax,
          divisions: ((widget.doseMax - widget.doseMin) * 100).round(),
          label: '${dose.toStringAsFixed(1)}',
          onChanged: (valor) {
            setState(() {
              dose = valor;
              mlHora = _calcularMlHora();
            });
          },
        ),
      ],
    );
  }
}
/**/ Widget buildEstrelaFavorito({
  required bool isFavorito,
  required VoidCallback onToggle,
}) {return IconButton(icon: Icon(
    isFavorito ? Icons.star_rounded : Icons.star_border_rounded,
    color: isFavorito ? Colors.amber[700] : Colors.grey[400],
    size: 26,
  ), tooltip: isFavorito ? 'Remover dos favoritos' : 'Adicionar aos favoritos', onPressed: onToggle, padding: const EdgeInsets.all(0), visualDensity: VisualDensity.compact, constraints: const BoxConstraints(),);}
/**/ Widget _linhaIndicacaoDoseFixa({required String titulo, required String descricaoDose, required String unidade, required double valorMinimo, required double valorMaximo,}) {return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 4),
        Text(descricaoDose, textAlign: TextAlign.justify),
        const SizedBox(height: 4),
        Text(
          'Dose: ${valorMinimo.toStringAsFixed(1)} – ${valorMaximo.toStringAsFixed(1)} $unidade',
          style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.w500),
        ),
        const Divider(),
      ],
    ),
  );}
/**/ Widget _linhaPreparo(String descricao, String concentracao) {final bool temTextoDireito = concentracao.trim().isNotEmpty;return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      children: [
        Expanded(
          flex: temTextoDireito ? 7 : 10,
          child: Text(
            descricao,
            textAlign: TextAlign.justify,
            style: const TextStyle(fontSize: 14),
          ),
        ),
        if (temTextoDireito)
          Expanded(
            flex: 3,
            child: Text(
              concentracao,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
      ],
    ),
  );}
/**/ Widget _textoObs(String texto) {return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Text(
      texto,
      textAlign: TextAlign.justify,
      style: const TextStyle(fontSize: 14),
    ),
  );}
/**/ Widget _linhaIndicacaoDoseCalculada({
  required String titulo,
  required String descricaoDose,
  double? dosePorKg,
  double? dosePorKgMinima,
  double? dosePorKgMaxima,
  double? doseMaxima,
  String? unidade,
  required double peso,

}) {
  String resultadoTexto = '';
  if (dosePorKg != null) {
    double calculado = dosePorKg * peso;
    if (doseMaxima != null && calculado > doseMaxima) {
      calculado = doseMaxima;
    }
    resultadoTexto = '${calculado.toStringAsFixed(1)}${unidade != null && unidade.isNotEmpty ? ' $unidade' : ''}';
  } else if (dosePorKgMinima != null && dosePorKgMaxima != null) {
    double min = dosePorKgMinima * peso;
    double max = dosePorKgMaxima * peso;
    if (doseMaxima != null) {
      if (min > doseMaxima) min = doseMaxima;
      if (max > doseMaxima) max = doseMaxima;
    }
    if (min.toStringAsFixed(1) == max.toStringAsFixed(1)) {
      resultadoTexto = '${min.toStringAsFixed(1)}${unidade != null && unidade.isNotEmpty ? ' $unidade' : ''}';
    } else {
      resultadoTexto = '${min.toStringAsFixed(1)} - ${max.toStringAsFixed(1)}${unidade != null && unidade.isNotEmpty ? ' $unidade' : ''}';
    }
  } else if (unidade != null && unidade.isNotEmpty) {
    resultadoTexto = unidade;
  }
  final bool mostrarDireita = resultadoTexto.isNotEmpty;
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: mostrarDireita ? 6 : 10,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text('$descricaoDose', textAlign: TextAlign.justify, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
        if (mostrarDireita)
          Expanded(
            flex: 4,
            child: Align(
              alignment: Alignment.topRight,
              child: Text(
                resultadoTexto,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.indigo,
                ),
              ),
            ),
          ),
      ],
    ),
  );
}
//CONFIGURAÇÕES//

/* LISTA DE MEDICAMENTOS */ /**/
class _DrogasPageState extends State<DrogasPage> {Set<String> favoritos = {};final TextEditingController _searchController = TextEditingController();String _query = '';@override void initState() {super.initState();_carregarFavoritos();_searchController.addListener(() {
      setState(() {
        _query = _searchController.text.toLowerCase();
      });
    });}Future<void> _carregarFavoritos() async {
    final favs = await FavoritosManager.obterFavoritos();
    setState(() {
      favoritos = favs;
    });
  }void _alternarFavorito(String nomeMedicamento) async {
    final novoEstado = !favoritos.contains(nomeMedicamento);
    await FavoritosManager.salvarFavorito(nomeMedicamento, novoEstado);
    if (!mounted) return;
    setState(() {
      if (novoEstado) {
        favoritos.add(nomeMedicamento);
      } else {
        favoritos.remove(nomeMedicamento);
      }
    });
  }@override Widget build(BuildContext context) {final double peso = SharedData.peso ?? 70;final double? idade = SharedData.idade;if (peso == null || idade == null) {return const Scaffold(body: Center(child: CircularProgressIndicator()),);}final bool isAdulto = idade >= 18;
    final List<Map<String, dynamic>> medicamentos = <Map<String, dynamic>>[
      //Adicione os Medicamentos Aqui:
      {
        'nome': 'Adrenalina',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Adrenalina',
          idBulario: 'adrenalina',
          isFavorito: favoritos.contains('Adrenalina'),
          onToggleFavorito: () => _alternarFavorito('Adrenalina'),
          conteudo: buildCardAdrenalina(
            context,
            peso,
            isAdulto,
            favoritos.contains('Adrenalina'),
                () => _alternarFavorito('Adrenalina'),
          ),
        ),
      }, // Adrenalina
      {
        'nome': 'Noradrenalina',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Noradrenalina',
          idBulario: 'bulario_noradrenalina',
          isFavorito: favoritos.contains('Noradrenalina'),
          onToggleFavorito: () => _alternarFavorito('Noradrenalina'),
          conteudo: buildCardNoradrenalina(
            context,
            peso,
            isAdulto,
            favoritos.contains('Noradrenalina'),
                () => _alternarFavorito('Noradrenalina'),
          ),
        ),
      }, // Noradrenalina
      {
        'nome': 'Efedrina',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Efedrina',
          idBulario: 'efedrina',
          isFavorito: favoritos.contains('Efedrina'),
          onToggleFavorito: () => _alternarFavorito('Efedrina'),
          conteudo: buildCardEfedrina(
            context,
            peso,
            isAdulto,
          ),
        ),
      }, // Efedrina
      {
        'nome': 'Metaraminol',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Metaraminol',
          idBulario: 'bulario_metaraminol',
          isFavorito: favoritos.contains('Metaraminol'),
          onToggleFavorito: () => _alternarFavorito('Metaraminol'),
          conteudo: buildCardMetaraminol(
            context,
            peso,
            isAdulto,
          ),
        ),
      }, // Metaraminol
      {
        'nome': 'Fenilefrina',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'fenilefrina',
          idBulario: 'adrenalina',
          isFavorito: favoritos.contains('Fenilefrina'),
          onToggleFavorito: () => _alternarFavorito('Fenilefrina'),
          conteudo: buildCardFenilefrina(
            context,
            peso,
            isAdulto,
          ),
        ),
      }, // Fenilefrina
      {
        'nome': 'Dobutamina',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Dobutamina',
          idBulario: 'dobutamina',
          isFavorito: favoritos.contains('Dobutamina'),
          onToggleFavorito: () => _alternarFavorito('Dobutamina'),
          conteudo: buildCardDobutamina(
            context,
            peso,
            isAdulto,
          ),
        ),
      }, // Dobutamina
      {
        'nome': 'Dopamina',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Dopamina',
          idBulario: 'dopamina',
          isFavorito: favoritos.contains('Dopamina'),
          onToggleFavorito: () => _alternarFavorito('Dopamina'),
          conteudo: buildCardDopamina(
            context,
            peso,
            isAdulto,
            favoritos.contains('Dopamina'),
                () => _alternarFavorito('Dopamina'),
          ),
        ),
      }, // Dopamina
      {
        'nome': 'Vasopressina',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Vasopressina',
          idBulario: 'vasopressina',
          isFavorito: favoritos.contains('Vasopressina'),
          onToggleFavorito: () => _alternarFavorito('Vasopressina'),
          conteudo: buildCardVasopressina(
            context,
            peso,
            isAdulto,
            favoritos.contains('Vasopressina'),
                () => _alternarFavorito('Vasopressina'),
          ),
        ),
      }, // Vasopressina
      {
        'nome': 'Milrinona',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Milrinona',
          idBulario: 'milrinona',
          isFavorito: favoritos.contains('Milrinona'),
          onToggleFavorito: () => _alternarFavorito('Milrinona'),
          conteudo: buildCardMilrinona(
            context,
            peso,
            isAdulto,
          ),
        ),
      }, // Milrinona
      {
        'nome': 'Nitroprussiato de Sódio',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Nitroprussiato de Sódio',
          idBulario: 'nitroprussiato',
          isFavorito: favoritos.contains('Nitroprussiato de Sódio'),
          onToggleFavorito: () => _alternarFavorito('Nitroprussiato de Sódio'),
          conteudo: buildCardNitroprussiato(
            context,
            peso,
            isAdulto,
          ),
        ),
      }, // Nitroprussiato de Sódio
      {
        'nome': 'Nitroglicerina',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Nitroglicerina',
          idBulario: 'nitroglicerina',
          isFavorito: favoritos.contains('Nitroglicerina'),
          onToggleFavorito: () => _alternarFavorito('Nitroglicerina'),
          conteudo: buildCardNitroglicerina(
            context,
            peso,
            isAdulto,
          ),
        ),
      }, // Nitroglicerina
      {
        'nome': 'Timoglobulina',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Timoglobulina',
          idBulario: 'timoglobulina',
          isFavorito: favoritos.contains('Timoglobulina'),
          onToggleFavorito: () => _alternarFavorito('Timoglobulina'),
          conteudo: buildCardTimoglobulina(
            context,
            peso,
            isAdulto,
            favoritos.contains('Timoglobulina'),
                () => _alternarFavorito('Timoglobulina'),
          ),
        ),
      }, // Timoglobulina
      {
        'nome': 'Glicose 50%',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Glicose 50%',
          idBulario: 'glicose50',
          isFavorito: favoritos.contains('Glicose 50%'),
          onToggleFavorito: () => _alternarFavorito('Glicose 50%'),
          conteudo: buildCardGlicose50(
            context,
            peso,
            isAdulto,
            favoritos.contains('Glicose 50%'),
                () => _alternarFavorito('Glicose 50%'),
          ),
        ),
      }, // Glicose 50%
      {
        'nome': 'Insulina Regular',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Insulina Regular',
          idBulario: 'insulina_regular',
          isFavorito: favoritos.contains('Insulina Regular'),
          onToggleFavorito: () => _alternarFavorito('Insulina Regular'),
          conteudo: buildCardInsulinaRegular(
            context,
            peso,
            isAdulto,
            favoritos.contains('Insulina Regular'),
                () => _alternarFavorito('Insulina Regular'),
          ),
        ),
      }, // Insulina Regular
      {
        'nome': 'Fenobarbital',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Fenobarbital',
          idBulario: 'fenobarbital',
          isFavorito: favoritos.contains('Fenobarbital'),
          onToggleFavorito: () => _alternarFavorito('Fenobarbital'),
          conteudo: buildCardFenobarbital(
            context,
            peso,
            isAdulto,
            favoritos.contains('Fenobarbital'),
                () => _alternarFavorito('Fenobarbital'),
          ),
        ),
      }, // Fenobarbital
      {
        'nome': 'Fenitoína',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Fenitoína',
          idBulario: 'fenitoina',
          isFavorito: favoritos.contains('Fenitoína'),
          onToggleFavorito: () => _alternarFavorito('Fenitoína'),
          conteudo: buildCardFenitoina(
            context,
            peso,
            isAdulto,
            favoritos.contains('Fenitoína'),
                () => _alternarFavorito('Fenitoína'),
          ),
        ),
      }, // Fenitoína
      {
        'nome': 'Propofol',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Propofol',
          idBulario: 'propofol',
          isFavorito: favoritos.contains('Propofol'),
          onToggleFavorito: () => _alternarFavorito('Propofol'),
          conteudo: buildCardPropofol(
            context,
            peso,
            isAdulto,
          ),
        ),
      }, // Propofol
      {
        'nome': 'Dextrocetamina',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Dextrocetamina',
          idBulario: 'dextrocetamina',
          isFavorito: favoritos.contains('Dextrocetamina'),
          onToggleFavorito: () => _alternarFavorito('Dextrocetamina'),
          conteudo: buildCardDextrocetamina(
            context,
            peso,
            isAdulto,
          ),
        ),
      }, // Dextrocetamina
      {
        'nome': 'Dexmedetomidina',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Dexmedetomidina',
          idBulario: 'dexmedetomidina',
          isFavorito: favoritos.contains('Dexmedetomidina'),
          onToggleFavorito: () => _alternarFavorito('Dexmedetomidina'),
          conteudo: buildCardDexmedetomidina(
            context,
            peso,
            isAdulto,
            favoritos.contains('Dexmedetomidina'),
                () => _alternarFavorito('Dexmedetomidina'),
          ),
        ),
      }, // Dexmedetomidina
      {
        'nome': 'Clonidina',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Clonidina',
          idBulario: 'clonidina',
          isFavorito: favoritos.contains('Clonidina'),
          onToggleFavorito: () => _alternarFavorito('Clonidina'),
          conteudo: buildCardClonidina(
            context,
            peso,
            isAdulto,
            favoritos.contains('Clonidina'),
                () => _alternarFavorito('Clonidina'),
          ),
        ),
      }, // Clonidina
      {
        'nome': 'Cetamina',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Cetamina',
          idBulario: 'cetamina',
          isFavorito: favoritos.contains('Cetamina'),
          onToggleFavorito: () => _alternarFavorito('Cetamina'),
          conteudo: buildCardCetamina(
            context,
            peso,
            isAdulto,
            favoritos.contains('Cetamina'),
                () => _alternarFavorito('Cetamina'),
          ),
        ),
      }, // Cetamina
      {
        'nome': 'Tiopental',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Tiopental',
          idBulario: 'tiopental',
          isFavorito: favoritos.contains('Tiopental'),
          onToggleFavorito: () => _alternarFavorito('Tiopental'),
          conteudo: buildCardTiopental(
            context,
            peso,
            isAdulto,
            favoritos.contains('Tiopental'),
                () => _alternarFavorito('Tiopental'),
          ),
        ),
      }, // Tiopental
      {
        'nome': 'Etomidato',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Etomidato',
          idBulario: 'etomidato',
          isFavorito: favoritos.contains('Etomidato'),
          onToggleFavorito: () => _alternarFavorito('Etomidato'),
          conteudo: buildCardEtomidato(
            context,
            peso,
            isAdulto,
            favoritos.contains('Etomidato'),
                () => _alternarFavorito('Etomidato'),
          ),
        ),
      }, // Etomidato
      {
        'nome': 'Hioscina',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Hioscina',
          idBulario: 'hioscina',
          isFavorito: favoritos.contains('Hioscina'),
          onToggleFavorito: () => _alternarFavorito('Hioscina'),
          conteudo: buildCardHioscina(
            context,
            peso,
            isAdulto,
            favoritos.contains('Hioscina'),
                () => _alternarFavorito('Hioscina'),
          ),
        ),
      }, // Hioscina
      {
        'nome': 'Dimenidrinato',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Dimenidrinato',
          idBulario: 'dimenidrinato',
          isFavorito: favoritos.contains('Dimenidrinato'),
          onToggleFavorito: () => _alternarFavorito('Dimenidrinato'),
          conteudo: buildCardDimenidrinato(
            context,
            peso,
            isAdulto,
            favoritos.contains('Dimenidrinato'),
                () => _alternarFavorito('Dimenidrinato'),
          ),
        ),
      }, // Dimenidrinato
      {
        'nome': 'Droperidol',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Droperidol',
          idBulario: 'droperidol',
          isFavorito: favoritos.contains('Droperidol'),
          onToggleFavorito: () => _alternarFavorito('Droperidol'),
          conteudo: buildCardDroperidol(
            context,
            peso,
            isAdulto,
          ),
        ),
      }, // Droperidol
      {
        'nome': 'Metoclopramida',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Metoclopramida',
          idBulario: 'metoclopramida',
          isFavorito: favoritos.contains('Metoclopramida'),
          onToggleFavorito: () => _alternarFavorito('Metoclopramida'),
          conteudo: buildCardMetoclopramida(
            context,
            peso,
            isAdulto,
          ),
        ),
      }, // Metoclopramida
      {
        'nome': 'Bromoprida',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Bromoprida',
          idBulario: 'bromoprida',
          isFavorito: favoritos.contains('Bromoprida'),
          onToggleFavorito: () => _alternarFavorito('Bromoprida'),
          conteudo: buildCardBromoprida(
            context,
            peso,
            isAdulto,
          ),
        ),
      }, // Bromoprida
      {
        'nome': 'Adenosina',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Adenosina',
          idBulario: 'adenosina',
          isFavorito: favoritos.contains('Adenosina'),
          onToggleFavorito: () => _alternarFavorito('Adenosina'),
          conteudo: buildCardAdenosina(
            context, peso, isAdulto, favoritos.contains('Adenosina'),
                () => _alternarFavorito('Adenosina'),
          ),
        ),
      }, // Adenosina
      {
        'nome': 'Midazolam',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Midazolam',
          idBulario: 'midazolam',
          isFavorito: favoritos.contains('Midazolam'),
          onToggleFavorito: () => _alternarFavorito('Midazolam'),
          conteudo: buildCardMidazolam(
            context,
            peso,
            isAdulto,
          ),
        ),
      }, // Midazolam
      {
        'nome': 'Diazepam',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Diazepam',
          idBulario: 'diazepam',
          isFavorito: favoritos.contains('Diazepam'),
          onToggleFavorito: () => _alternarFavorito('Diazepam'),
          conteudo: buildCardDiazepam(
            context,
            peso,
            isAdulto,
          ),
        ),
      }, // Diazepam
      {
        'nome': 'Lorazepam',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Lorazepam',
          idBulario: 'lorazepam',
          isFavorito: favoritos.contains('Lorazepam'),
          onToggleFavorito: () => _alternarFavorito('Lorazepam'),
          conteudo: buildCardLorazepam(
            context,
            peso,
            isAdulto,
          ),
        ),
      }, // lorazepam
      {
        'nome': 'Lidocaína (uso EV)',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Lidocaína (uso EV)',
          idBulario: 'lidocaina_ev',
          isFavorito: favoritos.contains('Lidocaína (uso EV)'),
          onToggleFavorito: () => _alternarFavorito('Lidocaína (uso EV)'),
          conteudo: buildCardLidocainaAntiarritmica(
            context, peso, isAdulto, favoritos.contains('Lidocaína (uso EV)'),
                () => _alternarFavorito('Lidocaína (uso EV)'),
          ),
        ),
      }, // Lidocaína (uso EV)
      {
        'nome': 'Amiodarona',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Amiodarona',
          idBulario: 'amiodarona',
          isFavorito: favoritos.contains('Amiodarona'),
          onToggleFavorito: () => _alternarFavorito('Amiodarona'),
          conteudo: buildCardAmiodarona(
            context, peso, isAdulto, favoritos.contains('Amiodarona'),
                () => _alternarFavorito('Amiodarona'),
          ),
        ),
      }, // Amiodarona
      {
        'nome': 'Cloreto de Potássio',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Cloreto de Potássio',
          idBulario: 'cloreto_potassio',
          isFavorito: favoritos.contains('Cloreto de Potássio'),
          onToggleFavorito: () => _alternarFavorito('Cloreto de Potássio'),
          conteudo: buildCardCloretoPotassio(
            context, peso, isAdulto, favoritos.contains('Cloreto de Potássio'),
                () => _alternarFavorito('Cloreto de Potássio'),
          ),
        ),
      }, // Cloreto de Potássio
      {
        'nome': 'Bicarbonato de Sódio',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Bicarbonato de Sódio',
          idBulario: 'bicarbonato_sodio',
          isFavorito: favoritos.contains('Bicarbonato de Sódio'),
          onToggleFavorito: () => _alternarFavorito('Bicarbonato de Sódio'),
          conteudo: buildCardBicarbonatoSodio(
            context, peso, isAdulto, favoritos.contains('Bicarbonato de Sódio'),
                () => _alternarFavorito('Bicarbonato de Sódio'),
          ),
        ),
      }, // Bicarbonato de Sódio
      {
        'nome': 'Cloreto de Cálcio',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Cloreto de Cálcio',
          idBulario: 'cloreto_calcio',
          isFavorito: favoritos.contains('Cloreto de Cálcio'),
          onToggleFavorito: () => _alternarFavorito('Cloreto de Cálcio'),
          conteudo: buildCardCloretoCalcio(
            context, peso, isAdulto, favoritos.contains('Cloreto de Cálcio'),
                () => _alternarFavorito('Cloreto de Cálcio'),
          ),
        ),
      }, // Cloreto de Cálcio
      {
        'nome': 'Gluconato de Cálcio',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Gluconato de Cálcio',
          idBulario: 'gluconato_calcio',
          isFavorito: favoritos.contains('Gluconato de Cálcio'),
          onToggleFavorito: () => _alternarFavorito('Gluconato de Cálcio'),
          conteudo: buildCardGluconatoCalcio(
            context, peso, isAdulto, favoritos.contains('Gluconato de Cálcio'),
                () => _alternarFavorito('Gluconato de Cálcio'),
          ),
        ),
      }, // Gluconato de Cálcio
      {
        'nome': 'Sulfato de Magnésio',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Sulfato de Magnésio',
          idBulario: 'sulfato_magnesio',
          isFavorito: favoritos.contains('Sulfato de Magnésio'),
          onToggleFavorito: () => _alternarFavorito('Sulfato de Magnésio'),
          conteudo: buildCardSulfatoMagnesio(
            context, peso, isAdulto, favoritos.contains('Sulfato de Magnésio'),
                () => _alternarFavorito('Sulfato de Magnésio'),
          ),
        ),
      }, // Sulfato de Magnésio
      {
        'nome': 'Hidrocortisona',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Hidrocortisona',
          idBulario: 'hidrocortisona',
          isFavorito: favoritos.contains('Hidrocortisona'),
          onToggleFavorito: () => _alternarFavorito('Hidrocortisona'),
          conteudo: buildCardHidrocortisona(
            context, peso, isAdulto,
          ),
        ),
      }, // Hidrocortisona
      {
        'nome': 'Dexametasona',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Dexametasona',
          idBulario: 'dexametasona',
          isFavorito: favoritos.contains('Dexametasona'),
          onToggleFavorito: () => _alternarFavorito('Dexametasona'),
          conteudo: buildCardDexametasona(
            context, peso, isAdulto,
          ),
        ),
      }, // Dexametasona
      {
        'nome': 'Metilprednisolona',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Metilprednisolona',
          idBulario: 'metilprednisolona',
          isFavorito: favoritos.contains('Metilprednisolona'),
          onToggleFavorito: () => _alternarFavorito('Metilprednisolona'),
          conteudo: buildCardMetilprednisolona(
            context, peso, isAdulto,
          ),
        ),
      }, // Metilprednisolona
      {
        'nome': 'Betametasona',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Betametasona',
          idBulario: 'betametasona',
          isFavorito: favoritos.contains('Betametasona'),
          onToggleFavorito: () => _alternarFavorito('Betametasona'),
          conteudo: buildCardBetametasona(
            context, peso, isAdulto,
          ),
        ),
      }, // Betametasona
      {
        'nome': 'Ergometrina',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Ergometrina',
          idBulario: 'ergometrina',
          isFavorito: favoritos.contains('Ergometrina'),
          onToggleFavorito: () => _alternarFavorito('Ergometrina'),
          conteudo: buildCardErgometrina(
            context, peso, isAdulto, favoritos.contains('Ergometrina'),
                () => _alternarFavorito('Ergometrina'),
          ),
        ),
      }, // Ergometrina
      {
        'nome': 'Ocitocina',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Ocitocina',
          idBulario: 'ocitocina',
          isFavorito: favoritos.contains('Ocitocina'),
          onToggleFavorito: () => _alternarFavorito('Ocitocina'),
          conteudo: buildCardOcitocina(
            context, peso, isAdulto, favoritos.contains('Ocitocina'),
                () => _alternarFavorito('Ocitocina'),
          ),
        ),
      }, // Ocitocina
      {
        'nome': 'Torasemida',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Torasemida',
          idBulario: 'torasemida',
          isFavorito: favoritos.contains('Torasemida'),
          onToggleFavorito: () => _alternarFavorito('Torasemida'),
          conteudo: buildCardTorasemida(
            context,
            peso,
            isAdulto,
          ),
        ),
      }, // Torasemida
      {
        'nome': 'Bumetadina',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Bumetadina',
          idBulario: 'bumetadina',
          isFavorito: favoritos.contains('Bumetadina'),
          onToggleFavorito: () => _alternarFavorito('Bumetadina'),
          conteudo: buildCardBumetadina(
            context,
            peso,
            isAdulto,
          ),
        ),
      }, // Bumetadina
      {
        'nome': 'Furosemida',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Furosemida',
          idBulario: 'furosemida',
          isFavorito: favoritos.contains('Furosemida'),
          onToggleFavorito: () => _alternarFavorito('Furosemida'),
          conteudo: buildCardFurosemida(
            context,
            peso,
            isAdulto,
          ),
        ),
      }, // Furosemida
      {
        'nome': 'Manitol',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Manitol',
          idBulario: 'manitol',
          isFavorito: favoritos.contains('Manitol'),
          onToggleFavorito: () => _alternarFavorito('Manitol'),
          conteudo: buildCardManitol(
            context,
            peso,
            isAdulto,
          ),
        ),
      }, // Manitol
      {
        'nome': 'Mivacúrio',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Mivacúrio',
          idBulario: 'mivacurio',
          isFavorito: favoritos.contains('Mivacúrio'),
          onToggleFavorito: () => _alternarFavorito('Mivacúrio'),
          conteudo: buildCardMivacurio(
            context,
            peso,
            isAdulto,
          ),
        ),
      }, // Mivacúrio
      {
        'nome': 'Cisatracúrio',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Cisatracúrio',
          idBulario: 'cisatracurio',
          isFavorito: favoritos.contains('Cisatracúrio'),
          onToggleFavorito: () => _alternarFavorito('Cisatracúrio'),
          conteudo: buildCardCisatracurio(
            context,
            peso,
            isAdulto,
          ),
        ),
      }, // Cisatracúrio
      {
        'nome': 'Atracúrio',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Atracúrio',
          idBulario: 'atracurio',
          isFavorito: favoritos.contains('Atracúrio'),
          onToggleFavorito: () => _alternarFavorito('Atracúrio'),
          conteudo: buildCardAtracurio(
            context,
            peso,
            isAdulto,
          ),
        ),
      }, // Atracúrio
      {
        'nome': 'Vecurônio',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Vecurônio',
          idBulario: 'vecuronio',
          isFavorito: favoritos.contains('Vecurônio'),
          onToggleFavorito: () => _alternarFavorito('Vecurônio'),
          conteudo: buildCardVecuronio(
            context,
            peso,
            isAdulto,
          ),
        ),
      }, // Vecurônio
      {
        'nome': 'Rocurônio',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Rocurônio',
          idBulario: 'rocuronio',
          isFavorito: favoritos.contains('Rocurônio'),
          onToggleFavorito: () => _alternarFavorito('Rocurônio'),
          conteudo: buildCardRocuronio(
            context,
            peso,
            isAdulto,
          ),
        ),
      }, // Rocurônio
      {
        'nome': 'Succinilcolina',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Succinilcolina',
          idBulario: 'succinilcolina',
          isFavorito: favoritos.contains('Succinilcolina'),
          onToggleFavorito: () => _alternarFavorito('Succinilcolina'),
          conteudo: buildCardSuccinilcolina(
            context,
            peso,
            isAdulto,
          ),
        ),
      }, // Succinilcolina
      {
        'nome': 'Protamina',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Protamina',
          idBulario: 'protamina',
          isFavorito: favoritos.contains('Protamina'),
          onToggleFavorito: () => _alternarFavorito('Protamina'),
          conteudo: buildCardProtamina(
            context,
            peso,
            isAdulto,
          ),
        ),
      }, // Protamina
      {
        'nome': 'Sugamadex',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Sugamadex',
          idBulario: 'sugamadex',
          isFavorito: favoritos.contains('Sugamadex'),
          onToggleFavorito: () => _alternarFavorito('Sugamadex'),
          conteudo: buildCardSugamadex(
            context,
            peso,
            isAdulto,
          ),
        ),
      }, // Sugamadex
      {
        'nome': 'Flumazenil',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Flumazenil',
          idBulario: 'flumazenil',
          isFavorito: favoritos.contains('Flumazenil'),
          onToggleFavorito: () => _alternarFavorito('Flumazenil'),
          conteudo: buildCardFlumazenil(
            context,
            peso,
            isAdulto,
          ),
        ),
      }, // Flumazenil
      {
        'nome': 'Naloxona',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Naloxona',
          idBulario: 'naloxona',
          isFavorito: favoritos.contains('Naloxona'),
          onToggleFavorito: () => _alternarFavorito('Naloxona'),
          conteudo: buildCardNaloxona(
            context,
            peso,
            isAdulto,
          ),
        ),
      }, // Naloxona
      {
        'nome': 'Neostigmina',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Neostigmina',
          idBulario: 'neostigmina',
          isFavorito: favoritos.contains('Neostigmina'),
          onToggleFavorito: () => _alternarFavorito('Neostigmina'),
          conteudo: buildCardNeostigmina(
            context,
            peso,
            isAdulto,
          ),
        ),
      }, // Neostigmina
      {
        'nome': 'Hidroxicobalamina',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Hidroxicobalamina',
          idBulario: 'hidroxicobalamina',
          isFavorito: favoritos.contains('Hidroxicobalamina'),
          onToggleFavorito: () => _alternarFavorito('Hidroxicobalamina'),
          conteudo: buildCardHidroxicobalamina(
            context,
            peso,
            isAdulto,
          ),
        ),
      }, // Hidroxicobalamina
      {
        'nome': 'Tiossulfato de Sódio',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Tiossulfato de Sódio',
          idBulario: 'tiossulfato_sodio',
          isFavorito: favoritos.contains('Tiossulfato de Sódio'),
          onToggleFavorito: () => _alternarFavorito('Tiossulfato de Sódio'),
          conteudo: buildCardTiossulfatoSodio(
            context,
            peso,
            isAdulto,
          ),
        ),
      }, // Tiossulfato de Sódio
      {
        'nome': 'Dantroleno',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Dantroleno',
          idBulario: 'dantroleno',
          isFavorito: favoritos.contains('Dantroleno'),
          onToggleFavorito: () => _alternarFavorito('Dantroleno'),
          conteudo: buildCardDantroleno(
            context,
            peso,
            isAdulto,
          ),
        ),
      }, // Dantroleno
      {
        'nome': 'Picada de Cobra',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Picada de Cobra',
          idBulario: 'soro_antiofidico',
          isFavorito: favoritos.contains('Picada de Cobra'),
          onToggleFavorito: () => _alternarFavorito('Picada de Cobra'),
          conteudo: buildCardPicadaCobra(
            context,
            peso,
            isAdulto,
          ),
        ),
      }, // Picada de Cobra
      {
        'nome': 'Ipatrópio',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Ipatrópio',
          idBulario: 'ipratropio',
          isFavorito: favoritos.contains('Ipatrópio'),
          onToggleFavorito: () => _alternarFavorito('Ipatrópio'),
          conteudo: buildCardIpatropio(
            context,
            peso,
            isAdulto,
            favoritos.contains('Ipatrópio'),
                () => _alternarFavorito('Ipatrópio'),
          ),
        ),
      }, // Ipatrópio
      {
        'nome': 'Fenoterol',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Fenoterol',
          idBulario: 'fenoterol',
          isFavorito: favoritos.contains('Fenoterol'),
          onToggleFavorito: () => _alternarFavorito('Fenoterol'),
          conteudo: buildCardFenoterol(
            context,
            peso,
            isAdulto,
            favoritos.contains('Fenoterol'),
                () => _alternarFavorito('Fenoterol'),
          ),
        ),
      }, // Fenoterol
      {
        'nome': 'Salbutamol',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Salbutamol',
          idBulario: 'salbutamol',
          isFavorito: favoritos.contains('Salbutamol'),
          onToggleFavorito: () => _alternarFavorito('Salbutamol'),
          conteudo: buildCardSalbutamol(
            context,
            peso,
            isAdulto,
            favoritos.contains('Salbutamol'),
                () => _alternarFavorito('Salbutamol'),
          ),
        ),
      }, // Salbutamol
      {
        'nome': 'Terbutalina',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Terbutalina',
          idBulario: 'terbutalina',
          isFavorito: favoritos.contains('Terbutalina'),
          onToggleFavorito: () => _alternarFavorito('Terbutalina'),
          conteudo: buildCardTerbutalina(
            context,
            peso,
            isAdulto,
            favoritos.contains('Terbutalina'),
                () => _alternarFavorito('Terbutalina'),
          ),
        ),
      }, // Terbutalina
      {
        'nome': 'Atropina',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Atropina',
          idBulario: 'atropina',
          isFavorito: favoritos.contains('Atropina'),
          onToggleFavorito: () => _alternarFavorito('Atropina'),
          conteudo: buildCardAtropina(
            context,
            peso,
            isAdulto,
            favoritos.contains('Atropina'),
                () => _alternarFavorito('Atropina'),
          ),
        ),
      }, // Atropina
      {
        'nome': 'Enoxaparina',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Enoxaparina',
          idBulario: 'enoxaparina',
          isFavorito: favoritos.contains('Enoxaparina'),
          onToggleFavorito: () => _alternarFavorito('Enoxaparina'),
          conteudo: buildCardEnoxaparina(
            context,
            peso,
            isAdulto,
            favoritos.contains('Enoxaparina'),
                () => _alternarFavorito('Enoxaparina'),
          ),
        ),
      }, // Enoxaparina
      {
        'nome': 'Heparina Sódica',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Heparina Sódica',
          idBulario: 'heparina_sodica',
          isFavorito: favoritos.contains('Heparina Sódica'),
          onToggleFavorito: () => _alternarFavorito('Heparina Sódica'),
          conteudo: buildCardHeparinaSodica(
            context,
            peso,
            isAdulto,
            favoritos.contains('Heparina Sódica'),
                () => _alternarFavorito('Heparina Sódica'),
          ),
        ),
      }, // Heparina Sódica
      {
        'nome': 'Ácido Tranexâmico',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Ácido Tranexâmico',
          idBulario: 'acido_tranexamico',
          isFavorito: favoritos.contains('Ácido Tranexâmico'),
          onToggleFavorito: () => _alternarFavorito('Ácido Tranexâmico'),
          conteudo: buildCardAcidoTranexamico(
            context,
            peso,
            isAdulto,
          ),
        ),
      }, // Ácido Tranexâmico
      {
        'nome': 'Ácido Aminocaproico',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          idBulario: 'acido_aminocaproico',
          nome: 'Ácido Aminocaproico',
          isFavorito: favoritos.contains('Ácido Aminocaproico'),
          onToggleFavorito: () => _alternarFavorito('Ácido Aminocaproico'),
          conteudo: buildCardAcidoAminocaproico(
            context,
            peso,
            isAdulto,
          ),
        ),
      }, // Ácido Aminocaproico
      {
        'nome': 'Alteplase',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Alteplase',
          idBulario: 'alteplase',
          isFavorito: favoritos.contains('Alteplase'),
          onToggleFavorito: () => _alternarFavorito('Alteplase'),
          conteudo: buildCardAlteplase(
            context,
            peso,
            isAdulto,
          ),
        ),
      }, // Alteplase
      {
        'nome': 'Buprenorfina',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Buprenorfina',
          idBulario: 'buprenorfina',
          isFavorito: favoritos.contains('Buprenorfina'),
          onToggleFavorito: () => _alternarFavorito('Buprenorfina'),
          conteudo: buildCardBuprenorfina(
            context,
            peso,
            isAdulto,
            favoritos.contains('Buprenorfina'),
                () => _alternarFavorito('Buprenorfina'),
          ),
        ),
      }, // Buprenorfina
      {
        'nome': 'Pentazocina',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Pentazocina',
          idBulario: 'pentazocina',
          isFavorito: favoritos.contains('Pentazocina'),
          onToggleFavorito: () => _alternarFavorito('Pentazocina'),
          conteudo: buildCardPentazocina(
            context,
            peso,
            isAdulto,
            favoritos.contains('Pentazocina'),
                () => _alternarFavorito('Pentazocina'),
          ),
        ),
      }, // Pentazocina
      {
        'nome': 'Alfentanil',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Alfentanil',
          idBulario: 'alfentanil',
          isFavorito: favoritos.contains('Alfentanil'),
          onToggleFavorito: () => _alternarFavorito('Alfentanil'),
          conteudo: buildCardAlfentanil(
            context,
            peso,
            isAdulto,
            favoritos.contains('Alfentanil'),
                () => _alternarFavorito('Alfentanil'),
          ),
        ),
      }, // Alfentanil
      {
        'nome': 'Petidina',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Petidina',
          idBulario: 'petidina',
          isFavorito: favoritos.contains('Petidina'),
          onToggleFavorito: () => _alternarFavorito('Petidina'),
          conteudo: buildCardPetidina(
            context,
            peso,
            isAdulto,
            favoritos.contains('Petidina'),
                () => _alternarFavorito('Petidina'),
          ),
        ),
      }, // Petidina
      {
        'nome': 'Nalbuphina',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Nalbuphina',
          idBulario: 'nalbuphina',
          isFavorito: favoritos.contains('Nalbuphina'),
          onToggleFavorito: () => _alternarFavorito('Nalbuphina'),
          conteudo: buildCardNalbuphina(
            context,
            peso,
            isAdulto,
            favoritos.contains('Nalbuphina'),
                () => _alternarFavorito('Nalbuphina'),
          ),
        ),
      }, // Nalbuphina
      {
        'nome': 'Meperidina',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Meperidina',
          idBulario: 'meperidina',
          isFavorito: favoritos.contains('Meperidina'),
          onToggleFavorito: () => _alternarFavorito('Meperidina'),
          conteudo: buildCardMeperidina(
            context,
            peso,
            isAdulto,
            favoritos.contains('Meperidina'),
                () => _alternarFavorito('Meperidina'),
          ),
        ),
      }, // Meperidina
      {
        'nome': 'Morfina',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Morfina',
          idBulario: 'morfina',
          isFavorito: favoritos.contains('Morfina'),
          onToggleFavorito: () => _alternarFavorito('Morfina'),
          conteudo: buildCardMorfina(
            context,
            peso,
            isAdulto,
            favoritos.contains('Morfina'),
                () => _alternarFavorito('Morfina'),
          ),
        ),
      }, // Morfina
      {
        'nome': 'Sufentanil',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Sufentanil',
          idBulario: 'sufentanil',
          isFavorito: favoritos.contains('Sufentanil'),
          onToggleFavorito: () => _alternarFavorito('Sufentanil'),
          conteudo: buildCardSufentanil(
            context,
            peso,
            isAdulto,
            favoritos.contains('Sufentanil'),
                () => _alternarFavorito('Sufentanil'),
          ),
        ),
      }, // Sufentanil
      {
        'nome': 'Remifentanil',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Remifentanil',
          idBulario: 'remifentanil',
          isFavorito: favoritos.contains('Remifentanil'),
          onToggleFavorito: () => _alternarFavorito('Remifentanil'),
          conteudo: buildCardRemifentanil(
            context,
            peso,
            isAdulto,
            favoritos.contains('Remifentanil'),
                () => _alternarFavorito('Remifentanil'),
          ),
        ),
      }, // Remifentanil
      {
        'nome': 'Fentanil',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Fentanil',
          idBulario: 'fentanil',
          isFavorito: favoritos.contains('Fentanil'),
          onToggleFavorito: () => _alternarFavorito('Fentanil'),
          conteudo: buildCardFentanil(
            context,
            peso,
            isAdulto,
            favoritos.contains('Fentanil'),
                () => _alternarFavorito('Fentanil'),
          ),
        ),
      }, // Fentanil
      {
        'nome': 'Tramadol',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Tramadol',
          idBulario: 'tramadol',
          isFavorito: favoritos.contains('Tramadol'),
          onToggleFavorito: () => _alternarFavorito('Tramadol'),
          conteudo: buildCardTramadol(
            context,
            peso,
            isAdulto,
            favoritos.contains('Tramadol'),
                () => _alternarFavorito('Tramadol'),
          ),
        ),
      }, // Tramadol
      {
        'nome': 'Metadona',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Metadona',
          idBulario: 'metadona',
          isFavorito: favoritos.contains('Metadona'),
          onToggleFavorito: () => _alternarFavorito('Metadona'),
          conteudo: buildCardMetadona(
            context,
            peso,
            isAdulto,
            favoritos.contains('Metadona'),
                () => _alternarFavorito('Metadona'),
          ),
        ),
      }, // Metadona
      {
        'nome': 'Cefazolina',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Cefazolina',
          idBulario: 'cefazolina',
          isFavorito: favoritos.contains('Cefazolina'),
          onToggleFavorito: () => _alternarFavorito('Cefazolina'),
          conteudo: buildCardCefazolina(
            context,
            peso,
            isAdulto,
            favoritos.contains('Cefazolina'),
                () => _alternarFavorito('Cefazolina'),
          ),
        ),
      }, // Cefazolina
      {
        'nome': 'Cefuroxima',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Cefuroxima',
          idBulario: 'cefuroxima',
          isFavorito: favoritos.contains('Cefuroxima'),
          onToggleFavorito: () => _alternarFavorito('Cefuroxima'),
          conteudo: buildCardCefuroxima(
            context,
            peso,
            isAdulto,
            favoritos.contains('Cefuroxima'),
                () => _alternarFavorito('Cefuroxima'),
          ),
        ),
      }, // Cefuroxima
      {
        'nome': 'Ceftriaxona',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Ceftriaxona',
          idBulario: 'ceftriaxona',
          isFavorito: favoritos.contains('Ceftriaxona'),
          onToggleFavorito: () => _alternarFavorito('Ceftriaxona'),
          conteudo: buildCardCeftriaxona(
            context,
            peso,
            isAdulto,
            favoritos.contains('Ceftriaxona'),
                () => _alternarFavorito('Ceftriaxona'),
          ),
        ),
      }, // Ceftriaxona
      {
        'nome': 'Vancomicina',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Vancomicina',
          idBulario: 'vancomicina',
          isFavorito: favoritos.contains('Vancomicina'),
          onToggleFavorito: () => _alternarFavorito('Vancomicina'),
          conteudo: buildCardVancomicina(
            context,
            peso,
            isAdulto,
            favoritos.contains('Vancomicina'),
                () => _alternarFavorito('Vancomicina'),
          ),
        ),
      }, // Vancomicina
      {
        'nome': 'Metronidazol',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Metronidazol',
          idBulario: 'metronidazol',
          isFavorito: favoritos.contains('Metronidazol'),
          onToggleFavorito: () => _alternarFavorito('Metronidazol'),
          conteudo: buildCardMetronidazol(
            context,
            peso,
            isAdulto,
            favoritos.contains('Metronidazol'),
                () => _alternarFavorito('Metronidazol'),
          ),
        ),
      }, // Metronidazol
      {
        'nome': 'Paracetamol',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Paracetamol',
          idBulario: 'paracetamol',
          isFavorito: favoritos.contains('Paracetamol'),
          onToggleFavorito: () => _alternarFavorito('Paracetamol'),
          conteudo: buildCardParacetamol(
            context,
            peso,
            isAdulto,
            favoritos.contains('Paracetamol'),
                () => _alternarFavorito('Paracetamol'),
          ),
        ),
      }, // Paracetamol
      {
        'nome': 'Dipirona',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Dipirona',
          idBulario: 'dipirona',
          isFavorito: favoritos.contains('Dipirona'),
          onToggleFavorito: () => _alternarFavorito('Dipirona'),
          conteudo: buildCardDipirona(
            context,
            peso,
            isAdulto,
            favoritos.contains('Dipirona'),
                () => _alternarFavorito('Dipirona'),
          ),
        ),
      }, // Dipirona
      {
        'nome': 'Óxido Nitros',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Óxido Nitroso',
          idBulario: 'oxido_nitroso',
          isFavorito: favoritos.contains('Óxido Nitroso'),
          onToggleFavorito: () => _alternarFavorito('Óxido Nitroso'),
          conteudo: buildCardOxidoNitroso(
            context,
            peso,
            isAdulto,
            favoritos.contains('Óxido Nitroso'),
                () => _alternarFavorito('Óxido Nitroso'),
          ),
        ),
      }, // Óxido Nitroso
      {
        'nome': 'Sevoflurano',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Sevoflurano',
          idBulario: 'sevoflurano',
          isFavorito: favoritos.contains('Sevoflurano'),
          onToggleFavorito: () => _alternarFavorito('Sevoflurano'),
          conteudo: buildCardSevoflurano(
            context,
            peso,
            isAdulto,
            favoritos.contains('Sevoflurano'),
                () => _alternarFavorito('Sevoflurano'),
          ),
        ),
      }, // Sevoflurano
      {
        'nome': 'Desflurano',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Desflurano',
          idBulario: 'desflurano',
          isFavorito: favoritos.contains('Desflurano'),
          onToggleFavorito: () => _alternarFavorito('Desflurano'),
          conteudo: buildCardDesflurano(
            context,
            peso,
            isAdulto,
            favoritos.contains('Desflurano'),
                () => _alternarFavorito('Desflurano'),
          ),
        ),
      }, // Desflurano
      {
        'nome': 'Isoflurano',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Isoflurano',
          idBulario: 'isoflurano',
          isFavorito: favoritos.contains('Isoflurano'),
          onToggleFavorito: () => _alternarFavorito('Isoflurano'),
          conteudo: buildCardIsoflurano(
            context,
            peso,
            isAdulto,
            favoritos.contains('Isoflurano'),
                () => _alternarFavorito('Isoflurano'),
          ),
        ),
      }, // Isoflurano
      {
        'nome': 'Ropivacaína (Infiltração)',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Ropivacaína (Infiltração)',
          idBulario: 'ropivacaina_infiltracao',
          isFavorito: favoritos.contains('Ropivacaína (Infiltração)'),
          onToggleFavorito: () => _alternarFavorito('Ropivacaína (Infiltração)'),
          conteudo: buildCardRopivacainaInfiltracao(
            context,
            peso,
            isAdulto,
            favoritos.contains('Ropivacaína (Infiltração)'),
                () => _alternarFavorito('Ropivacaína (Infiltração)'),
          ),
        ),
      }, // Ropivacaína (Infiltração)
      {
        'nome': 'Bupivacaína (Infiltração)',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Bupivacaína (Infiltração)',
          idBulario: 'bupivacaina_infiltracao',
          isFavorito: favoritos.contains('Bupivacaína (Infiltração)'),
          onToggleFavorito: () => _alternarFavorito('Bupivacaína (Infiltração)'),
          conteudo: buildCardBupivacaina(
            context,
            peso,
            isAdulto,
            favoritos.contains('Bupivacaína (Infiltração)'),
                () => _alternarFavorito('Bupivacaína (Infiltração)'),
          ),
        ),
      }, // Bupivacaína (Infiltração)
      {
        'nome': 'Lidocaína (Infiltração)',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Lidocaína (Infiltração)',
          idBulario: 'lidocaina_infiltracao',
          isFavorito: favoritos.contains('Lidocaína (Infiltração)'),
          onToggleFavorito: () => _alternarFavorito('Lidocaína (Infiltração)'),
          conteudo: buildCardLidocaina(
            context,
            peso,
            isAdulto,
            favoritos.contains('Lidocaína (Infiltração)'),
                () => _alternarFavorito('Lidocaína (Infiltração)'),
          ),
        ),
      }, // Lidocaína (Infiltração)
      {
        'nome': 'Soro Fisiológico 0,9%',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Soro Fisiológico 0,9%',
          idBulario: 'soro_fisiologico_09',
          isFavorito: favoritos.contains('Soro Fisiológico 0,9%'),
          onToggleFavorito: () => _alternarFavorito('Soro Fisiológico 0,9%'),
          conteudo: buildCardSoroFisiologico09(
            context,
            peso,
            isAdulto,
            favoritos.contains('Soro Fisiológico 0,9%'),
                () => _alternarFavorito('Soro Fisiológico 0,9%'),
          ),
        ),
      }, // Soro Fisiológico 0,9%
      {
        'nome': 'Água Destilada',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Água Destilada',
          idBulario: 'agua_destilada',
          isFavorito: favoritos.contains('Água Destilada'),
          onToggleFavorito: () => _alternarFavorito('Água Destilada'),
          conteudo: buildCardAguaDestilada(
            context,
            peso,
            isAdulto,
            favoritos.contains('Água Destilada'),
                () => _alternarFavorito('Água Destilada'),
          ),
        ),
      }, // Água Destilada
      {
        'nome': 'Emulsão Lipídica',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Emulsão Lipídica',
          idBulario: 'emulsao_lipidica',
          isFavorito: favoritos.contains('Emulsão Lipídica'),
          onToggleFavorito: () => _alternarFavorito('Emulsão Lipídica'),
          conteudo: buildCardEmulsaoLipidica(
            context,
            peso,
            isAdulto,
            favoritos.contains('Emulsão Lipídica'),
                () => _alternarFavorito('Emulsão Lipídica'),
          ),
        ),
      }, // Emulsão Lipídica
      {
        'nome': 'Salina Hipertônica 3%',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Salina Hipertônica 3%',
          idBulario: 'adrenalina',
          isFavorito: favoritos.contains('Salina Hipertônica 3%'),
          onToggleFavorito: () => _alternarFavorito('Salina Hipertônica 3%'),
          conteudo: buildCardSolucaoSalinaHipertonica3(
            context,
            peso,
            isAdulto,
            favoritos.contains('Salina Hipertônica 3%'),
                () => _alternarFavorito('Salina Hipertônica 3%'),
          ),
        ),
      }, // Salina Hipertônica 3%
      {
        'nome': 'Coloides',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Coloides',
          idBulario: 'coloides',
          isFavorito: favoritos.contains('Coloides'),
          onToggleFavorito: () => _alternarFavorito('Coloides'),
          conteudo: buildCardColoides(
            context,
            peso,
            isAdulto,
            favoritos.contains('Coloides'),
                () => _alternarFavorito('Coloides'),
          ),
        ),
      }, // Coloides
      {
        'nome': 'Salina Hipertônica 20%',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Salina Hipertônica 20%',
          idBulario: 'salina_hipertonica_20',
          isFavorito: favoritos.contains('Salina Hipertônica 20%'),
          onToggleFavorito: () => _alternarFavorito('Salina Hipertônica 20%'),
          conteudo: buildCardSolucaoSalina20(
            context,
            peso,
            isAdulto,
            favoritos.contains('Salina Hipertônica 20%'),
                () => _alternarFavorito('Salina Hipertônica 20%'),
          ),
        ),
      }, // Salina Hipertônica 20%
      {
        'nome': 'Plasma-Lyte®',
        'builder': () => buildMedicamentoExpansivel(
          context: context,
          nome: 'Plasma-Lyte®',
          idBulario: 'plasmalyte',
          isFavorito: favoritos.contains('Plasma-Lyte®'),
          onToggleFavorito: () => _alternarFavorito('Plasma-Lyte®'),
          conteudo: buildCardPlasmaLygth(
            context,
            peso,
            isAdulto,
            favoritos.contains('Plasma-Lyte®'),
                () => _alternarFavorito('Plasma-Lyte®'),
          ),
        ),
      }, // Plasma-Lyte®



    ];
    final List<Map<String, dynamic>> medicamentosFiltrados = medicamentos.where((med) => med['nome'].toLowerCase().contains(_query)).toList();medicamentosFiltrados.sort((a, b) {
      final nomeA = a['nome'] as String;
      final nomeB = b['nome'] as String;
      final aFav = favoritos.contains(nomeA);
      final bFav = favoritos.contains(nomeB);
      if (aFav && !bFav) return -1;
      if (!aFav && bFav) return 1;
      return nomeA.compareTo(nomeB);
    });
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Buscar medicamento...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.black54),
            icon: Icon(Icons.search, color: Colors.black),
          ),
          style: const TextStyle(color: Colors.black),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 4),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: medicamentosFiltrados.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Nenhum medicamento encontrado.',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Ajude-nos a melhorar:',
                        style: TextStyle(fontSize: 14),
                      ),
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
                            color: Colors.white,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                    : ListView.builder(
                  itemCount: medicamentosFiltrados.length,
                  itemBuilder: (context, index) {
                    final med = medicamentosFiltrados[index];
                    try {
                      return med['builder']();
                    } catch (e) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Erro ao carregar ${med['nome']}: $e',
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* MEDICAMENTOS */

// Continua ...





//____________________________________________________________________________//

//____________________________________________________________________________//
//____________________________________________________________________________//
//____________________________________________________________________________//
//____________________________________________________________________________//
//____________________________________________________________________________//
//____________________________________________________________________________//
//____________________________________________________________________________//
//____________________________________________________________________________//
//____________________________________________________________________________//
//____________________________________________________________________________//
//____________________________________________________________________________//
//____________________________________________________________________________//
//____________________________________________________________________________//
//____________________________________________________________________________//
//____________________________________________________________________________//
//____________________________________________________________________________//
//____________________________________________________________________________//
//____________________________________________________________________________//
//____________________________________________________________________________//
//____________________________________________________________________________//
//____________________________________________________________________________//
//____________________________________________________________________________//
//____________________________________________________________________________//




















// 🩺 Diuréticos ...
Widget buildCardManitol(BuildContext context, double peso, bool isAdulto,) {return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Frasco 250–500mL a 20% (200mg/mL)', 'Manitol®'),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Uso EV em bolus ou infusão lenta com filtro', ''),
      _linhaPreparo('Aquecer se houver precipitado', ''),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      _linhaIndicacaoDoseCalculada(
        titulo: 'Redução da PIC',
        descricaoDose: '0,25–1 g/kg EV bolus a cada 4–6h (máx 2g/kg)',
        unidade: 'g',
        dosePorKgMinima: 0.25,
        dosePorKgMaxima: 1.0,
        doseMaxima: 2.0 * peso,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Redução da PIO',
        descricaoDose: '0,5–2 g/kg EV em 30–60min',
        unidade: 'g',
        dosePorKgMinima: 0.5,
        dosePorKgMaxima: 2.0,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'IRA oligúrica / rabdomiólise',
        descricaoDose: '50–100g EV em 250–500mL SF',
        unidade: 'g',
        dosePorKgMinima: 50 / peso,
        doseMaxima: 100,
        peso: peso,
      ),

      const SizedBox(height: 16),
      const Text('Cálculo da Infusão', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      ConversaoInfusaoSlider(
        peso: peso,
        opcoesConcentracoes: {
          '500mL a 20% (200mg/mL)': 200000,
          '250mL a 20% (200mg/mL)': 200000,
        },
        unidade: 'g/kg',
        doseMin: 0.25,
        doseMax: 1.0,
      ),

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Diurético osmótico potente, de uso crítico.'),
      _textoObs('• Risco de hipervolemia, hiponatremia e insuficiência renal.'),
      _textoObs('• Contraindicado em ICC, anúria e HIC ativa não controlada.'),
      _textoObs('• Cristaliza abaixo de 15 °C — usar filtro e aquecer.'),
    ],
  );}
Widget buildCardFurosemida(BuildContext context, double peso, bool isAdulto,) {
  final String faixa = SharedData.faixaEtaria;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Ampola 20mg/2mL (10mg/mL)', 'Lasix®, genéricos'),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('IV direto, IM ou infusão (1mg/mL)', ''),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      if (faixa == 'Adulto' || faixa == 'Idoso') ...[
        _linhaIndicacaoDoseCalculada(
          titulo: 'Edema agudo / ICC',
          descricaoDose: '20–80 mg IV (máx 200mg/dose)',
          unidade: 'mg',
          dosePorKgMinima: 20 / peso,
          dosePorKgMaxima: 80 / peso,
          doseMaxima: 200,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'IRC / Síndrome nefrótica',
          descricaoDose: '40–120 mg/dia',
          unidade: 'mg',
          dosePorKgMinima: 40 / peso,
          dosePorKgMaxima: 120 / peso,
          doseMaxima: 160,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Infusão contínua',
          descricaoDose: '0,1–0,4 mg/kg/h',
          peso: peso,
        ),
      ] else if (faixa == 'Recém-nascido') ...[
        _linhaIndicacaoDoseCalculada(
          titulo: 'Edema pediátrico',
          descricaoDose: '0,5–2 mg/kg/dose IV/VO cada 12–24h',
          unidade: 'mg',
          dosePorKgMinima: 0.5,
          dosePorKgMaxima: 2.0,
          doseMaxima: 40,
          peso: peso,
        ),
      ] else if (faixa == 'Lactente' || faixa == 'Criança' || faixa == 'Adolescente') ...[
        _linhaIndicacaoDoseCalculada(
          titulo: 'Edema pediátrico',
          descricaoDose: '0,5–2 mg/kg/dose IV/VO cada 12–24h',
          unidade: 'mg',
          dosePorKgMinima: 0.5,
          dosePorKgMaxima: 2.0,
          doseMaxima: 40,
          peso: peso,
        ),
      ],

      const SizedBox(height: 16),
      const Text('Cálculo da Infusão', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      ConversaoInfusaoSlider(
        peso: peso,
        opcoesConcentracoes: {
          '250mg/250mL (1mg/mL)': 1000,
          '125mg/250mL (0,5mg/mL)': 500,
        },
        unidade: 'mg/kg/h',
        doseMin: 0.1,
        doseMax: 0.4,
      ),

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Diurético de alça de rápida ação.'),
      _textoObs('• Pode exigir altas doses na IRC.'),
      _textoObs('• Monitorar eletrólitos, volemia e função renal.'),
    ],
  );
}
Widget buildCardBumetadina(BuildContext context, double peso, bool isAdulto, {int? idadeDias}) {
  final String faixa = SharedData.faixaEtaria;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Ampola 1mg/4mL (0,25mg/mL)', 'Burinax®, Bumex®'),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Via IV direta lenta ou infusão com bomba. Alternativamente, IM profunda.', ''),
      _linhaPreparo('Para infusão: diluir 1mg em 50–100mL de SF 0,9% ou SG 5%', ''),
      _linhaPreparo('Evitar soluções alcalinas. Usar bomba de infusão e monitorização de eletrólitos.', ''),

      // NOVA SEÇÃO DE INDICAÇÕES CLÍNICAS
      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      if (faixa == 'Adulto' || faixa == 'Idoso') ...[
        _linhaIndicacaoDoseCalculada(
          titulo: 'Insuficiência cardíaca congestiva',
          descricaoDose: '0,5–2 mg/dose IV ou IM, 1–2x/dia. Máx 10mg/dia.',
          unidade: 'mg',
          dosePorKgMinima: (0.5 / peso).clamp(0.005, 2.0),
          dosePorKgMaxima: (2.0 / peso).clamp(0.005, 2.0),
          doseMaxima: 10,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Edema por doença renal crônica',
          descricaoDose: '1–5 mg/dia IV, dividido em 1–2 doses.',
          unidade: 'mg',
          dosePorKgMinima: (1.0 / peso).clamp(0.01, 5.0),
          dosePorKgMaxima: (5.0 / peso).clamp(0.01, 5.0),
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Hipertensão com sobrecarga de volume',
          descricaoDose: '0,5–2 mg VO 1x/dia (off-label)',
          unidade: 'mg',
          dosePorKgMinima: (0.5 / peso).clamp(0.005, 2.0),
          dosePorKgMaxima: (2.0 / peso).clamp(0.005, 2.0),
          peso: peso,
        ),
      ] else if (faixa == 'Recém-nascido') ...[
        _linhaIndicacaoDoseCalculada(
          titulo: 'Edema neonatal (off-label)',
          descricaoDose: '0,01–0,05 mg/kg/dose IV/VO cada 12–24h',
          unidade: 'mg',
          dosePorKgMinima: 0.01,
          dosePorKgMaxima: 0.05,
          doseMaxima: 1,
          peso: peso,
        ),
      ] else if (faixa == 'Lactente' || faixa == 'Criança' || faixa == 'Adolescente') ...[
        _linhaIndicacaoDoseCalculada(
          titulo: 'Edema pediátrico (off-label)',
          descricaoDose: '0,005–0,1 mg/kg/dose IV/VO cada 6–12h (máx 1mg)',
          unidade: 'mg',
          dosePorKgMinima: 0.005,
          dosePorKgMaxima: 0.1,
          doseMaxima: 1,
          peso: peso,
        ),
      ],

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Diurético de alça de altíssima potência, aproximadamente 40x mais potente que a furosemida.'),
      _textoObs('• Alta biodisponibilidade oral (~90%), com início de ação rápido.'),
      _textoObs('• Eficaz em casos de resistência à furosemida, especialmente na doença renal crônica.'),
      _textoObs('• Menor perfil de ototoxicidade comparado à furosemida em doses equivalentes.'),
      _textoObs('• Necessário monitorar eletrólitos (K+, Mg2+, Na+) e função renal.'),
      _textoObs('• Uso criterioso em idosos e pacientes com risco de hipovolemia.'),

      // NOVA SEÇÃO: Condutas Off-label
      const SizedBox(height: 16),
      const Text('Condutas Off-label', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      const SizedBox(height: 4),
      const Padding(
        padding: EdgeInsets.only(left: 12, bottom: 4),
        child: Text('• Substituto potente da furosemida em resistência ao tratamento diurético.'),
      ),
      const Padding(
        padding: EdgeInsets.only(left: 12, bottom: 4),
        child: Text('• Uso em hipertensão arterial resistente com sobrecarga de volume.'),
      ),
      const Padding(
        padding: EdgeInsets.only(left: 12, bottom: 4),
        child: Text('• Potencial em edema pulmonar associado à síndrome nefrótica refratária.'),
      ),
    ],
  );
}
Widget buildCardTorasemida(BuildContext context, double peso, bool isAdulto,) {
  final String faixa = SharedData.faixaEtaria;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Comprimidos 5mg / 10mg / 20mg', 'Torrex®, Demadex®'),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Via oral (principal) ou IV (em alguns países)', ''),
      _linhaPreparo('Início em 1h VO, duração 6–8h', ''),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      if (faixa == 'Adulto' || faixa == 'Idoso') ...[
        _linhaIndicacaoDoseCalculada(
          titulo: 'Insuficiência cardíaca / Edema',
          descricaoDose: '10–40 mg VO/dia',
          unidade: 'mg',
          doseMaxima: 40,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'HAS',
          descricaoDose: '5–10 mg VO/dia',
          unidade: 'mg',
          doseMaxima: 10,
          peso: peso,
        ),
      ] else if (faixa == 'Recém-nascido') ...[
        _linhaIndicacaoDoseCalculada(
          titulo: 'Uso off-label pediátrico',
          descricaoDose: '0,1–0,2 mg/kg/dose VO 1–2x/dia (máx 5mg)',
          unidade: 'mg',
          dosePorKgMinima: 0.1,
          dosePorKgMaxima: 0.2,
          doseMaxima: 5,
          peso: peso,
        ),
      ] else if (faixa == 'Lactente' || faixa == 'Criança' || faixa == 'Adolescente') ...[
        _linhaIndicacaoDoseCalculada(
          titulo: 'Uso off-label pediátrico',
          descricaoDose: '0,1–0,2 mg/kg/dose VO 1–2x/dia (máx 5mg)',
          unidade: 'mg',
          dosePorKgMinima: 0.1,
          dosePorKgMaxima: 0.2,
          doseMaxima: 5,
          peso: peso,
        ),
      ],

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Diurético de alça mais potente e duradouro que a furosemida.'),
      _textoObs('• Alta biodisponibilidade VO (~90%).'),
      _textoObs('• Monitorar eletrólitos e função renal.'),
    ],
  );
}

// 🩺 Bloqueadores Neuromusculares
Widget buildCardSuccinilcolina(BuildContext context, double peso, bool isAdulto) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Frasco 20mg/mL (10mL = 200mg)', 'Anectine®, Celoklin®'),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('IV direta lenta em bolus', ''),
      _linhaPreparo('Não usar em infusão contínua', ''),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Intubação de sequência rápida',
        descricaoDose: '1–1,5 mg/kg IV bolus',
        unidade: 'mg',
        dosePorKgMinima: 1.0,
        dosePorKgMaxima: 1.5,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Laringoscopia / intubação breve',
        descricaoDose: '0,6–1 mg/kg IV bolus',
        unidade: 'mg',
        dosePorKgMinima: 0.6,
        dosePorKgMaxima: 1.0,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Laringoespasmo refratário',
        descricaoDose: '0,1–0,2 mg/kg IV bolus',
        unidade: 'mg',
        dosePorKgMinima: 0.1,
        dosePorKgMaxima: 0.2,
        peso: peso,
      ),

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Despolarizante de ultracurta duração.'),
      _textoObs('• Contraindicado em trauma, queimaduras, paralisias e doenças neuromusculares.'),
      _textoObs('• Pode causar hipercalemia, fasciculações e hipertermia maligna.'),
      _textoObs('• Não usar em infusão contínua devido ao risco de paralisia prolongada.'),
    ],
  );
}
Widget buildCardRocuronio(BuildContext context, double peso, bool isAdulto) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Frasco 10mg/mL (10mL = 100mg)', 'Esmeron®, Rocuron®'),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('IV direta (intubação) ou infusão contínua', ''),
      _linhaPreparo('Diluir 100mg em 100mL SF = 1mg/mL para bomba', ''),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Intubação de sequência rápida',
        descricaoDose: '0,6–1,2 mg/kg IV bolus',
        unidade: 'mg',
        dosePorKgMinima: 0.6,
        dosePorKgMaxima: 1.2,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Manutenção do bloqueio',
        descricaoDose: '5–10 mcg/kg/min IV contínua',
        unidade: 'mcg/kg/min',
        dosePorKgMinima: 5,
        dosePorKgMaxima: 10,
        peso: peso,
      ),

      const SizedBox(height: 16),
      const Text('Cálculo da Infusão', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      ConversaoInfusaoSlider(
        peso: peso,
        opcoesConcentracoes: {'100mg/100mL (1mg/mL)': 1000},
        unidade: 'mcg/kg/min',
        doseMin: 5,
        doseMax: 10,
      ),

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Substituto da succinilcolina para ISR.'),
      _textoObs('• Eliminação hepática e renal.'),
      _textoObs('• Estável fora da refrigeração.'),
      _textoObs('• Reversível com Sugamadex.'),
    ],
  );
}
Widget buildCardVecuronio(BuildContext context, double peso, bool isAdulto) {return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Frasco 4mg ou 10mg (pó liofilizado)', 'Norcuron®'),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Diluir 10mg em 10mL SF = 1mg/mL', ''),
      _linhaPreparo('Para bomba: 20mg em 100mL SF = 0,2mg/mL', ''),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Intubação orotraqueal',
        descricaoDose: '0,1 mg/kg IV lenta',
        unidade: 'mg',
        dosePorKg: 0.1,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Manutenção do bloqueio',
        descricaoDose: '1–2 mcg/kg/min IV contínua',
        unidade: 'mcg/kg/min',
        dosePorKgMinima: 1,
        dosePorKgMaxima: 2,
        peso: peso,
      ),

      const SizedBox(height: 16),
      const Text('Cálculo da Infusão', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      ConversaoInfusaoSlider(
        peso: peso,
        opcoesConcentracoes: {'20mg/100mL (0,2mg/mL)': 200},
        unidade: 'mcg/kg/min',
        doseMin: 1,
        doseMax: 2,
      ),

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Metabolismo hepático + excreção renal.'),
      _textoObs('• Refrigerado (2–8 °C).'),
      _textoObs('• Sem liberação significativa de histamina.'),
    ],
  );}
Widget buildCardAtracurio(BuildContext context, double peso, bool isAdulto, {int? idadeDias}) {
  // idadeDias: idade do paciente em dias (opcional, para diferenciar neonato)
  final bool isNeonato = !isAdulto && (idadeDias != null && idadeDias < 30);
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Frasco 25mL – 250mg (10mg/mL).', ''),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Uso EV exclusivo: \n• bolus lento ou infusão contínua em bomba.', ''),
      _linhaPreparo('Diluir para 1mg/mL (Ex: 100mg em 100mL SF 0,9%)', ''),
      _linhaPreparo('Usar bomba de infusão e monitorar TOF.', ''),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Intubação orotraqueal',
        descricaoDose: isAdulto
            ? '• 0,4–0,5 mg/kg IV lenta \n(intubação em 2–3 min)'
            : '• Neonatos: 0,3–0,4 mg/kg IV lenta\n• Crianças >30d: 0,4–0,5 mg/kg IV lenta',
        unidade: 'mg',
        dosePorKgMinima: isAdulto ? 0.4 : (isNeonato ? 0.3 : 0.4),
        dosePorKgMaxima: isAdulto ? 0.5 : (isNeonato ? 0.4 : 0.5),
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Manutenção do bloqueio',
        descricaoDose: '• 5–10 mcg/kg/min IV contínua\n• Ajustar por monitorização neuromuscular',
        unidade: 'mcg/kg/min',
        dosePorKgMinima: 5,
        dosePorKgMaxima: 10,
        peso: peso,
      ),

      const SizedBox(height: 16),
      const Text('Cálculo da Infusão', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      ConversaoInfusaoSlider(
        peso: peso,
        opcoesConcentracoes: {'100mg/100mL (1mg/mL)': 1000},
        unidade: 'mcg/kg/min',
        doseMin: 5,
        doseMax: 10,
      ),


      // Off-label condutas após os cálculos
      const SizedBox(height: 8),
      const Text('Condutas Off-label', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      const SizedBox(height: 4),
      const Padding(
        padding: EdgeInsets.only(left: 12, bottom: 4),
        child: Text('• Substituição da furosemida em pacientes com síndrome nefrótica refratária'),
      ),
      const Padding(
        padding: EdgeInsets.only(left: 12, bottom: 4),
        child: Text('• Opção em hipertensão com sobrecarga de volume em pacientes com má resposta a tiazídicos'),
      ),

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Bloqueador não-despolarizante do tipo benzilisoquinolínico.'),
      _textoObs('• Metabolismo por degradação de Hofmann (não depende de rim/fígado).'),
      _textoObs('• Libera histamina: risco de hipotensão, broncoespasmo e rubor.'),
      _textoObs('• Refrigeração obrigatória (2–8 °C) — instável à temperatura ambiente.'),
      _textoObs('• Monitorar TOF sempre que possível.'),
      _textoObs('• Off-label: relaxamento muscular em pacientes com síndrome da angústia respiratória aguda (SARA).'),
    ],
  );
}
Widget buildCardCisatracurio(BuildContext context, double peso, bool isAdulto) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Frasco 2mg/mL (5mL = 10mg ou 10mL = 20mg)', 'Nimbex®'),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('IV direta ou infusão contínua', ''),
      _linhaPreparo('Ex: 20mg em 100mL SF = 0,2mg/mL', ''),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Intubação orotraqueal',
        descricaoDose: '0,1–0,2 mg/kg IV lenta',
        unidade: 'mg',
        dosePorKgMinima: 0.1,
        dosePorKgMaxima: 0.2,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Manutenção do bloqueio',
        descricaoDose: '1–3 mcg/kg/min IV contínua',
        unidade: 'mcg/kg/min',
        dosePorKgMinima: 1,
        dosePorKgMaxima: 3,
        peso: peso,
      ),

      const SizedBox(height: 16),
      const Text('Cálculo da Infusão', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      ConversaoInfusaoSlider(
        peso: peso,
        opcoesConcentracoes: {'20mg/100mL (0,2mg/mL)': 200},
        unidade: 'mcg/kg/min',
        doseMin: 1,
        doseMax: 3,
      ),

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Degradação de Hofmann – independente de fígado e rim.'),
      _textoObs('• Não libera histamina em doses terapêuticas.'),
      _textoObs('• Refrigeração entre 2–8 °C.'),
    ],
  );
}
Widget buildCardMivacurio(BuildContext context, double peso, bool isAdulto) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Frasco 2mg/mL (10mL = 20mg)', 'Mivacron®'),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('IV bolus ou infusão contínua', ''),
      _linhaPreparo('Ex: 20mg em 100mL SF = 0,2mg/mL', ''),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Intubação orotraqueal',
        descricaoDose: '0,15–0,25 mg/kg IV lenta (20–30s)',
        unidade: 'mg',
        dosePorKgMinima: 0.15,
        dosePorKgMaxima: 0.25,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Manutenção de bloqueio',
        descricaoDose: '3–15 mcg/kg/min IV contínua',
        unidade: 'mcg/kg/min',
        dosePorKgMinima: 3,
        dosePorKgMaxima: 15,
        peso: peso,
      ),

      const SizedBox(height: 16),
      const Text('Cálculo da Infusão', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      ConversaoInfusaoSlider(
        peso: peso,
        opcoesConcentracoes: {'20mg/100mL (0,2mg/mL)': 200},
        unidade: 'mcg/kg/min',
        doseMin: 3,
        doseMax: 15,
      ),

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Ação ultracurta, metabolizado por colinesterase plasmática.'),
      _textoObs('• Pode causar liberação de histamina.'),
      _textoObs('• Útil em procedimentos curtos.'),
    ],
  );
}


// 🩺 Benzodiazepínicos
Widget buildCardMidazolam(BuildContext context, double peso, bool isAdulto) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Ampola 5mg/mL ou 15mg/3mL', 'Versed®, Dormonid®'),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Uso direto IV ou IM', ''),
      _linhaPreparo('Infusão: diluir em SF 0,9% (Ex: 50mg/50mL = 1mg/mL)', ''),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      if (isAdulto) ...[
        _linhaIndicacaoDoseCalculada(
          titulo: 'Sedação consciente',
          descricaoDose: '1–2,5 mg IV lenta, repetir se necessário (máx 5mg)',
          unidade: 'mg',
          dosePorKgMinima: 0.015,
          dosePorKgMaxima: 0.07,
          doseMaxima: 5,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Indução anestésica',
          descricaoDose: '0,1–0,2 mg/kg IV lenta',
          unidade: 'mg',
          dosePorKgMinima: 0.1,
          dosePorKgMaxima: 0.2,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Infusão contínua em UTI',
          descricaoDose: '0,02–0,1 mg/kg/h IV contínua',
          peso: peso,
        ),
      ] else ...[
        _linhaIndicacaoDoseCalculada(
          titulo: 'Convulsão pediátrica aguda',
          descricaoDose: '0,1–0,2 mg/kg IV ou IM (máx 10mg)',
          unidade: 'mg',
          dosePorKgMinima: 0.1,
          dosePorKgMaxima: 0.2,
          doseMaxima: 10,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Sedação pediátrica contínua',
          descricaoDose: '0,05–0,2 mg/kg/h IV',
          peso: peso,
        ),
      ],

      const SizedBox(height: 16),
      const Text('Cálculo da Infusão', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      ConversaoInfusaoSlider(
        peso: peso,
        opcoesConcentracoes: {
          '50mg/50mL (1mg/mL)': 1000,
          '100mg/100mL (1mg/mL)': 1000,
        },
        unidade: 'mg/kg/h',
        doseMin: 0.02,
        doseMax: 0.2,
      ),

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Ação rápida e curta, ideal para sedação procedural.'),
      _textoObs('• Potente ansiolítico, hipnótico e anticonvulsivante.'),
      _textoObs('• Amnésia anterógrada frequente.'),
      _textoObs('• Depressão respiratória especialmente com opioides.'),
    ],
  );
}
Widget buildCardDiazepam(BuildContext context, double peso, bool isAdulto) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Ampola 10mg/2mL (5mg/mL)', 'Valium®, Uni-Diazepam®'),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Uso direto IV ou IM', ''),
      _linhaPreparo('Evitar diluição – instável em soluções aquosas', ''),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      if (isAdulto) ...[
        _linhaIndicacaoDoseCalculada(
          titulo: 'Crise convulsiva aguda',
          descricaoDose: '5–10 mg IV lenta ou IM (repetir após 10–15min)',
          unidade: 'mg',
          doseMaxima: 20,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Abstinência alcoólica / agitação',
          descricaoDose: '10 mg IV ou IM a cada 6–8h',
          unidade: 'mg',
          doseMaxima: 10,
          peso: peso,
        ),
      ] else ...[
        _linhaIndicacaoDoseCalculada(
          titulo: 'Convulsão pediátrica',
          descricaoDose: '0,2–0,3 mg/kg IV (máx 10mg)',
          unidade: 'mg',
          dosePorKgMinima: 0.2,
          dosePorKgMaxima: 0.3,
          doseMaxima: 10,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Sedação leve',
          descricaoDose: '0,1–0,2 mg/kg IM',
          unidade: 'mg',
          dosePorKgMinima: 0.1,
          dosePorKgMaxima: 0.2,
          peso: peso,
        ),
      ],

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Ação longa, risco de acúmulo.'),
      _textoObs('• Contraindicado para infusão contínua.'),
      _textoObs('• Antagonizável com flumazenil.'),
    ],
  );
}
Widget buildCardLorazepam(BuildContext context, double peso, bool isAdulto) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Ampola 4mg/1mL', 'Lorax®, Ativan®'),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Uso direto IV ou IM lenta', ''),
      _linhaPreparo('Evitar SF – instável. Diluir em SG 5% se necessário', ''),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      if (isAdulto) ...[
        _linhaIndicacaoDoseCalculada(
          titulo: 'Estado de mal epiléptico',
          descricaoDose: '4mg IV lenta (2mg/min máx) → repetir após 10–15min',
          unidade: 'mg',
          doseMaxima: 8,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Agitação psicomotora',
          descricaoDose: '1–2mg IV ou IM a cada 6–8h se necessário',
          unidade: 'mg',
          doseMaxima: 2,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Ansiedade / Pré-medicação',
          descricaoDose: '0,05 mg/kg IM ou VO 1h antes',
          unidade: 'mg',
          dosePorKgMinima: 0.03,
          dosePorKgMaxima: 0.05,
          doseMaxima: 4,
          peso: peso,
        ),
      ] else ...[
        _linhaIndicacaoDoseCalculada(
          titulo: 'Crise convulsiva pediátrica',
          descricaoDose: '0,05–0,1 mg/kg IV lenta (máx 4mg)',
          unidade: 'mg',
          dosePorKgMinima: 0.05,
          dosePorKgMaxima: 0.1,
          doseMaxima: 4,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Sedação leve UTI pediátrica',
          descricaoDose: '0,02–0,05 mg/kg IV a cada 6–8h',
          unidade: 'mg',
          peso: peso,
        ),
      ],

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Benzodiazepínico de duração intermediária.'),
      _textoObs('• Primeira linha no status epilepticus hospitalar.'),
      _textoObs('• Evitar infusão contínua – risco de acúmulo.'),
      _textoObs('• Antagonizável com flumazenil.'),
    ],
  );
}


// 🛡️ Reversores e Antídotos
Widget buildCardNaloxona(BuildContext context, double peso, bool isAdulto) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Ampola 0,4mg/mL (1mL)', 'Narcan®, Naloxon®'),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('IV direta, IM ou SC', ''),
      _linhaPreparo('Pode ser diluída em 10mL SF para administração lenta', ''),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      _linhaIndicacaoDoseCalculada(
        titulo: 'Reversão de depressão respiratória (adulto)',
        descricaoDose: '0,04–0,4mg IV, repetir cada 2–3 min (máx 10mg). Infusão: 0,4–2mg/h',
        unidade: 'mg',
        dosePorKgMinima: 0.005,
        dosePorKgMaxima: 0.01,
        doseMaxima: 10,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Superdose em pediatria',
        descricaoDose: '0,01–0,1 mg/kg IV ou IM (máx 2mg/dose)',
        unidade: 'mg',
        dosePorKgMinima: 0.01,
        dosePorKgMaxima: 0.1,
        doseMaxima: 2,
        peso: peso,
      ),

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Antagonista competitivo dos receptores opioides μ, κ e δ.'),
      _textoObs('• Meia-vida curta (~30–90min): pode ser necessária repetição.'),
      _textoObs('• Pode precipitar síndrome de abstinência em usuários crônicos.'),
    ],
  );
}
Widget buildCardFlumazenil(BuildContext context, double peso, bool isAdulto) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Ampola 0,1mg/mL (5mL = 0,5mg)', 'Lanexat®, Anexate®'),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('IV direta ou diluir em 100mL SF para infusão lenta', ''),
      _linhaPreparo('Bolus de 0,2mg a cada 60s até resposta (máx 1mg)', ''),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      _linhaIndicacaoDoseCalculada(
        titulo: 'Reversão de sedação (adulto)',
        descricaoDose: '0,2mg IV a cada 60s (máx 1mg). Manutenção: 0,1–0,4mg/h',
        unidade: 'mg',
        dosePorKgMinima: 0.002,
        dosePorKgMaxima: 0.01,
        doseMaxima: 1.0,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Superdose acidental ou terapêutica (pediatria)',
        descricaoDose: '0,01 mg/kg IV lenta (máx 0,2mg/dose)',
        unidade: 'mg',
        dosePorKgMinima: 0.005,
        dosePorKgMaxima: 0.01,
        doseMaxima: 0.2,
        peso: peso,
      ),

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Antagonista competitivo dos benzodiazepínicos (GABA-A).'),
      _textoObs('• Meia-vida curta (~1h): risco de ressedação.'),
      _textoObs('• Cuidado em epilepsia tratada com BZD ou overdose mista (risco de convulsões).'),
    ],
  );
}
Widget buildCardSugamadex(BuildContext context, double peso, bool isAdulto) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Frasco 100mg/mL (2mL ou 5mL)', 'Bridion®'),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('IV direta, sem diluição', ''),
      _linhaPreparo('Bolus rápido em no máximo 10 segundos', ''),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      _linhaIndicacaoDoseCalculada(
        titulo: 'Reversão de bloqueio moderado (TOF 2)',
        descricaoDose: '2 mg/kg IV bolus único',
        unidade: 'mg',
        dosePorKg: 2.0,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Reversão profunda (TOF 0 + PTC 1–2)',
        descricaoDose: '4 mg/kg IV bolus único',
        unidade: 'mg',
        dosePorKg: 4.0,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Reversão imediata após intubação com rocurônio (1,2 mg/kg)',
        descricaoDose: '16 mg/kg IV bolus único',
        unidade: 'mg',
        dosePorKg: 16.0,
        peso: peso,
      ),

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Específico para rocurônio e vecurônio.'),
      _textoObs('• Ação muito rápida (1–3 min).'),
      _textoObs('• Não atua sobre bloqueadores benzilisoquinolínicos.'),
      _textoObs('• Pode causar bradicardia, broncoespasmo e reações anafiláticas.'),
    ],
  );
}
Widget buildCardProtamina(BuildContext context, double peso, bool isAdulto) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Ampola 10mg/mL (5mL = 50mg)', 'Protamina sulfato'),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Diluir em 50–100mL SF 0,9%', ''),
      _linhaPreparo('Administração IV lenta — máx 5mg/min', ''),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      _linhaIndicacaoDoseCalculada(
        titulo: 'Reversão de heparina não fracionada (HNF)',
        descricaoDose: '1mg neutraliza ~100 UI de HNF administrada nos últimos 30–60 min',
        unidade: 'mg',
        dosePorKgMinima: 0.5,
        dosePorKgMaxima: 1.0,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Reversão parcial de HBPM',
        descricaoDose: '1mg neutraliza ~1mg de enoxaparina (se <8h da dose)',
        unidade: 'mg',
        dosePorKgMinima: 0.5,
        dosePorKgMaxima: 1.0,
        peso: peso,
      ),

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Administrar lentamente (≤5mg/min) para evitar hipotensão e reações anafilactoides.'),
      _textoObs('• Risco de efeito anticoagulante paradoxal se usado em excesso.'),
      _textoObs('• Cautela em pacientes alérgicos a peixe, vasectomizados e usuários de NPH.'),
    ],
  );
}
Widget buildCardDantroleno(BuildContext context, double peso, bool isAdulto) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Frasco 20mg + 60mL água estéril', 'Dantrium®, Revonto®'),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Reconstituir cada frasco com 60mL de água estéril (não usar SF)', ''),
      _linhaPreparo('Usar imediatamente após reconstituição', ''),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      _linhaIndicacaoDoseCalculada(
        titulo: 'Hipertermia maligna (ataque)',
        descricaoDose: '2,5 mg/kg IV bolus a cada 5 min até máx 10mg/kg',
        unidade: 'mg',
        dosePorKg: 2.5,
        doseMaxima: 10.0 * peso,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Hipertermia maligna (manutenção)',
        descricaoDose: '1 mg/kg IV a cada 6h ou infusão 0,25 mg/kg/h',
        unidade: 'mg',
        dosePorKgMinima: 0.25,
        dosePorKgMaxima: 1.0,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Síndrome neuroléptica maligna',
        descricaoDose: '1–2,5 mg/kg IV a cada 6h ou infusão titulada',
        unidade: 'mg',
        dosePorKgMinima: 1.0,
        dosePorKgMaxima: 2.5,
        peso: peso,
      ),

      const SizedBox(height: 16),
      const Text('Cálculo da Infusão', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      ConversaoInfusaoSlider(
        peso: peso,
        opcoesConcentracoes: {
          '60mg/60mL (1mg/mL)': 1000,
          '120mg/100mL (1,2mg/mL)': 1200,
        },
        unidade: 'mg/kg/h',
        doseMin: 0.25,
        doseMax: 1.0,
      ),

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Tratamento de hipertermia maligna.'),
      _textoObs('• Reduz liberação de cálcio do retículo sarcoplasmático.'),
      _textoObs('• Reconstituir apenas com água estéril (não usar SF).'),
    ],
  );
}
Widget buildCardTiossulfatoSodio(BuildContext context, double peso, bool isAdulto) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Frasco 25%, 12,5g/50mL (250mg/mL)', 'Sodium Thiosulfate®'),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('IV lenta em 10–20 min', ''),
      _linhaPreparo('Não misturar com nitrito ou cianokit na mesma seringa', ''),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      _linhaIndicacaoDoseCalculada(
        titulo: 'Intoxicação por cianeto (adjuvante)',
        descricaoDose: '12,5g IV (50mL da solução 25%)',
        unidade: 'g',
        doseMaxima: 12.5,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Calcifilaxia',
        descricaoDose: '12,5–25g IV 3x/semana após hemodiálise',
        unidade: 'g',
        doseMaxima: 25,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Intoxicações diversas (off-label)',
        descricaoDose: '10–15g IV lenta',
        unidade: 'g',
        doseMaxima: 15,
        peso: peso,
      ),

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Conversão de cianeto em tiocianato, excretado renalmente.'),
      _textoObs('• Usado como adjuvante ao lado da hidroxicobalamina.'),
      _textoObs('• Não misturar com nitrito na mesma via.'),
    ],
  );
}
Widget buildCardHidroxicobalamina(BuildContext context, double peso, bool isAdulto) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Frasco 1g/50mL (20mg/mL)', 'Cyanokit®, Hidrovit®'),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('IV lenta em 15 min (antídoto) ou IM profunda (suplementação)', ''),
      _linhaPreparo('Para infusão: 5g em 200mL SF 0,9%', ''),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      _linhaIndicacaoDoseCalculada(
        titulo: 'Intoxicação por cianeto',
        descricaoDose: '5g IV em 15 min, repetir se necessário (máx 10g)',
        unidade: 'g',
        doseMaxima: 10,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Anemia megaloblástica',
        descricaoDose: '1000 mcg IM semanal por 4–6 semanas → mensal',
        unidade: 'mcg',
        doseMaxima: 1000,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Prevenção (gastrectomia, alcoolismo, bariátrica)',
        descricaoDose: '1000 mcg IM ou VO mensal',
        unidade: 'mcg',
        doseMaxima: 1000,
        peso: peso,
      ),

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Antídoto de escolha para intoxicação por cianeto.'),
      _textoObs('• Causa coloração avermelhada na pele, urina e mucosas (benigno).'),
      _textoObs('• Reações: hipertensão transitória, náusea, cefaleia.'),
    ],
  );
}
Widget buildCardNeostigmina(BuildContext context, double peso, bool isAdulto) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Ampola 0,5mg/mL ou 1mg/mL (2mL)', 'Prostigmina®, genéricos'),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Diluir em 10–20mL SF 0,9% se necessário', ''),
      _linhaPreparo('Associar atropina (10–20 mcg/kg) ou glicopirrolato para evitar bradicardia', ''),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      _linhaIndicacaoDoseCalculada(
        titulo: 'Reversão de bloqueio neuromuscular',
        descricaoDose: '0,04–0,07 mg/kg IV lenta (máx 5mg)',
        unidade: 'mg',
        dosePorKgMinima: 0.04,
        dosePorKgMaxima: 0.07,
        doseMaxima: 5.0,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Íleo paralítico / retenção urinária (off-label)',
        descricaoDose: '0,5–2,5mg IM ou SC a cada 4–6h',
        unidade: 'mg',
        doseMaxima: 2.5,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Miastenia gravis',
        descricaoDose: '0,5–2mg VO a cada 4–6h',
        unidade: 'mg',
        doseMaxima: 2.0,
        peso: peso,
      ),

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Inibidor da acetilcolinesterase.'),
      _textoObs('• Sempre associar atropina ou glicopirrolato.'),
      _textoObs('• Início em 1–3 min, pico em 7–10 min, duração 30–60 min.'),
      _textoObs('• Contraindicado em obstrução mecânica intestinal ou urinária.'),
    ],
  );
}
Widget buildCardPicadaCobra(BuildContext context, double peso, bool isAdulto) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Classificação e Manejo Inicial', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Estabilizar via aérea, ventilação e circulação (ABC)', ''),
      _linhaPreparo('Lavar o local com SF. Não fazer torniquete nem cortes.', ''),
      _linhaPreparo('Imobilizar membro afetado em posição funcional', ''),
      _linhaPreparo('Coletar informações sobre o animal: local, hora, aparência', ''),

      const SizedBox(height: 16),
      const Text('Indicação de Soro Antiveneno', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaIndicacaoDoseFixa(
        titulo: 'Bothrops (Jararaca)',
        descricaoDose: '8 ampolas IV (leve) | 12 (moderado) | 20 (grave)',
        unidade: 'ampolas',
        valorMinimo: 8,
        valorMaximo: 20,
      ),
      _linhaIndicacaoDoseFixa(
        titulo: 'Crotalus (Cascavel)',
        descricaoDose: '5 ampolas IV (leve) | até 10 (moderado a grave)',
        unidade: 'ampolas',
        valorMinimo: 5,
        valorMaximo: 10,
      ),
      _linhaIndicacaoDoseFixa(
        titulo: 'Lachesis (Surucucu)',
        descricaoDose: '10 a 20 ampolas IV, conforme gravidade',
        unidade: 'ampolas',
        valorMinimo: 10,
        valorMaximo: 20,
      ),
      _linhaIndicacaoDoseFixa(
        titulo: 'Micrurus (Coral verdadeira)',
        descricaoDose: '10 ampolas IV, dose única, independentemente do peso',
        unidade: 'ampolas',
        valorMinimo: 10,
        valorMaximo: 10,
      ),

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• O soro deve ser diluído em 250–500mL de SF 0,9% e infundido lentamente (1h).'),
      _textoObs('• Sempre monitorar sinais de anafilaxia — ter adrenalina e anti-histamínicos prontos.'),
      _textoObs('• Pode haver necessidade de repetição da dose após 12–24h.'),
      _textoObs('• Encaminhar notificação ao SINAN e manter vigilância de sintomas locais/sistêmicos.'),
    ],
  );
}




// 🩺 Anticoagulantes, Antifibrinolíticos e Trombolítico

Widget buildCardHeparinaSodica(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito,) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Ampola 5.000 UI/mL ou 25.000 UI/5mL', 'Liquemine®, genéricos'),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Via IV direta (bolus), infusão contínua ou SC', ''),
      _linhaPreparo('Diluir em 100–250mL SG 5% ou SF 0,9% (para infusão)', ''),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      _linhaIndicacaoDoseCalculada(
        titulo: 'TEV (TVP/TEP) – tratamento',
        descricaoDose: 'Bolus 5.000 UI IV → infusão contínua 18 UI/kg/h com TTPa alvo',
        unidade: 'UI',
        dosePorKg: 18,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Síndrome coronariana aguda',
        descricaoDose: '60 UI/kg IV bolus (máx 5.000 UI) + 12–15 UI/kg/h IV contínuo',
        unidade: 'UI',
        dosePorKgMinima: 12,
        dosePorKgMaxima: 15,
        doseMaxima: 5000,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Profilaxia de TEV (SC)',
        descricaoDose: '5.000 UI SC a cada 8–12h (não monitorar TTPa)',
        unidade: 'UI',
        dosePorKgMinima: 5000 / peso,
        dosePorKgMaxima: 5000 / peso,
        peso: peso,
      ),

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Anticoagulante parenteral via antitrombina III (inibe trombina e fator Xa).'),
      _textoObs('• Necessário monitorar TTPa (alvo: 1,5 a 2,5x controle) nas infusões.'),
      _textoObs('• Reversível com protamina (1mg para cada 100 UI de heparina nas últimas 60 min).'),
      _textoObs('• Risco de TIH (trombocitopenia induzida por heparina) — monitorar plaquetas.'),
      _textoObs('• Preferir enoxaparina quando possível em situações ambulatoriais ou menor risco hemorrágico.'),
    ],
  );
}
Widget buildCardEnoxaparina(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito,) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Seringa pré-preenchida 20, 40, 60, 80, 100, 120mg', 'Clexane®, Versa®'),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Aplicação SC profunda na parede abdominal ou face externa da coxa', ''),
      _linhaPreparo('Não massagear o local após aplicação', ''),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      _linhaIndicacaoDoseCalculada(
        titulo: 'Profilaxia de trombose (clínico ou pós-operatório)',
        descricaoDose: '40mg SC 1x/dia (ou 20mg 1x/dia se IR grave)',
        unidade: 'mg',
        dosePorKgMinima: 40 / peso,
        dosePorKgMaxima: 40 / peso,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Tratamento de TEV (TVP/TEP)',
        descricaoDose: '1mg/kg SC a cada 12h ou 1,5mg/kg 1x/dia',
        unidade: 'mg',
        dosePorKgMinima: 1.0,
        dosePorKgMaxima: 1.5,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Síndrome coronariana aguda (SCA)',
        descricaoDose: '1mg/kg SC a cada 12h por 2–8 dias (máx 100mg/dose)',
        unidade: 'mg',
        dosePorKg: 1.0,
        doseMaxima: 100,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Trombose venosa em pediatria (off-label)',
        descricaoDose: '1,5mg/kg SC 1x/dia ou 1mg/kg a cada 12h (ajustar conforme anti-Xa)',
        unidade: 'mg',
        dosePorKgMinima: 1.0,
        dosePorKgMaxima: 1.5,
        peso: peso,
      ),

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Heparina de baixo peso molecular com ação anti-Xa predominante.'),
      _textoObs('• Não requer monitoramento de rotina se função renal normal.'),
      _textoObs('• Ajustar dose se ClCr < 30 mL/min.'),
      _textoObs('• Contraindicada em sangramento ativo, TIH e neurocirurgias recentes.'),
      _textoObs('• Antídoto parcial: protamina (1mg para cada 1mg de enoxaparina se <8h da dose).'),
    ],
  );
}
Widget buildCardAlteplase(BuildContext context, double peso, bool isAdulto) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Frasco 50mg (liofilizado) + diluente 50mL', 'Activase®, Alteplase Genérico'),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Uso exclusivo IV. Reconstituir com o diluente incluso (50mg/50mL = 1mg/mL)', ''),
      _linhaPreparo('Utilizar bomba de infusão para controle preciso da velocidade', ''),
      _linhaPreparo('Evitar agitação vigorosa — girar suavemente até completa dissolução', ''),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      _linhaIndicacaoDoseCalculada(
        titulo: 'AVC isquêmico agudo',
        descricaoDose: 'Total: 0,9 mg/kg (máx 90mg)\n• Bolus: 10% da dose total em 1 min\n• Infusão: 90% restante em 60 min',
        unidade: 'mg',
        dosePorKg: 0.9,
        doseMaxima: 90,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'IAM com supra de ST (trombólise)',
        descricaoDose: '• Bolus: 15mg IV imediato\n• Infusão 1: 0,75 mg/kg em 30 min (máx 50mg)\n• Infusão 2: 0,5 mg/kg em 60 min (máx 35mg)',
        unidade: 'mg',
        dosePorKgMinima: 0.5,
        dosePorKgMaxima: 0.75,
        doseMaxima: 100,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Tromboembolismo pulmonar (TEP) maciço',
        descricaoDose: '• Infusão padrão: 100mg IV em 2h\n• Alternativa: 0,6 mg/kg em 15 min (máx 50mg)',
        unidade: 'mg\n( em 15 min )',
        dosePorKgMinima: 0.6,
        dosePorKgMaxima: 0.6,
        doseMaxima: 100,
        peso: peso,
      ),


      const SizedBox(height: 16),
      const Text('Outras Indicações (off-label / secundárias)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Trombólise de cateteres centrais obstruídos (2–4mg em 2mL, instilar por 30–120 min).'),
      _textoObs('• Uso em AVC de circulação posterior deve ser criteriosamente avaliado.'),

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Ativador do plasminogênio tecidual (rTPA).'),
      _textoObs('• Alto risco de sangramento — avaliar contraindicações.'),
      _textoObs('• Monitorar sinais vitais e neurológicos durante e após a infusão.'),
      _textoObs('• Contraindicado em sangramento ativo, AVCh, aneurisma, cirurgia recente e plaquetopenia grave.'),
      _textoObs('• Não usar anticoagulantes nas primeiras 24h salvo indicação formal.'),
    ],
  );
}
Widget buildCardAcidoAminocaproico(BuildContext context, double peso, bool isAdulto) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Frasco 100mL (5g – 50mg/mL)', ''),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Pode ser administrado IV direta, infusão lenta ou VO', ''),
      _linhaPreparo('Diluir em 100mL SF 0,9% ou SG 5% para 10–30 min', ''),
      _linhaPreparo('Evitar uso rápido em bolus — risco de hipotensão', ''),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      _linhaIndicacaoDoseCalculada(
        titulo: 'Hiperfibrinólise em cirurgia',
        descricaoDose: '• Ataque: 4–5g IV em 1h\n• Manutenção: 1g/h por até 8h',
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Hemorragias em coagulopatias',
        descricaoDose: '• 100–150 mg/kg IV a cada 6h\n• Máximo: 30g/dia',
        unidade: 'g',
        dosePorKgMinima: 0.100,
        dosePorKgMaxima: 0.150,
        doseMaxima: 30000,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Uso oral profilático',
        descricaoDose: '• 1–2g VO, 3 a 4x/dia\n• Máximo: 8g/dia durante sangramentos',
    peso:peso
      ),

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Antifibrinolítico que inibe a conversão de plasminogênio em plasmina.'),
      _textoObs('• Alternativa útil ao ácido tranexâmico, especialmente por via oral.'),
      _textoObs('• Risco aumentado de trombose e convulsões em pacientes predispostos.'),
      _textoObs('• Contraindicado em hematuria macroscópica de origem renal.'),
      _textoObs('• Monitorar função renal em uso prolongado.'),
    ],
  );
}
Widget buildCardAcidoTranexamico(BuildContext context, double peso, bool isAdulto) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Ampolas de 250mg/2,5mL ou 500mg/5mL (100mg/mL) ', ''),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('IV: diluir 1g em 100mL SF 0,9% ou SG 5%. Infundir em 10–20 min.', ''),
      _linhaPreparo('VO: comprimidos 250–500mg. Administrar 2–3x/dia.', ''),
      _linhaPreparo('Evitar bolus IV rápido – risco de convulsão e hipotensão.', ''),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      _linhaIndicacaoDoseCalculada(
        titulo: 'Hemorragia aguda',
        descricaoDose: '• 1g IV infusão lenta\n• Repetir 1g após 8h (máx 2g/dia)',
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Cirurgia com sangramento',
        descricaoDose: '• 10–15 mg/kg IV antes da incisão\n• Repetir cada 3–6h',
        unidade: 'mg',
        dosePorKgMinima: 10,
        dosePorKgMaxima: 15,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Infusão contínua \n(manutenção após bolus)',
        descricaoDose: '• Iniciar 1 mg/kg/h IV contínua após bolus\n• Ajustar conforme risco e sangramento',
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Menorragia',
        descricaoDose: '• 500–1000mg VO 2–3x/dia durante o período menstrual (até 5 dias)',
        peso: peso,
      ),

      const SizedBox(height: 16),
      const Text('Infusão contínua', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      const Text('Após a dose de ataque, pode ser necessário manter infusão contínua conforme risco de sangramento.'),

      const SizedBox(height: 16),
      const Text('Cálculo da Infusão', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      ConversaoInfusaoSlider(
        peso: peso,
        opcoesConcentracoes: {
          '1g/100mL (10mg/mL)': 10000,
          '2g/100mL (20mg/mL)': 20000,
        },
        unidade: 'mg/kg/h',
        doseMin: 0.5,
        doseMax: 2.0,
      ),

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Antifibrinolítico que bloqueia a ativação da plasmina.'),
      _textoObs('• Eficaz em trauma, HPP, sangramentos ginecológicos e cirurgia cardíaca.'),
      _textoObs('• Doses altas ou bolus rápido aumentam risco de convulsão.'),
      _textoObs('• Ajustar dose em insuficiência renal grave.'),
      _textoObs('• Off-label: uso em sangramentos por cirrose, trombocitopatias e epistaxe refratária.'),
      _textoObs('• Monitorar sinais de TVP e convulsão em pacientes com predisposição trombótica.'),
    ],
  );
}


// 🩺 Vasopressores e Hipotensores

Widget buildCardDobutamina(BuildContext context, double peso, bool isAdulto) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Ampola 250mg/20mL (12,5mg/mL)', ''),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('250mg em 250mL SG 5%', '1 mg/mL'),
      _linhaPreparo('500mg em 250mL SG 5%', '2 mg/mL'),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      _linhaIndicacaoDoseCalculada(
        titulo: 'Insuficiência cardíaca aguda/descompensada',
        descricaoDose: '2–20 mcg/kg/min IV contínua',
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Choque cardiogênico',
        descricaoDose: '2–20 mcg/kg/min IV contínua',
        peso: peso,
      ),

      const SizedBox(height: 16),
      const Text('Cálculo da Infusão', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      ConversaoInfusaoSlider(
        peso: peso,
        opcoesConcentracoes: {
          '250mg/250mL (1mg/mL)': 1000,
          '500mg/250mL (2mg/mL)': 2000,
        },
        unidade: 'mcg/kg/min',
        doseMin: 2.0,
        doseMax: 20.0,
      ),

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Agonista beta-1 predominante com leve efeito beta-2 e alfa-1.'),
      _textoObs('• Aumenta contratilidade e débito sem grande vasoconstrição.'),
      _textoObs('• Pode causar taquiarritmias em altas doses.'),
      _textoObs('• Útil em baixo débito e hipoperfusão.'),
      _textoObs('• Monitorizar ECG e sinais vitais continuamente.'),
    ],
  );
}
Widget buildCardFenilefrina(BuildContext context, double peso, bool isAdulto) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Ampola 10mg/mL (solução injetável)', ''),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('10mg em 100mL SF 0,9%', '100 mcg/mL'),
      _linhaPreparo('10mg em 250mL SF 0,9%', '40 mcg/mL'),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      if (isAdulto) ...[
        _linhaIndicacaoDoseCalculada(
          titulo: 'Hipotensão em anestesia',
          descricaoDose: '50–200 mcg IV bolus lento',
          dosePorKgMinima: 0.5,
          dosePorKgMaxima: 3.0,
          doseMaxima: 0.2,
          unidade: 'mg',
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Infusão contínua',
          descricaoDose: '0,2–2 mcg/kg/min',
          peso: peso,
        ),
      ] else ...[
        _linhaIndicacaoDoseCalculada(
          titulo: 'Hipotensão pediátrica',
          descricaoDose: '1–5 mcg/kg em bolus IV',
          dosePorKgMinima: 0.001,
          dosePorKgMaxima: 0.005,
          doseMaxima: 0.2,
          unidade: 'mg',
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Infusão contínua',
          descricaoDose: '0,1–0,5 mcg/kg/min',
          peso: peso,
        ),
      ],

      const SizedBox(height: 16),
      const Text('Cálculo da Infusão', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      ConversaoInfusaoSlider(
        peso: peso,
        opcoesConcentracoes: {
          '10mg/100mL (100mcg/mL)': 100,
          '10mg/250mL (40mcg/mL)': 40,
        },
        unidade: 'mcg/kg/min',
        doseMin: 0.1,
        doseMax: 2.0,
      ),

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Agonista alfa-1 puro (sem efeito beta).'),
      _textoObs('• Ideal para hipotensão com taquicardia.'),
      _textoObs('• Causa vasoconstrição periférica intensa.'),
      _textoObs('• Pode reduzir débito cardíaco em disfunção ventricular.'),
      _textoObs('• Usar com monitorização contínua.'),
    ],
  );
}
Widget buildCardMetaraminol(BuildContext context, double peso, bool isAdulto) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Ampola 10mg/mL (solução injetável)', 'Aramine®'),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('10mg em 20mL SF 0,9%', '0,5 mg/mL (bolus)'),
      _linhaPreparo('10mg em 100mL SF 0,9%', '0,1 mg/mL (infusão contínua)'),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      if (isAdulto) ...[
        _linhaIndicacaoDoseCalculada(
          titulo: 'Hipotensão aguda',
          descricaoDose: '0,5–5 mg IV bolus',
          dosePorKgMinima: 0.01,
          dosePorKgMaxima: 0.1,
          doseMaxima: 5,
          unidade: 'mg',
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Infusão contínua em choque vasodilatador',
          descricaoDose: '0,5–5 mcg/min',
          unidade: 'mL/h',
          dosePorKgMinima: 0.01,
          dosePorKgMaxima: 0.08,
          peso: peso,
        ),
      ] else ...[
        _linhaIndicacaoDoseCalculada(
          titulo: 'Hipotensão pediátrica',
          descricaoDose: '0,01–0,1 mg/kg IV bolus',
          dosePorKgMinima: 0.01,
          dosePorKgMaxima: 0.1,
          doseMaxima: 5,
          unidade: 'mg',
          peso: peso,
        ),
      ],

      const SizedBox(height: 16),
      const Text('Cálculo da Infusão', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      ConversaoInfusaoSlider(
        peso: peso,
        opcoesConcentracoes: {
          '10mg/100mL (0,1mg/mL)': 100,
        },
        unidade: 'mcg/kg/min',
        doseMin: 0.01,
        doseMax: 0.08,
      ),

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Vasoconstritor alfa-adrenérgico puro.'),
      _textoObs('• Útil em hipotensão refratária à fluidoterapia.'),
      _textoObs('• Ação rápida e curta duração.'),
      _textoObs('• Pode causar bradicardia reflexa.'),
      _textoObs('• Evitar extravasamento (risco de necrose).'),
    ],
  );
}
Widget buildCardEfedrina(BuildContext context, double peso, bool isAdulto) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Ampola 50mg/mL (solução injetável)', ''),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('50mg em 10mL SF 0,9%', '5 mg/mL'),
      _linhaPreparo('50mg em 50mL SF 0,9%', '1 mg/mL'),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      if (isAdulto) ...[
        _linhaIndicacaoDoseCalculada(
          titulo: 'Hipotensão intraoperatória',
          descricaoDose: '5–25 mg IV lento ou IM (titulável)',
          dosePorKgMinima: 0.1,
          dosePorKgMaxima: 0.5,
          doseMaxima: 25,
          unidade: 'mg',
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Resgate vasopressor em obstetrícia (pós-RA)',
          descricaoDose: '5–10 mg IV lento em bolus (repetível)',
          dosePorKgMinima: 0.1,
          dosePorKgMaxima: 0.2,
          doseMaxima: 10,
          unidade: 'mg',
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Infusão contínua (uso off-label)',
          descricaoDose: '1–5 mcg/min (ajustar por resposta)',
          dosePorKgMinima: 0.015,
          dosePorKgMaxima: 0.075,
          unidade: '\n mcg/kg/min',
          peso: peso,
        ),
      ] else ...[
        _linhaIndicacaoDoseCalculada(
          titulo: 'Hipotensão em pediatria',
          descricaoDose: '0,1–0,3 mg/kg IV lento (máx 25mg/dose)',
          dosePorKgMinima: 0.1,
          dosePorKgMaxima: 0.3,
          doseMaxima: 25,
          unidade: 'mg',
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Infusão contínua (uso off-label)',
          descricaoDose: '0,05–0,3 mcg/kg/min IV contínua',
          dosePorKgMinima: 0.05,
          dosePorKgMaxima: 0.3,
          unidade: 'mcg/kg/min',
          peso: peso,
        ),
      ],

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Estimula receptores alfa e beta-adrenérgicos.'),
      _textoObs('• Aumenta pressão arterial e débito cardíaco.'),
      _textoObs('• Útil em hipotensão associada à anestesia.'),
      _textoObs('• Efeito imediato com duração de 10–60 minutos.'),
      _textoObs('• Pode causar taquicardia e arritmias.'),

      const SizedBox(height: 16),
      const Text('Cálculo da Infusão', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      ConversaoInfusaoSlider(
        peso: peso,
        opcoesConcentracoes: {
          '50mg/50mL (1mg/mL)': 1000,
          '50mg/100mL (0,5mg/mL)': 500,
        },
        unidade: 'mcg/kg/min',
        doseMin: 0.05,
        doseMax: 0.3,
      ),
    ],
  );
}
Widget buildCardAdrenalina(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito,) {
  // Certifique-se de que SharedData.idade está disponível no escopo
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Ampola 1mg/mL (solução injetável)', ''),
      _linhaPreparo('Ampola 0,1mg/mL (uso neonatal)', ''),

      const SizedBox(height: 16),
      const Text('Preparo',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('1mg em 1mL', 'Puro'),
      _linhaPreparo('1mg em 9mL SF 0,9%', '0,1 mg/mL'),
      _linhaPreparo('6mg em 94mL SF 0,9%', '60 mcg/mL'),



      const SizedBox(height: 16),
      const Text('Indicações Clínicas',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      // Faixa etária: Neonatal (<1 mês), Pediátrico (1 mês a <18 anos), Adulto (>=18 anos)
      if (SharedData.idade != null && SharedData.idade! < 1) ...[
        const Text('Neonatal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.teal)),
        const SizedBox(height: 6),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Bradicardia neonatal',
          descricaoDose: '0,01 mg/kg EV (Ventilar antes)',
          dosePorKg: 0.01,
          doseMaxima: 1.0,
          unidade: 'mg',
          peso: peso,
        ),
      ] else if (SharedData.idade != null && SharedData.idade! < 18) ...[
        const Text('Pediátrico', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.deepPurple)),
        const SizedBox(height: 6),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Parada cardíaca pediátrica',
          descricaoDose: '0,01 mg/kg EV a cada 3–5 min',
          dosePorKg: 0.01,
          doseMaxima: 1.0,
          unidade: 'mg',
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Choque anafilático',
          descricaoDose: '0,01 mg/kg IM',
          dosePorKg: 0.01,
          doseMaxima: 0.3,
          unidade: 'mg',
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Broncoespasmo agudo refratário',
          descricaoDose: '0,01 mg/kg SC ou IM (máx 3 doses)',
          dosePorKg: 0.01,
          doseMaxima: 0.3,
          unidade: 'mg',
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Crup viral grave',
          descricaoDose: '5mg em 5mL SF nebulizado',
          unidade: '5 mg',
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Bradicardia refratária',
          descricaoDose: '0,01 mg/kg EV bolus \n+infusão contínua 0,1–1mcg/kg/min',
          dosePorKg: 0.01,
          doseMaxima: 1,
          unidade: 'mg \n 0,1–1 mcg/kg/min',
          peso: peso,
        ),
      ] else ...[
        const Text('Adulto', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.indigo)),
        const SizedBox(height: 6),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Parada cardiorrespiratória',
          descricaoDose: '1mg IV a cada 3–5 min',
          dosePorKg: 1.0,
          doseMaxima: 1.0,
          unidade: 'mg',
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Anafilaxia',
          descricaoDose: '0,5mg IM',
          dosePorKgMinima: 0.3,
          dosePorKgMaxima: 0.5,
          doseMaxima: 0.5,
          unidade: 'mg',
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Broncoespasmo grave',
          descricaoDose: '0,01mg/kg SC/IM',
          dosePorKg: 0.01,
          doseMaxima: 0.5,
          unidade: 'mg',
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Choque refratário',
          descricaoDose: '0,05–2 mcg/kg/min IV contínua',
          unidade: 'mcg/kg/min',
          dosePorKgMinima: 0.05,
          dosePorKgMaxima: 2.0,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Bradicardia refratária',
          descricaoDose: '1 – 20 mcg/min IV infusão contínua\nNessas Condições:\n-Solução de 60mcg/mL:\n-Cada 1ml/h corresponde 1mcg/min ',
          unidade: 'mcg/min',
          dosePorKgMinima: 1/peso,
          dosePorKgMaxima: 20/peso,
          peso: peso,
        ),
      ],

      // Outras Indicações (off-label / secundárias)
      const SizedBox(height: 16),
      const Text('Outras Indicações (off-label / secundárias)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Uso intraósseo em situações de emergência quando acesso venoso não disponível.'),
      _textoObs('• Nebulização para estenose subglótica e crup viral grave (epinefrina racêmica).'),
      _textoObs('• Pode ser utilizada em instilação endotraqueal (dose aumentada).'),

      // Cálculo da Infusão
      const SizedBox(height: 16),
      const Text('Cálculo da Infusão', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      ConversaoInfusaoSlider(
        peso: peso,
        opcoesConcentracoes: {
          '6mg/94mL (60mcg/mL)': 60,
          '1mg/100mL (10mcg/mL)': 10,
        },
        unidade: 'mcg/kg/min',
        doseMin: 0.05,
        doseMax: 2.0,
      ),

      const SizedBox(height: 16),
      const Text('Observações',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Vasopressor e broncodilatador de ação imediata.'),
      _textoObs('• Ideal para situações de emergência.'),
      _textoObs('• Monitorar ritmo cardíaco e pressão arterial.'),
      _textoObs('• Risco de arritmias em altas doses.'),
      _textoObs('• Uso cuidadoso em idosos e cardiopatas.'),
    ],
  );
}
Widget buildCardVasopressina(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito,) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Ampola 20 UI/mL (solução injetável)', ''),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('20 UI em 100mL SF 0,9%', '0,2 UI/mL'),
      _linhaPreparo('20 UI em 50mL SF 0,9%', '0,4 UI/mL'),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      if (isAdulto) ...[
        _linhaIndicacaoDoseCalculada(
          titulo: 'Choque vasodilatador (sépse/refratário)',
          descricaoDose: '0,01–0,04 UI/min IV contínua',
          unidade: 'UI/min',
          dosePorKgMinima: 0.01 / peso,
          dosePorKgMaxima: 0.04 / peso,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Parada cardiorrespiratória',
          descricaoDose: '40 UI IV bolus (dose única alternativa à adrenalina)',
          doseMaxima: 40,
          unidade: 'UI',
          peso: peso,
        ),
      ] else ...[
        _linhaIndicacaoDoseCalculada(
          titulo: 'Choque séptico pediátrico refratário',
          descricaoDose: '0,0003–0,002 UI/kg/min IV contínua',
          peso: peso,
        ),
      ],

      const SizedBox(height: 16),
      const Text('Cálculo da Infusão', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      ConversaoInfusaoSlider(
        peso: peso,
        opcoesConcentracoes: {
          '20 UI/100mL (0,2 UI/mL)': 0.2,
          '20 UI/50mL (0,4 UI/mL)': 0.4,
        },
        unidade: 'UI/min',
        doseMin: 0.01,
        doseMax: 0.04,
      ),

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Agonista de receptores V1 (vasoconstrição) e V2 (antidiurético).'),
      _textoObs('• Reduz necessidade de catecolaminas no choque séptico.'),
      _textoObs('• Alternativa à adrenalina na parada cardiorrespiratória (40 UI dose única).'),
      _textoObs('• Potente efeito vasoconstritor esplâncnico e coronariano.'),
      _textoObs('• Pode causar hiponatremia, isquemia periférica ou mesentérica.'),
    ],
  );
}
Widget buildCardNoradrenalina(BuildContext context,double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito,) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Ampola 4mg/2mL (2mg/mL)', ''),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('4mg em 250mL SF 0,9%', '16 mcg/mL (adulto)'),
      _linhaPreparo('1mg em 100mL SG 5%', '10 mcg/mL (pediátrico)'),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      if (isAdulto) ...[
        _linhaIndicacaoDoseCalculada(
          titulo: 'Choque séptico / vasodilatador',
          descricaoDose: '0,05–2 mcg/kg/min IV contínua',
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Hipotensão refratária à reposição volêmica',
          descricaoDose: '0,05–1 mcg/kg/min IV contínua',
          peso: peso,
        ),
      ] else ...[
        _linhaIndicacaoDoseCalculada(
          titulo: 'Choque séptico pediátrico',
          descricaoDose: '0,05–1 mcg/kg/min IV contínua',
          peso: peso,
        ),
      ],

      const SizedBox(height: 16),
      const Text('Cálculo da Infusão', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      ConversaoInfusaoSlider(
        peso: peso,
        opcoesConcentracoes: {
          '4mg/250mL (16mcg/mL)': 16,
          '1mg/100mL (10mcg/mL)': 10,
        },
        unidade: 'mcg/kg/min',
        doseMin: 0.05,
        doseMax: 2.0,
      ),

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Potente vasoconstritor alfa-adrenérgico.'),
      _textoObs('• Droga de escolha no choque séptico.'),
      _textoObs('• Monitorar continuamente a pressão arterial.'),
      _textoObs('• Usar em bomba de infusão, preferencialmente via acesso central.'),
      _textoObs('• Ajustar dose conforme resposta hemodinâmica do paciente.'),
    ],
  );
}
Widget buildCardDopamina(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito,) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Ampola 200mg/5mL (40mg/mL)', ''),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('200mg em 250mL SG 5%', '0,8 mg/mL (800 mcg/mL)'),
      _linhaPreparo('400mg em 250mL SG 5%', '1,6 mg/mL (1600 mcg/mL)'),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      if (isAdulto) ...[
        _linhaIndicacaoDoseCalculada(
          titulo: 'Choque com baixa perfusão',
          descricaoDose: '2–20 mcg/kg/min IV contínua',
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Bradicardia sintomática com instabilidade',
          descricaoDose: '2–10 mcg/kg/min IV contínua',
          peso: peso,
        ),
      ] else ...[
        _linhaIndicacaoDoseCalculada(
          titulo: 'Choque séptico ou cardiogênico (pediatria)',
          descricaoDose: '2–20 mcg/kg/min IV contínua',
          peso: peso,
        ),
      ],

      const SizedBox(height: 16),
      const Text('Cálculo da Infusão', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      ConversaoInfusaoSlider(
        peso: peso,
        opcoesConcentracoes: {
          '200mg/250mL (800mcg/mL)': 800,
          '400mg/250mL (1600mcg/mL)': 1600,
        },
        unidade: 'mcg/kg/min',
        doseMin: 2.0,
        doseMax: 20.0,
      ),

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Ação dose-dependente:'),
      _textoObs('  • Baixa (1–3 mcg/kg/min): efeito dopaminérgico renal (não recomendado mais para este fim).'),
      _textoObs('  • Média (5–10 mcg/kg/min): efeito beta-1 inotrópico (aumento do débito cardíaco).'),
      _textoObs('  • Alta (10–20 mcg/kg/min): efeito alfa-1 vasoconstritor (aumenta PA).'),
      _textoObs('• Monitorar ritmo cardíaco e pressão arterial constantemente.'),
      _textoObs('• Preferencialmente utilizar bomba de infusão.'),
      _textoObs('• Pode causar arritmias, taquicardia e isquemia em altas doses.'),
    ],
  );
}
Widget buildCardNitroglicerina(BuildContext context, double peso, bool isAdulto) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Ampola 50mg/10mL (5mg/mL)', ''),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('50mg em 250mL SG 5%', '200 mcg/mL'),
      _linhaPreparo('50mg em 500mL SG 5%', '100 mcg/mL'),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      if (isAdulto) ...[
        _linhaIndicacaoDoseCalculada(
          titulo: 'Angina instável / IAM com supra',
          descricaoDose: '5–200 mcg/min IV contínua',
          unidade: 'mcg/min',
          dosePorKgMinima: 5 / peso,
          dosePorKgMaxima: 200 / peso,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Edema agudo de pulmão (vasodilatador venoso)',
          descricaoDose: '20–100 mcg/min IV contínua',
          unidade: 'mcg/min',
          dosePorKgMinima: 20 / peso,
          dosePorKgMaxima: 100 / peso,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Crise hipertensiva',
          descricaoDose: '5–100 mcg/min IV contínua',
          unidade: 'mcg/min',
          dosePorKgMinima: 5 / peso,
          dosePorKgMaxima: 100 / peso,
          peso: peso,
        ),
      ] else ...[
        _linhaIndicacaoDoseCalculada(
          titulo: 'Controle da pré/pós-carga em cirurgia cardíaca',
          descricaoDose: '0,5–5 mcg/kg/min IV contínua',
          peso: peso,
        ),
      ],

      const SizedBox(height: 16),
      const Text('Cálculo da Infusão', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      ConversaoInfusaoSlider(
        peso: peso,
        opcoesConcentracoes: {
          '50mg/250mL (200mcg/mL)': 200,
          '50mg/500mL (100mcg/mL)': 100,
        },
        unidade: isAdulto ? 'mcg/min' : 'mcg/kg/min',
        doseMin: isAdulto ? 5 : 0.5,
        doseMax: isAdulto ? 100 : 5.0,
      ),

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Vasodilatador venoso potente com leve ação arterial em doses mais altas.'),
      _textoObs('• Reduz pré-carga e demanda miocárdica por oxigênio.'),
      _textoObs('• Monitorar PA e sinais de hipotensão com uso contínuo.'),
      _textoObs('• Uso exclusivo em bomba de infusão contínua.'),
      _textoObs('• Pode causar cefaleia e rubor facial.'),
    ],
  );
}
Widget buildCardNitroprussiato(BuildContext context, double peso, bool isAdulto) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Frasco-ampola 2mL \n(50mg – pó liofilizado)', 'Nipride®, Nitropress®'),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Reconstituir em SG 5% (exclusivo). Proteger da luz após preparo.', ''),
      _linhaPreparo('Diluição: 50mg em 250mL SG5% = 200mcg/mL', ''),
      _linhaPreparo('Diluição alternativa: 50mg em 500mL SG5% = 100mcg/mL', ''),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaIndicacaoDoseFixa(
        titulo: 'Emergência hipertensiva / dissecção de aorta',
        descricaoDose:'• Início: 0,3 mcg/kg/min\n• Ajuste até 10 mcg/kg/min conforme resposta',
        unidade: 'mcg/kg/min',
        valorMinimo: 0.3,
        valorMaximo: 10,
      ),    _linhaIndicacaoDoseFixa(
        titulo: 'Controle hemodinâmico em cirurgia cardiovascular',
        descricaoDose: '0,3–3 mcg/kg/min IV contínua',
        unidade: 'mcg/kg/min',
        valorMinimo: 0.3,
        valorMaximo: 3.0,
      ),



      const SizedBox(height: 16),
      const Text('Cálculo da Infusão', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      ConversaoInfusaoSlider(
        peso: peso,
        opcoesConcentracoes: {
          '50mg/250mL (200mcg/mL)': 200,
          '50mg/500mL (100mcg/mL)': 100,
        },
        unidade: 'mcg/kg/min',
        doseMin: 0.3,
        doseMax: 10.0,
      ),

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Proteger da luz após preparo — envolver seringa e equipo com papel alumínio.'),
      _textoObs('• Risco de toxicidade por cianeto em infusões prolongadas ou altas doses.'),
      _textoObs('• Uso exclusivo com bomba de infusão contínua e monitorização rigorosa.'),
      _textoObs('• Vasodilatador arterial e venoso potente, de ação rápida.'),
      _textoObs('• Pode causar hipotensão grave se titulado rapidamente.'),
    ],
  );
}
Widget buildCardMilrinona(BuildContext context, double peso, bool isAdulto) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Ampola 10mg/10mL (1mg/mL)', ''),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('10mg em 100mL SG 5%', '0,1 mg/mL'),
      _linhaPreparo('20mg em 100mL SG 5%', '0,2 mg/mL'),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      if (isAdulto) ...[
        _linhaIndicacaoDoseCalculada(
          titulo: 'IC descompensada / pós-operatório cardíaco',
          descricaoDose: 'Bolus de 50 mcg/kg EV lento em 10 min, seguido de 0,375–0,75 mcg/kg/min',
          peso: peso,
        ),
      ] else ...[
        _linhaIndicacaoDoseCalculada(
          titulo: 'Disfunção ventricular pós-operatória (pediatria)',
          descricaoDose: 'Bolus de 50 mcg/kg em 10 min, seguido de 0,25–0,75 mcg/kg/min',
          peso: peso,
        ),
      ],

      const SizedBox(height: 16),
      const Text('Cálculo da Infusão', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      ConversaoInfusaoSlider(
        peso: peso,
        opcoesConcentracoes: {
          '10mg/100mL (0,1mg/mL)': 100,
          '20mg/100mL (0,2mg/mL)': 200,
        },
        unidade: 'mcg/kg/min',
        doseMin: 0.25,
        doseMax: 0.75,
      ),

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Inibidor da fosfodiesterase III com efeito inotrópico e vasodilatador.'),
      _textoObs('• Melhora contratilidade e reduz a pós-carga.'),
      _textoObs('• Meia-vida longa (2–4h), cuidado com acúmulo em disfunção renal.'),
      _textoObs('• Pode causar hipotensão e arritmias.'),
      _textoObs('• Evitar associação com inibidores de PDE ou levosimendana.'),
    ],
  );
}


// 🩺 Anticolinérgicos e Broncodilatadores
Widget buildCardSalbutamol(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito,) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Solução inalatória 0,5% (5mg/mL)', 'Aerolin®, Ventolin®'),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Diluir em 3–4mL SF 0,9% e nebulizar por 5–10 minutos', ''),
      _linhaPreparo('Dose usual: 2,5mg (0,5mL) ou 5mg (1mL)', ''),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      if (isAdulto) ...[
        _linhaIndicacaoDoseCalculada(
          titulo: 'Crise asmática / broncoespasmo em DPOC',
          descricaoDose: '2,5–5mg por nebulização a cada 20 min até resposta; depois a cada 4–6h',
          unidade: 'mg',
          dosePorKgMinima: 2.5 / peso,
          dosePorKgMaxima: 5.0 / peso,
          peso: peso,
        ),
      ] else ...[
        _linhaIndicacaoDoseCalculada(
          titulo: 'Broncoespasmo em crianças (asma / bronquiolite)',
          descricaoDose: '0,15 mg/kg por nebulização (mín 1,25mg – máx 5mg)',
          unidade: 'mg',
          dosePorKg: 0.15,
          doseMaxima: 5.0,
          peso: peso,
        ),
      ],

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Agonista β2-adrenérgico seletivo, broncodilatador de ação rápida.'),
      _textoObs('• Início em 5 minutos, pico em 30 minutos, duração até 4–6h.'),
      _textoObs('• Pode causar taquicardia, tremores, hipocalemia e agitação.'),
      _textoObs('• Uso seguro em pediatria e em nebulizações combinadas com ipatrópio.'),
      _textoObs('• Monitorar FC, SatO₂ e eletrólitos nas crises graves.'),
    ],
  );
}
Widget buildCardFenoterol(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito,) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Solução inalatória 0,5mg/mL (10 gotas = 0,25mg)', 'Berotec®, genéricos'),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Diluir em 3–4mL SF 0,9% e nebulizar por 5–10 min', ''),
      _linhaPreparo('Pode ser associado a ipatrópio ou corticoide inalatório', ''),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      if (isAdulto) ...[
        _linhaIndicacaoDoseCalculada(
          titulo: 'Crise asmática / broncoespasmo em DPOC',
          descricaoDose: '0,25–0,5mg (10–20 gotas) por nebulização a cada 6–8h',
          unidade: 'mg',
          dosePorKgMinima: 0.25 / peso,
          dosePorKgMaxima: 0.5 / peso,
          peso: peso,
        ),
      ] else ...[
        _linhaIndicacaoDoseCalculada(
          titulo: 'Broncoespasmo em crianças',
          descricaoDose: '0,05–0,1 mg (2–4 gotas) por nebulização a cada 6h',
          unidade: 'mg',
          dosePorKgMinima: 0.05 / peso,
          dosePorKgMaxima: 0.1 / peso,
          peso: peso,
        ),
      ],

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Agonista β2-adrenérgico → broncodilatação rápida e eficaz.'),
      _textoObs('• Início em 5–10 min, duração até 4–6h.'),
      _textoObs('• Efeitos adversos: tremor, taquicardia e hipocalemia.'),
      _textoObs('• Frequentemente associado a ipatrópio.'),
      _textoObs('• Monitorar FC e resposta clínica, especialmente em crianças e cardiopatas.'),
    ],
  );
}
Widget buildCardIpatropio(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito,) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Solução inalatória 0,25mg/mL (20 gotas = 0,5mg)', 'Atrovent®, Aerolin® Duo'),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Diluir em 3–4mL SF 0,9% e nebulizar em 5–10 minutos', ''),
      _linhaPreparo('Pode ser associado a beta2 agonistas (ex: salbutamol)', ''),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      if (isAdulto) ...[
        _linhaIndicacaoDoseCalculada(
          titulo: 'Crise asmática / broncoespasmo em DPOC',
          descricaoDose: '0,5mg (20 gotas) por nebulização a cada 6–8h',
          unidade: 'mg',
          dosePorKgMinima: 0.5 / peso,
          dosePorKgMaxima: 0.5 / peso,
          peso: peso,
        ),
      ] else ...[
        _linhaIndicacaoDoseCalculada(
          titulo: 'Bronquiolite / broncoespasmo pediátrico',
          descricaoDose: '0,25mg (10 gotas) por nebulização a cada 6–8h',
          unidade: 'mg',
          dosePorKgMinima: 0.25 / peso,
          dosePorKgMaxima: 0.25 / peso,
          peso: peso,
        ),
      ],

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Antagonista muscarínico M1/M3 → promove broncodilatação via inibição vagal.'),
      _textoObs('• Efeito máximo em 30–60 min, duração de até 6h.'),
      _textoObs('• Pode causar boca seca, tosse ou gosto metálico.'),
      _textoObs('• Uso complementar a beta2 agonistas e corticoides.'),
      _textoObs('• Seguro em crianças, gestantes e idosos.'),
    ],
  );
}
Widget buildCardAtropina(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito,) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Ampolas 0,5mg/mL ou 1mg/mL – 1mL ', ''),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Pode ser administrada IV lenta, IM, SC ou via endotraqueal (em emergência)', ''),
      _linhaPreparo('Para bolus IV: administrar puro ou diluir 1:10 em SF 0,9%', ''),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      if (isAdulto) ...[
        _linhaIndicacaoDoseCalculada(
          titulo: 'Bradicardia sintomática',
          descricaoDose: '• 0,5mg IV a cada 3–5min até 3mg (máximo)',
          peso: peso,
        ),
      ],

      _linhaIndicacaoDoseCalculada(
        titulo: 'Bradicardia pediátrica/RCP',
        descricaoDose: '• 0,02mg/kg IV \n(mín 0,1mg – máx 0,5mg por dose)',
        unidade: 'mg',
        dosePorKg: 0.02,
        doseMaxima: 0.5,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Intoxicação por organofosforado',
        descricaoDose: '• 2–5mg IV a cada 5–10min até sinais de atropinização\n• Pode ultrapassar 100mg em intoxicações graves',
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Pré-medicação anestésica',
        descricaoDose: '• 0,01–0,02mg/kg IM ou IV \n30–60 min antes da indução• Máximo: 1mg por dose',
        unidade: 'mg',
        dosePorKgMinima: 0.01,
        dosePorKgMaxima: 0.02,
        doseMaxima: 1.0,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Reversão de BNM \n(com neostigmina)',
        descricaoDose: '• 0,015–0,03 mg/kg IV lenta \njunto com neostigmina\n• Máximo: 1mg por dose',
        unidade: 'mg',
        dosePorKgMinima: 0.015,
        dosePorKgMaxima: 0.03,
        doseMaxima: 1.0,
        peso: peso,
      ),

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Antimuscarínico que bloqueia os receptores M1 e M3 – reduz secreções e bradicardia vagal.'),
      _textoObs('• Primeira escolha em bradicardia sintomática e intoxicação por organofosforado/carbamato.'),
      _textoObs('• Sinais de atropinização: taquicardia, midríase, pele seca, agitação, confusão.'),
      _textoObs('• Manter administração até controle de secreções e frequência cardíaca >80 bpm em intoxicações.'),
      _textoObs('• Cautela em cardiopatas, idosos, glaucoma de ângulo fechado e obstrução urinária.'),
      _textoObs('• Off-label: pré-medicação para bloqueio anestésico ou bradicardia reflexa esperada em procedimentos vagais.'),
      _textoObs('• Associada à neostigmina para reversão de bloqueadores não despolarizantes.'),
    ],
  );
}
Widget buildCardTerbutalina(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito,) {return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Ampola 1mg/mL (1mL SC ou IM)', 'Bricanyl® injetável ou aerossol dosificado'),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('SC pura ou diluída em 1–2mL SF 0,9% (se necessário)', ''),
      _linhaPreparo('Pode ser repetida após 15–20 min até 3x se necessário', ''),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      if (isAdulto) ...[
        _linhaIndicacaoDoseCalculada(
          titulo: 'Crise asmática grave / broncoespasmo',
          descricaoDose: '0,25mg SC (1/4 da ampola) a cada 20 min até 3 doses',
          unidade: 'mg',
          dosePorKgMinima: 0.25 / peso,
          dosePorKgMaxima: 0.25 / peso,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Tocolítico (off-label obstetrícia)',
          descricaoDose: '250mcg SC a cada 4–6h para inibir contrações uterinas',
          unidade: 'mcg',
          dosePorKgMinima: 250 / peso,
          doseMaxima: 250,
          peso: peso,
        ),
      ] else ...[
        _linhaIndicacaoDoseCalculada(
          titulo: 'Crise asmática pediátrica grave',
          descricaoDose: '0,005–0,01 mg/kg SC a cada 20–30 min (máx 0,3mg/dose)',
          unidade: 'mg',
          dosePorKgMinima: 0.005,
          dosePorKgMaxima: 0.01,
          doseMaxima: 0.3,
          peso: peso,
        ),
      ],

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Agonista β2 potente com ação broncodilatadora e relaxante uterina.'),
      _textoObs('• Via subcutânea ideal em crises graves quando nebulização não é possível.'),
      _textoObs('• Pode causar taquicardia, agitação, tremores e hipocalemia.'),
      _textoObs('• Uso obstétrico é off-label, com monitoramento fetal rigoroso.'),
      _textoObs('• Contraindicado em cardiopatas, hipertensos e hipertireoidismo não controlado.'),
    ],
  );}

// 🩺 Opioides e Analgésicos Potentes
Widget buildCardPetidina(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito,) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Ampola 50mg/mL ou 100mg/mL', 'Dolantina®, Meperidina Genérico'),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('IV, IM ou SC. Diluir em SF se IV', ''),
      _linhaPreparo('Uso lento para evitar efeitos adversos', ''),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Dor aguda moderada a intensa',
        descricaoDose: '50–100mg IM/IV a cada 4–6h (máx 600mg/dia)',
        unidade: 'mg',
        dosePorKgMinima: 50 / peso,
        dosePorKgMaxima: 100 / peso,
        doseMaxima: 600,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Analgesia obstétrica',
        descricaoDose: '25–50mg IM a cada 3–4h',
        unidade: 'mg',
        dosePorKgMinima: 25 / peso,
        dosePorKgMaxima: 50 / peso,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Calafrios pós-anestésicos (off-label)',
        descricaoDose: '12,5–25mg IV lenta, dose única',
        unidade: 'mg',
        dosePorKgMinima: 12.5 / peso,
        dosePorKgMaxima: 25 / peso,
        peso: peso,
      ),

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Opioide de ação intermediária.'),
      _textoObs('• Risco de neurotoxicidade (normeperidina).'),
      _textoObs('• Evitar em insuficiência renal e idosos.'),
      _textoObs('• Útil em analgesia obstétrica.'),
      _textoObs('• Pode causar náuseas, sedação, hipotensão e confusão.'),
    ],
  );
}
Widget buildCardAlfentanil(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito,) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Ampola 0,5mg/mL (2mL ou 10mL)', 'Rapifen®, Alfenta®'),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Uso IV exclusivo: bolus lento ou infusão contínua', ''),
      _linhaPreparo('Exemplo de diluição para infusão: 5mg (10mL) em 50mL SF 0,9% → concentração final: 0,1mg/mL (100mcg/mL)', ''),
      _linhaPreparo('Recomenda-se uso em bomba de infusão para melhor controle da dose', ''),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      // Faixa etária: Neonatal (<1 mês), Pediátrico (1 mês a <18 anos), Adulto (>=18 anos)
      if (SharedData.idade != null && SharedData.idade! < 1) ...[
        const Text('Neonatal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.teal)),
        const SizedBox(height: 6),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Indução para intubação (off-label)',
          descricaoDose: '10–20 mcg/kg IV lento',
          unidade: 'mcg',
          dosePorKgMinima: 10,
          dosePorKgMaxima: 20,
          peso: peso,
        ),
      ] else if (SharedData.idade != null && SharedData.idade! < 18) ...[
        const Text('Pediátrico', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.deepPurple)),
        const SizedBox(height: 6),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Indução anestésica pediátrica',
          descricaoDose: '10–30 mcg/kg IV lento',
          unidade: 'mg',
          dosePorKgMinima: 10/1000,
          dosePorKgMaxima: 30/1000,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Manutenção anestésica',
          descricaoDose: '0,25–0,5 mcg/kg/min IV contínua',
          unidade: 'mcg/kg/min',
          dosePorKgMinima: 0.25/peso,
          dosePorKgMaxima: 0.5/peso,
          peso: peso,
        ),
      ] else ...[
        const Text('Adulto', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.indigo)),
        const SizedBox(height: 6),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Indução e intubação',
          descricaoDose: '10–50 mcg/kg IV lento',
          unidade: 'mg',
          dosePorKgMinima: 10/1000,
          dosePorKgMaxima: 50/1000,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Manutenção anestésica (procedimentos curtos)',
          descricaoDose: '0,5–1 mcg/kg/min IV contínua',
          unidade: 'mcg/kg/min',
          dosePorKgMinima: 0.5/peso,
          dosePorKgMaxima: 1.0/peso,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Sedação em UTI (off-label)',
          descricaoDose: '0,25–0,5 mcg/kg/min IV contínua',
          unidade: 'mcg/kg/min',
          dosePorKgMinima: 0.25/peso,
          dosePorKgMaxima: 0.5/peso,
          peso: peso,
        ),
      ],

      // Outras Indicações (off-label / secundárias)
      const SizedBox(height: 16),
      const Text('Outras Indicações (off-label / secundárias)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Pode ser útil para pré-tratamento em intubação difícil com resposta autonômica exacerbada.'),
      _textoObs('• Usado em neurocirurgias e procedimentos com necessidade de despertar rápido.'),

      // Cálculo da Infusão
      const SizedBox(height: 16),
      const Text('Cálculo da Infusão', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      ConversaoInfusaoSlider(
        peso: peso,
        opcoesConcentracoes: {
          '5mg/50mL (0,1mg/mL)': 100,
          '2mg/20mL (0,1mg/mL)': 100,
        },
        unidade: 'mcg/kg/min',
        doseMin: 0.0,
        doseMax: 0.5,
      ),

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Opioide de ação ultra-rápida e curta.'),
      _textoObs('• Ideal para procedimentos curtos e sedação.'),
      _textoObs('• Potente, porém com início mais rápido que o fentanil.'),
      _textoObs('• Risco de rigidez torácica se bolus rápido.'),
      _textoObs('• Cautela em idosos, hipovolêmicos e hepatopatas.'),
    ],
  );
}
Widget buildCardPentazocina(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito,) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Ampola 30mg/mL | Comprimido 50mg', 'Fortwin®, Talwin®'),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('IV lenta, IM ou VO. Diluir em 5–10mL SF se IV', ''),
      _linhaPreparo('Evitar com opioides agonistas plenos', ''),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Dor aguda moderada/intensa',
        descricaoDose: '30–60mg IM/IV a cada 3–4h (máx 360mg/dia)',
        unidade: 'mg',
        dosePorKgMinima: 30,
        dosePorKgMaxima: 60,
        doseMaxima: 360,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Dor crônica (VO)',
        descricaoDose: '50mg VO a cada 4h (máx 600mg/dia)',
        unidade: '50 mg a cada 4h',
        dosePorKgMinima: 50,
        doseMaxima: 600,
        peso: peso,
      ),

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Agonista κ e antagonista parcial μ.'),
      _textoObs('• Menor depressão respiratória.'),
      _textoObs('• Pode causar delírios, disforia.'),
      _textoObs('• Contraindicado com opioides plenos.'),
      _textoObs('• Cautela em psiquiátricos e insuficiência hepática.'),
    ],
  );
}
Widget buildCardBuprenorfina(
  BuildContext context,
  double peso,
  bool isAdulto,
  bool isFavorito,
  VoidCallback onToggleFavorito,
  {int? idadeDias}
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Comprimidos sublinguais: 0,2mg, 2mg, 8mg', ''),
      _linhaPreparo('Adesivos transdérmicos: 5, 10, 15 ou 20 mcg/h (uso contínuo por 7 dias)', ''),
      _linhaPreparo('Ampolas injetáveis: 0,3mg/mL para uso IV/IM', ''),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Sublingual: manter sob a língua até completa dissolução. Não mastigar ou engolir.', ''),
      _linhaPreparo('Transdérmico: aplicar na pele seca e íntegra. Substituir a cada 7 dias.', ''),
      _linhaPreparo('Injetável: diluir 1:10 em SF 0,9% se necessário para administração IV lenta ou IM.', ''),
      _linhaPreparo('Evitar uso em bolus rápido. Monitorar sinais vitais durante administração parenteral.', ''),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      if (idadeDias != null && idadeDias < 30) ...[
        _linhaIndicacaoDoseCalculada(
          titulo: 'Analgesia neonatal (off-label)',
          descricaoDose: '0,5–1 mcg/kg IV ou IM a cada 6–12h',
          unidade: 'mcg',
          dosePorKgMinima: 0.5,
          dosePorKgMaxima: 1.0,
          peso: peso,
        ),
      ] else ...[
        _linhaIndicacaoDoseCalculada(
          titulo: 'Dor aguda moderada a intensa (hospitalar)',
          descricaoDose: '0,3–0,6mg IV ou IM a cada 6–8h',
          unidade: 'mg',
          dosePorKgMinima: (0.3 / peso).clamp(0.003, 0.03),
          dosePorKgMaxima: (0.6 / peso).clamp(0.003, 0.03),
          doseMaxima: 2.0,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Dor crônica oncológica ou não oncológica',
          descricaoDose: 'Adesivo 5–20mcg/h trocado a cada 7 dias (uso contínuo)',
          unidade: 'mcg/h',
          dosePorKg: 5,
          doseMaxima: 20,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Tratamento da dependência de opioides',
          descricaoDose: '2–4mg SL na indução, manutenção até 24mg/dia',
          unidade: 'mg',
          dosePorKg: 2,
          doseMaxima: 24,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Analgesia pós-operatória (off-label)',
          descricaoDose: '0,3mg IV/IM no intra ou pós-operatório imediato (dose única ou repetida)',
          unidade: 'mg',
          dosePorKgMinima: (0.3 / peso).clamp(0.003, 0.03),
          dosePorKgMaxima: (0.3 / peso).clamp(0.003, 0.03),
          doseMaxima: 0.6,
          peso: peso,
        ),
      ],

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Agonista parcial dos receptores μ e antagonista κ-opioide.'),
      _textoObs('• Efeito teto para analgesia e depressão respiratória — maior segurança em comparação à morfina.'),
      _textoObs('• Não é revertida completamente com naloxona em casos de intoxicação.'),
      _textoObs('• Pode precipitar abstinência em pacientes em uso recente de opioides plenos.'),
      _textoObs('• Sublingual de escolha para descontinuação ou substituição de opioides.'),
      _textoObs('• Formas de liberação prolongada (adesivo) úteis na dor crônica e cuidados paliativos.'),
      _textoObs('• Metabolismo hepático — ajustar dose em insuficiência hepática grave.'),
      _textoObs('• Monitorar sedação, FR e efeitos adversos, especialmente no início do tratamento.'),
    ],
  );
}
Widget buildCardSufentanil(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito,) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Ampola 50mcg/mL (1mL ou 2mL)', 'Sufenta®, Sufentanil Cristália'),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Pode ser usado IV direto em bolus ou infusão contínua', ''),
      _linhaPreparo('Diluir 100mcg em 50mL SF 0,9% = 2mcg/mL', ''),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      _linhaIndicacaoDoseCalculada(
        titulo: 'Indução anestésica',
        descricaoDose: '0,2–0,6 mcg/kg IV lenta',
        unidade: 'mcg',
        dosePorKgMinima: 0.2,
        dosePorKgMaxima: 0.6,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Manutenção anestésica / alta dor',
        descricaoDose: '0,1–0,4 mcg/kg/h em infusão contínua',
        unidade: 'mcg/kg/h',
        dosePorKgMinima: 0.1,
        dosePorKgMaxima: 0.4,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Sedação em UTI (off-label)',
        descricaoDose: '0,05–0,2 mcg/kg/h em bomba contínua',
        unidade: 'mcg/kg/h',
        dosePorKgMinima: 0.05,
        dosePorKgMaxima: 0.2,
        peso: peso,
      ),

      const SizedBox(height: 16),
      const Text('Cálculo da Infusão', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      ConversaoInfusaoSlider(
        peso: peso,
        opcoesConcentracoes: {
          '100mcg/50mL (2mcg/mL)': 2,
          '250mcg/50mL (5mcg/mL)': 5,
        },
        unidade: 'mcg/kg/h',
        doseMin: 0.05,
        doseMax: 0.4,
      ),

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Opioide μ agonista — potência ~10x maior que o fentanil.'),
      _textoObs('• Início rápido (1–3 min) e meia-vida curta (~30 min).'),
      _textoObs('• Controle hemodinâmico excelente em anestesia balanceada.'),
      _textoObs('• Pode causar rigidez torácica — administrar lentamente.'),
      _textoObs('• Monitorar sedação, FR e acúmulo em infusão prolongada.'),
    ],
  );
}
Widget buildCardMorfina(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito,) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Ampola 10mg/mL | Comprimidos VO 10mg, 30mg, 60mg', 'Dimorf®, MST®, Genérico'),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('IV: diluir 1mL em 9mL SF 0,9% para bolus lento (1mg/mL)', ''),
      _linhaPreparo('SC, IM ou VO (liberação imediata ou prolongada)', ''),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      _linhaIndicacaoDoseCalculada(
        titulo: 'Dor aguda grave (uso hospitalar)',
        descricaoDose: '2–5mg IV ou 5–10mg IM/SC a cada 4h conforme resposta',
        unidade: 'mg',
        dosePorKgMinima: 2 / peso,
        dosePorKgMaxima: 10 / peso,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Dor crônica oncológica (via oral)',
        descricaoDose: '10–30mg VO a cada 4h (liberação imediata)',
        unidade: 'mg',
        dosePorKgMinima: 10 / peso,
        dosePorKgMaxima: 30 / peso,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Dispneia refratária / cuidados paliativos',
        descricaoDose: '2,5–5mg SC a cada 4–6h ou bomba contínua (ex: 0,5–1mg/h)',
        unidade: 'mg',
        dosePorKgMinima: 2.5 / peso,
        dosePorKgMaxima: 5 / peso,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Síndrome coronariana aguda (SCA)',
        descricaoDose: '2–4mg IV lenta (repetir conforme dor e resposta)',
        unidade: 'mg',
        dosePorKgMinima: 2 / peso,
        dosePorKgMaxima: 4 / peso,
        peso: peso,
      ),

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Opioide agonista μ puro — padrão ouro para dor intensa.'),
      _textoObs('• Depressão respiratória, constipação e hipotensão são comuns — monitorar.'),
      _textoObs('• Dose deve ser individualizada com titulação cuidadosa.'),
      _textoObs('• Antagonizável com naloxona em caso de intoxicação.'),
      _textoObs('• Cautela em idosos, IR e pneumopatias crônicas.'),
    ],
  );
}
Widget buildCardMeperidina(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito,) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Ampola 50mg/mL ou 100mg/mL', 'Dolantina®, Meperidina Genérico'),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Pode ser administrada IV, IM ou SC', ''),
      _linhaPreparo('Diluir em SF 0,9% para infusão lenta se necessário', ''),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      _linhaIndicacaoDoseCalculada(
        titulo: 'Dor aguda moderada a intensa (hospitalar)',
        descricaoDose: '50–100mg IM ou IV a cada 4–6h conforme necessidade',
        unidade: 'mg',
        dosePorKgMinima: 50 / peso,
        dosePorKgMaxima: 100 / peso,
        doseMaxima: 600,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Analgesia obstétrica (trabalho de parto)',
        descricaoDose: '25–50mg IM a cada 3–4h (fase latente preferida)',
        unidade: 'mg',
        dosePorKgMinima: 25 / peso,
        dosePorKgMaxima: 50 / peso,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Calafrios pós-anestésicos',
        descricaoDose: '12,5–25mg IV lenta, dose única',
        unidade: 'mg',
        dosePorKgMinima: 12.5 / peso,
        dosePorKgMaxima: 25 / peso,
        peso: peso,
      ),

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Opioide sintético com ação analgésica e antiespasmódica.'),
      _textoObs('• Metabolizado em normeperidina → risco de convulsões (acúmulo na insuficiência renal).'),
      _textoObs('• Evitar em idosos, epilepsia e insuficiência renal.'),
      _textoObs('• Alternativa em obstetrícia pela menor depressão respiratória neonatal.'),
      _textoObs('• Monitorar sedação, FR e sinais neurológicos no uso prolongado.'),
    ],
  );
}
Widget buildCardNalbuphina(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito,) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Ampola 10mg/mL (1mL ou 2mL)', 'Nubain®'),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Pode ser administrada IV lenta, IM ou SC', ''),
      _linhaPreparo('Diluir em SF 0,9% para infusão controlada se necessário', ''),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      _linhaIndicacaoDoseCalculada(
        titulo: 'Dor aguda moderada a intensa (hospitalar)',
        descricaoDose: '10–20mg IV ou IM a cada 3–6h conforme necessidade',
        unidade: 'mg',
        dosePorKgMinima: 10 / peso,
        dosePorKgMaxima: 20 / peso,
        doseMaxima: 160,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Dor obstétrica (fase ativa do trabalho de parto)',
        descricaoDose: '10mg IM ou IV a cada 3h (evitar próximo do parto)',
        unidade: 'mg',
        dosePorKgMinima: 10 / peso,
        dosePorKgMaxima: 10 / peso,
        doseMaxima: 10,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Paciente com risco de depressão respiratória',
        descricaoDose: '10mg IV (dose única ou fracionada), com monitoramento',
        unidade: 'mg',
        dosePorKgMinima: 10 / peso,
        dosePorKgMaxima: 10 / peso,
        doseMaxima: 10,
        peso: peso,
      ),

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Agonista κ-opioide e antagonista μ-opioide — efeito teto para depressão respiratória.'),
      _textoObs('• Excelente alternativa à morfina em pacientes com risco de apneia.'),
      _textoObs('• Pode causar sedação, náuseas, sudorese e, raramente, disforia.'),
      _textoObs('• Evitar uso concomitante com opioides μ-puros (antagonismo).'),
      _textoObs('• Menor potencial de abuso e dependência.'),
    ],
  );
}
Widget buildCardRemifentanil(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito,) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Frasco 1mg, 2mg ou 5mg (liofilizado)', 'Ultiva®'),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Diluir 2mg em 40mL SF 0,9% = 50mcg/mL', ''),
      _linhaPreparo('Diluir 5mg em 100mL SF 0,9% = 50mcg/mL', ''),
      _linhaPreparo('Uso exclusivo em infusão contínua — não administrar em bolus', ''),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      _linhaIndicacaoDoseCalculada(
        titulo: 'Indução e manutenção anestésica',
        descricaoDose: '0,05–2 mcg/kg/min IV contínua (titulável)',
        unidade: 'mcg/kg/min',
        dosePorKgMinima: 0.05,
        dosePorKgMaxima: 2.0,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Neurocirurgia / despertar rápido',
        descricaoDose: '0,1–0,3 mcg/kg/min IV contínua',
        unidade: 'mcg/kg/min',
        dosePorKgMinima: 0.1,
        dosePorKgMaxima: 0.3,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Analgesia intraoperatória combinada (com hipnóticos)',
        descricaoDose: '0,05–0,2 mcg/kg/min IV contínua',
        unidade: 'mcg/kg/min',
        dosePorKgMinima: 0.05,
        dosePorKgMaxima: 0.2,
        peso: peso,
      ),

      const SizedBox(height: 16),
      const Text('Cálculo da Infusão', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      ConversaoInfusaoSlider(
        peso: peso,
        opcoesConcentracoes: {
          '2mg/40mL (50mcg/mL)': 50,
          '5mg/100mL (50mcg/mL)': 50,
        },
        unidade: 'mcg/kg/min',
        doseMin: 0.05,
        doseMax: 2.0,
      ),

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Opioide μ agonista ultrapotente e ultracurto.'),
      _textoObs('• Metabolismo por esterases plasmáticas — não depende de fígado ou rim.'),
      _textoObs('• Ideal para procedimentos com necessidade de despertar rápido e controle fino da analgesia.'),
      _textoObs('• Não usar em bolus — risco elevado de rigidez torácica e apneia.'),
      _textoObs('• Suspender infusão 5–10 minutos antes do término da cirurgia.'),
    ],
  );
}
Widget buildCardFentanil(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito,) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Ampola 50mcg/mL (2mL, 5mL, 10mL)', 'Fentanil Cristália®, Dimorfent®'),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Usar IV direta ou em infusão contínua', ''),
      _linhaPreparo('Diluir 500mcg em 50mL = 10mcg/mL ou 250mcg/50mL = 5mcg/mL', ''),
      _linhaPreparo('Evitar bolus rápido — risco de rigidez torácica e apneia', ''),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      _linhaIndicacaoDoseCalculada(
        titulo: 'Indução anestésica (pré-intubação)',
        descricaoDose: '1–5 mcg/kg IV lenta',
        unidade: 'mcg',
        dosePorKgMinima: 1,
        dosePorKgMaxima: 5,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Manutenção anestésica (infusão)',
        descricaoDose: '1–3 mcg/kg/h IV',
        unidade: 'mcg/kg/h',
        dosePorKgMinima: 1,
        dosePorKgMaxima: 3,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Sedação em UTI',
        descricaoDose: '0,5–2 mcg/kg/h IV contínua',
        unidade: 'mcg/kg/h',
        dosePorKgMinima: 0.5,
        dosePorKgMaxima: 2.0,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Analgesia intraoperatória em bolus',
        descricaoDose: '25–100 mcg IV a cada 30–60 min (titulável)',
        unidade: 'mcg',
        dosePorKgMinima: 25 / peso,
        dosePorKgMaxima: 100 / peso,
        peso: peso,
      ),

      const SizedBox(height: 16),
      const Text('Cálculo da Infusão', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      ConversaoInfusaoSlider(
        peso: peso,
        opcoesConcentracoes: {
          '500mcg/50mL (10mcg/mL)': 10,
          '250mcg/50mL (5mcg/mL)': 5,
        },
        unidade: 'mcg/kg/h',
        doseMin: 0.5,
        doseMax: 3.0,
      ),

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Opioide μ agonista potente, início rápido (2–5 min), duração intermediária (30–60 min).'),
      _textoObs('• Usado amplamente em anestesia, sedação e analgesia controlada.'),
      _textoObs('• Pode causar rigidez torácica, bradicardia, depressão respiratória e náuseas.'),
      _textoObs('• Antagonizável com naloxona em casos de intoxicação.'),
      _textoObs('• Monitorização contínua obrigatória de FR, SpO₂ e sedação em infusão.'),
    ],
  );
}
Widget buildCardTramadol(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito,) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Ampola 50mg/mL | Comprimidos VO 50mg, 100mg (imediata ou prolongada)', 'Tramal®, Tramadon®, genéricos'),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Uso IV lento (diluir 1:1 em SF) ou IM / VO direto', ''),
      _linhaPreparo('Duração de ação: 4–6 horas (liberação imediata)', ''),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      _linhaIndicacaoDoseCalculada(
        titulo: 'Dor moderada a intensa (uso parenteral)',
        descricaoDose: '50–100mg IV ou IM a cada 6h (máximo 400mg/dia)',
        unidade: 'mg',
        dosePorKgMinima: 50 / peso,
        dosePorKgMaxima: 100 / peso,
        doseMaxima: 400,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Dor crônica (via oral)',
        descricaoDose: '50–100mg VO a cada 6–8h ou 100–200mg/dia LP',
        unidade: 'mg',
        dosePorKgMinima: 50 / peso,
        dosePorKgMaxima: 100 / peso,
        doseMaxima: 400,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Pediatria (acima de 1 ano)',
        descricaoDose: '1–2 mg/kg IV ou VO a cada 6–8h (máx 400mg/dia)',
        unidade: 'mg',
        dosePorKgMinima: 1.0,
        dosePorKgMaxima: 2.0,
        doseMaxima: 400,
        peso: peso,
      ),

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Opioide atípico: agonista μ fraco + inibidor da recaptação de serotonina e noradrenalina.'),
      _textoObs('• Menor risco de depressão respiratória comparado à morfina.'),
      _textoObs('• Pode causar náusea, tontura, sudorese, confusão e sonolência.'),
      _textoObs('• Contraindicado em epilepsia não controlada e uso de IMAOs ou ISRS (risco de síndrome serotoninérgica).'),
      _textoObs('• Usar com cautela em insuficiência renal ou hepática.'),
    ],
  );
}
Widget buildCardMetadona(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito,) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Comprimido 5mg, 10mg | Solução 10mg/mL | Ampola 10mg/mL', 'Metadon®, Dolophine®, genéricos'),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Uso VO direto ou IV lenta em 5–10 min (ampola 10mg/mL)', ''),
      _linhaPreparo('Ajuste da dose com extremo cuidado — risco de acúmulo', ''),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      _linhaIndicacaoDoseCalculada(
        titulo: 'Dor crônica intensa / refratária',
        descricaoDose: '2,5–10mg VO ou IV a cada 8–12h; ajuste a cada ≥5 dias',
        unidade: 'mg',
        dosePorKgMinima: 2.5 / peso,
        dosePorKgMaxima: 10.0 / peso,
        doseMaxima: 30,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Substituição em dependência de opioides',
        descricaoDose: '20–30mg VO inicial, ajuste gradual até 60–120mg/dia (1–2x/dia)',
        unidade: 'mg',
        dosePorKg: 20,
        doseMaxima: 120,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Síndrome de abstinência em UTI / cuidados paliativos',
        descricaoDose: '2,5–5mg VO ou SC a cada 12h, ajuste lento',
        unidade: 'mg',
        dosePorKgMinima: 2.5 / peso,
        dosePorKgMaxima: 5.0 / peso,
        peso: peso,
      ),

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Agonista μ-opioide com meia-vida longa (até 60h).'),
      _textoObs('• Atua também como inibidor da recaptação de serotonina e noradrenalina e antagonista NMDA.'),
      _textoObs('• Alto risco de acúmulo e toxicidade — ajustes devem ser extremamente cautelosos.'),
      _textoObs('• Risco de prolongamento de QT e arritmias — ECG recomendado em altas doses.'),
      _textoObs('• Conversão de outros opioides para metadona deve ser feita por especialistas.'),
    ],
  );
}

// 🩺 Antibióticos de Profilaxia Cirúrgica

Widget buildCardCeftriaxona(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito,) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Frasco-ampola 1g ou 2g (pó para reconstituição)', 'Rocefin®, Ceftriaxone Genérico'),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('1g diluído em 10mL água estéril para EV lenta (3–5 min)', ''),
      _linhaPreparo('Para infusão: 1–2g em 100mL SG 5% ou SF 0,9% em 30 min', ''),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      _linhaIndicacaoDoseCalculada(
        titulo: 'Infecções respiratórias, urinárias, abdominais e osteoarticulares',
        descricaoDose: '1–2g IV 1x/dia (ou 12/12h em casos graves)',
        unidade: 'g',
        dosePorKgMinima: 1.0 / peso,
        dosePorKgMaxima: 2.0 / peso,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Meningite / neuroinfecção',
        descricaoDose: '2g IV a cada 12h (4g/dia total)',
        unidade: 'g',
        dosePorKgMinima: 2.0 / peso,
        dosePorKgMaxima: 2.0 / peso,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Profilaxia cirúrgica em neurocirurgia / trauma',
        descricaoDose: '2g IV 30 min antes da incisão',
        unidade: 'g',
        dosePorKgMinima: 2.0 / peso,
        dosePorKgMaxima: 2.0 / peso,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Pediatria / neonatologia',
        descricaoDose: '50–100 mg/kg/dia 1x/dia (máx 2g/dose) | meningite: 100 mg/kg/dia 2x',
        unidade: 'mg',
        dosePorKgMinima: 50,
        dosePorKgMaxima: 100,
        doseMaxima: 2000,
        peso: peso,
      ),

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Cefalosporina de 3ª geração com excelente penetração no SNC e amplo espectro.'),
      _textoObs('• Não cobre Pseudomonas aeruginosa.'),
      _textoObs('• Eliminação mista renal e biliar — segura na IRC leve/moderada.'),
      _textoObs('• Pode causar pseudolitíase biliar e colestase transitória.'),
      _textoObs('• Contraindicado reconstituir com soluções que contenham cálcio.'),
    ],
  );
}
Widget buildCardCefuroxima(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito,) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Frasco-ampola 750mg ou 1,5g | Comprimidos 250mg, 500mg (axetil)', 'Zinnat®, Cefurix®, genéricos'),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('IV direta: diluir 750mg em 7–10mL SF 0,9% (3–5 min)', ''),
      _linhaPreparo('Infusão: 1,5g em 100mL SF em 30 min | VO: após alimentação (melhor absorção)', ''),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      _linhaIndicacaoDoseCalculada(
        titulo: 'Infecções respiratórias altas e baixas',
        descricaoDose: '750mg IV a cada 8h ou 500mg VO 2x/dia (7–10 dias)',
        unidade: 'mg',
        dosePorKgMinima: 750 / peso,
        dosePorKgMaxima: 1500 / peso,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Profilaxia cirúrgica (alternativa à cefazolina)',
        descricaoDose: '1,5g IV 30 min antes da incisão | repetir após 4h se necessário',
        unidade: 'g',
        dosePorKgMinima: 1.5 / peso,
        dosePorKgMaxima: 1.5 / peso,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'ITU complicada / pielonefrite leve',
        descricaoDose: '750mg IV 2–3x/dia ou 250–500mg VO 2x/dia',
        unidade: 'mg',
        dosePorKgMinima: 250 / peso,
        dosePorKgMaxima: 1000 / peso,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Pediatria (VO ou IV)',
        descricaoDose: '20–30mg/kg/dia divididos em 2 doses (máx 500mg/dose)',
        unidade: 'mg',
        dosePorKgMinima: 20,
        dosePorKgMaxima: 30,
        doseMaxima: 500,
        peso: peso,
      ),

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Cefalosporina de 2ª geração, maior espectro contra Gram-negativos.'),
      _textoObs('• Eficaz para infecções respiratórias, urinárias e cutâneas.'),
      _textoObs('• VO deve ser tomada após refeições (melhor absorção).'),
      _textoObs('• Ajuste em insuficiência renal.'),
      _textoObs('• Pode causar diarreia, incluindo por Clostridioides difficile.'),
    ],
  );
}
Widget buildCardCefazolina(
  BuildContext context,
  double peso,
  bool isAdulto,
  bool isFavorito,
  VoidCallback onToggleFavorito, {
  int? idadeDias,
}) {
  final String faixa = SharedData.faixaEtaria;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Frasco-ampola 1g ou 2g (pó para reconstituição)', 'Cefazolin®, Kefazol®'),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Diluir 1g em 10mL de água estéril para EV direta lenta (3–5 min)', ''),
      _linhaPreparo('Para infusão: 1g em 100mL SF 0,9% em 20–30 minutos', ''),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      if (faixa == 'Recém-nascido') ...[
        _linhaIndicacaoDoseCalculada(
          titulo: 'Uso neonatal (off-label)',
          descricaoDose: '25–50 mg/kg/dose IV a cada 12h (máx 2g/dia)',
          unidade: 'mg',
          dosePorKgMinima: 25,
          dosePorKgMaxima: 50,
          doseMaxima: 2000,
          peso: peso,
        ),
      ] else if (faixa == 'Lactente' || faixa == 'Criança' || faixa == 'Adolescente') ...[
        _linhaIndicacaoDoseCalculada(
          titulo: 'Uso pediátrico (infecções gerais)',
          descricaoDose: '25–50 mg/kg/dose IV a cada 8h (máx 6g/dia)',
          unidade: 'mg',
          dosePorKgMinima: 25,
          dosePorKgMaxima: 50,
          doseMaxima: 6000,
          peso: peso,
        ),
      ] else if (faixa == 'Adulto' || faixa == 'Idoso') ...[
        _linhaIndicacaoDoseCalculada(
          titulo: 'Profilaxia cirúrgica (adulto)',
          descricaoDose: '1–2g IV 30–60 min antes da incisão. Repetir a cada 4h em cirurgias longas ou com sangramento',
          unidade: 'g',
          dosePorKgMinima: (1.0 / peso).clamp(0.01, 0.05),
          dosePorKgMaxima: (2.0 / peso).clamp(0.01, 0.05),
          doseMaxima: 6,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Infecções de pele, partes moles e osteoarticulares',
          descricaoDose: '1–2g IV a cada 8h, ajuste por função renal (máx 6g/dia)',
          unidade: 'g',
          dosePorKgMinima: (1.0 / peso).clamp(0.01, 0.05),
          dosePorKgMaxima: (2.0 / peso).clamp(0.01, 0.05),
          doseMaxima: 6,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Infecções urinárias e respiratórias leves',
          descricaoDose: '500mg–1g IV a cada 8h, conforme gravidade',
          unidade: 'g',
          dosePorKgMinima: (0.5 / peso).clamp(0.005, 0.03),
          dosePorKgMaxima: (1.0 / peso).clamp(0.005, 0.03),
          doseMaxima: 4,
          peso: peso,
        ),
      ],

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Cefalosporina de 1ª geração com excelente atividade contra Gram-positivos.'),
      _textoObs('• Fármaco de escolha para profilaxia cirúrgica em múltiplos tipos de cirurgia.'),
      _textoObs('• Ineficaz contra anaeróbios e Pseudomonas — associar se necessário.'),
      _textoObs('• Eliminação renal predominante — ajustar dose em insuficiência renal.'),
      _textoObs('• Não atravessa adequadamente a barreira hematoencefálica — não indicada para meningite.'),
      _textoObs('• Baixo risco de reação cruzada com penicilinas (~1–2%).'),
      _textoObs('• Segura em gestantes e crianças.'),
      _textoObs('• Reconstituir apenas com diluentes compatíveis.'),
    ],
  );
}
Widget buildCardMetronidazol(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito,) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Frasco 500mg/100mL (IV) | Comprimidos 250mg, 400mg | Suspensão oral', 'Flagyl®, Metronidazol Genérico'),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Infusão IV em 60 minutos | VO direto após refeições', ''),
      _linhaPreparo('Evitar álcool durante e até 48h após o uso (efeito dissulfiram-like)', ''),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      _linhaIndicacaoDoseCalculada(
        titulo: 'Infecções abdominais e ginecológicas',
        descricaoDose: '500mg IV ou VO a cada 8h (7–14 dias)',
        unidade: 'mg',
        dosePorKgMinima: 500 / peso,
        dosePorKgMaxima: 500 / peso,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Colite por *Clostridioides difficile*',
        descricaoDose: '500mg VO a cada 8h por 10 dias',
        unidade: 'mg',
        dosePorKgMinima: 500 / peso,
        dosePorKgMaxima: 500 / peso,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Amebíase, giardíase e tricomoníase',
        descricaoDose: '250–750mg VO 3x/dia por 5–10 dias',
        unidade: 'mg',
        dosePorKgMinima: 250 / peso,
        dosePorKgMaxima: 750 / peso,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Pediatria (≥1 ano)',
        descricaoDose: '20–30 mg/kg/dia divididos em 2–3 doses (máx 2g/dia)',
        unidade: 'mg',
        dosePorKgMinima: 20,
        dosePorKgMaxima: 30,
        doseMaxima: 2000,
        peso: peso,
      ),

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Ativo contra anaeróbios e protozoários — medicamento essencial da OMS.'),
      _textoObs('• Excelente penetração tecidual (incluindo abscessos cerebrais).'),
      _textoObs('• Pode causar gosto metálico, náuseas, tontura e neuropatia periférica.'),
      _textoObs('• Contraindicado no primeiro trimestre e na amamentação.'),
      _textoObs('• Interage com álcool (efeito dissulfiram) e varfarina.'),
    ],
  );
}
Widget buildCardClindamicina(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito,) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Frasco 600mg/4mL | Cápsulas 300mg | Creme vaginal | Solução tópica 1%', 'Dalacin C®, Clindamin®, genéricos'),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('IV lenta (≥30 min): diluir 600mg em 100mL SF ou SG 5%', ''),
      _linhaPreparo('VO: manter intervalo de 6/6h ou 8/8h', ''),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      _linhaIndicacaoDoseCalculada(
        titulo: 'Infecções de pele, partes moles e odontogênicas',
        descricaoDose: '300–600mg VO ou IV a cada 6–8h',
        unidade: 'mg',
        dosePorKgMinima: 300 / peso,
        dosePorKgMaxima: 600 / peso,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Infecções intra-abdominais e pélvicas',
        descricaoDose: '600–900mg IV a cada 8h',
        unidade: 'mg',
        dosePorKgMinima: 600 / peso,
        dosePorKgMaxima: 900 / peso,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Pediatria (≥1 mês)',
        descricaoDose: '10–13 mg/kg/dose IV ou VO a cada 8h (máx 600mg/dose)',
        unidade: 'mg',
        dosePorKgMinima: 10,
        dosePorKgMaxima: 13,
        doseMaxima: 600,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Toxina estreptocócica (Strep. pyogenes)',
        descricaoDose: '600–900mg IV a cada 8h associada à penicilina',
        unidade: 'mg',
        dosePorKgMinima: 600 / peso,
        dosePorKgMaxima: 900 / peso,
        peso: peso,
      ),

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Excelente cobertura contra cocos Gram-positivos e anaeróbios.'),
      _textoObs('• Opção para alérgicos à penicilina.'),
      _textoObs('• Bloqueia toxinas de Streptococcus pyogenes e Staphylococcus aureus.'),
      _textoObs('• Risco de colite associada ao uso (C. difficile).'),
      _textoObs('• Não requer ajuste para função renal — metabolismo hepático.'),
    ],
  );
}
Widget buildCardVancomicina(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito,) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Frasco 500mg ou 1g (liofilizado)', 'Vancomicina Genérico, Vancocin®'),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Diluir 1g em 20mL água estéril → infundir em 250mL SF ou SG 5% em ≥60 minutos', ''),
      _linhaPreparo('Evitar infusão rápida — risco de síndrome do "pescoço vermelho"', ''),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      _linhaIndicacaoDoseCalculada(
        titulo: 'Infecções graves por Gram-positivos',
        descricaoDose: '15–20mg/kg IV a cada 8–12h (ajustar por função renal e nível sérico)',
        unidade: 'mg',
        dosePorKgMinima: 15,
        dosePorKgMaxima: 20,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Colite pseudomembranosa (VO)',
        descricaoDose: '125–250mg VO 4x/dia por 10–14 dias',
        unidade: 'mg',
        dosePorKg: 125,
        doseMaxima: 250,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Profilaxia neurocirúrgica (off-label)',
        descricaoDose: '1g IV 60 min antes da incisão cirúrgica',
        unidade: 'mg',
        dosePorKgMinima: 1000 / peso,
        dosePorKgMaxima: 1000 / peso,
        peso: peso,
      ),

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Atividade contra Gram-positivos, incluindo MRSA e enterococos.'),
      _textoObs('• Monitorar níveis séricos (alvo: 15–20 mcg/mL).'),
      _textoObs('• Ajustar dose pela função renal.'),
      _textoObs('• Infundir lentamente (≥60 minutos) para evitar reação de liberação de histamina.'),
      _textoObs('• Uso VO restrito a infecções intestinais — não tem absorção sistêmica.'),
    ],
  );
}


// 🩺 Analgésicos Antipiréticos
Widget buildCardParacetamol(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito,) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Comprimidos 500mg, 750mg | Gotas 200mg/mL | Solução oral | Ampola 10mg/mL (100mL)', 'Tylenol®, Genéricos'),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('VO, IV (100mL em 15–30 min), ou uso pediátrico em gotas ou solução oral', ''),
      _linhaPreparo('Respeitar limite máximo diário — risco de hepatotoxicidade', ''),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      _linhaIndicacaoDoseCalculada(
        titulo: 'Dor leve a moderada (adulto)',
        descricaoDose: '500–1000mg VO ou IV a cada 6h (máx 4g/dia)',
        unidade: 'mg',
        dosePorKgMinima: 500 / peso,
        dosePorKgMaxima: 1000 / peso,
        doseMaxima: 4000,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Antipirético (adulto)',
        descricaoDose: '500–1000mg VO ou IV a cada 6h conforme necessidade',
        unidade: 'mg',
        dosePorKgMinima: 500 / peso,
        dosePorKgMaxima: 1000 / peso,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Uso pediátrico (acima de 3 meses)',
        descricaoDose: '10–15 mg/kg/dose VO ou IV a cada 6h (máx 75mg/kg/dia ou 4g/dia)',
        unidade: 'mg',
        dosePorKgMinima: 10,
        dosePorKgMaxima: 15,
        doseMaxima: 4000,
        peso: peso,
      ),

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Analgésico e antipirético sem ação anti-inflamatória.'),
      _textoObs('• Seguro em pediatria, gestantes e alérgicos a AINEs.'),
      _textoObs('• Não ultrapassar 4g/dia (adultos) e 75mg/kg/dia (crianças).'),
      _textoObs('• Intoxicação leva à necrose hepática — antídoto: N-acetilcisteína (NAC).'),
      _textoObs('• Ajustar dose em hepatopatas, etilistas crônicos e idosos frágeis.'),
    ],
  );
}
Widget buildCardDipirona(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito,) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Comprimidos 500mg | Gotas 500mg/mL | Solução oral | Ampola 1g/2mL (500mg/mL)', 'Novalgina®, Anador®, genéricos'),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('VO, IV lenta (2mL em 5 min), IM ou SC (com cautela)', ''),
      _linhaPreparo('Uso pediátrico em gotas ou solução oral: 1 gota = 20mg', ''),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      _linhaIndicacaoDoseCalculada(
        titulo: 'Dor leve a moderada / febre (adulto)',
        descricaoDose: '500–1000mg VO ou IV a cada 6–8h (máx 4g/dia)',
        unidade: 'mg',
        dosePorKgMinima: 500 / peso,
        dosePorKgMaxima: 1000 / peso,
        doseMaxima: 4000,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Cólica / dor espasmódica aguda',
        descricaoDose: '1g IV lenta (2mL) a cada 8h se necessário',
        unidade: 'mg',
        dosePorKgMinima: 1000 / peso,
        dosePorKgMaxima: 1000 / peso,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Uso pediátrico (acima de 3 meses)',
        descricaoDose: '10–20 mg/kg/dose VO ou IV a cada 6–8h (máx 4g/dia)',
        unidade: 'mg',
        dosePorKgMinima: 10,
        dosePorKgMaxima: 20,
        doseMaxima: 4000,
        peso: peso,
      ),

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Potente antipirético e analgésico, sem ação anti-inflamatória relevante.'),
      _textoObs('• Muito usado em PS para dor e febre refratária.'),
      _textoObs('• Raro risco de agranulocitose (monitorar se uso prolongado).'),
      _textoObs('• Contraindicado no 1º trimestre da gestação e próximo ao parto.'),
      _textoObs('• Cautela em pacientes alérgicos a AINEs ou com disfunção hematológica.'),
    ],
  );
}

// 🩺 Anestésicos Inalatórios
Widget buildCardIsoflurano(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito,) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Frasco 250mL para vaporizador padrão', 'Forane®, Isoforine®, genéricos'),

      const SizedBox(height: 16),
      const Text('Administração', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Via inalatória contínua com vaporizador calibrado', ''),
      _linhaPreparo('Indução: 1–3% | Manutenção: 0,5–2%', ''),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      _linhaIndicacaoDoseCalculada(
        titulo: 'Manutenção anestésica',
        descricaoDose: '0,5–2% Isoflurano com O₂/ar ou O₂/N₂O',
        unidade: '%',
        dosePorKgMinima: 0.5,
        dosePorKgMaxima: 2.0,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Neurocirurgia / pacientes instáveis',
        descricaoDose: '0,6–1,2% com analgesia associada',
        unidade: '%',
        dosePorKgMinima: 0.6,
        dosePorKgMaxima: 1.2,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Broncoespasmo intraoperatório',
        descricaoDose: '1–2% Isoflurano',
        unidade: '%',
        dosePorKgMinima: 1.0,
        dosePorKgMaxima: 2.0,
        peso: peso,
      ),

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Estável hemodinamicamente, com efeito broncodilatador.'),
      _textoObs('• Indução mais lenta comparado a sevo e desflurano.'),
      _textoObs('• Contraindicado em hipertermia maligna.'),
      _textoObs('• Pode aumentar PIC — cuidado em TCE.'),
    ],
  );
}
Widget buildCardDesflurano(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito,) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Frasco 240mL para vaporizador específico (Tec 6® ou similar)', 'Suprane®'),

      const SizedBox(height: 16),
      const Text('Administração', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Via inalatória com vaporizador exclusivo para Desflurano', ''),
      _linhaPreparo('Indução: 3–6% | Manutenção: 4–12%', ''),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      _linhaIndicacaoDoseCalculada(
        titulo: 'Manutenção da anestesia',
        descricaoDose: '4–12% Desflurano após indução IV',
        unidade: '%',
        dosePorKgMinima: 4,
        dosePorKgMaxima: 12,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Cirurgias ambulatoriais',
        descricaoDose: '6–10% Desflurano com N₂O/O₂',
        unidade: '%',
        dosePorKgMinima: 6,
        dosePorKgMaxima: 10,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Obesidade / neurocirurgia',
        descricaoDose: '3–6% com opioides e monitorização EEG',
        unidade: '%',
        dosePorKgMinima: 3,
        dosePorKgMaxima: 6,
        peso: peso,
      ),

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Início e recuperação extremamente rápidos.'),
      _textoObs('• Não indicado para indução inalatória isolada — irrita vias aéreas.'),
      _textoObs('• Exige vaporizador específico.'),
      _textoObs('• Contraindicado em hipertermia maligna.'),
    ],
  );
}
Widget buildCardSevoflurano(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito,) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Frasco 250mL líquido volátil para vaporizador específico', 'Sevorane®, Sevoflurano Cristália'),

      const SizedBox(height: 16),
      const Text('Administração', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Via inalatória por circuito fechado com vaporizador calibrado', ''),
      _linhaPreparo('Concentração: indução 5–8% | manutenção 1–3%', ''),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      _linhaIndicacaoDoseCalculada(
        titulo: 'Indução anestésica inalatória',
        descricaoDose: '5–8% Sevoflurano com O₂/N₂O até perda da consciência',
        unidade: '%',
        dosePorKgMinima: 5,
        dosePorKgMaxima: 8,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Manutenção anestésica',
        descricaoDose: '1–3% Sevoflurano com O₂ ou ar medicinal',
        unidade: '%',
        dosePorKgMinima: 1,
        dosePorKgMaxima: 3,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Indução sequencial',
        descricaoDose: 'Sevoflurano 2–4% após opioides IV',
        unidade: '%',
        dosePorKgMinima: 2,
        dosePorKgMaxima: 4,
        peso: peso,
      ),

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Indução e recuperação rápidas.'),
      _textoObs('• Não irrita vias aéreas — ideal para pediatria.'),
      _textoObs('• Contraindicado em hipertermia maligna.'),
      _textoObs('• Monitorização rigorosa durante o uso.'),
      _textoObs('• Evitar exposições prolongadas em crianças (potencial neurotoxicidade).'),
    ],
  );
}
Widget buildCardOxidoNitroso(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito,) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Gás medicinal pressurizado (cilindros 100%, mistura 50% com O₂ disponível)', 'N₂O Medicinal – cilindro azul claro'),

      const SizedBox(height: 16),
      const Text('Administração', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Via inalatória com máscara facial vedada', ''),
      _linhaPreparo('Mistura típica: 50% N₂O + 50% O₂ (pré-misturado ou balanceado manualmente)', ''),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      _linhaIndicacaoDoseCalculada(
        titulo: 'Sedação consciente',
        descricaoDose: 'Início com 30–50% N₂O + O₂ → titulação conforme resposta (máx 70%)',
        unidade: '% N₂O',
        dosePorKgMinima: 30 / peso,
        dosePorKgMaxima: 70 / peso,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Indução anestésica',
        descricaoDose: 'Mistura 50–70% N₂O com oxigênio como coadjuvante à anestesia geral',
        unidade: '% N₂O',
        dosePorKgMinima: 50 / peso,
        dosePorKgMaxima: 70 / peso,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Procedimentos rápidos e dolorosos',
        descricaoDose: 'Mistura 50% N₂O + 50% O₂ por 2–5 min antes e durante o procedimento',
        unidade: '% N₂O',
        dosePorKgMinima: 50 / peso,
        dosePorKgMaxima: 50 / peso,
        peso: peso,
      ),

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Efeito analgésico e ansiolítico em segundos, com recuperação rápida após suspensão.'),
      _textoObs('• Contraindicado em pneumotórax, hipertensão intracraniana, obstrução intestinal e deficiência de B12.'),
      _textoObs('• Requer sistema de exaustão adequado.'),
      _textoObs('• Não utilizar acima de 70% sem suporte avançado de vida.'),
    ],
  );
}

// 🩺 Anestésicos Locais //
Widget buildCardLidocaina(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito,) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Solução 1% ou 2% (10mg/mL ou 20mg/mL)', 'Xylestesin®, Lidocaína Cristália®'),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Usar sem diluição para bloqueios ou infiltração', ''),
      _linhaPreparo('Dose máxima varia com uso de vasoconstritor', ''),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      _linhaIndicacaoDoseCalculada(
        titulo: 'Infiltração ou bloqueio (sem vasoconstritor)',
        descricaoDose: 'Até 4,5 mg/kg (máx 300mg)',
        unidade: 'mg',
        dosePorKgMinima: 4.5,
        dosePorKgMaxima: 4.5,
        doseMaxima: 300,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Infiltração (com vasoconstritor)',
        descricaoDose: 'Até 7 mg/kg (máx 500mg)',
        unidade: 'mg',
        dosePorKgMinima: 7,
        dosePorKgMaxima: 7,
        doseMaxima: 500,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Raquianestesia (hiperbárica)',
        descricaoDose: '50–100mg, duração de 1–1,5h',
        unidade: 'mg',
        dosePorKgMinima: 50 / peso,
        dosePorKgMaxima: 100 / peso,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Antiarrítmico IV',
        descricaoDose: 'Bolus 1–1,5 mg/kg → infusão 1–4 mg/min',
        unidade: 'mg',
        dosePorKgMinima: 1.0,
        dosePorKgMaxima: 1.5,
        peso: peso,
      ),

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Ação rápida e curta (~30–60 min).'),
      _textoObs('• Associar vasoconstritor prolonga o efeito e reduz toxicidade.'),
      _textoObs('• Sinais de toxicidade: parestesias, zumbido, convulsões.'),
      _textoObs('• Tratamento de toxicidade: emulsão lipídica e suporte intensivo.'),
    ],
  );
}
Widget buildCardBupivacaina(
  BuildContext context,
  double peso,
  bool isAdulto,
  bool isFavorito,
  VoidCallback onToggleFavorito, {
  int? idadeDias,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Ampolas de 0,25% (2,5mg/mL), 0,5% (5mg/mL) e 0,75% (7,5mg/mL)', 'Neocaína®, Bupivacaína Cristália®'),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Pode ser usada sem diluição ou diluída em SF 0,9% conforme técnica', ''),
      _linhaPreparo('Para peridural: diluir para 0,25% ou 0,5% se necessário (maior volume)', ''),
      _linhaPreparo('Para raquianestesia: usar solução hiperbárica pronta 0,5%', ''),
      _linhaPreparo('Bloqueios periféricos: usar 0,25%–0,5% conforme profundidade e duração desejada', ''),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      if (idadeDias != null && idadeDias < 30) ...[
        _linhaIndicacaoDoseCalculada(
          titulo: 'Bloqueios regionais em neonatos (off-label)',
          descricaoDose: '0,5–1 mg/kg por dose, preferir concentrações 0,25%',
          unidade: 'mg',
          dosePorKgMinima: 0.5,
          dosePorKgMaxima: 1.0,
          doseMaxima: 2.5 * peso,
          peso: peso,
        ),
      ] else ...[
        _linhaIndicacaoDoseCalculada(
          titulo: 'Anestesia peridural para cirurgias ou parto',
          descricaoDose: '1,5–2,5 mg/kg por dose fracionada (máx 175mg/dose ou 400mg/dia)',
          unidade: 'mg',
          dosePorKgMinima: (1.5 / peso).clamp(0.01, 3.0),
          dosePorKgMaxima: (2.5 / peso).clamp(0.01, 3.0),
          doseMaxima: 400,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Raquianestesia (anestesia subaracnoidea)',
          descricaoDose: '7,5–15mg em solução hiperbárica a 0,5%',
          unidade: 'mg',
          dosePorKgMinima: 7.5 / peso,
          dosePorKgMaxima: 15 / peso,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Bloqueios de nervos periféricos (plexo braquial, femoral, ciático)',
          descricaoDose: '1–2 mg/kg com máximo de 175mg por dose',
          unidade: 'mg',
          dosePorKgMinima: (1 / peso).clamp(0.01, 3.0),
          dosePorKgMaxima: (2 / peso).clamp(0.01, 3.0),
          doseMaxima: 175,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Infiltração cirúrgica contínua (cateter)',
          descricaoDose: 'Infusão contínua de 5–8 mL/h com solução a 0,25–0,5%',
          unidade: 'mg/h',
          dosePorKg: 12.5 / peso,
          doseMaxima: 40,
          peso: peso,
        ),
      ],

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Anestésico local do tipo amida com início de ação em 15–30 min e duração prolongada (~4–12h).'),
      _textoObs('• Alta lipossolubilidade e ligação a proteínas → maior risco de cardiotoxicidade em comparação à lidocaína.'),
      _textoObs('• Contraindicado em bloqueios intravenosos regionais (Bier) devido ao risco de arritmias fatais.'),
      _textoObs('• Evitar uso em grandes volumes sem monitorização adequada.'),
      _textoObs('• A dose máxima diária geralmente recomendada é de 2–3 mg/kg (máx 400mg/dia).'),
      _textoObs('• Toxicidade sistêmica manifesta-se por zumbido, parestesias, convulsões e colapso cardiovascular.'),
      _textoObs('• Tratamento da toxicidade: infusão de emulsão lipídica 20% (Intralipid®).'),

      // NOVA SEÇÃO: Condutas Off-label
      const SizedBox(height: 16),
      const Text('Condutas Off-label', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      const SizedBox(height: 4),
      const Padding(
        padding: EdgeInsets.only(left: 12, bottom: 4),
        child: Text('• Uso em bloqueios do plano fascial (ex: TAP, ESP, QL) com solução diluída.', style: TextStyle(fontSize: 13)),
      ),
      const Padding(
        padding: EdgeInsets.only(left: 12, bottom: 4),
        child: Text('• Infiltração cirúrgica em analgesia multimodal (cirurgias ortopédicas, obstétricas).', style: TextStyle(fontSize: 13)),
      ),
      const Padding(
        padding: EdgeInsets.only(left: 12, bottom: 4),
        child: Text('• Cateteres de analgesia contínua em cirurgias de grande porte.', style: TextStyle(fontSize: 13)),
      ),
    ],
  );
}
Widget buildCardRopivacainaInfiltracao(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito,) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Ampolas 0,2%, 0,5% e 0,75% (2–20mL)', 'Naropin®, Ropi®, genéricos'),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Usar sem diluir para bloqueios superficiais/localizados', ''),
      _linhaPreparo('Pode ser diluída em SF 0,9% para maior volume (final: 0,2–0,5%)', ''),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      _linhaIndicacaoDoseCalculada(
        titulo: 'Infiltração local para analgesia',
        descricaoDose: '1–3 mg/kg (máx 200mg) com 0,2% a 0,5%',
        unidade: 'mg',
        dosePorKgMinima: 1,
        dosePorKgMaxima: 3,
        doseMaxima: 200,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Bloqueio de campo/nervo periférico/plano fascial',
        descricaoDose: '2–3 mg/kg (ajustar volume pela técnica)',
        unidade: 'mg',
        dosePorKgMinima: 2,
        dosePorKgMaxima: 3,
        doseMaxima: 200,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Infiltração contínua por cateter',
        descricaoDose: '0,2–0,3% em infusão (5–10mL/h) por até 72h',
        unidade: 'mg/h',
        dosePorKg: 10 / peso,
        doseMaxima: 30,
        peso: peso,
      ),

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Anestésico local tipo amida, menos cardiotóxico que bupivacaína.'),
      _textoObs('• Início em 10–20 min, duração de 2–6h.'),
      _textoObs('• Contraindicado em alergia a anestésicos tipo amida.'),
      _textoObs('• Monitorar toxicidade sistêmica: zumbido, parestesias, convulsões, arritmias.'),
      _textoObs('• Não usar com vasoconstritor em áreas terminais.'),
    ],
  );
}

// 🩺 Soluções de Expansão
Widget buildCardEmulsaoLipidica(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito,) {return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Frascos 100mL, 250mL, 500mL a 20%', 'Intralipid®, Lipoven®, genéricos'),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      _linhaIndicacaoDoseCalculada(
        titulo: 'Toxicidade sistêmica por anestésico local (LAST)',
        descricaoDose: 'Bolus 1,5 mL/kg em 1 min → infusão 0,25–0,5 mL/kg/min por 30–60 min',
        unidade: 'mL',
        dosePorKgMinima: 1.5,
        dosePorKgMaxima: 1.5,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Nutrição parenteral (adulto)',
        descricaoDose: '0,5–1 g/kg/dia → iniciar com 10–20 mL/h e titular',
        unidade: 'g',
        dosePorKgMinima: 0.5,
        dosePorKgMaxima: 1.0,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Nutrição parenteral (neonatal e pediátrica)',
        descricaoDose: '1–3 g/kg/dia',
        unidade: 'g',
        dosePorKgMinima: 1.0,
        dosePorKgMaxima: 3.0,
        peso: peso,
      ),

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Antídoto eficaz para intoxicação por anestésicos locais lipofílicos (ex: bupivacaína).'),
      _textoObs('• Atua sequestrando o anestésico na corrente sanguínea (“lipid sink”).'),
      _textoObs('• Uso hospitalar, preferencialmente em UTI ou centro cirúrgico.'),
      _textoObs('• Na nutrição parenteral, fornece ácidos graxos essenciais e calorias.'),
      _textoObs('• Monitorar triglicérides, função hepática e sinais de sobrecarga lipídica.'),
    ],
  );}
Widget buildCardAguaDestilada(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito,) {
  final double volumeTotal = peso <= 10
      ? 100 * peso
      : peso <= 20
      ? 1000 + (peso - 10) * 50
      : 1500 + (peso - 20) * 20;

  final double sodio = peso * 3;
  final double potassio = peso * 2;
  final double glicose = peso * 5 * 1440 / 1000;

  final double nacl20_ml = sodio / 3.4;
  final double kcl19_ml = potassio / 2.5;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Ampolas 10, 20, 50mL e Frascos de 100 a 1000mL \nÁgua Destilada Estéril para Diluição', ''),

      const SizedBox(height: 16),
      const Text('Usos e Orientações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Uso exclusivo para reconstituição de medicamentos IV ou preparo de soluções.', ''),
      _linhaPreparo('NUNCA administrar isoladamente (risco de hemólise grave).', ''),
      _linhaPreparo('Proibido como veículo de infusão contínua ou expansor de volume.', ''),

      if (!isAdulto) ...[
        const SizedBox(height: 16),
        const Text('Cálculo – Solução Pediátrica de Manutenção', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _linhaPreparo('Volume total (24h): ${volumeTotal.toStringAsFixed(0)} mL', ''),
        _linhaPreparo('Sódio (Na⁺): ${sodio.toStringAsFixed(0)} mEq/dia', ''),
        _linhaPreparo('Potássio (K⁺): ${potassio.toStringAsFixed(0)} mEq/dia', ''),
        _linhaPreparo('Glicose: ${glicose.toStringAsFixed(0)} g/dia', ''),
        _linhaPreparo(
          '💉 Adição necessária:',
          '${nacl20_ml.toStringAsFixed(1)} mL de NaCl 20% + ${kcl19_ml.toStringAsFixed(1)} mL de KCl 19,1%',
        ),
      ],

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Água estéril isenta de eletrólitos — não indicada como fluido intravenoso direto.'),
      _textoObs('• Deve ser usada apenas em diluições e reconstituições de fármacos compatíveis.'),
      _textoObs('• A infusão isolada pode causar hemólise osmótica e colapso circulatório.'),
      _textoObs('• Off-label: utilizada como veículo em soluções oftálmicas, inalatórias e tópicas.'),
      _textoObs('• Manusear com técnica asséptica rigorosa.'),
    ],
  );
}
Widget buildCardSoroFisiologico09(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito,) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Bolsas 100mL, 250mL, 500mL, 1000mL | Ampolas 10mL, 20mL, 50mL', 'Cloreto de Sódio 0,9% – Genérico'),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      _linhaIndicacaoDoseCalculada(
        titulo: 'Manutenção ou hidratação venosa',
        descricaoDose: '20–40mL/kg/dia (ajustar conforme perdas)',
        unidade: 'mL',
        dosePorKgMinima: 20,
        dosePorKgMaxima: 40,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Expansão volêmica inicial',
        descricaoDose: '20–30mL/kg em bolus rápido',
        unidade: 'mL',
        dosePorKgMinima: 20,
        dosePorKgMaxima: 30,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Lavagem de feridas, sondas, vias respiratórias',
        descricaoDose: '10–100mL conforme finalidade',
        unidade: 'mL',
        dosePorKgMinima: 10 / peso,
        dosePorKgMaxima: 100 / peso,
        peso: peso,
      ),

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Solução isotônica (308 mOsm/L) — compatível com sangue e tecidos.'),
      _textoObs('• Pode causar hipercloremia e acidose metabólica em grandes volumes.'),
      _textoObs('• Não contém calorias ou outros eletrólitos além de Na⁺ e Cl⁻.'),
      _textoObs('• Ideal como diluente de medicamentos ou veículo de infusão.'),
      _textoObs('• Monitorar balanço hídrico, eletrólitos e sinais de sobrecarga.'),
    ],
  );
}
Widget buildCardPlasmaLygth(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito,) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Frascos 1000mL, 500mL | pH ~7,4 | Osmolaridade: 294 mOsm/L', 'Plasma-Lyte 148®, Plasma-Lyte M®'),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      _linhaIndicacaoDoseCalculada(
        titulo: 'Reposição volêmica em desidratação moderada a grave',
        descricaoDose: '20–30 mL/kg em bolus rápido (500–1000mL em adultos)',
        unidade: 'mL',
        dosePorKgMinima: 20,
        dosePorKgMaxima: 30,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Manutenção venosa em pacientes críticos ou cirúrgicos',
        descricaoDose: '1–2 mL/kg/h em infusão contínua (ajustar conforme balanço)',
        unidade: 'mL/kg/h',
        dosePorKgMinima: 1,
        dosePorKgMaxima: 2,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Hidratação geral e reposição eletrolítica leve',
        descricaoDose: '20–40 mL/kg/dia (uso semelhante ao SF ou RL)',
        unidade: 'mL',
        dosePorKgMinima: 20,
        dosePorKgMaxima: 40,
        peso: peso,
      ),

      const SizedBox(height: 16),
      const Text('Composição por litro', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Na⁺: 140 mEq | K⁺: 5 mEq | Mg²⁺: 1,5 mEq | Cl⁻: 98 mEq', ''),
      _linhaPreparo('Acetato: 27 mEq | Gluconato: 23 mEq | Osmolaridade: 294 mOsm/L', ''),

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Solução isotônica balanceada — composição próxima ao plasma.'),
      _textoObs('• Menor risco de acidose hiperclorêmica comparado ao SF 0,9%.'),
      _textoObs('• Ideal para pacientes com distúrbios ácido-base ou necessidade de grande volume.'),
      _textoObs('• Pode ser utilizada em pediatria, cirurgia e UTI.'),
      _textoObs('• Contraindicado em hiperpotassemia ou hipermagnesemia graves.'),
    ],
  );
}
Widget buildCardColoides(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito,) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Albumina 20%, 5% | Gelatinas | Hidroxietilamido (HES) 6%', 'Albumina®, Voluven®, Gelafundin®'),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      _linhaIndicacaoDoseCalculada(
        titulo: 'Expansão volêmica em choque ou grandes perdas',
        descricaoDose: '10–20 mL/kg IV conforme resposta hemodinâmica',
        unidade: 'mL',
        dosePorKgMinima: 10,
        dosePorKgMaxima: 20,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Hipoalbuminemia grave (<2 g/dL)',
        descricaoDose: '1g/kg de albumina 20% por dia (equivale a 5mL/kg)',
        unidade: 'mL',
        dosePorKgMinima: 5,
        dosePorKgMaxima: 5,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Paracentese maciça (ascite em cirrose)',
        descricaoDose: '6–8g de albumina 20% por litro de ascite retirado',
        unidade: 'g',
        dosePorKg: 6 / peso,
        doseMaxima: 8,
        peso: peso,
      ),

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Coloides permanecem mais tempo no intravascular que cristaloides.'),
      _textoObs('• Albumina é o coloide natural mais seguro — preferida em cirrose, sepse e hipoalbuminemia.'),
      _textoObs('• HES e gelatinas → risco de sangramento, nefrotoxicidade e anafilaxia.'),
      _textoObs('• Uso deve ser criterioso — avaliar benefício x risco x custo.'),
      _textoObs('• Monitorar PA, diurese e sinais de sobrecarga.'),
    ],
  );
}
Widget buildCardSolucaoSalina20(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito,) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Ampolas 10mL, 20mL, 50mL (200mg/mL = 3,4 mEq/mL de Na⁺)', 'NaCl 20% – Hipertônico concentrado estéril'),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      _linhaIndicacaoDoseCalculada(
        titulo: 'Reposição de sódio em hiponatremia sintomática',
        descricaoDose: '0,5–1 mEq/kg por bolus → 1 mL = 3,4 mEq Na⁺',
        unidade: 'mL',
        dosePorKgMinima: 0.15,
        dosePorKgMaxima: 0.3,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Adição em soluções de manutenção pediátrica',
        descricaoDose: 'Para ${peso.toStringAsFixed(1)} kg: ~${(peso * 3).toStringAsFixed(0)} mEq Na⁺ → ${((peso * 3) / 3.4).toStringAsFixed(1)} mL de NaCl 20%',
        unidade: 'mL',
        dosePorKg: ((peso * 3) / 3.4),
        doseMaxima: ((peso * 3) / 3.4),
        peso: peso,
      ),

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Cada 1 mL contém 200mg de NaCl → 3,4 mEq de Na⁺.'),
      _textoObs('• Usada para manipular soluções — não utilizar em infusão direta isolada.'),
      _textoObs('• Monitorar sódio rigorosamente para evitar mielinólise pontina.'),
      _textoObs('• Usar bomba de seringa com extrema cautela se administração direta.'),
      _textoObs('• Conservar refrigerada após aberto.'),
    ],
  );
}
Widget buildCardSolucaoSalinaHipertonica3(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito,) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Frascos 100mL, 250mL, 500mL e 1000mL (30g NaCl/L = 513 mEq/L)', 'NaCl 3% – Solução hipertônica estéril'),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      _linhaIndicacaoDoseCalculada(
        titulo: 'Hiponatremia sintomática grave',
        descricaoDose: '2–4 mL/kg IV em bolus (até 100mL), repetir até melhora neurológica',
        unidade: 'mL',
        dosePorKgMinima: 2,
        dosePorKgMaxima: 4,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Hiponatremia crônica',
        descricaoDose: '0,5–1 mL/kg/h IV contínuo (monitorar Na⁺ sérico a cada 4h)',
        unidade: 'mL/kg/h',
        dosePorKgMinima: 0.5,
        dosePorKgMaxima: 1.0,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Hipertensão intracraniana (TCE, HIC)',
        descricaoDose: '2–5 mL/kg IV em bolus a cada 4–6h ou infusão contínua',
        unidade: 'mL',
        dosePorKgMinima: 2,
        dosePorKgMaxima: 5,
        peso: peso,
      ),

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Cada 1 mL de NaCl 3% contém 0,513 mEq de Na⁺.'),
      _textoObs('• Corrigir sódio máximo de 8–10 mEq/L em 24h (risco de mielinólise).'),
      _textoObs('• Idealmente acesso central, mas pode ser periférico com cautela.'),
      _textoObs('• Monitorar eletrólitos, osmolaridade e diurese frequentemente.'),
      _textoObs('• Contraindicado em hipernatremia, ICC descompensada e edema agudo de pulmão.'),
    ],
  );
}




// 🩺 Uterotônicos
Widget buildCardErgometrina(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito,) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Ampola 0,2mg/mL (1mL)', 'Ergotrate®, Methergin®'),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Usar IM direta ou IV lenta (≥1 min)', ''),
      _linhaPreparo('Repetir dose a cada 2–4h se necessário', ''),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      _linhaIndicacaoDoseCalculada(
        titulo: 'Hemorragia pós-parto (HPP)',
        descricaoDose: '0,2mg IM ou IV lenta, repetir a cada 2–4h (máx 1mg/24h)',
        unidade: 'mg',
        doseMaxima: 1,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Atonia uterina refratária',
        descricaoDose: '0,2mg IM ou IV lenta após falha da ocitocina',
        unidade: 'mg',
        doseMaxima: 0.2,
        peso: peso,
      ),

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Agonista direto de receptores musculares lisos uterinos.'),
      _textoObs('• Contraindicado em hipertensão, pré-eclâmpsia e cardiopatia isquêmica.'),
      _textoObs('• Pode causar náuseas, vômitos, vasoconstrição e elevação da pressão arterial.'),
      _textoObs('• Uso preferencial após a saída da placenta.'),
      _textoObs('• Manter sob refrigeração (entre 2–8 °C).'),
    ],
  );
}
Widget buildCardOcitocina(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito,) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Ampola 5 UI/mL ou 10 UI/mL', 'Syntocinon®, Ocytocin®'),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Diluir 10 UI em 500mL SF 0,9% → 20 mUI/mL', ''),
      _linhaPreparo('Iniciar com 10–20 mUI/min, aumentar conforme resposta uterina', ''),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      _linhaIndicacaoDoseCalculada(
        titulo: 'Indução/condução do trabalho de parto',
        descricaoDose: 'Iniciar com 2–4 mUI/min EV, aumentar até máx 20–40 mUI/min',
        unidade: 'mUI/min',
        dosePorKgMinima: 2,
        dosePorKgMaxima: 40,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Prevenção de hemorragia pós-parto (profilaxia)',
        descricaoDose: '5–10 UI IM ou IV lenta após saída da placenta',
        unidade: 'UI',
        doseMaxima: 10,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Tratamento de atonia uterina / HPP',
        descricaoDose: '10–40 UI em 500–1000mL SF em bomba contínua (máx 40 UI/1000mL)',
        unidade: 'UI',
        doseMaxima: 40,
        peso: peso,
      ),

      const SizedBox(height: 16),
      const Text('Cálculo da Infusão', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      ConversaoInfusaoSlider(
        peso: peso,
        opcoesConcentracoes: {
          '10 UI/500mL (20 mUI/mL)': 20,
          '20 UI/1000mL (20 mUI/mL)': 20,
        },
        unidade: 'mUI/min',
        doseMin: 2,
        doseMax: 40,
      ),

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Hormônio natural com potente ação uterotônica.'),
      _textoObs('• Primeira escolha na profilaxia e tratamento da hemorragia pós-parto.'),
      _textoObs('• Pode causar hipotensão, náuseas, vômitos e taquicardia.'),
      _textoObs('• Requer monitoramento uterino e fetal contínuo durante infusão.'),
      _textoObs('• Risco de intoxicação hídrica em infusões prolongadas ou altas doses.'),
    ],
  );
}


// 🩺 Corticosteroides
Widget buildCardHidrocortisona(BuildContext context, double peso, bool isAdulto) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Frasco-ampola 100mg (pó liofilizado) + diluente 2mL', 'Solu-Cortef®'),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Reconstituir 100mg em 2–10mL SF 0,9% para bolus', ''),
      _linhaPreparo('Para infusão: 100mg em 100mL SF 0,9% (1mg/mL)', ''),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      _linhaIndicacaoDoseCalculada(
        titulo: 'Insuficiência adrenal aguda / crise suprarrenal',
        descricaoDose: '100mg IV bolus → 200mg/dia (50mg a cada 6h)',
        unidade: 'mg',
        doseMaxima: 200,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Choque séptico (adjuvante)',
        descricaoDose: '200mg/dia contínuos ou 50mg IV a cada 6h',
        unidade: 'mg',
        doseMaxima: 200,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Anafilaxia grave (pós-adrenalina)',
        descricaoDose: '100–200mg IV em bolus único',
        unidade: 'mg',
        doseMaxima: 200,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Crise asmática / DPOC grave',
        descricaoDose: '100–200mg IV única ou dividida em 2x/dia',
        unidade: 'mg',
        doseMaxima: 200,
        peso: peso,
      ),

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Glicocorticoide com atividade mineralocorticoide relevante.'),
      _textoObs('• Primeira escolha na insuficiência adrenal e choque refratário.'),
      _textoObs('• Monitorar glicemia, infecções e retenção hídrica.'),
      _textoObs('• Necessário desmame após uso prolongado.'),
    ],
  );
}
Widget buildCardDexametasona(BuildContext context, double peso, bool isAdulto) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Ampola 4mg/mL (2mL = 8mg)', 'Decadron®, Dexason®, Maxidex®'),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Pode ser administrada IV, IM ou VO (em solução)', ''),
      _linhaPreparo('Diluir se necessário em SG 5% para infusão lenta', ''),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      if (isAdulto) ...[
        _linhaIndicacaoDoseCalculada(
          titulo: 'Crise asmática grave / DPOC',
          descricaoDose: '4–10 mg IV ou IM, dose única ou 1x/dia por 3–5 dias',
          unidade: 'mg',
          doseMaxima: 10,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Edema cerebral',
          descricaoDose: '10 mg IV bolus, seguido de 4 mg IV a cada 6h',
          unidade: 'mg',
          doseMaxima: 10,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Náuseas/vômitos induzidos por quimioterapia',
          descricaoDose: '8–16 mg IV 30 min antes da quimioterapia',
          unidade: 'mg',
          doseMaxima: 16,
          peso: peso,
        ),
      ] else ...[
        _linhaIndicacaoDoseCalculada(
          titulo: 'Laringite viral / estridor infantil',
          descricaoDose: '0,15–0,6 mg/kg IM ou VO, dose única (máx 10mg)',
          unidade: 'mg',
          dosePorKgMinima: 0.15,
          dosePorKgMaxima: 0.6,
          doseMaxima: 10,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Crise asmática ou alérgica pediátrica',
          descricaoDose: '0,15–0,3 mg/kg IM ou IV, 1x/dia por 2–3 dias',
          unidade: 'mg',
          doseMaxima: 10,
          peso: peso,
        ),
      ],

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Glicocorticoide de alta potência e longa duração (>36h).'),
      _textoObs('• Excelente penetração no SNC.'),
      _textoObs('• Ideal para edema cerebral e crises respiratórias.'),
      _textoObs('• Risco de hiperglicemia e imunossupressão em uso prolongado.'),
    ],
  );
}
Widget buildCardMetilprednisolona(BuildContext context, double peso, bool isAdulto) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Frasco-ampola 500mg ou 1g (pó liofilizado)', 'Solu-Medrol®'),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Diluir com 8–16mL SF 0,9% para bolus', ''),
      _linhaPreparo('Para infusão: diluir em 100–250mL SG 5% ou SF 0,9%', ''),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      if (isAdulto) ...[
        _linhaIndicacaoDoseCalculada(
          titulo: 'Crise asmática / DPOC',
          descricaoDose: '125–250mg IV em bolus ou 2x/dia por 3–5 dias',
          unidade: 'mg',
          doseMaxima: 250,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Anafilaxia (pós-adrenalina)',
          descricaoDose: '125–250mg IV lenta',
          unidade: 'mg',
          doseMaxima: 250,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Pulsoterapia imunossupressora',
          descricaoDose: '1g/dia IV por 3–5 dias',
          unidade: 'mg',
          doseMaxima: 1000,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Trauma medular agudo (esquema antigo)',
          descricaoDose: '30mg/kg IV bolus, seguido de 5,4mg/kg/h por 23h',
          unidade: 'mg',
          dosePorKg: 30,
          peso: peso,
        ),
      ] else ...[
        _linhaIndicacaoDoseCalculada(
          titulo: 'Crise asmática ou alérgica pediátrica',
          descricaoDose: '1–2 mg/kg/dose IV ou IM a cada 12–24h (máx 60mg)',
          unidade: 'mg',
          dosePorKgMinima: 1,
          dosePorKgMaxima: 2,
          doseMaxima: 60,
          peso: peso,
        ),
      ],

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Corticoide potente, boa penetração no SNC.'),
      _textoObs('• Usado em bolus ou infusão.'),
      _textoObs('• Pulsoterapia exige monitorização rigorosa.'),
      _textoObs('• Desmame gradual em uso prolongado.'),
    ],
  );
}
Widget buildCardBetametasona(BuildContext context, double peso, bool isAdulto) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Ampolas 6mg/2mL (3mg/mL) ', ''),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Administração IM profunda ou IV lenta (≥2 min)', ''),
      _linhaPreparo('Para infusão: diluir 4–8 mg em 50–100 mL de SF ou SG5%', ''),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      if (isAdulto) ...[
        _linhaIndicacaoDoseCalculada(
          titulo: 'Crises inflamatórias e alérgicas agudas',
          descricaoDose: '4–8 mg IM ou IV a cada 6–12h, por 2–5 dias',
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Doenças autoimunes / dermatológicas / reumatológicas',
          descricaoDose: '0,05–0,1 mg/kg/dia IM ou VO (máx 8 mg/dia)',
          unidade: 'mg',
          dosePorKgMinima: 0.05,
          dosePorKgMaxima: 0.1,
          doseMaxima: 8,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Maduração pulmonar fetal (obstetrícia)',
          descricaoDose: '12 mg IM a cada 24h por 2 doses (total 24 mg)',
          peso: peso,
        ),
      ] else ...[
        _linhaIndicacaoDoseCalculada(
          titulo: 'Laringotraqueíte / estridor / crupe',
          descricaoDose: '0,1–0,2 mg/kg IM ou VO, dose única (máx 6 mg)',
          unidade: 'mg',
          dosePorKgMinima: 0.1,
          dosePorKgMaxima: 0.2,
          doseMaxima: 6,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Crises inflamatórias ou alérgicas graves',
          descricaoDose: '0,1–0,2 mg/kg/dose IM ou IV a cada 6–24h (máx 8 mg)',
          unidade: 'mg',
          dosePorKgMinima: 0.1,
          dosePorKgMaxima: 0.2,
          doseMaxima: 8,
          peso: peso,
        ),
      ],

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Glicocorticoide potente, de longa duração (biológica: 36–54h).'),
      _textoObs('• Sem atividade mineralocorticoide significativa.'),
      _textoObs('• Ideal em edemas cerebrais, crises asmáticas, imunossupressão, prematuridade.'),
      _textoObs('• Avaliar glicemia, pressão arterial e risco infeccioso em tratamentos prolongados.'),
      _textoObs('• Pode ser usado como alternativa à dexametasona em diversas indicações.'),
      _textoObs('• Off-label: injeções intra-articulares, intralesionais e locais em dermatologia.'),
    ],
  );
}


// 🩺 Sedativos Alfa-2 Agonistas
Widget buildCardClonidina(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito,) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Ampola 150mcg/mL (1mL)', 'Diluição recomendada antes do uso'),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('150mcg em 15mL SF 0,9%', '10 mcg/mL'),
      _linhaPreparo('150mcg em 50mL SF 0,9%', '3 mcg/mL (infusão pediátrica)'),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      if (isAdulto) ...[
        _linhaIndicacaoDoseCalculada(
          titulo: 'Hipertensão arterial grave',
          descricaoDose: '50–150 mcg VO ou 1–2 mcg/kg IV lento',
          unidade: 'mcg',
          dosePorKgMinima: 1,
          dosePorKgMaxima: 2,
          doseMaxima: 150,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Sedação leve em UTI',
          descricaoDose: '0,2–1 mcg/kg/h IV contínua',
          peso: peso,
        ),
      ] else ...[
        _linhaIndicacaoDoseCalculada(
          titulo: 'Sedação pediátrica (off-label)',
          descricaoDose: '0,25–1 mcg/kg/h IV contínua',
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Controle da pressão arterial em TCE',
          descricaoDose: '0,5–1 mcg/kg IV lento ou infusão',
          unidade: 'mcg',
          dosePorKgMinima: 0.5,
          dosePorKgMaxima: 1,
          peso: peso,
        ),
      ],

      const SizedBox(height: 16),
      const Text('Cálculo da Infusão', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      ConversaoInfusaoSlider(
        peso: peso,
        opcoesConcentracoes: {
          '150mcg/15mL (10 mcg/mL)': 10,
          '150mcg/50mL (3 mcg/mL)': 3,
        },
        unidade: 'mcg/kg/h',
        doseMin: 0.2,
        doseMax: 1.0,
      ),

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Agonista seletivo de receptores alfa-2 adrenérgicos com efeito hipotensor e sedativo.'),
      _textoObs('• Efeito semelhante à dexmedetomidina, porém com menor custo.'),
      _textoObs('• Pode causar bradicardia e hipotensão.'),
      _textoObs('• Útil como coadjuvante na anestesia e em síndromes de abstinência.'),
      _textoObs('• Evitar suspensão abrupta após uso prolongado → risco de efeito rebote.'),
    ],
  );
}
Widget buildCardDexmedetomidina(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito,) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Frasco 200mcg/2mL (100mcg/mL)', 'Precedex®'),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('200mcg em 50mL SF 0,9%', '4 mcg/mL'),
      _linhaPreparo('200mcg em 100mL SF 0,9%', '2 mcg/mL'),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      if (isAdulto) ...[
        _linhaIndicacaoDoseCalculada(
          titulo: 'Sedação em UTI',
          descricaoDose: '0,2–1 mcg/kg/h IV contínua (sem bolus)',
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Sedação em procedimento',
          descricaoDose: 'Bolus de 1 mcg/kg em 10 min, seguido de 0,2–0,7 mcg/kg/h',
          peso: peso,
        ),
      ] else ...[
        _linhaIndicacaoDoseCalculada(
          titulo: 'Sedação pediátrica (off-label)',
          descricaoDose: '0,2–1 mcg/kg/h IV contínua',
          peso: peso,
        ),
      ],

      const SizedBox(height: 16),
      const Text('Cálculo da Infusão', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      ConversaoInfusaoSlider(
        peso: peso,
        opcoesConcentracoes: {
          '200mcg/50mL (4 mcg/mL)': 4,
          '200mcg/100mL (2 mcg/mL)': 2,
        },
        unidade: 'mcg/kg/h',
        doseMin: 0.2,
        doseMax: 1.0,
      ),

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Agonista seletivo de receptores alfa-2 adrenérgicos.'),
      _textoObs('• Sedação consciente: paciente facilmente despertável.'),
      _textoObs('• Não deprime a respiração — ideal em pacientes ventilando espontaneamente.'),
      _textoObs('• Pode causar bradicardia e hipotensão, especialmente em bolus.'),
      _textoObs('• Uso exclusivo por bomba de infusão contínua.'),
    ],
  );
}


// 🩺 Eletrolíticos Críticos
Widget buildCardSulfatoMagnesio(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito,) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Ampola 10% (1g/10mL = 8 mEq/10mL)', 'Sulfato de Magnésio 10% ou 20%'),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('EV direta (10–20 min) ou diluído em SG5%/SF0,9%', ''),
      _linhaPreparo('Infusão contínua: 4g em 250mL SG5% (16mg/mL)', ''),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      _linhaIndicacaoDoseCalculada(
        titulo: 'Eclâmpsia / Pré-eclâmpsia grave',
        descricaoDose: 'Ataque: 4–6g IV lenta em 20 min → Manutenção: 1–2g/h',
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Torsades de Pointes / TV polimórfica',
        descricaoDose: '2g IV lenta em 5–15 min',
        unidade: 'mg',
        doseMaxima: 2000,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Hipomagnesemia sintomática',
        descricaoDose: '1–2g IV em 30 min, repetir se necessário',
        unidade: 'mg',
        doseMaxima: 2000,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Asma grave refratária',
        descricaoDose: '2g IV em 20 min (off-label)',
        unidade: 'mg',
        doseMaxima: 2000,
        peso: peso,
      ),

      const SizedBox(height: 16),
      const Text('Cálculo da Infusão', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      ConversaoInfusaoSlider(
        peso: peso,
        opcoesConcentracoes: {
          '4g/250mL (16mg/mL)': 16000,
          '2g/100mL (20mg/mL)': 20000,
        },
        unidade: 'mg/h',
        doseMin: 1000,
        doseMax: 2000,
      ),

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Corrige hipomagnesemia e estabiliza membranas celulares.'),
      _textoObs('• Potente anticonvulsivante em eclâmpsia.'),
      _textoObs('• Exclusivamente renal — monitorar função renal.'),
      _textoObs('• Monitorar reflexos, diurese e FR em uso contínuo.'),
      _textoObs('• Doses altas → risco de bloqueio neuromuscular e parada respiratória.'),
    ],
  );
}
Widget buildCardGluconatoCalcio(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito,) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Ampola 10% (1g/10mL = 93mg de Ca²⁺)', 'Gluconato de Cálcio 10%'),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('IV lenta (5–10 min) ou diluído em SG5%/SF0,9%', ''),
      _linhaPreparo('Infusão contínua: 1g em 100mL SG5% ou SF0,9%', ''),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      _linhaIndicacaoDoseCalculada(
        titulo: 'Hipocalcemia sintomática / Hipercalemia com ECG alterado',
        descricaoDose: '100–200mg/kg IV lenta (máx 3g)',
        unidade: 'mg',
        dosePorKgMinima: 100,
        dosePorKgMaxima: 200,
        doseMaxima: 3000,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Toxicidade por sulfato de magnésio / bloqueadores de canal de cálcio',
        descricaoDose: '1g IV lenta a cada 6–8h ou infusão contínua',
        unidade: 'mg',
        doseMaxima: 1000,
        peso: peso,
      ),

      const SizedBox(height: 16),
      const Text('Cálculo da Infusão', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      ConversaoInfusaoSlider(
        peso: peso,
        opcoesConcentracoes: {
          '1g/100mL (10mg/mL)': 10000,
          '2g/100mL (20mg/mL)': 20000,
        },
        unidade: 'mg/kg/h',
        doseMin: 50,
        doseMax: 200,
      ),

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Preferido ao cloreto para acesso periférico (menos irritante).'),
      _textoObs('• Cada ampola → 4,65 mEq de cálcio elementar.'),
      _textoObs('• Usar bomba de infusão se contínuo.'),
      _textoObs('• Monitorar ECG, potássio e cálcio iônico.'),
      _textoObs('• Pode ser repetido conforme clínica.'),
    ],
  );
}
Widget buildCardCloretoCalcio(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito,) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Ampola 10% (1g/10mL = 27mg/mL de Ca²⁺)', 'Hipercal®'),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('IV lenta (3–5 min) ou infusão em bomba', ''),
      _linhaPreparo('Evitar periférico — risco de necrose. Preferir acesso central.', ''),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      _linhaIndicacaoDoseCalculada(
        titulo: 'Hipocalcemia sintomática / Hipercalemia grave',
        descricaoDose: '10–20mg/kg Ca²⁺ elementar IV lenta (máx 1g)',
        unidade: 'mg',
        dosePorKgMinima: 10,
        dosePorKgMaxima: 20,
        doseMaxima: 1000,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Intoxicação por bloqueadores de canal de cálcio',
        descricaoDose: '500–1000mg (1 ampola) IV em bolus + infusão contínua (0,5–1 mg/kg/h)',
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Antagonismo da toxicidade do magnésio',
        descricaoDose: '500–1000mg IV lenta',
        unidade: 'mg',
        doseMaxima: 1000,
        peso: peso,
      ),

      const SizedBox(height: 16),
      const Text('Cálculo da Infusão', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      ConversaoInfusaoSlider(
        peso: peso,
        opcoesConcentracoes: {
          '1g/100mL (10mg/mL)': 10000,
          '500mg/50mL (10mg/mL)': 10000,
        },
        unidade: 'mg/kg/h',
        doseMin: 0.5,
        doseMax: 2.0,
      ),

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Reposição mais concentrada que gluconato.'),
      _textoObs('• 3x mais cálcio elementar que o gluconato de cálcio.'),
      _textoObs('• Incompatível com bicarbonato na mesma via (precipita).'),
      _textoObs('• Extravasamento → risco de necrose → preferir acesso central.'),
      _textoObs('• Monitorar ECG e eletrólitos durante infusão.'),
    ],
  );
}
Widget buildCardCloretoPotassio(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito,) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Frasco-ampola 19,1% (2mEq/mL)', '10mL = 20mEq'),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Diluir 20–40mEq em 100–250mL SF ou SG 5%', 'Concentração segura: máx 40mEq/L em periférico'),
      _linhaPreparo('Infundir com bomba controlada, monitorar ritmo cardíaco', ''),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      _linhaIndicacaoDoseCalculada(
        titulo: 'Reposição de hipocalemia leve a moderada',
        descricaoDose: '20–40 mEq em 4–6h IV',
        unidade: 'mEq',
        dosePorKgMinima: 0.3,
        dosePorKgMaxima: 0.6,
        doseMaxima: 40,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Hipocalemia grave ou com arritmia',
        descricaoDose: '0,5–1 mEq/kg/dose IV lenta (monitorizada)',
        unidade: 'mEq',
        dosePorKgMinima: 0.5,
        dosePorKgMaxima: 1.0,
        doseMaxima: 60,
        peso: peso,
      ),

      const SizedBox(height: 16),
      const Text('Cálculo da Infusão', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      ConversaoInfusaoSlider(
        peso: peso,
        opcoesConcentracoes: {
          '20mEq/100mL (0,2mEq/mL)': 200,
          '40mEq/250mL (0,16mEq/mL)': 160,
        },
        unidade: 'mEq/h',
        doseMin: 5,
        doseMax: 20,
      ),

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Corrigir hipomagnesemia antes da reposição se refratária.'),
      _textoObs('• Infusão periférica: máx 10 mEq/h. Central: até 20 mEq/h com ECG contínuo.'),
      _textoObs('• Risco de parada cardíaca se infundido rápido ou não diluído.'),
      _textoObs('• Uso exclusivo EV. Nunca IM ou SC.'),
      _textoObs('• Monitorar potássio e função renal durante a terapia.'),
    ],
  );
}
Widget buildCardBicarbonatoSodio(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito,) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Ampolas 8,4% – 10mL (10 mEq) ou 50mL (50 mEq) – 1 mEq/mL', ''),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Uso IV direto (bolus) ou infusão contínua diluído em SG 5%', ''),
      _linhaPreparo('Evitar diluição em SF – risco de precipitação de carbonato', ''),
      _linhaPreparo('Usar acesso central se solução concentrada (8,4%) ou infusão prolongada', ''),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      _linhaIndicacaoDoseCalculada(
        titulo: 'Acidose metabólica grave (pH < 7,1)',
        descricaoDose: '1–2 mEq/kg IV lenta, repetir conforme gasometria',
        unidade: 'mL',
        dosePorKgMinima: 1.0,
        dosePorKgMaxima: 2.0,
        doseMaxima: 150,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Parada cardiorrespiratória \n(com acidose comprovada)',
        descricaoDose: '1 mEq/kg em bolus IV. Repetir conforme resposta.',
        unidade: 'mL',
        dosePorKg: 1.0,
        doseMaxima: 100,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Intoxicações específicas \n(tricíclicos, salicilatos)',
        descricaoDose: '1–2 mEq/kg IV lenta + infusão para manter pH 7,45–7,55',
        unidade: 'mL',
        dosePorKgMinima: 1.0,
        dosePorKgMaxima: 2.0,
        peso: peso,

      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Hipercalemia com alterações no ECG',
        descricaoDose: '50–100 mEq IV lenta (com ECG contínuo)',
        peso: peso,

      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Alcalinização urinária (ex: intoxicação por fenobarbital)',
        descricaoDose: '100–150 mEq em 1 L SG5%, infundir 250–500 mL/h',
        peso: peso,

      ),


      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Alcalinizante sistêmico para acidose metabólica grave ou intoxicações pH-dependentes.'),
      _textoObs('• Monitorar pH arterial, eletrólitos (K+, Na+, Ca++) e osmolaridade.'),
      _textoObs('• Evitar uso excessivo — risco de alcalose metabólica, hipernatremia e sobrecarga.'),
      _textoObs('• Extravasamento → necrose tecidual grave: preferir acesso central.'),
      _textoObs('• Incompatível com cálcio na mesma via IV (precipitação).'),
      _textoObs('• Off-label: correção de acidose na diálise, intoxicações incomuns, crises de acidose tubular renal tipo I.'),
    ],
  );
}



// 🩺 Antiarrítmicos
Widget buildCardMetoprolol(BuildContext context, double peso, bool isAdulto) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Ampola 5mg/5mL (1mg/mL)', 'Metoprolol tartrato IV'),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('IV lenta (1–2mg/min)', 'Pode diluir em 10–20mL SF 0,9%'),
      _linhaPreparo('Monitorar ECG e PA durante', ''),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Taquiarritmias supraventriculares',
        descricaoDose: '2,5–5mg IV lenta cada 5min (máx 15mg)',
        unidade: 'mg',
        dosePorKgMinima: 0.05,
        dosePorKgMaxima: 0.1,
        doseMaxima: 15,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Controle PA e FC no IAM',
        descricaoDose: '5mg IV cada 5min (até 3 doses)',
        unidade: 'mg',
        doseMaxima: 15,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Hipertensão perioperatória',
        descricaoDose: '1–5mg IV lenta, repetir conforme resposta',
        unidade: 'mg',
        dosePorKgMinima: 0.02,
        dosePorKgMaxima: 0.08,
        doseMaxima: 5,
        peso: peso,
      ),

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Betabloqueador seletivo β1.'),
      _textoObs('• Cuidado em ICC, BAV e DPOC grave.'),
      _textoObs('• Monitorar ECG, PA e broncoespasmo.'),
    ],
  );
}
Widget buildCardLidocainaAntiarritmica(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito,) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Ampola 20mg/mL (2mL ou 5mL)', 'Lidocaína sem vasoconstrictor, uso EV'),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('IV direto lento (1-2 min) ou diluir em 100mL SG5% para infusão', ''),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      if (isAdulto) ...[
        _linhaIndicacaoDoseCalculada(
          titulo: 'Taquicardia ventricular / FV pós-choque',
          descricaoDose: 'Bolus de 1–1,5 mg/kg IV lento.\nRepetir 0,5–0,75 mg/kg a cada 5-10 min até dose total de 3mg/kg.',
          unidade: 'mg',
          dosePorKgMinima: 1.0,
          dosePorKgMaxima: 1.5,
          doseMaxima: 3 * peso,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Infusão contínua (manutenção)',
          descricaoDose: '1–4 mg/min IV em bomba',
          unidade: 'mg/min',
          peso: peso,
        ),
      ] else ...[
        _linhaIndicacaoDoseCalculada(
          titulo: 'Taquiarritmias ventriculares pediátricas',
          descricaoDose: '1 mg/kg IV lento\nRepetir 0,5–1 mg/kg até máx 3 mg/kg',
          unidade: 'mg',
          dosePorKgMinima: 1.0,
          dosePorKgMaxima: 3.0,
          doseMaxima: 3 * peso,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Infusão contínua pediátrica',
          descricaoDose: '20–50 mcg/kg/min',
          unidade: 'mcg/kg/min',
          peso: peso,
        ),
      ],

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Classe Ib antiarrítmico: atua nos canais de sódio.'),
      _textoObs('• Indicado principalmente para arritmias ventriculares.'),
      _textoObs('• Monitorar sinais de toxicidade: parestesias, confusão, tremores, convulsões.'),
      _textoObs('• Ajustar dose na insuficiência hepática ou disfunção cardíaca grave.'),
    ],
  );
}
Widget buildCardAmiodarona(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito,) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Ampola 3mL (150mg – 50mg/mL)', 'Ancoron®, Aratac®'),

      const SizedBox(height: 16),
      const Text('Preparo e Indicação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Uso exclusivo EV. Diluir apenas em SG 5%', ''),
      _linhaPreparo('Bolus: 150mg em 20mL SG5% – infusão ≥10 min', ''),
      _linhaPreparo('Manutenção: 900mg em 500mL SG5% (1,8mg/mL)', ''),
      _linhaPreparo('Evitar SF: risco de precipitação da droga', ''),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      if (isAdulto) ...[
        const Text('Adulto', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.indigo)),
        const SizedBox(height: 6),
        _linhaIndicacaoDoseCalculada(
          titulo: 'FV/TV sem pulso (PCR)',
          descricaoDose: '• 1ª dose: 300mg IV bolus \n(após 3º choque)\n• 2ª dose: 150mg IV se recorrência',
          unidade: '300 mg\n \n \n150mg',
peso:peso
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Taquiarritmias com pulso (TV/FV instável)',
          descricaoDose: '• Ataque: 150mg IV diluído em 100mL SG5% (10 min)\n• Manutenção: 1mg/min (6h) → 0,5mg/min (18h)',
peso:peso
        ),
      ] else ...[
        const Text('Pediátrico', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.deepPurple)),
        const SizedBox(height: 6),
        _linhaIndicacaoDoseCalculada(
          titulo: 'FV/TV sem pulso (PCR)',
          descricaoDose: '5mg/kg IV bolus (em SG5%)\n• Pode repetir até 15mg/kg/dia (máx 300mg)',
          unidade: 'mg',
          dosePorKgMinima: 5.0,
          dosePorKgMaxima: 5.0,
          doseMaxima: 300,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Taquiarritmias com pulso (instáveis)',
          descricaoDose: '5mg/kg IV diluído em SG5% em 20–60 min\n• Repetir até 15mg/kg/dia (máx 2,2g)',
          unidade: 'mg',
          dosePorKgMinima: 5.0,
          dosePorKgMaxima: 15.0,
          doseMaxima: 2200,
          peso: peso,
        ),
      ],

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Diluir exclusivamente em SG5% – incompatível com SF.'),
      _textoObs('• Risco elevado de flebite: preferir acesso venoso central.'),
      _textoObs('• Antiarrítmico classe III: bloqueia canais de potássio, sódio e cálcio.'),
      _textoObs('• Efeito prolongado e meia-vida longa (semanas).'),
      _textoObs('• Controle rigoroso de PA e ritmo (risco de hipotensão e bradicardia).'),
    ],
  );
}
Widget buildCardEsmolol(BuildContext context, double peso, bool isAdulto) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Frasco 100mg/10mL ou 2500mg/250mL (10mg/mL)', 'Brevibloc®'),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('100mg em 10mL = bolus (10mg/mL)', ''),
      _linhaPreparo('2500mg em 250mL SF = 10mg/mL para infusão', ''),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaIndicacaoDoseCalculada(
        titulo: 'FA/Flutter',
        descricaoDose: 'Bolus 0,5 mg/kg IV + infusão 50–300 mcg/kg/min',
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Controle PA/FC em cirurgias',
        descricaoDose: 'Bolus 0,5–1 mg/kg + infusão 50–200 mcg/kg/min',
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Taquicardia supraventricular',
        descricaoDose: 'Bolus 0,5 mg/kg + infusão contínua',
        peso: peso,
      ),

      const SizedBox(height: 16),
      const Text('Cálculo da Infusão', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      ConversaoInfusaoSlider(
        peso: peso,
        opcoesConcentracoes: {
          '2500mg/250mL (10mg/mL)': 10000,
          '1000mg/100mL (10mg/mL)': 10000,
        },
        unidade: 'mcg/kg/min',
        doseMin: 50,
        doseMax: 300,
      ),

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Betabloqueador ultracurto, início rápido, meia-vida ~9min.'),
      _textoObs('• Ideal para controle transitório de FC e PA.'),
      _textoObs('• Cuidado com hipotensão e bradicardia.'),
      _textoObs('• Efeito cessa rapidamente após suspender.'),
      _textoObs('• Contraindicado em BAV, ICC descompensada e bradicardia.'),
    ],
  );
}
Widget buildCardAdenosina(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito,) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Ampola 6mg/2mL (3mg/mL)', 'Uso IV – bolus rápido'),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Via de administração: apenas IV em bolus rápido (1–2 segundos)', ''),
      _linhaPreparo('Aplicar em veia proximal (antecubital ou central) com monitorização contínua', ''),
      _linhaPreparo('Seguir IMEDIATAMENTE com flush de 20mL SF 0,9% (seringa em Y preferencial)', ''),

      const SizedBox(height: 16),
      const Text('Indicações e Posologia para TSVP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      if (isAdulto) ...[
        const Text('Adulto', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.indigo)),
        const SizedBox(height: 6),
        _linhaIndicacaoDoseFixa(
          titulo: 'TSVP – Adulto',
          descricaoDose: '1ª dose: 6mg IV em bolus rápido (1–2 segundos), seguida de flush imediato com 20mL SF 0,9%.\n'
                         '2ª dose: 12mg IV bolus após 1–2 min.\n'
                         '3ª dose: 12mg IV bolus se necessário (máximo total: 30mg).',
          unidade: 'mg',
          valorMinimo: 6,
          valorMaximo: 18,
        ),
      ] else ...[
        const Text('Pediátrico', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.deepPurple)),
        const SizedBox(height: 6),
        _linhaIndicacaoDoseCalculada(
          titulo: 'TSVP – Pediátrico',
          descricaoDose: '1ª dose: 0,1 mg/kg IV bolus rápido + flush imediato.\n'
                         '2ª dose: 0,2 mg/kg (máximo 12mg).',
          unidade: 'mg',
          dosePorKgMinima: 0.1,
          dosePorKgMaxima: 0.2,
          doseMaxima: 12,
          peso: peso,
        ),
      ],

      // Outras indicações (off-label / secundárias)
      const SizedBox(height: 16),
      const Text('Outras Indicações (off-label / secundárias)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Diagnóstico diferencial de taquicardias de QRS largo, quando há dúvida entre TSV com aberrância e TV.'),
      _textoObs('• Útil em testes de provocação para avaliação de condução no nó AV.'),
      _textoObs('• Pode ser usada para reversão de taquicardia atrial multifocal ou flutter atrial, mas com eficácia limitada.'),

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Antiarritmico classe V: bloqueia transitoriamente o nó AV.'),
      _textoObs('• Meia-vida plasmática ultracurta (~10 segundos).'),
      _textoObs('• Eficaz na conversão rápida de TSVP em ritmo sinusal.'),
      _textoObs('• Efeitos transitórios: rubor, dispneia, dor torácica, sensação de morte iminente e pausa sinusal.'),
      _textoObs('• ECG contínuo obrigatório durante e após a administração.'),
      _textoObs('• Contraindicado em bloqueios AV de 2º/3º grau e bradicardia grave sem marcapasso.'),

      // Seção Cálculo de Infusão (informando que não há uso em infusão contínua)
      const SizedBox(height: 16),
      const Text('Cálculo de Infusão', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• A adenosina é usada exclusivamente em bolus IV rápido. Não possui aplicação clínica em infusão contínua.'),
    ],
  );
}


// 🩺 Antieméticos
Widget buildCardDroperidol(BuildContext context, double peso, bool isAdulto) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Ampola 2,5mg/mL (2mL)', ''),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('IV lenta ou IM direta', ''),
      _linhaPreparo('Opcional: diluir em SF 0,9% para infusão lenta', ''),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      if (isAdulto) ...[
        _linhaIndicacaoDoseCalculada(
          titulo: 'Náuseas e vômitos refratários',
          descricaoDose: '0,625–1,25mg IV lenta',
          unidade: 'mg',
          dosePorKgMinima: 0.01,
          dosePorKgMaxima: 0.02,
          doseMaxima: 1.25,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Agitação / sedação rápida',
          descricaoDose: '2,5–10mg IM ou IV lenta',
          unidade: 'mg',
          dosePorKgMinima: 0.03,
          dosePorKgMaxima: 0.15,
          doseMaxima: 10,
          peso: peso,
        ),
      ] else ...[
        _linhaIndicacaoDoseCalculada(
          titulo: 'Antiemético pediátrico (off-label)',
          descricaoDose: '0,015–0,05 mg/kg IV ou IM',
          unidade: 'mg',
          dosePorKgMinima: 0.015,
          dosePorKgMaxima: 0.05,
          peso: peso,
        ),
      ],

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Antiemético potente com efeito antipsicótico e sedativo.'),
      _textoObs('• Prolonga o intervalo QT – monitorar ECG se dose ≥1mg.'),
      _textoObs('• Eficaz em náuseas refratárias e delírios agudos.'),
      _textoObs('• Pode causar hipotensão, sedação profunda e distonia.'),
      _textoObs('• Contraindicado em pacientes com histórico de QT longo.'),
    ],
  );
}
Widget buildCardMetoclopramida(BuildContext context, double peso, bool isAdulto) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Ampola 10mg/2mL (5mg/mL)', 'Plasil® injetável'),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('IV lenta ou IM direta', ''),
      _linhaPreparo('Opcional: diluir em SF 20–50mL para infusão lenta', ''),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      if (isAdulto) ...[
        _linhaIndicacaoDoseCalculada(
          titulo: 'Náuseas e vômitos',
          descricaoDose: '10mg IV lenta ou IM a cada 8h',
          unidade: 'mg',
          doseMaxima: 10,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Coadjuvante na enxaqueca',
          descricaoDose: '10mg IV lenta no início da crise (associado a AINEs)',
          unidade: 'mg',
          peso: peso,
        ),
      ] else ...[
        _linhaIndicacaoDoseCalculada(
          titulo: 'Antiemético pediátrico',
          descricaoDose: '0,1–0,2 mg/kg IV ou IM a cada 8h',
          unidade: 'mg',
          dosePorKgMinima: 0.1,
          dosePorKgMaxima: 0.2,
          doseMaxima: 10,
          peso: peso,
        ),
      ],

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Antagonista dopaminérgico com efeito antiemético e procinético.'),
      _textoObs('• Útil em náuseas pós-operatórias, gastroenterite e enxaqueca.'),
      _textoObs('• Pode causar efeitos extrapiramidais, especialmente em jovens.'),
      _textoObs('• Evitar em pacientes com Parkinson ou uso de antipsicóticos.'),
      _textoObs('• Contraindicado em epilepsia ou obstrução intestinal mecânica.'),
    ],
  );
}
Widget buildCardBromoprida(BuildContext context, double peso, bool isAdulto) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Ampola 10mg/2mL (5mg/mL)', ''),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('IV lenta ou IM direta', ''),
      _linhaPreparo('Opcional: diluir em SF 0,9% para infusão lenta', ''),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      if (isAdulto) ...[
        _linhaIndicacaoDoseCalculada(
          titulo: 'Náuseas e vômitos',
          descricaoDose: '0,15–0,3 mg/kg IV ou IM a cada 8h (máx 10mg)',
          unidade: 'mg',
          dosePorKgMinima: 0.15,
          dosePorKgMaxima: 0.3,
          doseMaxima: 10,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Refluxo / gastroparesia',
          descricaoDose: '0,15–0,3 mg/kg VO ou IV 3x/dia, 30 min antes das refeições (máx 10mg)',
          unidade: 'mg',
          dosePorKgMinima: 0.15,
          dosePorKgMaxima: 0.3,
          doseMaxima: 10,
          peso: peso,
        ),
      ] else ...[
        _linhaIndicacaoDoseCalculada(
          titulo: 'Antiemético pediátrico',
          descricaoDose: '0,1–0,2 mg/kg IV ou IM a cada 8h (máx 10mg)\n⚠️ Evitar uso em menores de 1 ano',
          unidade: 'mg',
          dosePorKgMinima: 0.1,
          dosePorKgMaxima: 0.2,
          doseMaxima: 10,
          peso: peso,
        ),
      ],

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Antagonista dopaminérgico D2 com efeito antiemético e procinético.'),
      _textoObs('• Boa alternativa à metoclopramida com menor penetração no SNC.'),
      _textoObs('• Eficácia similar à metoclopramida, menor penetração no SNC.'),
      _textoObs('• Pode causar sonolência e efeitos extrapiramidais, especialmente em crianças.'),
      _textoObs('• Contraindicado em obstrução intestinal mecânica e feocromocitoma.'),
      _textoObs('• Uso pediátrico: maior risco de efeitos extrapiramidais em crianças pequenas.'),
      _textoObs('• Evitar uso em menores de 1 ano devido à imaturidade da barreira hematoencefálica e metabolismo hepático.'),
    ],
  );
}
Widget buildCardHioscina(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito,) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Ampola 20mg/mL (escopolamina butilbrometo)', 'Buscopan® injetável'),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Pode ser usada diretamente por via IM, IV ou SC', ''),
      _linhaPreparo('Pode ser diluída em SF para infusão lenta', ''),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      if (isAdulto) ...[
        _linhaIndicacaoDoseCalculada(
          titulo: 'Espasmos gastrintestinais, biliares ou urinários',
          descricaoDose: '20mg IV, IM ou SC a cada 6–8h se necessário',
          unidade: 'mg',
          doseMaxima: 20,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Pré-medicação antissecretora (off-label)',
          descricaoDose: '0,2–0,4 mg IV lenta (escopolamina base)',
          unidade: 'mg',
          peso: peso,
        ),
      ] else ...[
        _linhaIndicacaoDoseCalculada(
          titulo: 'Espasmos abdominais pediátricos',
          descricaoDose: '0,3 mg/kg/dia divididos em 3 doses IM ou SC',
          unidade: 'mg',
          dosePorKgMinima: 0.1,
          dosePorKgMaxima: 0.3,
          peso: peso,
        ),
      ],

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Antimuscarínico com ação antiespasmódica e antissecretora.'),
      _textoObs('• Pode causar sonolência, boca seca e visão turva.'),
      _textoObs('• Cuidado em idosos: risco de delirium e retenção urinária.'),
      _textoObs('• Útil como adjuvante em náuseas refratárias.'),
      _textoObs('• Doses elevadas podem causar efeitos centrais (confusão, alucinações).'),
    ],
  );
}
Widget buildCardDimenidrinato(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito,) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Ampola 50mg/mL (1mL)', 'Dramin® injetável'),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Pode ser usado direto por via IV lenta ou IM', ''),
      _linhaPreparo('Opcional: diluir em 20–50mL SF 0,9% para infusão lenta', ''),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      if (isAdulto) ...[
        _linhaIndicacaoDoseCalculada(
          titulo: 'Náuseas, vômitos, vertigem',
          descricaoDose: '50–100mg IM ou IV lenta a cada 4–6h se necessário',
          unidade: 'mg',
          dosePorKgMinima: 0.5,
          dosePorKgMaxima: 1.5,
          doseMaxima: 100,
          peso: peso,
        ),
      ] else ...[
        _linhaIndicacaoDoseCalculada(
          titulo: 'Antiemético pediátrico',
          descricaoDose: '1,25mg/kg/dose a cada 6h (máx 75mg/dia)',
          unidade: 'mg',
          dosePorKgMinima: 1.0,
          dosePorKgMaxima: 1.25,
          doseMaxima: 75,
          peso: peso,
        ),
      ],

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Anti-histamínico H1 com ação antiemética e antivertiginosa.'),
      _textoObs('• Pode causar sedação intensa e boca seca.'),
      _textoObs('• Evitar uso concomitante com outros depressores do SNC.'),
      _textoObs('• Ideal para enjoo de movimento, labirintite e cinetose.'),
      _textoObs('• Cautela em idosos: risco de delirium e retenção urinária.'),
    ],
  );
}

// 🩺 Indutores Anestésicos

Widget buildCardCetamina(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito,) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Ampola 500mg/10mL (50mg/mL)', ''),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('500mg em 100mL SG 5%', '5 mg/mL'),
      _linhaPreparo('Pode ser usada sem diluir para bolus IM/IV', ''),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      if (isAdulto) ...[
        _linhaIndicacaoDoseCalculada(
          titulo: 'Indução anestésica IV',
          descricaoDose: '1–2 mg/kg IV lenta',
          unidade: 'mg',
          dosePorKgMinima: 1.0,
          dosePorKgMaxima: 2.0,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Sedação subanestésica (analgesia)',
          descricaoDose: '0,25–0,5 mg/kg em bolus ou infusão',
          unidade: 'mg',
          dosePorKgMinima: 0.25,
          dosePorKgMaxima: 0.5,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Broncoespasmo refratário / asma grave',
          descricaoDose: '0,5–1 mg/kg IV + 0,15–0,5 mg/kg/h',
          peso: peso,
        ),
      ] else ...[
        _linhaIndicacaoDoseCalculada(
          titulo: 'Indução anestésica pediátrica',
          descricaoDose: '1–2 mg/kg IV ou 4–10 mg/kg IM',
          unidade: 'mg',
          dosePorKgMinima: 1.0,
          dosePorKgMaxima: 2.0,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Sedação / analgesia pediátrica',
          descricaoDose: '0,25–1 mg/kg em bolus',
          unidade: 'mg',
          dosePorKgMinima: 0.25,
          dosePorKgMaxima: 1.0,
          peso: peso,
        ),
      ],

      const SizedBox(height: 16),
      const Text('Cálculo da Infusão', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      ConversaoInfusaoSlider(
        peso: peso,
        opcoesConcentracoes: {
          '500mg/100mL (5mg/mL)': 5,
          '250mg/100mL (2,5mg/mL)': 2.5,
        },
        unidade: 'mg/kg/h',
        doseMin: 0.1,
        doseMax: 0.5,
      ),

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Anestésico dissociativo com ação em receptores NMDA.'),
      _textoObs('• Preserva drive respiratório e reflexos das vias aéreas.'),
      _textoObs('• Efeitos psicodislépticos comuns.'),
      _textoObs('• Útil em pacientes com broncoespasmo ou instabilidade hemodinâmica.'),
      _textoObs('• Associar benzodiazepínico para reduzir agitação.'),
    ],
  );
}
Widget buildCardTiopental(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito,) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Frasco 1g (pó liofilizado)', 'Reconstituir com 20mL de SF 0,9%'),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('1g em 20mL = 50mg/mL', 'Diluir mais se necessário'),
      _linhaPreparo('Infusão contínua: 1g em 250mL = 4mg/mL', ''),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      if (isAdulto) ...[
        _linhaIndicacaoDoseCalculada(
          titulo: 'Indução anestésica',
          descricaoDose: '3–5 mg/kg IV lenta',
          unidade: 'mg',
          dosePorKgMinima: 3,
          dosePorKgMaxima: 5,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Status epilepticus refratário',
          descricaoDose: 'Carga de 5–10 mg/kg IV + infusão 1–5 mg/kg/h',
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Controle de hipertensão intracraniana',
          descricaoDose: '0,5–3 mg/kg/h IV contínua',
          peso: peso,
        ),
      ] else ...[
        _linhaIndicacaoDoseCalculada(
          titulo: 'Indução pediátrica',
          descricaoDose: '5–7 mg/kg IV lenta',
          unidade: 'mg',
          dosePorKgMinima: 5,
          dosePorKgMaxima: 7,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Status epilepticus pediátrico',
          descricaoDose: 'Carga de 5–10 mg/kg + infusão 0,5–3 mg/kg/h',
          peso: peso,
        ),
      ],

      const SizedBox(height: 16),
      const Text('Cálculo da Infusão', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      ConversaoInfusaoSlider(
        peso: peso,
        opcoesConcentracoes: {
          '1g/250mL (4mg/mL)': 4,
          '500mg/250mL (2mg/mL)': 2,
        },
        unidade: 'mg/kg/h',
        doseMin: 0.5,
        doseMax: 5.0,
      ),

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Barbitúrico de ação ultracurta, potente depressor do SNC.'),
      _textoObs('• Pode causar hipotensão e depressão respiratória.'),
      _textoObs('• Evitar extravasamento: risco de necrose tecidual.'),
      _textoObs('• Monitorização contínua necessária em infusões prolongadas.'),
      _textoObs('• Contraindicado em porfiria aguda intermitente.'),
    ],
  );
}
Widget buildCardEtomidato(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito,) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Ampola 20mg/10mL (2mg/mL)', ''),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Uso direto, sem necessidade de diluição', ''),
      _linhaPreparo('Infundir lentamente em 30–60 segundos', ''),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      _linhaIndicacaoDoseCalculada(
        titulo: 'Indução anestésica (paciente instável)',
        descricaoDose: '0,2–0,3 mg/kg IV lenta (único uso)',
        unidade: 'mg',
        dosePorKgMinima: 0.2,
        dosePorKgMaxima: 0.3,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Procedimentos breves (cardioversão, intubação)',
        descricaoDose: '0,15–0,3 mg/kg IV',
        unidade: 'mg',
        dosePorKgMinima: 0.15,
        dosePorKgMaxima: 0.3,
        peso: peso,
      ),

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Hipnótico de ação ultrarrápida, ideal para pacientes instáveis.'),
      _textoObs('• Não causa hipotensão significativa ou depressão miocárdica.'),
      _textoObs('• Sem efeito analgésico – associar opioide.'),
      _textoObs('• Pode causar mioclonias e dor na injeção.'),
      _textoObs('• Evitar uso prolongado: supressão adrenocortical.'),
    ],
  );
}
Widget buildCardDextrocetamina(BuildContext context, double peso, bool isAdulto) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Ampola 25mg/mL (Ketanest S®)', ''),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Diluir em SF 0,9% ou SG 5%', 'Ex: 100mg em 100mL (1mg/mL)'),
      _linhaPreparo('Utilizar bomba de infusão para infusões contínuas', ''),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      if (isAdulto) ...[
        _linhaIndicacaoDoseCalculada(
          titulo: 'Indução anestésica (IV)',
          descricaoDose: '0,5–1 mg/kg IV lenta',
          unidade: 'mg',
          dosePorKgMinima: 0.5,
          dosePorKgMaxima: 1.0,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Analgesia subanestésica em UTI',
          descricaoDose: '0,05–0,5 mg/kg/h IV contínua',
          peso: peso,
        ),
      ] else ...[
        _linhaIndicacaoDoseCalculada(
          titulo: 'Indução anestésica pediátrica',
          descricaoDose: '1–1,5 mg/kg IV',
          unidade: 'mg',
          dosePorKgMinima: 1.0,
          dosePorKgMaxima: 1.5,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Sedação subanestésica',
          descricaoDose: '0,1–0,5 mg/kg/h IV contínua',
          peso: peso,
        ),
      ],

      const SizedBox(height: 16),
      const Text('Cálculo da Infusão', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      ConversaoInfusaoSlider(
        peso: peso,
        opcoesConcentracoes: {
          '100mg/100mL (1mg/mL)': 1000,
          '200mg/100mL (2mg/mL)': 2000,
        },
        unidade: 'mg/kg/h',
        doseMin: 0.05,
        doseMax: 0.5,
      ),

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Enantiômero S(+) da cetamina: maior potência anestésica e menos efeitos psicodislépticos.'),
      _textoObs('• Promove analgesia, anestesia e sedação dose-dependentes.'),
      _textoObs('• Preserva reflexos de vias aéreas e drive respiratório.'),
      _textoObs('• Pode causar hipertensão e taquicardia, especialmente em bolus.'),
      _textoObs('• Usar com cautela em pacientes com hipertensão intracraniana.'),
    ],
  );
}
Widget buildCardPropofol(BuildContext context, double peso, bool isAdulto) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Ampola 200mg/20mL (1%)', 'Também disponível em frascos maiores'),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Uso direto, não diluir', 'Agitar antes de usar – emulsão oleosa'),
      _linhaPreparo('Descartar após 6h do preparo', 'Risco de contaminação'),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),

      if (isAdulto) ...[
        _linhaIndicacaoDoseCalculada(
          titulo: 'Indução anestésica',
          descricaoDose: '1,5–2,5 mg/kg em bolus IV',
          unidade: 'mg',
          dosePorKgMinima: 1.5,
          dosePorKgMaxima: 2.5,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Sedação em UTI',
          descricaoDose: '0,3–4 mg/kg/h IV contínua',
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Procedimento diagnóstico curto',
          descricaoDose: '0,5–1,5 mg/kg em bolus IV + manutenção conforme resposta',
          unidade: 'mg',
          dosePorKgMinima: 0.5,
          dosePorKgMaxima: 1.5,
          peso: peso,
        ),
      ] else ...[
        _linhaIndicacaoDoseCalculada(
          titulo: 'Indução anestésica pediátrica',
          descricaoDose: '2,5–3,5 mg/kg IV',
          unidade: 'mg',
          dosePorKgMinima: 2.5,
          dosePorKgMaxima: 3.5,
          peso: peso,
        ),
        _linhaIndicacaoDoseCalculada(
          titulo: 'Sedação pediátrica contínua',
          descricaoDose: '1–4 mg/kg/h IV contínua',
          peso: peso,
        ),
      ],

      const SizedBox(height: 16),
      const Text('Cálculo da Infusão', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      ConversaoInfusaoSlider(
        peso: peso,
        opcoesConcentracoes: {
          '1% (10mg/mL)': 10000,
        },
        unidade: 'mg/kg/h',
        doseMin: 0.5,
        doseMax: 4.0,
      ),

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Sedativo-hipnótico de ação ultrarrápida.'),
      _textoObs('• Pode causar hipotensão e depressão respiratória.'),
      _textoObs('• Evitar infusão prolongada em altas doses: risco de Síndrome de Infusão de Propofol.'),
      _textoObs('• Não possui efeito analgésico. Associar opioide se necessário.'),
      _textoObs('• Usar exclusivamente por via intravenosa.'),
    ],
  );
}


// 🩺 Anticonvulsivantes de Emergência
Widget buildCardFenitoina(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito,) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Ampola 250mg/5mL (50mg/mL)', ''),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Diluir 1:1 com SF 0,9% para administração lenta', 'Ex: 250mg em 5mL + 5mL SF'),
      _linhaPreparo('Infusão máxima: 50 mg/min em adultos', '1–3 mg/kg/min em crianças'),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Estado de mal epiléptico (dose de ataque)',
        descricaoDose: '15–20 mg/kg EV lenta',
        unidade: 'mg',
        dosePorKgMinima: 15,
        dosePorKgMaxima: 20,
        doseMaxima: 1000,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Manutenção após controle',
        descricaoDose: '5–7 mg/kg/dia divididos em 2–3 doses',
        unidade: 'mg/dia',
        dosePorKgMinima: 5,
        dosePorKgMaxima: 7,
        peso: peso,
      ),

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Anticonvulsivante de ação prolongada; estabiliza canais de sódio.'),
      _textoObs('• Evitar extravasamento venoso: risco de necrose (síndrome púrpura local).'),
      _textoObs('• Não diluir em SG: precipita. Sempre diluir em SF 0,9%.'),
      _textoObs('• Monitorar níveis séricos em uso prolongado.'),
      _textoObs('• Pode causar bradicardia e hipotensão se infundido rapidamente.'),
    ],
  );
}
Widget buildCardFenobarbital(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito,) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Ampola 100mg/mL (solução injetável)', ''),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Diluir 1:10 em SF 0,9% para infusão lenta', 'Ex: 100mg em 10mL'),
      _linhaPreparo('Velocidade máxima: 1mg/kg/min', 'Infundir em 20–30min'),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Estado de mal epiléptico',
        descricaoDose: '15–20 mg/kg EV dose única lenta',
        unidade: 'mg',
        dosePorKgMinima: 15,
        dosePorKgMaxima: 20,
        doseMaxima: 1000,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Crise convulsiva refratária',
        descricaoDose: '5–10 mg/kg EV',
        unidade: 'mg',
        dosePorKgMinima: 5,
        dosePorKgMaxima: 10,
        doseMaxima: 600,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Profilaxia de convulsões neonatais',
        descricaoDose: '10–20 mg/kg dose de ataque + 3–5 mg/kg/dia manutenção',
        unidade: 'mg',
        dosePorKgMinima: 10,
        dosePorKgMaxima: 20,
        peso: peso,
      ),

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Barbitúrico de ação prolongada com efeito anticonvulsivante e sedativo.'),
      _textoObs('• Administrar lentamente devido ao risco de hipotensão e depressão respiratória.'),
      _textoObs('• Evitar infusão rápida: risco de apneia, hipotensão grave e parada cardíaca.'),
      _textoObs('• Monitorar níveis séricos em uso prolongado ou múltiplas doses.'),
      _textoObs('• Pode causar sonolência prolongada, especialmente em neonatos.'),
    ],
  );
}

// 🩺 Controle de Glicemia Crítica
Widget buildCardInsulinaRegular(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Frasco-ampola 100 UI/mL (10 mL)', ''),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('50 UI em 50mL SF 0,9%', '1 UI/mL (infusão contínua)'),
      _linhaPreparo('Bolus IV direto sem diluição (1–10 UI)', ''),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Cetoacidose diabética',
        descricaoDose: '0,1 UI/kg IV bolus + 0,1 UI/kg/h em infusão contínua',
        unidade: 'UI',
        dosePorKg: 0.1,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Estado hiperglicêmico hiperosmolar',
        descricaoDose: '0,1 UI/kg/h EV contínua (sem bolus)',
        unidade: 'UI/h',
        dosePorKg: 0.1,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Hipercalemia (adjuvante com glicose)',
        descricaoDose: '10 UI IV bolus com 50mL de G50%',
        unidade: 'UI',
        doseMaxima: 10,
        peso: peso,
      ),

      const SizedBox(height: 16),
      const Text('Cálculo da Infusão', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      ConversaoInfusaoSlider(
        peso: peso,
        opcoesConcentracoes: {
          '50 UI/50mL (1 UI/mL)': 1,
        },
        unidade: 'UI/kg/h',
        doseMin: 0.05,
        doseMax: 0.2,
      ),

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Insulina de ação rápida, única indicada para uso IV.'),
      _textoObs('• Controle rigoroso da glicemia capilar a cada 1 hora.'),
      _textoObs('• Monitorar potássio sérico – risco de hipocalemia grave.'),
      _textoObs('• Diluir apenas em SF 0,9%, preparo recente.'),
      _textoObs('• Na hipercalemia, sempre associar à glicose IV para evitar hipoglicemia.'),
    ],
  );
}
Widget buildCardGlicose50(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Ampola 10mL (5g de glicose – 50%)', ''),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Uso direto, sem diluição', 'Ampola pronta para uso IV'),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      if (isAdulto) ...[
        _linhaIndicacaoDoseCalculada(
          titulo: 'Hipoglicemia grave sintomática',
          descricaoDose: '25–50mL IV em bolus (1–2 ampolas)',
          unidade: 'mL',
          dosePorKgMinima: 0.5,
          dosePorKgMaxima: 1.0,
          doseMaxima: 50,
          peso: peso,
        ),
      ] else ...[
        _linhaIndicacaoDoseCalculada(
          titulo: 'Hipoglicemia neonatal/pediátrica grave',
          descricaoDose: '0,5–1g/kg (1–2 mL/kg de G50%) diluído em SG 10%',
          unidade: 'mL',
          dosePorKgMinima: 1.0,
          dosePorKgMaxima: 2.0,
          doseMaxima: 10,
          peso: peso,
        ),
      ],

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Ação imediata nas hipoglicemias sintomáticas.'),
      _textoObs('• Pode causar flebite – preferir acesso venoso calibroso.'),
      _textoObs('• Monitorar glicemia capilar 10–15 minutos após uso.'),
      _textoObs('• Em pediatria, diluir preferencialmente para G10%.'),
      _textoObs('• Contraindicado em hiperglicemia ou intolerância à glicose.'),
    ],
  );
}


// 🩺 Imunossupressores Especiais
Widget buildCardTimoglobulina(BuildContext context, double peso, bool isAdulto, bool isFavorito, VoidCallback onToggleFavorito) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      const Text('Apresentação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('Frasco-ampola 25mg (pó liofilizado)', 'Reconstituir com SG 5%'),

      const SizedBox(height: 16),
      const Text('Preparo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaPreparo('25mg em 100mL SG 5%', '0,25 mg/mL (infusão IV lenta)'),
      _linhaPreparo('Filtrar com filtro de 0,22μm', 'Infusão mínima de 4 horas'),

      const SizedBox(height: 16),
      const Text('Indicações Clínicas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Rejeição aguda de transplante renal',
        descricaoDose: '1,5 mg/kg/dia por 7–14 dias',
        unidade: 'mg',
        dosePorKg: 1.5,
        peso: peso,
      ),
      _linhaIndicacaoDoseCalculada(
        titulo: 'Aplasia medular severa',
        descricaoDose: '3,5 mg/kg/dia por 5 dias',
        unidade: 'mg',
        dosePorKg: 3.5,
        peso: peso,
      ),

      const SizedBox(height: 16),
      const Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 8),
      _textoObs('• Imunossupressor derivado de anticorpos policlonais contra linfócitos T.'),
      _textoObs('• Uso hospitalar. Pré-medicação obrigatória: antipirético, anti-histamínico e corticosteroide.'),
      _textoObs('• Administrar em infusão IV lenta, sempre com filtro de 0,22μm.'),
      _textoObs('• Alto risco de reação infusional grave e leucopenia.'),
      _textoObs('• Monitorar função hepática, renal e contagem de linfócitos durante o tratamento.'),
    ],
  );
}
