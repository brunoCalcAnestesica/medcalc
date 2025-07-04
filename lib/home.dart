import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'shared_data.dart';
import 'formatters.dart';
import 'fisiologia.dart';
import 'drogas.dart';
import 'pcr.dart';
import 'inducao.dart';
import 'medsuspense.dart';



class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class MinhaPagina extends StatelessWidget {
  const MinhaPagina({super.key});

  void _enviarFeedback() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'bhdaroz@gmail.com',
      queryParameters: {
        'subject': 'Feedback sobre o MedCalc',
        'body': 'Queremos saber sua opinião. Ajude-nos a melhorar!'
      },
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      throw 'Não foi possível abrir o cliente de e-mail.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MedCalc'),
        actions: [
          IconButton(
            icon: const Icon(Icons.mail_outline,color: Colors.white,),
            tooltip: 'Queremos saber sua opinião. Ajude-nos a melhorar.',
            onPressed: () async {
              final Uri emailUri = Uri(
                scheme: 'mailto',
                path: 'bhdaroz@gmail.com',
                query: Uri.encodeFull(
                  'subject=Feedback sobre o MedCalc&body=Olá,\n\nQueremos saber sua opinião. Ajude-nos a melhorar o aplicativo MedCalc!',
                ),
              );
              if (await canLaunchUrl(emailUri)) {
                await launchUrl(emailUri);
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Não foi possível abrir o aplicativo de e-mail.')),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Conteúdo da página'),
      ),
    );
  }
}


class _HomePageState extends State<HomePage> {
  int _currentIndex = 0; // <<< ESSA LINHA AQUI CORRIGE TUDO!

  final TextEditingController _pesoAtualController = TextEditingController();
  final TextEditingController _alturaController = TextEditingController();
  final TextEditingController _idadeController = TextEditingController();

  String _idadeTipo = 'anos'; // 'dias', 'meses', 'anos'
  String? _faixaEtaria;
  String _sexoSelecionado = 'Masculino';

  void _atualizarDados() {
    double? idadeBruta = double.tryParse(_idadeController.text.replaceAll(',', '.'));
    double? pesoBruto = double.tryParse(_pesoAtualController.text.replaceAll(',', '.'));
    double? alturaBruta = double.tryParse(_alturaController.text.replaceAll(',', '.'));



    setState(() {
      if (idadeBruta == null || pesoBruto == null || alturaBruta == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, preencha todos os campos corretamente.'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      // Peso e Altura
      SharedData.peso = pesoBruto;
      SharedData.altura = alturaBruta;

      // Idade convertida
      if (_idadeTipo == 'dias') {
        SharedData.idade = idadeBruta / 365.0;
      } else if (_idadeTipo == 'meses') {
        SharedData.idade = idadeBruta / 12.0;
      } else {
        SharedData.idade = idadeBruta;
      }

      // Sexo e tipo de idade
      SharedData.sexo = _sexoSelecionado;
      SharedData.idadeTipo = _idadeTipo;

      // Faixa etária
      _faixaEtaria = SharedData.faixaEtaria;

      // Salvar no dispositivo
      _savePacientePreferences();

      // Ir para próxima aba
      _currentIndex = 1;
    });
  }



  Future<void> _savePacientePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble('peso', SharedData.peso ?? 0);
    prefs.setDouble('altura', SharedData.altura ?? 0);
    prefs.setDouble('idade', SharedData.idade ?? 0);
    prefs.setString('sexo', SharedData.sexo);
    prefs.setString('idadeTipo', SharedData.idadeTipo);
  }

  @override
  void initState() {
    super.initState();
    _carregarPacientePreferences();
  }

  Future<void> _carregarPacientePreferences() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      SharedData.peso = prefs.getDouble('peso');
      SharedData.altura = prefs.getDouble('altura');
      SharedData.idade = prefs.getDouble('idade');
      SharedData.sexo = prefs.getString('sexo') ?? 'Masculino';
      SharedData.idadeTipo = prefs.getString('idadeTipo') ?? 'anos';

