import 'package:flutter/material.dart';

enum TipoAnimal { boi, vaca, bezerra, bezerro, novilha }

enum StatusVacina { emDia, atrasada, naoVacinado }

class Vacina {
  final String nome;
  final DateTime dataAplicacao;
  final DateTime? proximaData;
  final String? observacao;

  Vacina({
    required this.nome,
    required this.dataAplicacao,
    this.proximaData,
    this.observacao,
  });

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'dataAplicacao': dataAplicacao.toIso8601String(),
      'proximaData': proximaData?.toIso8601String(),
      'observacao': observacao,
    };
  }

  factory Vacina.fromMap(Map<String, dynamic> map) {
    return Vacina(
      nome: map['nome'],
      dataAplicacao: DateTime.parse(map['dataAplicacao']),
      proximaData: map['proximaData'] != null
          ? DateTime.parse(map['proximaData'])
          : null,
      observacao: map['observacao'],
    );
  }
}

class RegistroCio {
  final DateTime data;
  final String? observacao;
  final DateTime? previsaoProximoCio;

  RegistroCio({required this.data, this.observacao, this.previsaoProximoCio});

  Map<String, dynamic> toMap() {
    return {
      'data': data.toIso8601String(),
      'observacao': observacao,
      'previsaoProximoCio': previsaoProximoCio?.toIso8601String(),
    };
  }

  factory RegistroCio.fromMap(Map<String, dynamic> map) {
    return RegistroCio(
      data: DateTime.parse(map['data']),
      observacao: map['observacao'],
      previsaoProximoCio: map['previsaoProximoCio'] != null
          ? DateTime.parse(map['previsaoProximoCio'])
          : null,
    );
  }
}

class Animal {
  final String id;
  String identificacao;
  TipoAnimal tipo;
  int meses;
  String loteAtual;
  String observacao;
  List<Vacina> vacinas;
  List<RegistroCio> registrosCio; // Nova propriedade
  DateTime dataCadastro;
  DateTime? dataUltimaTransferencia;

  Animal({
    required this.id,
    required this.identificacao,
    required this.tipo,
    required this.meses,
    required this.loteAtual,
    this.observacao = '',
    List<Vacina>? vacinas,
    List<RegistroCio>? registrosCio, // Nova propriedade no construtor
    DateTime? dataCadastro,
    this.dataUltimaTransferencia,
  })  : vacinas = vacinas ?? [],
        registrosCio = registrosCio ?? [],
        dataCadastro = dataCadastro ?? DateTime.now();

  // Getters úteis
  String get tipoString {
    switch (tipo) {
      case TipoAnimal.boi:
        return 'Boi';
      case TipoAnimal.vaca:
        return 'Vaca';
      case TipoAnimal.bezerra:
        return 'Bezerra';
      case TipoAnimal.bezerro:
        return 'Bezerro';
      case TipoAnimal.novilha:
        return 'Novilha';
    }
  }

  // Verifica se o animal é fêmea (pode ter cio)
  bool get podeTerCio {
    return tipo == TipoAnimal.vaca || tipo == TipoAnimal.bezerra;
  }

  // Pega o último registro de cio
  RegistroCio? get ultimoCio {
    if (registrosCio.isEmpty) return null;
    registrosCio.sort((a, b) => b.data.compareTo(a.data));
    return registrosCio.first;
  }

  // Calcula a previsão do próximo cio (ciclo de 21 dias)
  DateTime? get previsaoProximoCio {
    RegistroCio? ultimo = ultimoCio;
    if (ultimo == null) return null;

    // Se há previsão personalizada, usa ela
    if (ultimo.previsaoProximoCio != null) {
      return ultimo.previsaoProximoCio;
    }

    // Senão, calcula baseado no ciclo padrão de 21 dias
    return ultimo.data.add(Duration(days: 21));
  }

  // Status do cio
  String get statusCio {
    if (!podeTerCio) return 'N/A';

    RegistroCio? ultimo = ultimoCio;
    if (ultimo == null) return 'Sem registro';

    DateTime agora = DateTime.now();
    DateTime? previsao = previsaoProximoCio;

    if (previsao == null) return 'Último: ${_formatarData(ultimo.data)}';

    int diasParaProximoCio = previsao.difference(agora).inDays;

    if (diasParaProximoCio < 0) {
      return 'Atrasado (${diasParaProximoCio.abs()} dias)';
    } else if (diasParaProximoCio == 0) {
      return 'Previsto hoje';
    } else if (diasParaProximoCio <= 3) {
      return 'Próximo ($diasParaProximoCio dias)';
    } else {
      return 'Em $diasParaProximoCio dias';
    }
  }

  // Cor do status do cio
  Color get corStatusCio {
    if (!podeTerCio) return Colors.grey;

    RegistroCio? ultimo = ultimoCio;
    if (ultimo == null) return Colors.orange;

    DateTime agora = DateTime.now();
    DateTime? previsao = previsaoProximoCio;

    if (previsao == null) return Colors.blue;

    int diasParaProximoCio = previsao.difference(agora).inDays;

    if (diasParaProximoCio < 0) {
      return Colors.red; // Atrasado
    } else if (diasParaProximoCio <= 3) {
      return Colors.orange; // Próximo
    } else {
      return Colors.green; // Normal
    }
  }

