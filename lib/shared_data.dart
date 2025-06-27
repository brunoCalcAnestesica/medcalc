class SharedData {
  static double? peso;
  static double? altura;
  static double? idade;
  static String sexo = 'Masculino';
  static String idadeTipo = 'anos';

  static int? get idadeEmDias {
    if (idade == null) return null;
    switch (idadeTipo) {
      case 'dias':
        return idade!.round();
      case 'meses':
        return (idade! * 30).round();
      case 'anos':
      default:
        return (idade! * 365).round();
    }
  }

  static String get faixaEtaria {
    final dias = idadeEmDias;
    if (dias == null) return '-';
    if (dias < 30) return 'Recém-nascido';
    if (dias < 365) return 'Lactente';
    if (dias < 365 * 12) return 'Criança';
    if (dias < 365 * 18) return 'Adolescente';
    if (dias < 365 * 60) return 'Adulto';
    return 'Idoso';
  }
}
