import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

/// Lista de palavras‑chave que acionam o alerta de risco‑benefício (ficava dentro do State)
const List<String> alertKeywords = [
  'convulsão',
  'infarto',
  'epilpesia',
  'cardiovascular',
];

/// Função auxiliar para extrair o nome do princípio ativo (PT) de um JSON de medicamento
String? extractPtActiveIngredient(Map<String, dynamic> jsonData, String language) {
  if (jsonData.containsKey(language)) {
    final langData = jsonData[language];
    if (langData is Map && langData.containsKey('bulario')) {
      final bul = langData['bulario'];
      if (bul is Map && bul.containsKey('nomePrincipioAtivo')) {
        return bul['nomePrincipioAtivo'];
      }
    }
  }
  return null;
}

String appLanguage = 'PT'; // valor inicial padrão


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  final systemLang = WidgetsBinding.instance.platformDispatcher.locale.languageCode.toLowerCase();
  switch (systemLang) {
    case 'pt':
      appLanguage = 'PT';
      break;
    case 'es':
      appLanguage = 'ES';
      break;
    case 'zh':
      appLanguage = 'CH';
      break;
    default:
      appLanguage = 'US';
  }

  final termoAceito = prefs.getBool('termoAceito') ?? false;
  final mostrarAvisoInicial = prefs.getBool('mostrarAvisoInicial') ?? true;


  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Med Suspend',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: const Color(0xFFF5F9FC),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF102A43),
          secondary: Color(0xFF334E68),
          error: Color(0xFFDA1E28),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF102A43),
          foregroundColor: Colors.white,
          elevation: 2,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF102A43),
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: MaterialStateProperty.all(Color(0xFF102A43)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          hintStyle: const TextStyle(color: Color(0xFF334E68)),
          prefixIconColor: const Color(0xFF334E68),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFFF0F4F8),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          elevation: 3,
          shadowColor: Colors.black12,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF334E68)),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 15, height: 1.5),
          bodyLarge: TextStyle(fontSize: 16, height: 1.5),
          titleMedium: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
      ),
      home: const MedSuspenseHomePage(),
    ),
  );
}


class MedSuspenseApp extends StatelessWidget {
  const MedSuspenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Med Suspend',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: const Color(0xFFF5F9FC),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF102A43),
          secondary: Color(0xFF334E68),
          error: Color(0xFFDA1E28),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF102A43),
          foregroundColor: Colors.white,
          elevation: 2,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF102A43),
            foregroundColor: Colors.white,
            textStyle: TextStyle(fontWeight: FontWeight.w600),
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: MaterialStatePropertyAll(Color(0xFF102A43)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide.none,
          ),
          hintStyle: TextStyle(color: Color(0xFF334E68)),
          prefixIconColor: Color(0xFF334E68),
        ),
        cardTheme: CardThemeData(
          color: Color(0xFFF0F4F8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          elevation: 3,
          shadowColor: Colors.black12,
          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        ),
        iconTheme: IconThemeData(color: Color(0xFF334E68)),
        textTheme: TextTheme(
          bodyMedium: TextStyle(fontSize: 15, height: 1.5),
          bodyLarge: TextStyle(fontSize: 16, height: 1.5),
          titleMedium: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
      ),
      home: const MedSuspenseHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}





class MedSuspenseHomePage extends StatefulWidget {
  const MedSuspenseHomePage({super.key});

  @override
  State<MedSuspenseHomePage> createState() => _MedSuspenseHomePageState();
}




class _MedSuspenseHomePageState extends State<MedSuspenseHomePage> {
  String selectedLanguage = appLanguage;
  Set<String> expandedTiles = {};
  List<Map<String, dynamic>> medications = [];
  List<Map<String, dynamic>> filteredMedications = [];
  final TextEditingController _searchController = TextEditingController();
  Set<String> favoriteMeds = {}; // Armazena os nomes dos medicamentos favoritos
  Timer? _debounce;          // controls the search debounce
  bool get _hasSearchInput => _searchController.text.trim().isNotEmpty;