  String get idadeFormatada {
    if (meses < 12) {
      return '$meses ${meses == 1 ? 'mês' : 'meses'}';
    } else {
      int anos = meses ~/ 12;
      int mesesRestantes = meses % 12;
      if (mesesRestantes == 0) {
        return '$anos ${anos == 1 ? 'ano' : 'anos'}';
      } else {
        return '$anos ${anos == 1 ? 'ano' : 'anos'} e $mesesRestantes ${mesesRestantes == 1 ? 'mês' : 'meses'}';
      }
    }
  }

  StatusVacina get statusVacinas {
    if (vacinas.isEmpty) return StatusVacina.naoVacinado;

    DateTime agora = DateTime.now();
    bool temAtrasada = false;

    for (Vacina vacina in vacinas) {
      if (vacina.proximaData != null && vacina.proximaData!.isBefore(agora)) {
        temAtrasada = true;
        break;
      }
    }

    return temAtrasada ? StatusVacina.atrasada : StatusVacina.emDia;
  }

  Color get corStatusVacina {
    switch (statusVacinas) {
      case StatusVacina.emDia:
        return Colors.green;
      case StatusVacina.atrasada:
        return Colors.red;
      case StatusVacina.naoVacinado:
        return Colors.orange;
    }
  }

  String get textoStatusVacina {
    switch (statusVacinas) {
      case StatusVacina.emDia:
        return 'Em dia';
      case StatusVacina.atrasada:
        return 'Atrasada';
      case StatusVacina.naoVacinado:
        return 'Não vacinado';
    }
  }

  // Métodos para manipulação
  void transferirPara(String novoLote) {
    loteAtual = novoLote;
    dataUltimaTransferencia = DateTime.now();
  }

  void adicionarVacina(Vacina vacina) {
    vacinas.add(vacina);
  }

  void removerVacina(int index) {
    if (index >= 0 && index < vacinas.length) {
      vacinas.removeAt(index);
    }
  }

  // Métodos para manipulação do cio
  void adicionarRegistroCio(RegistroCio registro) {
    registrosCio.add(registro);
    // Ordena por data (mais recente primeiro)
    registrosCio.sort((a, b) => b.data.compareTo(a.data));
  }

  void removerRegistroCio(int index) {
    if (index >= 0 && index < registrosCio.length) {
      registrosCio.removeAt(index);
    }
  }

  // Serialização
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'identificacao': identificacao,
      'tipo': tipo.toString(),
      'meses': meses,
      'loteAtual': loteAtual,
      'observacao': observacao,
      'vacinas': vacinas.map((v) => v.toMap()).toList(),
      'registrosCio':
          registrosCio.map((r) => r.toMap()).toList(), // Nova serialização
      'dataCadastro': dataCadastro.toIso8601String(),
      'dataUltimaTransferencia': dataUltimaTransferencia?.toIso8601String(),
    };
  }

  factory Animal.fromMap(Map<String, dynamic> map) {
    return Animal(
      id: map['id'],
      identificacao: map['identificacao'],
      tipo: TipoAnimal.values.firstWhere((e) => e.toString() == map['tipo']),
      meses: map['meses'],
      loteAtual: map['loteAtual'],
      observacao: map['observacao'] ?? '',
      vacinas: (map['vacinas'] as List<dynamic>?)
              ?.map((v) => Vacina.fromMap(v))
              .toList() ??
          [],
      registrosCio: // Nova deserialização
          (map['registrosCio'] as List<dynamic>?)
                  ?.map((r) => RegistroCio.fromMap(r))
                  .toList() ??
              [],
      dataCadastro: DateTime.parse(map['dataCadastro']),
      dataUltimaTransferencia: map['dataUltimaTransferencia'] != null
          ? DateTime.parse(map['dataUltimaTransferencia'])
          : null,
    );
  }

  Animal copyWith({
    String? id,
    String? identificacao,
    TipoAnimal? tipo,
    int? meses,
    String? loteAtual,
    String? observacao,
    List<Vacina>? vacinas,
    List<RegistroCio>? registrosCio, // Nova propriedade no copyWith
    DateTime? dataCadastro,
    DateTime? dataUltimaTransferencia,
  }) {
    return Animal(
      id: id ?? this.id,
      identificacao: identificacao ?? this.identificacao,
      tipo: tipo ?? this.tipo,
      meses: meses ?? this.meses,
      loteAtual: loteAtual ?? this.loteAtual,
      observacao: observacao ?? this.observacao,
      vacinas: vacinas ?? this.vacinas,
      registrosCio: registrosCio ?? this.registrosCio, // Nova propriedade
      dataCadastro: dataCadastro ?? this.dataCadastro,
      dataUltimaTransferencia:
          dataUltimaTransferencia ?? this.dataUltimaTransferencia,
    );
  }

  // Método auxiliar para formatação de data
  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/'
        '${data.month.toString().padLeft(2, '0')}/'
        '${data.year}';
  }
}
