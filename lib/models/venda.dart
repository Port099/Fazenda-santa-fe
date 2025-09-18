// Removed unused imports

class Venda {
  final String id;
  final List<AnimalVenda> animais;
  final DateTime dataVenda;
  final double valorTotal;
  final String? observacao;
  final String comprador;

  Venda({
    required this.id,
    required this.animais,
    required this.dataVenda,
    required this.valorTotal,
    this.observacao,
    required this.comprador,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'animais': animais.map((a) => a.toMap()).toList(),
      'dataVenda': dataVenda.toIso8601String(),
      'valorTotal': valorTotal,
      'observacao': observacao,
      'comprador': comprador,
    };
  }

  factory Venda.fromMap(Map<String, dynamic> map) {
    return Venda(
      id: map['id'],
      animais: (map['animais'] as List<dynamic>)
          .map((a) => AnimalVenda.fromMap(a))
          .toList(),
      dataVenda: DateTime.parse(map['dataVenda']),
      valorTotal: map['valorTotal'],
      observacao: map['observacao'],
      comprador: map['comprador'],
    );
  }
}

class AnimalVenda {
  final String animalId;
  final String identificacao;
  final String tipoAnimal;
  final double pesoKg;
  final double precoPorKg;
  final double valorTotal;

  AnimalVenda({
    required this.animalId,
    required this.identificacao,
    required this.tipoAnimal,
    required this.pesoKg,
    required this.precoPorKg,
  }) : valorTotal = pesoKg * precoPorKg;

  Map<String, dynamic> toMap() {
    return {
      'animalId': animalId,
      'identificacao': identificacao,
      'tipoAnimal': tipoAnimal,
      'pesoKg': pesoKg,
      'precoPorKg': precoPorKg,
      'valorTotal': valorTotal,
    };
  }

  factory AnimalVenda.fromMap(Map<String, dynamic> map) {
    return AnimalVenda(
      animalId: map['animalId'],
      identificacao: map['identificacao'],
      tipoAnimal: map['tipoAnimal'],
      pesoKg: map['pesoKg'],
      precoPorKg: map['precoPorKg'],
    );
  }
}