  final Map<String, Map<String, String>> translations = {
    'PT': {
      'title': 'Med Suspend',
      'searchHint': 'Buscar medicamento ou condição...',
      'consentTitle': 'Termo de Consentimento',
      'consentContent':
      'Este aplicativo é destinado exclusivamente a profissionais de saúde. As decisões de suspensão ou ajuste de medicamentos devem ser realizadas apenas sob orientação médica direta. A responsabilidade pelas condutas é intransferível.',
      'consentAgree': 'Li e Concordo',
      'bibliographicTitle': 'Fonte Bibliográfica',
      'bibliographicContent':
      'As informações contidas neste aplicativo são baseadas em:\n\n- Diretrizes da Sociedade Brasileira de Anestesiologia.\n- Publicações e manuais do Ministério da Saúde.\n- Guidelines internacionais sobre manejo perioperatório.\n\nObservação: As orientações apresentadas são meramente ilustrativas e não substituem a consulta com um especialista.',
      'close': 'Fechar',
      'suspenderLabel': 'Suspender',
      'riscoLabel': 'Risco',
      'reintroducaoLabel': 'Reintroduzir',
      'warningMessage':
      '⚠️ A suspensão deve ser individualizada conforme o risco clínico. Na ausência de contraindicações claras, considere manter a terapia e solicitar parecer especializado.',
      'observation':'Observação',
      'requestMedication': 'Peça algum medicamento que sentiu falta',
      'noResultsMessage': 'Pesquise o medicamento que deseja informações. Caso não encontre, Solicite a inclusão pelo e-mail: office@mcdoc.app',
      'indicacaoLabel': 'Indicação',
      'interacaoLabel': 'Interações',
    },
    'US': {
      'title': 'Med Suspend',
      'searchHint': 'Search medication or condition...',
      'consentTitle': 'Consent Form',
      'consentContent':
      'This application is intended exclusively for healthcare professionals. Decisions about medication suspension or adjustment should only be made under direct medical supervision. The responsibility for these actions cannot be transferred.',
      'consentAgree': 'I have read and agree',
      'bibliographicTitle': 'Bibliographic Source',
      'bibliographicContent':
      'The information in this application is based on:\n\n- Guidelines from the Brazilian Society of Anesthesiology.\n- Publications and manuals from the Ministry of Health.\n- International guidelines on perioperative management.\n\nNote: The recommendations provided are for illustration purposes only and do not replace consultation with a specialist.',
      'close': 'Close',
      'suspenderLabel': 'Suspend',
      'riscoLabel': 'Risk',
      'reintroducaoLabel': 'Reintroduce',
      'warningMessage':
      '⚠️ Discontinuation should be individualized based on clinical risk. In the absence of clear contraindications, consider maintaining therapy and seeking specialist consultation.',
      'observation':'Observação',
      'requestMedication': 'Request a missing medication',
      'noResultsMessage': 'Search for the medication you want information about. If you did not find it, please request its inclusion via email: office@mcdoc.app',
      'indicacaoLabel': 'Indication',
      'interacaoLabel': 'Drug Interactions',

    },
    'ES': {
      'title': 'Med Suspend',
      'searchHint': 'Buscar medicamento o condición...',
      'consentTitle': 'Formulario de Consentimiento',
      'consentContent':
      'Esta aplicación está destinada exclusivamente a profesionales de la salud. Las decisiones sobre la suspensión o el ajuste de medicamentos deben realizarse únicamente bajo supervisión médica directa. La responsabilidad de estas acciones no es transferible.',
      'consentAgree': 'He leído y estoy de acuerdo',
      'bibliographicTitle': 'Fuente Bibliográfica',
      'bibliographicContent':
      'La información contenida en esta aplicación se basa en:\n\n- Directrices de la Sociedad Brasileña de Anestesiología.\n- Publicaciones y manuales del Ministerio de Salud.\n- Directrices internacionales sobre el manejo perioperatorio.\n\nNota: Las orientaciones ofrecidas son meramente ilustrativas y no reemplazan la consulta con un especialista.',
      'close': 'Cerrar',
      'suspenderLabel': 'Suspender',
      'riscoLabel': 'Riesgo',
      'reintroducaoLabel': 'Reintroducir',
      'warningMessage':
      '⚠️ La suspensión debe individualizarse según el riesgo clínico. En ausencia de contraindicaciones claras, considere mantener la terapia y solicitar la opinión de un especialista.',
      'observation':'Observación',
      'requestMedication': 'Solicita un medicamento faltante',
      'noResultsMessage': 'Busque el medicamento sobre el que desea obtener información. Si no lo encuentra, solicite su inclusión por correo: office@mcdoc.app',
      'indicacaoLabel': 'Indicação',
      'interacaoLabel': 'Interacciones',
    },
    'CH': {
      'title': 'Med Suspend',
      'searchHint': '搜索药物或状况...',
      'consentTitle': '同意书',
      'consentContent':
      '此应用仅供医疗专业人员使用。药物停用或调整的决策应仅在直接的医疗指导下进行。操作责任不可转移。',
      'consentAgree': '我已阅读并同意',
      'bibliographicTitle': '参考文献',
      'bibliographicContent':
      '本应用中的信息基于：\n\n- 巴西麻醉学会指南。\n- 卫生部出版物及手册。\n- 国际围手术期管理指南。\n\n注意：所提供的建议仅供参考，不能替代专家咨询。',
      'close': '关闭',
      'suspenderLabel': '停用',
      'riscoLabel': '风险',
      'reintroducaoLabel': '重新引入或恢复',
      'warningMessage':
      '⚠️ 是否停药应根据临床风险进行个体化评估。在无明确禁忌的情况下，建议继续治疗并咨询相关专科医生。',
      'observation':'观察'
      ,'requestMedication': '请求补充缺失药物',
      'noResultsMessage': '搜索您想了解的药物。如未找到，请通过邮箱请求添加：office@mcdoc.app',
      'indicacaoLabel': 'Indicação',
      'interacaoLabel': '药物相互作用',
    },
  };

  @override
  void initState() {
    super.initState();
    _loadLanguage();
    _loadFavorites();
    _loadMedications();
    _searchController.addListener(_onSearchTextChanged);
    _checkInitialNoticePopup();
    // (removed extra setState listener)
  }

  Future<void> _checkInitialNoticePopup() async {
    final prefs = await SharedPreferences.getInstance();
    final mostrarPopup = prefs.getBool('mostrarPopupInicial') ?? true;

    if (mostrarPopup && mounted) {
      await Future.delayed(const Duration(milliseconds: 500)); // pequena espera após build
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          bool dontShowAgain = false;

          String getMessage(String lang) {
            return {
              'PT': 'ATENÇÃO: Este aplicativo foi desenvolvido com foco em profissionais da área cirúrgica.\n\nTodas as informações relacionadas à suspensão de medicamentos devem ser analisadas com base em avaliação individualizada de risco e benefício, conforme o contexto clínico de cada paciente.\n\nAs condutas aqui apresentadas possuem caráter consultivo e não substituem o julgamento médico, a experiência profissional ou protocolos institucionais. O uso deste aplicativo não isenta o profissional de saúde de sua responsabilidade ética, técnica e legal.',
              'US': 'WARNING: This application was developed for use by professionals in the surgical field.\n\nAll information regarding medication suspension must be carefully assessed on a case-by-case basis, considering individual clinical context and the risk-benefit ratio.\n\nThe recommendations are consultative in nature and do not replace medical judgment, professional experience, or institutional protocols. The use of this application does not exempt healthcare professionals from their ethical, technical, or legal responsibilities.',
              'ES': 'ADVERTENCIA: Esta aplicación fue desarrollada para su uso por profesionales del área quirúrgica.\n\nToda información relacionada con la suspensión de medicamentos debe ser evaluada cuidadosamente según el contexto clínico individual y la relación riesgo-beneficio.\n\nLas recomendaciones presentadas tienen carácter consultivo y no sustituyen el juicio médico, la experiencia profesional ni los protocolos institucionales. El uso de esta aplicación no exime al profesional de la salud de sus responsabilidades éticas, técnicas o legales.',
              'CH': '警告：本应用程序专为外科领域的专业人员设计。\n\n关于药物停用的所有信息应根据每位患者的具体临床情况，结合风险与收益进行个体化评估。\n\n本应用中的建议仅供参考，不能替代医学判断、专业经验或机构制定的临床指南。使用本应用程序并不免除医疗专业人员在伦理、技术和法律方面的责任。'
            }[selectedLanguage]!;
          }

          String getCheckboxLabel(String lang) {
            return {
              'PT': 'Não mostrar novamente',
              'US': 'Do not show again',
              'ES': 'No mostrar de nuevo',
              'CH': '不再显示'
            }[selectedLanguage]!;
          }

          String getButtonLabel(String lang) {
            return {
              'PT': 'Entendi',
              'US': 'I Understand',
              'ES': 'Entendido',
              'CH': '我明白了'
            }[selectedLanguage]!;
          }

          return AlertDialog(
            title: const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 36),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    getMessage(selectedLanguage),
                    style: const TextStyle(fontSize: 15),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      StatefulBuilder(
                        builder: (context, setState) {
                          return Checkbox(
                            value: dontShowAgain,
                            onChanged: (val) => setState(() => dontShowAgain = val ?? false),
                          );
                        },
                      ),
                      Expanded(child: Text(getCheckboxLabel(selectedLanguage), style: const TextStyle(fontSize: 13))),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  if (dontShowAgain) {
                    await prefs.setBool('mostrarPopupInicial', false);
                  }
                  Navigator.of(context).pop();
                },
                child: Text(getButtonLabel(selectedLanguage)),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _loadLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? lang = prefs.getString('selected_language');
    if (lang != null && translations.containsKey(lang)) {
      setState(() {
        selectedLanguage = lang;
      });
    }
  }

  Future<void> _loadFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final favs = prefs.getStringList('favoritos') ?? [];
    setState(() => favoriteMeds = favs.toSet());
    final expandedList = prefs.getStringList('expandedItems') ?? [];
    setState(() => expandedTiles = expandedList.toSet());
  }

  Future<void> _saveFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favoritos', favoriteMeds.toList());
  }

  Future<void> _saveLanguage(String lang) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', lang);
    setState(() {
      selectedLanguage = lang;
    });
  }

  /// Carrega medicamentos exclusivamente da pasta 'assets/bulas/medicamentos/' e injeta alerta quando necessário
  Future<void> _loadMedications() async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);
    final List<String> _exclusionKeywords = [
      // Termos a ser retirado //
      // pode expandir aqui com outras expressões que deseje bloquear
    ];
    // Garante que somente arquivos da pasta 'assets/bulas/medicamentos/' sejam utilizados
    final medicationFiles = manifestMap.keys
        .where((String key) => key.contains('assets/bulas/medicamentos/') && key.endsWith('.json'))
        .toList();

    List<Map<String, dynamic>> tempList = [];

    for (String path in medicationFiles) {
      // O path já é garantido ser da pasta 'assets/bulas/medicamentos/' e terminar com .json
      final String content = await rootBundle.loadString(path);
      final Map<String, dynamic> jsonData = json.decode(content);
      final contentLower = content.toLowerCase();
      bool shouldExclude = _exclusionKeywords.any((kw) => contentLower.contains(kw));
      if (shouldExclude) continue;

      if (jsonData[selectedLanguage] != null) {
        Map<String, dynamic> medData = Map<String, dynamic>.from(jsonData[selectedLanguage]);
        final String name = medData['external']['name'];
        medData['isFavorite'] = favoriteMeds.contains(name);

        // Adiciona nome do princípio ativo em PT, se existir (usando função auxiliar)
        medData['ptActiveIngredient'] = extractPtActiveIngredient(jsonData, appLanguage);

        // Verifica palavras‑chave em todo o JSON bruto
        final rawLower = content.toLowerCase();
        bool hasAlert = alertKeywords.any((kw) => rawLower.contains(kw));
        if (hasAlert) {
          medData['warning'] = translations[selectedLanguage]!['warningMessage'];
        }

        // Calcula e armazena o índice de busca normalizado
        final ext = (medData['external'] as Map<String, dynamic>?) ?? {};
        final bul = (medData['bulario'] as Map<String, dynamic>?) ?? {};
        final warning = medData['warning']?.toString() ?? '';
        final ptName = medData['ptActiveIngredient']?.toString() ?? '';
        final searchContent = [
          ...ext.values.map((e) => e?.toString() ?? ''),
          ...bul.values.map((e) => e?.toString() ?? ''),
          warning,
          ptName
        ].join(' ').toLowerCase();
        final contentNorm = removeDiacritics(searchContent);
        medData['searchIndex'] = contentNorm;

        tempList.add(medData);
      }
    }

    // Ordena alfabeticamente pelo nome
    tempList.sort((a, b) {
      final bool aFav = a['isFavorite'] == true;
      final bool bFav = b['isFavorite'] == true;

      // Primeiro, coloca os favoritos no topo
      if (aFav && !bFav) return -1;
      if (!aFav && bFav) return 1;

      // Depois, ordena em ordem alfabética
      final String nameA = a['external']['name'];
      final String nameB = b['external']['name'];
      return nameA.toLowerCase().compareTo(nameB.toLowerCase());
    });

    final favoriteList = tempList.where((med) => med['isFavorite'] == true).toList();

    setState(() {
      medications = tempList;
      filteredMedications = favoriteList;
    });
  }

  // -- Debounced search handler --------------------------------------------
  void _onSearchTextChanged() {
    // wait 250 ms after the user stops typing before filtering
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), _filterSearch);
  }

  void _filterSearch() {
    String query = removeDiacritics(_searchController.text.toLowerCase());
    final bool useFuzzy = query.length > 2;   // avoid heavy Levenshtein on very short queries
    setState(() {
      // expandedTiles.clear(); // Removido para manter menus expandidos após busca
      if (query.trim().isEmpty) {
        filteredMedications = medications.where((med) => favoriteMeds.contains(med['external']['name'])).toList();
        return;
      }
      filteredMedications = medications.where((med) {
        final ext = (med['external'] as Map<String, dynamic>?) ?? {};
        final searchIndex = med['searchIndex']?.toString() ?? '';
        final name = removeDiacritics((ext['name'] ?? '').toString().toLowerCase());

        if (name.contains(query)) return true;
        return searchIndex.contains(query) || (useFuzzy && levenshteinDistance(query, searchIndex) <= 3);
      }).toList()
        ..sort((a, b) {
          final aName = removeDiacritics((a['external']['name'] ?? '').toString().toLowerCase());
          final bName = removeDiacritics((b['external']['name'] ?? '').toString().toLowerCase());
          final queryNorm = removeDiacritics(query);

          // Mais parecido com a string digitada vem primeiro
          final aScore = aName.startsWith(queryNorm) ? 0 : (aName.contains(queryNorm) ? 1 : 2);
          final bScore = bName.startsWith(queryNorm) ? 0 : (bName.contains(queryNorm) ? 1 : 2);
          return aScore.compareTo(bScore);
        });
    });
  }

  void _toggleFavorite(String name) async {
    setState(() {
      if (favoriteMeds.contains(name)) {
        favoriteMeds.remove(name);
      } else {
        favoriteMeds.add(name);
      }
    });
    await _saveFavorites();
    _loadMedications(); // Para reordenar lista com favoritos no topo
  }

  void _navigateToDetailsPage(Map<String, dynamic> med) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MedicationDetailsPage(
          medication: med,
          selectedLanguage: selectedLanguage,
        ),
      ),
    );
  }




  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: translations[selectedLanguage]!['title']!.contains('MC')
          ? AppBar(
              leading: const SizedBox(),
              title: Text(translations[selectedLanguage]!['title']!),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.link),
                  tooltip: 'Links úteis e outros apps',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
                        final String linksTitle = {
                          'PT': 'Apps Relacionados',
                          'US': 'Related Apps',
                          'ES': 'Aplicaciones Relacionadas',
                          'CH': '相关应用程序',
                        }[selectedLanguage]!;
                        return AlertDialog(
                          title: Text(linksTitle),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (selectedLanguage == 'PT') ...[
                                TextButton.icon(
                                  icon: const Icon(Icons.open_in_new),
                                  label: Text(isIOS ? 'Med Calc (iOS)' : 'Med Calc (Android)'),
                                  onPressed: () async {
                                    final url = isIOS
                                        ? 'https://apps.apple.com/app/id6453359266'
                                        : 'https://play.google.com/store/apps/details?id=com.companyname.medcalc&hl=pt';
                                    if (await canLaunchUrl(Uri.parse(url))) {
                                      await launchUrl(Uri.parse(url));
                                    }
                                  },
                                ),
                                TextButton.icon(
                                  icon: const Icon(Icons.open_in_new),
                                  label: const Text('Manual SBA'),
                                  onPressed: () async {
                                    const url = 'https://www.sbahq.org/guias-e-manuais/';
                                    if (await canLaunchUrl(Uri.parse(url))) {
                                      await launchUrl(Uri.parse(url));
                                    }
                                  },
                                ),
                              ] else if (selectedLanguage == 'US') ...[
                                TextButton.icon(
                                  icon: const Icon(Icons.open_in_new),
                                  label: Text(isIOS ? 'Clinical Anesthesia (Barash) (iOS)' : 'Clinical Anesthesia (Barash) (Android)'),
                                  onPressed: () async {
                                    final url = isIOS
                                        ? 'https://apps.apple.com/us/app/clinical-anesthesia/id1530748863'
                                        : 'https://play.google.com/store/apps/details?id=com.mhmedical.clinicalanesthesia8e&hl=en';
                                    if (await canLaunchUrl(Uri.parse(url))) {
                                      await launchUrl(Uri.parse(url));
                                    }
                                  },
                                ),
                                TextButton.icon(
                                  icon: const Icon(Icons.open_in_new),
                                  label: Text(isIOS ? 'FDA Drug Database (iOS)' : 'FDA Drug Database (Android)'),
                                  onPressed: () async {
                                    const url = 'https://www.fda.gov/drugs';
                                    if (await canLaunchUrl(Uri.parse(url))) {
                                      await launchUrl(Uri.parse(url));
                                    }
                                  },
                                ),
                              ] else if (selectedLanguage == 'ES') ...[
                                TextButton.icon(
                                  icon: const Icon(Icons.open_in_new),
                                  label: Text(isIOS ? 'AEMPS - Agencia Española (iOS)' : 'AEMPS - Agencia Española (Android)'),
                                  onPressed: () async {
                                    final url = isIOS
                                        ? 'https://apps.apple.com/es/app/aemps-cima/id1473940172'
                                        : 'https://play.google.com/store/apps/details?id=es.aemps.cima&hl=es';
                                    if (await canLaunchUrl(Uri.parse(url))) {
                                      await launchUrl(Uri.parse(url));
                                    }
                                  },
                                ),
                                TextButton.icon(
                                  icon: const Icon(Icons.open_in_new),
                                  label: Text(isIOS ? 'Manual Farmacología Clínica (iOS)' : 'Manual Farmacología Clínica (Android)'),
                                  onPressed: () async {
                                    final url = isIOS
                                        ? 'https://apps.apple.com/es/app/manual-farmacologia-clinica/id1519551192'
                                        : 'https://www.adamedinstitute.org/manual-farmacologia-clinica/';
                                    if (await canLaunchUrl(Uri.parse(url))) {
                                      await launchUrl(Uri.parse(url));
                                    }
                                  },
                                ),
                              ] else if (selectedLanguage == 'CH') ...[
                                TextButton.icon(
                                  icon: const Icon(Icons.open_in_new),
                                  label: Text(isIOS ? '国家药品监督管理局 (iOS)' : '国家药品监督管理局 (Android)'),
                                  onPressed: () async {
                                    const url = 'https://www.nmpa.gov.cn/';
                                    if (await canLaunchUrl(Uri.parse(url))) {
                                      await launchUrl(Uri.parse(url));
                                    }
                                  },
                                ),
                                TextButton.icon(
                                  icon: const Icon(Icons.open_in_new),
                                  label: Text(isIOS ? '中国药典数据库 (iOS)' : '中国药典数据库 (Android)'),
                                  onPressed: () async {
                                    const url = 'https://dbpub.cnki.net/grid2008/index/ZGKYZT';
                                    if (await canLaunchUrl(Uri.parse(url))) {
                                      await launchUrl(Uri.parse(url));
                                    }
                                  },
                                ),
                              ],
                            ],
                          ),
                          actions: [
                            TextButton(
                              child: const Text('Fechar'),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            )
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Semantics(
              label: 'Campo de busca de medicamentos ou condições',
              child: TextField(
                controller: _searchController,
                autocorrect: false,
                decoration: InputDecoration(
                  hintText: translations[selectedLanguage]!['searchHint']!,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      FocusScope.of(context).unfocus();
                    },
                  )
                      : null,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                // onTap removed to prevent showing all on focus
              ),
            ),
          ),
          Expanded(
              child: filteredMedications.isEmpty
                  ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        translations[selectedLanguage]!['noResultsMessage']!
                            .replaceAll('office@mcdoc.app', ''), // remove o email fixo da mensagem
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () async {
                          final Uri emailLaunchUri = Uri(
                            scheme: 'mailto',
                            path: 'office@mcdoc.app',
                            query: Uri.encodeFull(
                                'subject=Solicitação de Medicamento ausente - Med Suspend &body=Olá,\n\nGostaria de solicitar a inclusão de um medicamento que não encontrei no aplicativo Med Suspend.'),
                          );
                          if (await canLaunchUrl(emailLaunchUri)) {
                            await launchUrl(emailLaunchUri);
                          }
                        },
                        child: const Text(
                          'office@mcdoc.app',
                          style: TextStyle(
                            color: Colors.blueGrey,
                            decoration: TextDecoration.underline,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
                  : ListView.builder(
                itemCount: filteredMedications.length,
                itemBuilder: (context, index) {
                  final med = filteredMedications[index];
                  final ext = med['external'] as Map<String, dynamic>;
                  final bul = med['bulario'] as Map<String, dynamic>? ?? {};
                  final String name = ext['name'];
                  bool isExpanded = expandedTiles.contains(name);

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                    color: const Color(0xFFF0F4F8),
                    child: ExpansionTile(
                      key: PageStorageKey(name), // preserves expansion state when scrolling
                      leading: const Icon(Icons.medication_outlined, color: Colors.blueGrey),
                      title: Text(
                        name,
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              med['isFavorite'] == true ? Icons.star : Icons.star_border,
                              color: med['isFavorite'] == true
                                  ? Colors.amber
                                  : Colors.blueGrey.shade300,
                            ),
                            onPressed: () => _toggleFavorite(name),
                            tooltip: 'Favorito',
                          ),
                          IconButton(
                            icon: const Icon(Icons.info_outline),
                            tooltip: 'Ver detalhes',
                            onPressed: () => _navigateToDetailsPage(med),
                          ),
                          AnimatedRotation(
                            turns: isExpanded ? 0.5 : 0.0,
                            duration: const Duration(milliseconds: 200),
                            child: const Icon(Icons.keyboard_arrow_down),
                          ),
                        ],
                      ),
                      onExpansionChanged: (val) async {
                        final prefs = await SharedPreferences.getInstance();
                        setState(() {
                          if (val) {
                            expandedTiles.add(name);
                          } else {
                            expandedTiles.remove(name);
                          }
                        });
                        await prefs.setStringList('expandedItems', expandedTiles.toList());
                      },
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildField(
                                  translations[selectedLanguage]!['suspenderLabel']!,
                                  ext['suspension']),
                              _buildField(
                                  translations[selectedLanguage]!['indicacaoLabel']!,
                                  bul['indicacoes']),
                              _buildField(
                                  translations[selectedLanguage]!['riscoLabel']!,
                                  ext['risk']),
                              _buildField(
                                  translations[selectedLanguage]!['interacaoLabel']!,
                                  bul['interacaoMedicamento']),
                              _buildField(
                                  translations[selectedLanguage]!['reintroducaoLabel']!,
                                  ext['reintroduction']),
                              if (med.containsKey('warning'))
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    med['warning'],
                                    style: const TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: Colors.red,
                                    ),
                                    textAlign: TextAlign.justify,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              )
          ),
        ],

      ),
    );
  }
}
Widget _buildField(String label, dynamic value) {
  if (value == null || value.toString().trim().isEmpty) return const SizedBox.shrink();

  return Padding(
    padding: const EdgeInsets.only(top: 6.0),
    child: RichText(
      textAlign: TextAlign.justify,
      text: TextSpan(
        style: const TextStyle(fontSize: 15, color: Colors.black87),
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF102A43), // azul MC
            ),
          ),
          TextSpan(
            text: value.toString().trim(),
          ),
        ],
      ),
    ),
  );
}