      _pesoAtualController.text = SharedData.peso != null ? SharedData.peso!.round().toString() : '';
      _alturaController.text = SharedData.altura != null ? SharedData.altura!.round().toString() : '';
      _idadeController.text = SharedData.idade != null
          ? _formatarValorIdadeOriginal(SharedData.idade!, SharedData.idadeTipo)
          : '';
      _sexoSelecionado = SharedData.sexo;
      _idadeTipo = SharedData.idadeTipo;
      _faixaEtaria = SharedData.faixaEtaria;
    });
  }

  String _formatarValorIdadeOriginal(double idadeEmAnos, String tipo) {
    if (tipo == 'dias') return (idadeEmAnos * 365).round().toString();
    if (tipo == 'meses') return (idadeEmAnos * 12).round().toString();
    return idadeEmAnos.round().toString();
  }

  @override
  void dispose() {
    _pesoAtualController.dispose();
    _alturaController.dispose();
    _idadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _getTituloAba(_currentIndex).isNotEmpty
            ? Text(
                _getTituloAba(_currentIndex),
                style: const TextStyle(fontWeight: FontWeight.bold),
              )
            : null,
        centerTitle: true,
        backgroundColor: const Color(0xFF102A43),
      ),
      body: Column(
        children: [
          _buildPacienteInfoHeader(),
          Expanded(
            child: [
              FisiologiaPage(key: UniqueKey()),
              DrogasPage(key: UniqueKey()),
              // Farmacoteca substituído por MedSuspensePage
              const MedSuspensePage(),
              const InducaoPage(),
              const PcrPage(),
            ][_currentIndex],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (SharedData.peso == null || SharedData.altura == null || SharedData.idade == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Preencha os dados para continuar.'),
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating,
              ),
            );
            return; // Impede a troca de aba
          }
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          // BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Paciente'), // REMOVIDO
          BottomNavigationBarItem(icon: Icon(Icons.monitor_heart), label: 'Fisiologia'),
          BottomNavigationBarItem(icon: Icon(Icons.medication), label: 'Drogas'),
          BottomNavigationBarItem(
            icon: Icon(Icons.warning_amber_rounded),
            label: 'MedSuspense'
          ),
          BottomNavigationBarItem(icon: Icon(Icons.local_hospital), label: 'Indução'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'PCR'),
        ],
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: 48, bottom: 16),
          child: GestureDetector(
            onTap: _showPacienteFormDialog,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.5),
                border: Border.all(color: Colors.indigo, width: 3),
              ),
              child: const Icon(Icons.calculate, color: Colors.indigo, size: 48),
            ),
          ),
        ),
      ),
    );
  }

  void _showPacienteFormDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Dados do Paciente'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(child: _buildPacienteForm()),
          ),
          actions: [
            TextButton(
              child: const Text('Fechar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  Widget _buildPacienteForm() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 400, // Limita o tamanho para não ficar esticado em telas grandes
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Dados do Paciente',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // << NOVO: Linha com escolha de sexo
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _sexoSelecionado,
                      decoration: const InputDecoration(
                        labelText: 'Sexo',
                        //prefixIcon: Icon(Icons.transgender),
                      ),
                      borderRadius: BorderRadius.circular(10),
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(
                          value: 'Masculino',
                          child: Row(
                            children: [
                              Icon(Icons.male, color: Colors.blue),
                              SizedBox(width: 8),
                              Text('Masculino'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'Feminino',
                          child: Row(
                            children: [
                              Icon(Icons.female, color: Colors.pink),
                              SizedBox(width: 8),
                              Text('Feminino'),
                            ],
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _sexoSelecionado = value!;
                        });

                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // << Peso e altura
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _pesoAtualController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d{0,3}([.,]?\d{0,3})?$')),
                        PesoMaximo200Com3DecimaisFormatter(),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Peso (kg)',
                        prefixIcon: Icon(Icons.monitor_weight),
                      ),
                      onChanged: (value) {
                        setState(() {
                          SharedData.peso = double.tryParse(value.replaceAll(',', '.'));
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _alturaController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d{0,3}([.,]?\d{0,3})?$')),
                        AlturaMaxima220Com3DecimaisFormatter(),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Altura (cm)',
                        prefixIcon: Icon(Icons.height),
                      ),
                      onChanged: (value) {
                        setState(() {
                          SharedData.altura = double.tryParse(value.replaceAll(',', '.'));
                        });
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // << Idade e tipo
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _idadeController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(2), // Máximo de 2 dígitos
                        FilteringTextInputFormatter.digitsOnly, // Apenas números inteiros (sem vírgulas ou pontos)
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Idade',
                        prefixIcon: Icon(Icons.cake),
                      ),
                      onChanged: (value) {
                        setState(() {
                          double? idade = double.tryParse(value);
                          if (idade != null) {
                            if (_idadeTipo == 'dias') {
                              SharedData.idade = idade / 365.0;
                            } else if (_idadeTipo == 'meses') {
                              SharedData.idade = idade / 12.0;
                            } else {
                              SharedData.idade = idade;
                            }
                          }
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _idadeTipo,
                      decoration: const InputDecoration(
                        labelText: 'Tipo',
                        prefixIcon: Icon(Icons.access_time),
                      ),
                      borderRadius: BorderRadius.circular(10),
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: 'dias', child: Text('Dias')),
                        DropdownMenuItem(value: 'meses', child: Text('Meses')),
                        DropdownMenuItem(value: 'anos', child: Text('Anos')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _idadeTipo = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              ElevatedButton.icon(
                onPressed: _atualizarDados,
                icon: const Icon(Icons.check_circle),
                label: const Text('Atualizar Dados'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),

              const SizedBox(height: 20),

              if (_faixaEtaria != null)
                Text(
                  'Faixa Etária: $_faixaEtaria',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 16),
                ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildPacienteInfoHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.indigo.shade100,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildInfoItem('Idade', _formatarIdade()),
          _buildInfoItem('Peso', SharedData.peso != null ? '${SharedData.peso!.round()} kg' : '-'),
          _buildInfoItem('Altura', SharedData.altura != null ? '${SharedData.altura!.round()} cm' : '-'),
          _buildInfoItem('Faixa', SharedData.faixaEtaria),
          _buildSexoInfoItem(),
        ],
      ),
    );
  }

  Widget _buildSexoInfoItem() {
    IconData icon = SharedData.sexo == 'Feminino' ? Icons.female : Icons.male;
    Color color = SharedData.sexo == 'Feminino' ? Colors.pink : Colors.blue;

    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          SharedData.sexo,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }


  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        Text(value, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}

String _formatarIdade() {
  if (SharedData.idade == null) return '-';
  double idade = SharedData.idade!;

  if (SharedData.idadeTipo == 'dias') {
    int dias = (idade * 365).round();
    return '$dias dias';
  } else if (SharedData.idadeTipo == 'meses') {
    int meses = (idade * 12).round();
    return '$meses meses';
  } else {
    return '${idade.round()} anos';
  }
}

String _getTituloAba(int index) {
  switch (index) {
    case 0:
      return 'MC - Fisiologia';
    case 1:
      return 'MC - Drogas';
    case 2:
      return 'MC - Med Suspend';
    case 3:
      return 'MC - Dose de Indução';
    case 4:
      return 'MC - PCR';
    default:
      return '';
  }
}