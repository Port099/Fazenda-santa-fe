import 'package:flutter/material.dart';
import '../models/animal.dart';
import '../models/lote.dart';

class FazendaController extends ChangeNotifier {
  List<Animal> _animais = [];

  List<Animal> get animais => List.unmodifiable(_animais);

  // Construtor com dados de exemplo
  FazendaController() {
    _carregarDadosExemplo();
  }

  void _carregarDadosExemplo() {
    _animais = [
      // Lote 1
      Animal(
        id: '1',
        identificacao: 'B001',
        tipo: TipoAnimal.boi,
        meses: 36,
        loteAtual: 'lote1',
        observacao: 'Animal saudável, boa reprodução',
        vacinas: [
          Vacina(
            nome: 'Aftosa',
            dataAplicacao: DateTime(2024, 1, 15),
            proximaData: DateTime(2024, 7, 15),
            observacao: 'Primeira dose do ano',
          ),
        ],
      ),
      Animal(
        id: '2',
        identificacao: 'V001',
        tipo: TipoAnimal.vaca,
        meses: 48,
        loteAtual: 'lote1',
        observacao: 'Vaca leiteira de alta produção',
        vacinas: [
          Vacina(
            nome: 'Brucelose',
            dataAplicacao: DateTime(2024, 2, 10),
            proximaData: DateTime(2025, 2, 10),
          ),
        ],
      ),

      // Lote 2
      Animal(
        id: '3',
        identificacao: 'N001',
        tipo: TipoAnimal.novilha,
        meses: 18,
        loteAtual: 'lote2',
        observacao: 'Primeira gestação',
      ),
      Animal(
        id: '4',
        identificacao: 'N002',
        tipo: TipoAnimal.novilha,
        meses: 20,
        loteAtual: 'lote2',
        observacao: 'Pronta para reprodução',
      ),

      // Curral
      Animal(
        id: '5',
        identificacao: 'BZ001',
        tipo: TipoAnimal.bezerro,
        meses: 6,
        loteAtual: 'curral',
        observacao: 'Em fase de desmama',
        vacinas: [
          Vacina(
            nome: 'Primeira dose',
            dataAplicacao: DateTime(2024, 6, 1),
            proximaData: DateTime(2024, 9, 1),
          ),
        ],
      ),
      Animal(
        id: '6',
        identificacao: 'BZ002',
        tipo: TipoAnimal.bezerra,
        meses: 8,
        loteAtual: 'curral',
        observacao: 'Desenvolvimento normal',
      ),
    ];
    notifyListeners();
  }

  // Métodos de busca
  List<Animal> getAnimaisPorLote(String loteId) {
    return _animais.where((animal) => animal.loteAtual == loteId).toList();
  }

  Animal? getAnimalPorId(String id) {
    try {
      return _animais.firstWhere((animal) => animal.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Animal> buscarAnimaisPorIdentificacao(String identificacao) {
    return _animais
        .where(
          (animal) => animal.identificacao.toLowerCase().contains(
            identificacao.toLowerCase(),
          ),
        )
        .toList();
  }

  List<Animal> getAnimaisPorTipo(TipoAnimal tipo) {
    return _animais.where((animal) => animal.tipo == tipo).toList();
  }

  // Métodos de manipulação
  void adicionarAnimal(Animal animal) {
    if (!_identificacaoExiste(animal.identificacao)) {
      _animais.add(animal);
      notifyListeners();
    } else {
      throw Exception('Identificação já existe');
    }
  }

  void editarAnimal(Animal animalEditado) {
    int index = _animais.indexWhere((animal) => animal.id == animalEditado.id);
    if (index != -1) {
      // Verifica se a identificação não conflita com outro animal
      if (_identificacaoExiste(animalEditado.identificacao, animalEditado.id)) {
        throw Exception('Identificação já existe');
      }
      _animais[index] = animalEditado;
      notifyListeners();
    }
  }

  void removerAnimal(String id) {
    _animais.removeWhere((animal) => animal.id == id);
    notifyListeners();
  }

  void transferirAnimal(String animalId, String novoLoteId) {
    Animal? animal = getAnimalPorId(animalId);
    if (animal != null) {
      animal.transferirPara(novoLoteId);
      notifyListeners();
    }
  }

  void transferirAnimaisEmLote(List<String> animaisIds, String novoLoteId) {
    for (String id in animaisIds) {
      transferirAnimal(id, novoLoteId);
    }
  }

  // Validações
  bool _identificacaoExiste(String identificacao, [String? excluirId]) {
    return _animais.any(
      (animal) =>
          animal.identificacao.toLowerCase() == identificacao.toLowerCase() &&
          animal.id != excluirId,
    );
  }

  bool podeAdicionarNoLote(String loteId) {
    Lote? lote = Lote.getLotePorId(loteId);
    if (lote == null) return false;

    int quantidadeAtual = getAnimaisPorLote(loteId).length;
    return quantidadeAtual < lote.capacidadeMaxima;
  }

  // Estatísticas
  Map<String, int> getEstatisticasPorLote() {
    Map<String, int> stats = {};
    for (Lote lote in Lote.todosOsLotes) {
      stats[lote.id] = getAnimaisPorLote(lote.id).length;
    }
    return stats;
  }

  Map<TipoAnimal, int> getEstatisticasPorTipo() {
    Map<TipoAnimal, int> stats = {};
    for (TipoAnimal tipo in TipoAnimal.values) {
      stats[tipo] = getAnimaisPorTipo(tipo).length;
    }
    return stats;
  }

  int get totalAnimais => _animais.length;

  int getAnimaisComVacinasAtrasadas() {
    return _animais
        .where((animal) => animal.statusVacinas == StatusVacina.atrasada)
        .length;
  }

  int getAnimaisSemVacinas() {
    return _animais
        .where((animal) => animal.statusVacinas == StatusVacina.naoVacinado)
        .length;
  }

  List<Animal> getAnimaisParaVacinar() {
    DateTime proximasSemanas = DateTime.now().add(Duration(days: 14));
    return _animais.where((animal) {
      return animal.vacinas.any(
        (vacina) =>
            vacina.proximaData != null &&
            vacina.proximaData!.isBefore(proximasSemanas) &&
            vacina.proximaData!.isAfter(DateTime.now()),
      );
    }).toList();
  }

  // Métodos utilitários
  void limparTodosOsAnimais() {
    _animais.clear();
    notifyListeners();
  }

  void recarregarDadosExemplo() {
    _animais.clear();
    _carregarDadosExemplo();
  }

  // Geração de ID único
  String _gerarNovoId() {
    if (_animais.isEmpty) return '1';

    List<int> ids = _animais
        .map((animal) => int.tryParse(animal.id) ?? 0)
        .where((id) => id > 0)
        .toList();

    if (ids.isEmpty) return '1';

    ids.sort();
    return (ids.last + 1).toString();
  }

  String gerarNovoId() => _gerarNovoId();

  getTotalAnimais() {}
}