class MedicationDetailsPage extends StatelessWidget {
  final Map<String, dynamic> medication;
  final String selectedLanguage;

  const MedicationDetailsPage({
    super.key,
    required this.medication,
    required this.selectedLanguage,
  });

  Map<String, String> getLocalizedLabels(String lang) {
    // ... (mantém a implementação existente)
    switch (lang) {
      case 'PT':
        return {
          'nomePrincipioAtivo': 'Nome do Princípio Ativo',
          'nomeComercial': 'Nome Comercial',
          'mecanismoAcao': 'Mecanismo de Ação',
          'farmacocinetica': 'Farmacocinética',
          'farmacodinamica': 'Farmacodinâmica',
          'indicacoes': 'Indicações',
          'reacoesAdversas': 'Reações Adversas',
          'riscoGravidez': 'Risco na Gravidez',
          'riscoLactacao': 'Risco na Lactação',
          'administracao': 'Administração',
          'doseMaxima': 'Dose Máxima',
          'doseMinima': 'Dose Mínima',
          'classificacao': 'Classificação',
          'apresentacao': 'Apresentação',
          'interacaoMedicamento': 'Interação Medicamentosa',
          'posologia': 'Posologia',
          'armazenamento': 'Armazenamento',
          'preparo': 'Preparo / Reconstituição / Diluição',
          'solucoesCompatíveis': 'Soluções Compatíveis',
          'contraindicacoes': 'Contraindicações',
          'cuidadosMedicos': 'Cuidados Médicos',
          'cuidadosFarmaceuticos': 'Cuidados Farmacêuticos',
          'cuidadosEnfermagem': 'Cuidados da Enfermagem',
          'fontesBibliograficas': 'Fontes Bibliográficas'
        };
      case 'US':
        return {
          'nomePrincipioAtivo': 'Active Ingredient',
          'nomeComercial': 'Brand Name',
          'mecanismoAcao': 'Mechanism of Action',
          'farmacocinetica': 'Pharmacokinetics',
          'farmacodinamica': 'Pharmacodynamics',
          'indicacoes': 'Indications',
          'reacoesAdversas': 'Adverse Reactions',
          'riscoGravidez': 'Pregnancy Risk',
          'riscoLactacao': 'Lactation Risk',
          'administracao': 'Administration',
          'doseMaxima': 'Maximum Dose',
          'doseMinima': 'Minimum Dose',
          'classificacao': 'Classification',
          'apresentacao': 'Presentation',
          'interacaoMedicamento': 'Drug Interactions',
          'posologia': 'Dosage',
          'armazenamento': 'Storage',
          'preparo': 'Preparation / Reconstitution / Dilution',
          'solucoesCompatíveis': 'Compatible Solutions',
          'contraindicacoes': 'Contraindications',
          'cuidadosMedicos': 'Medical Precautions',
          'cuidadosFarmaceuticos': 'Pharmaceutical Precautions',
          'cuidadosEnfermagem': 'Nursing Care',
          'fontesBibliograficas': 'Bibliographic Sources'
        };
      case 'ES':
        return {
          'nomePrincipioAtivo': 'Nombre del Principio Activo',
          'nomeComercial': 'Nombre Comercial',
          'mecanismoAcao': 'Mecanismo de Acción',
          'farmacocinetica': 'Farmacocinética',
          'farmacodinamica': 'Farmacodinámica',
          'indicacoes': 'Indicaciones',
          'reacoesAdversas': 'Reacciones Adversas',
          'riscoGravidez': 'Riesgo en el Embarazo',
          'riscoLactacao': 'Riesgo en la Lactancia',
          'administracao': 'Administración',
          'doseMaxima': 'Dosis Máxima',
          'doseMinima': 'Dosis Mínima',
          'classificacao': 'Clasificación',
          'apresentacao': 'Presentación',
          'interacaoMedicamento': 'Interacción Medicamentosa',
          'posologia': 'Posología',
          'armazenamento': 'Almacenamiento',
          'preparo': 'Reconstitución / Dilución',
          'solucoesCompatíveis': 'Soluciones Compatibles',
          'contraindicacoes': 'Contraindications',
          'cuidadosMedicos': 'Cuidados Médicos',
          'cuidadosFarmaceuticos': 'Cuidados Farmacéuticos',
          'cuidadosEnfermagem': 'Cuidados de Enfermería',
          'fontesBibliograficas': 'Fuentes Bibliográficas'
        };
      case 'CH':
        return {
          'nomePrincipioAtivo': '活性成分名称',
          'nomeComercial': '商品名称',
          'mecanismoAcao': '作用机制',
          'farmacocinetica': '药代动力学',
          'farmacodinamica': '药效学',
          'indicacoes': '适应症',
          'reacoesAdversas': '不良反应',
          'riscoGravidez': '妊娠风险',
          'riscoLactacao': '哺乳风险',
          'administracao': '给药途径',
          'doseMaxima': '最大剂量',
          'doseMinima': '最小剂量',
          'classificacao': '分类',
          'apresentacao': '药物形式',
          'interacaoMedicamento': '药物相互作用',
          'posologia': '剂量说明',
          'armazenamento': '储存条件',
          'preparo': '准备/重组/稀释',
          'solucoesCompatíveis': '兼容溶液',
          'contraindicacoes': '禁忌症',
          'cuidadosMedicos': '医疗注意事项',
          'cuidadosFarmaceuticos': '药学注意事项',
          'cuidadosEnfermagem': '护理注意事项',
          'fontesBibliograficas': '参考资料'
        };
      default:
        return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    final ext = medication['external'] as Map<String, dynamic>;
    final bul = medication['bulario'] as Map<String, dynamic>;
    final labels = getLocalizedLabels(selectedLanguage);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF102A43),
        title: Text(
          ext['name'] ?? 'Detalhes',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.menu_book_outlined, color: Colors.white),
            label: Text(
              selectedLanguage == 'PT'
                  ? 'Referência'
                  : selectedLanguage == 'US'
                  ? 'Reference'
                  : selectedLanguage == 'ES'
                  ? 'Referencia'
                  : '参考资料',
              style: const TextStyle(color: Colors.white),
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  final _refStyle = const TextStyle(fontSize: 14, fontWeight: FontWeight.w600);
                  return AlertDialog(
                    title: Text(
                      selectedLanguage == 'PT'
                          ? 'Fontes e Referências'
                          : selectedLanguage == 'US'
                          ? 'References & Sources'
                          : selectedLanguage == 'ES'
                          ? 'Fuentes y Referencias'
                          : '参考资料与引用',
                    ),
                    content: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (selectedLanguage == 'PT') ...[
                            Text('• Sociedade Brasileira de Anestesiologia (SBA)', style: _refStyle),
                            _buildLink('https://www.sbahq.org/', context),
                            const SizedBox(height: 6),
                            Text('• Bula Eletrônica ANVISA', style: _refStyle),
                            _buildLink('https://bulario.anvisa.gov.br/', context),
                            const SizedBox(height: 6),
                            Text('• SciELO Brasil — Literatura científica em saúde', style: _refStyle),
                            _buildLink('https://www.scielo.br/', context),
                            const SizedBox(height: 6),
                            Text('• Ministério da Saúde — Protocolos Clínicos e Diretrizes Terapêuticas', style: _refStyle),
                            _buildLink('https://www.gov.br/saude/', context),
                          ]
                          else if (selectedLanguage == 'US') ...[
                            Text('• FDA — U.S. Food and Drug Administration', style: _refStyle),
                            _buildLink('https://www.fda.gov/drugs/drug-approvals-and-databases', context),
                            const SizedBox(height: 6),
                            Text('• PubMed — National Library of Medicine', style: _refStyle),
                            _buildLink('https://pubmed.ncbi.nlm.nih.gov/', context),
                            const SizedBox(height: 6),
                            Text('• UpToDate — Clinical Decision Support', style: _refStyle),
                            _buildLink('https://www.uptodate.com/', context),
                            const SizedBox(height: 6),
                            Text('• Micromedex — Drug Reference Database', style: _refStyle),
                            _buildLink('https://www.micromedexsolutions.com/', context),
                          ]
                          else if (selectedLanguage == 'ES') ...[
                              Text('• Agencia Española de Medicamentos y Productos Sanitarios (AEMPS)', style: _refStyle),
                              _buildLink('https://www.aemps.gob.es/', context),
                              const SizedBox(height: 6),
                              Text('• Sociedad Española de Farmacia Hospitalaria (SEFH)', style: _refStyle),
                              _buildLink('https://www.sefh.es/', context),
                              const SizedBox(height: 6),
                              Text('• Portal de Salud Castilla y León', style: _refStyle),
                              _buildLink('https://www.saludcastillayleon.es/', context),
                              const SizedBox(height: 6),
                              Text('• SciELO España — Publicaciones biomédicas', style: _refStyle),
                              _buildLink('https://scielo.isciii.es/', context),
                            ]
                            else if (selectedLanguage == 'CH') ...[
                                Text('• 国家药监局 (NMPA) — 国家药品监督管理局', style: _refStyle),
                                _buildLink('https://www.nmpa.gov.cn/', context),
                                const SizedBox(height: 6),
                                Text('• DailyMed — 美国药品说明书数据库', style: _refStyle),
                                _buildLink('https://dailymed.nlm.nih.gov/dailymed/', context),
                                const SizedBox(height: 6),
                                Text('• CKCEST — 中国工程科技知识中心', style: _refStyle),
                                _buildLink('https://www.ckcest.cn/', context),
                                const SizedBox(height: 6),
                                Text('• 中国药物临床试验登记与信息公示平台', style: _refStyle),
                                _buildLink('https://www.chinadrugtrials.org.cn/', context),
                              ],
                          // NOVO BLOCO: Referências Bibliográficas Acadêmicas
                          const SizedBox(height: 12),
                          Text(
                            selectedLanguage == 'PT'
                                ? '📚 Referências Bibliográficas:'
                                : selectedLanguage == 'US'
                                ? '📚 Bibliographic References:'
                                : selectedLanguage == 'ES'
                                ? '📚 Referencias Bibliográficas:'
                                : '📚 参考文献：',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          if (selectedLanguage == 'PT') ...[
                            Text('- Sociedade Brasileira de Anestesiologia. Manual de Condutas em Anestesiologia. 2023.'),
                            Text('- Ministério da Saúde. Diretrizes e Protocolos de Medicamentos no Perioperatório.'),
                            Text('- OMC. Guia Farmacológico de Medicamentos Hospitalares.'),
                            Text('- Barash PG et al. Fundamentos de Anestesiologia Clínica. 1ª ed. Elsevier.'),
                            Text('- Miller RD. Anestesia. 8ª ed. Elsevier.'),
                          ] else if (selectedLanguage == 'US') ...[
                            Text('- Barash PG, Cullen BF, Stoelting RK. Clinical Anesthesia. 8th ed. Wolters Kluwer.'),
                            Text('- Miller RD. Miller’s Anesthesia. 8th ed. Elsevier.'),
                            Text('- Katzung BG. Basic and Clinical Pharmacology. 15th ed. McGraw-Hill.'),
                            Text('- ACC/AHA Perioperative Guidelines.'),
                            Text('- UpToDate: Medication Management in the Perioperative Period.'),
                          ] else if (selectedLanguage == 'ES') ...[
                            Text('- Sociedad Española de Anestesiología. Manual de Procedimientos Clínicos.'),
                            Text('- Ministerio de Sanidad. Guías Farmacológicas y Protocolos Clínicos.'),
                            Text('- López-Muñoz F. Manual de Farmacología Clínica.'),
                            Text('- Barash PG et al. Fundamentos de Anestesiología Clínica. 1ª ed. Elsevier.'),
                            Text('- Miller RD. Anestesia. 8ª ed. Elsevier.'),
                          ] else if (selectedLanguage == 'CH') ...[
                            Text('- 《麻醉学》 Miller RD. 第8版，Elsevier出版社'),
                            Text('- 《围术期用药管理指南》 国家卫生健康委员会'),
                            Text('- 《药理学》 北京大学医学出版社，第9版'),
                            Text('- 《中国药典》 2020版，国家药品监督管理局'),
                            Text('- 《临床麻醉学》 Barash PG等著，第1版'),
                          ],
                          const SizedBox(height: 12),
                          if (bul['fontesBibliograficas'] != null)
                            Text(
                              bul['fontesBibliograficas'],
                              style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
                              textAlign: TextAlign.justify,
                            ),
                          const SizedBox(height: 16),
                          if (selectedLanguage == 'US') ...[
                            Text(
                              'Responsible Physician: Dr. Bruno Henrique Daroz — Anesthesiologist — CREMESP - BR 230005 — RQE 98917',
                              style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: Colors.black87),
                              textAlign: TextAlign.left,
                            ),
                          ] else if (selectedLanguage == 'ES') ...[
                            Text(
                              'Responsable Técnico: Dr. Bruno Henrique Daroz — Médico Anestesiólogo — CREMESP - BR 230005 — RQE 98917',
                              style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: Colors.black87),
                              textAlign: TextAlign.left,
                            ),
                          ] else if (selectedLanguage == 'CH') ...[
                            Text(
                              '医学顾问：Bruno Henrique Daroz 医生 — 麻醉科医生 — 注册编号 CREMESP - BR 230005 — 专科认证 RQE 98917',
                              style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: Colors.black87),
                              textAlign: TextAlign.left,
                            ),
                          ],
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Fechar'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (medication.containsKey('warning'))
            Container(
              width: double.infinity,
              color: Colors.amber.shade100,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Text(
                medication['warning'],
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: bul.entries.map((entry) {
                  final key = entry.key;
                  final value = entry.value;
                  final label = labels[key] ?? key;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16.0),
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          value.toString(),
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }



  /// Helper para construir links clicáveis
  Widget _buildLink(String url, BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Não foi possível abrir $url')),
            );
          }
        }
      },
      child: Text(
        url,
        style: const TextStyle(
          fontSize: 15,
          color: Colors.blue,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}

// Função para calcular a distância de Levenshtein entre duas strings
int levenshteinDistance(String s, String t) {
  if (s == t) return 0;
  if (s.isEmpty) return t.length;
  if (t.isEmpty) return s.length;

  List<List<int>> d = List.generate(
    s.length + 1,
        (_) => List.filled(t.length + 1, 0),
  );

  for (int i = 0; i <= s.length; i++) d[i][0] = i;
  for (int j = 0; j <= t.length; j++) d[0][j] = j;

  for (int i = 1; i <= s.length; i++) {
    for (int j = 1; j <= t.length; j++) {
      final cost = s[i - 1] == t[j - 1] ? 0 : 1;
      d[i][j] = [
        d[i - 1][j] + 1,
        d[i][j - 1] + 1,
        d[i - 1][j - 1] + cost
      ].reduce((a, b) => a < b ? a : b);
    }
  }

  return d[s.length][t.length];
}


// Função auxiliar para remover acentuação (diacríticos)
String removeDiacritics(String str) {
  const withDiacritics = 'áàâãäçéèêëíìîïñóòôõöúùûüýÿÁÀÂÃÄÇÉÈÊËÍÌÎÏÑÓÒÔÕÖÚÙÛÜÝ';
  const withoutDiacritics = 'aaaaaceeeeiiiinooooouuuuyyAAAAACEEEEIIIINOOOOOUUUUY';

  for (int i = 0; i < withDiacritics.length; i++) {
    str = str.replaceAll(withDiacritics[i], withoutDiacritics[i]);
  }
  return str;
}
