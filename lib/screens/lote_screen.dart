import 'package:flutter/material.dart';
import '../models/lote.dart';
import '../models/animal.dart';
import '../controllers/fazenda_controller.dart';
import '../components/animal_card.dart';
import 'animal_profile_screen.dart';
import '../screens/add_animal_screen.dart';

class LoteScreen extends StatefulWidget {
  final Lote lote;
  final FazendaController controller;

  const LoteScreen({super.key, required this.lote, required this.controller});

  @override
  _LoteScreenState createState() => _LoteScreenState();
}

class _LoteScreenState extends State<LoteScreen> {
  final List<String> _animaisSelecionados = [];
  bool _modoSelecao = false;

  // Filtros
  final Set<String> _tiposSelecionados = {};
  RangeValues _idadeRange = RangeValues(0, 20);
  final Set<String> _statusVacinaSelecionados = {};
  bool _filtrosAtivos = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChange);
    super.dispose();
  }

  void _onControllerChange() {
    setState(() {});
  }

  void _toggleModoSelecao() {
    setState(() {
      _modoSelecao = !_modoSelecao;
      if (!_modoSelecao) {
        _animaisSelecionados.clear();
      }
    });
  }

  void _toggleAnimalSelecionado(String animalId) {
    setState(() {
      if (_animaisSelecionados.contains(animalId)) {
        _animaisSelecionados.remove(animalId);
      } else {
        _animaisSelecionados.add(animalId);
      }
    });
  }

  void _navegarParaPerfil(Animal animal) {
    if (_modoSelecao) {
      _toggleAnimalSelecionado(animal.id);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AnimalProfileScreen(
            animal: animal,
            controller: widget.controller,
          ),
        ),
      );
    }
  }

  void _adicionarAnimal() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddAnimalScreen(
          controller: widget.controller,
          loteInicial: widget.lote.id,
        ),
      ),
    );
  }

  void _mostrarFiltros() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 12),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(Icons.filter_list, color: widget.lote.cor, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Filtrar Animais',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    Spacer(),
                    if (_filtrosAtivos)
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            _limparFiltros();
                          });
                        },
                        child: Text(
                          'Limpar',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // Tipo de Animal
                      _buildSecaoFiltro(
                        'Tipo de Animal',
                        Icons.pets,
                        Colors.green,
                        Column(
                          children:
                              ['Boi', 'Vaca', 'Bezerro', 'Bezerra', 'Novilha']
                                  .map(
                                    (tipo) => CheckboxListTile(
                                      title: Text(tipo),
                                      value: _tiposSelecionados.contains(tipo),
                                      onChanged: (value) {
                                        setModalState(() {
                                          if (value == true) {
                                            _tiposSelecionados.add(tipo);
                                          } else {
                                            _tiposSelecionados.remove(tipo);
                                          }
                                          _atualizarStatusFiltros();
                                        });
                                      },
                                      activeColor: Colors.green,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  )
                                  .toList(),
                        ),
                      ),

                      SizedBox(height: 20),

                      // Idade
                      _buildSecaoFiltro(
                        'Faixa de Idade',
                        Icons.cake,
                        Colors.orange,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_idadeRange.start.round()} - ${_idadeRange.end.round()} anos',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                            RangeSlider(
                              values: _idadeRange,
                              min: 0,
                              max: 20,
                              divisions: 20,
                              onChanged: (values) {
                                setModalState(() {
                                  _idadeRange = values;
                                  _atualizarStatusFiltros();
                                });
                              },
                              activeColor: Colors.orange,
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 20),

                      // Status Vacina
                      _buildSecaoFiltro(
                        'Status da Vacina',
                        Icons.medical_services,
                        Colors.blue,
                        Column(
                          children: [
                            _buildCheckboxVacina(
                              'Vacinado (Em dia)',
                              'vacinado',
                              Colors.green,
                              setModalState,
                            ),
                            _buildCheckboxVacina(
                              'Vacina Atrasada',
                              'atrasada',
                              Colors.red,
                              setModalState,
                            ),
                            _buildCheckboxVacina(
                              'Não Vacinado',
                              'sem_vacina',
                              Colors.orange,
                              setModalState,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Container(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Cancelar'),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() {});
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.lote.cor,
                          foregroundColor: Colors.white,
                        ),
                        child: Text('Aplicar'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecaoFiltro(
    String titulo,
    IconData icone,
    Color cor,
    Widget conteudo,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cor.withAlpha((0.05 * 255).toInt()),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cor.withAlpha((0.2 * 255).toInt())),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icone, color: cor, size: 20),
              SizedBox(width: 8),
              Text(
                titulo,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          conteudo,
        ],
      ),
    );
  }

  Widget _buildCheckboxVacina(
    String titulo,
    String valor,
    Color cor,
    StateSetter setModalState,
  ) {
    return CheckboxListTile(
      title: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: cor,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          SizedBox(width: 8),
          Text(titulo),
        ],
      ),
      value: _statusVacinaSelecionados.contains(valor),
      onChanged: (value) {
        setModalState(() {
          if (value == true) {
            _statusVacinaSelecionados.add(valor);
          } else {
            _statusVacinaSelecionados.remove(valor);
          }
          _atualizarStatusFiltros();
        });
      },
      activeColor: Colors.blue,
      contentPadding: EdgeInsets.zero,
    );
  }

  void _atualizarStatusFiltros() {
    _filtrosAtivos =
        _tiposSelecionados.isNotEmpty ||
        _idadeRange.start > 0 ||
        _idadeRange.end < 20 ||
        _statusVacinaSelecionados.isNotEmpty;
  }

  void _limparFiltros() {
    _tiposSelecionados.clear();
    _idadeRange = RangeValues(0, 20);
    _statusVacinaSelecionados.clear();
    _filtrosAtivos = false;
  }

  // FUNÇÃO DE FILTROS CORRIGIDA
  List<Animal> _aplicarFiltros(List<Animal> animais) {
    if (!_filtrosAtivos) return animais;

    return animais.where((animal) {
      // Filtro por tipo
      if (_tiposSelecionados.isNotEmpty) {
        if (!_tiposSelecionados.contains(animal.tipoString)) {
          return false;
        }
      }

      // Filtro por idade
      if (_idadeRange.start > 0 || _idadeRange.end < 20) {
        // Converter meses para anos
        double idadeEmAnos = animal.meses / 12.0;

        if (idadeEmAnos < _idadeRange.start || idadeEmAnos > _idadeRange.end) {
          return false;
        }
      }

      // Filtro por status da vacina
      if (_statusVacinaSelecionados.isNotEmpty) {
        String statusVacina = _obterStatusVacina(animal);
        if (!_statusVacinaSelecionados.contains(statusVacina)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  // FUNÇÃO AUXILIAR PARA STATUS DA VACINA
  String _obterStatusVacina(Animal animal) {
    switch (animal.statusVacinas) {
      case StatusVacina.emDia:
        return 'vacinado';
      case StatusVacina.atrasada:
        return 'atrasada';
      case StatusVacina.naoVacinado:
        return 'sem_vacina';
    }
  }

  void _mostrarOpcoesAnimaisSelecionados() {
    if (_animaisSelecionados.isEmpty) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'O que fazer com ${_animaisSelecionados.length} animais?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            ListTile(
              leading: Icon(
                Icons.transfer_within_a_station,
                color: Colors.green,
              ),
              title: Text('Transferir'),
              subtitle: Text('Mover para outro lote'),
              onTap: _transferirAnimais,
            ),

            ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title: Text('Remover'),
              subtitle: Text('Excluir do sistema'),
              onTap: _removerAnimais,
            ),
          ],
        ),
      ),
    );
  }

  void _transferirAnimais() {
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Transferir para:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ...Lote.todosOsLotes
                .where((lote) => lote.id != widget.lote.id)
                .map(
                  (lote) => ListTile(
                    leading: Icon(lote.icone, color: lote.cor),
                    title: Text(lote.nome),
                    subtitle: Text(lote.descricao),
                    onTap: () {
                      widget.controller.transferirAnimaisEmLote(
                        _animaisSelecionados,
                        lote.id,
                      );
                      Navigator.pop(context);
                      setState(() {
                        _animaisSelecionados.clear();
                        _modoSelecao = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Animais transferidos para ${lote.nome}',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                  ),
                ),
          ],
        ),
      ),
    );
  }

  void _removerAnimais() {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar Remoção'),
        content: Text(
          'Remover ${_animaisSelecionados.length} animais do sistema?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              // Aqui você implementa a remoção conforme seu controller
              // Por exemplo:
              for (String id in _animaisSelecionados) {
                widget.controller.removerAnimal(id);
              }

              Navigator.pop(context);
              setState(() {
                _animaisSelecionados.clear();
                _modoSelecao = false;
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Animais removidos com sucesso'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Remover', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Animal> todosAnimais = widget.controller.getAnimaisPorLote(
      widget.lote.id,
    );
    List<Animal> animaisFiltrados = _aplicarFiltros(todosAnimais);
    double ocupacao = todosAnimais.length / widget.lote.capacidadeMaxima;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lote.nome),
        actions: [
          IconButton(
            icon: Icon(
              Icons.filter_list,
              color: _filtrosAtivos ? widget.lote.cor : null,
            ),
            onPressed: _mostrarFiltros,
          ),
          if (todosAnimais.isNotEmpty)
            IconButton(
              icon: Icon(_modoSelecao ? Icons.close : Icons.checklist),
              onPressed: _toggleModoSelecao,
            ),
          if (_modoSelecao && _animaisSelecionados.isNotEmpty)
            IconButton(
              icon: Icon(Icons.more_vert),
              onPressed: _mostrarOpcoesAnimaisSelecionados,
            ),
        ],
      ),
      body: Column(
        children: [
          // Info do lote
          Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  widget.lote.cor.withAlpha((0.1 * 255).toInt()),
                  widget.lote.cor.withAlpha((0.05 * 255).toInt()),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: widget.lote.cor.withAlpha((0.3 * 255).toInt()),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: widget.lote.cor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        widget.lote.icone,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.lote.nome,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          Text(
                            widget.lote.descricao,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildInfoItem(
                      'Animais',
                      todosAnimais.length.toString(),
                      Icons.pets,
                      widget.lote.cor,
                    ),
                    _buildInfoItem(
                      'Capacidade',
                      widget.lote.capacidadeMaxima.toString(),
                      Icons.warehouse,
                      Colors.grey[600]!,
                    ),
                    _buildInfoItem(
                      'Ocupação',
                      '${(ocupacao * 100).toInt()}%',
                      Icons.show_chart,
                      ocupacao > 0.8 ? Colors.red : Colors.green,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Adicione o resumo dos tipos aqui
          _buildResumoTipos(todosAnimais, widget.lote.cor),

          // Indicador de filtros
          if (_filtrosAtivos)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: widget.lote.cor.withAlpha((0.1 * 255).toInt()),
              child: Row(
                children: [
                  Icon(Icons.filter_list, color: widget.lote.cor, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Filtros ativos: ${animaisFiltrados.length} de ${todosAnimais.length}',
                      style: TextStyle(
                        color: widget.lote.cor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _limparFiltros();
                      });
                    },
                    child: Text(
                      'Limpar',
                      style: TextStyle(color: widget.lote.cor),
                    ),
                  ),
                ],
              ),
            ),

          // Seleção
          if (_modoSelecao && _animaisSelecionados.isNotEmpty)
            Container(
              padding: EdgeInsets.all(16),
              color: Colors.green.withAlpha((0.1 * 255).toInt()),
              child: Row(
                children: [
                  Icon(Icons.check, color: Colors.green),
                  SizedBox(width: 8),
                  Text(
                    '${_animaisSelecionados.length} selecionados',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

          // Lista
          Expanded(
            child: animaisFiltrados.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _filtrosAtivos ? Icons.search_off : widget.lote.icone,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16),
                        Text(
                          _filtrosAtivos
                              ? 'Nenhum animal encontrado com os filtros'
                              : 'Nenhum animal no ${widget.lote.nome}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 16),
                        if (!_filtrosAtivos)
                          ElevatedButton.icon(
                            onPressed: _adicionarAnimal,
                            icon: Icon(Icons.add),
                            label: Text('Adicionar Animal'),
                          ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: animaisFiltrados.length,
                    itemBuilder: (context, index) {
                      Animal animal = animaisFiltrados[index];
                      bool selecionado = _animaisSelecionados.contains(
                        animal.id,
                      );

                      return AnimalCard(
                        animal: animal,
                        onTap: () => _navegarParaPerfil(animal),
                        modoSelecao: _modoSelecao,
                        selecionado: selecionado,
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: _modoSelecao
          ? null
          : FloatingActionButton.extended(
              onPressed: _adicionarAnimal,
              icon: Icon(Icons.add),
              label: Text('Adicionar Animal'),
            ),
    );
  }

  Widget _buildInfoItem(String label, String valor, IconData icone, Color cor) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: cor.withAlpha((0.1 * 255).toInt()),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icone, color: cor, size: 20),
        ),
        SizedBox(height: 4),
        Text(
          valor,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: cor,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}

Map<String, int> _obterContagemPorTipo(List<Animal> animais) {
  Map<String, int> contagem = {};

  for (Animal animal in animais) {
    String tipo = animal.tipoString;
    contagem[tipo] = (contagem[tipo] ?? 0) + 1;
  }

  return contagem;
}

Widget _buildResumoTipos(List<Animal> animais, Color loteCor) {
  if (animais.isEmpty) return SizedBox.shrink();

  Map<String, int> contagem = _obterContagemPorTipo(animais);

  return Container(
    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.grey[50],
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey[200]!),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.analytics, color: Colors.grey[600], size: 18),
            SizedBox(width: 8),
            Text(
              'Quantidades no Lote',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: contagem.entries.map((entry) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: loteCor.withAlpha((0.1 * 255).toInt()),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: loteCor.withAlpha((0.3 * 255).toInt()),
                ),
              ),
              child: Text(
                '${entry.key}: ${entry.value}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: loteCor,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    ),
  );
}
// No método build(), adicione o widget após o container de informações do lote:

// No método build(), adicione o widget após o container de informações do lote:
