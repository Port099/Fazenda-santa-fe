import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/animal.dart';
import '../models/venda.dart';
import '../controllers/fazenda_controller.dart';

class VendasScreen extends StatefulWidget {
  final FazendaController controller;

  const VendasScreen({super.key, required this.controller});

  @override
  _VendasScreenState createState() => _VendasScreenState();
}

class _VendasScreenState extends State<VendasScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  
  final List<String> _animaisSelecionados = [];
  final Map<String, double> _pesos = {};
  final Map<String, double> _precos = {};
  final TextEditingController _compradorController = TextEditingController();
  final TextEditingController _observacaoController = TextEditingController();

  // Filtros
  Set<String> _tiposSelecionados = {};
  RangeValues _idadeRange = RangeValues(0, 20);
  Set<String> _statusVacinaSelecionados = {};
  bool _filtrosAtivos = false;
  bool _modoSelecaoMultipla = false;

  // Histórico de vendas (em uma aplicação real, isso viria do controller/banco de dados)
  final List<VendaCompleta> _historicoVendas = [];

  double get _valorTotal {
    double total = 0.0;
    for (String animalId in _animaisSelecionados) {
      double peso = _pesos[animalId] ?? 0.0;
      double preco = _precos[animalId] ?? 0.0;
      total += peso * preco;
    }
    return total;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    widget.controller.addListener(_onControllerChange);
  }

  @override
  void dispose() {
    _tabController.dispose();
    widget.controller.removeListener(_onControllerChange);
    _compradorController.dispose();
    _observacaoController.dispose();
    super.dispose();
  }

  void _onControllerChange() {
    setState(() {});
  }

  void _toggleModoSelecaoMultipla() {
    setState(() {
      _modoSelecaoMultipla = !_modoSelecaoMultipla;
      if (!_modoSelecaoMultipla) {
        // Manter apenas o primeiro animal selecionado
        if (_animaisSelecionados.isNotEmpty) {
          String primeiro = _animaisSelecionados.first;
          _animaisSelecionados.clear();
          _animaisSelecionados.add(primeiro);
        }
      }
    });
  }

  void _toggleAnimalSelecionado(String animalId) {
    setState(() {
      if (_animaisSelecionados.contains(animalId)) {
        _animaisSelecionados.remove(animalId);
        _pesos.remove(animalId);
        _precos.remove(animalId);
      } else {
        if (!_modoSelecaoMultipla) {
          // Modo seleção única
          _animaisSelecionados.clear();
          _pesos.clear();
          _precos.clear();
        }
        _animaisSelecionados.add(animalId);
      }
    });
  }

  void _mostrarDialogVenda(Animal animal) {
    final TextEditingController pesoController = TextEditingController();
    final TextEditingController precoController = TextEditingController();

    // Pré-preencher com valores existentes
    if (_pesos.containsKey(animal.id)) {
      pesoController.text = _pesos[animal.id]!.toStringAsFixed(2);
    }
    if (_precos.containsKey(animal.id)) {
      precoController.text = _precos[animal.id]!.toStringAsFixed(2);
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Dados de Venda - ${animal.identificacao}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${animal.tipoString} • ${animal.idadeFormatada}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 16),
            TextField(
              controller: pesoController,
              decoration: InputDecoration(
                labelText: 'Peso (kg)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.scale),
                suffix: Text('kg'),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
            ),
            SizedBox(height: 12),
            TextField(
              controller: precoController,
              decoration: InputDecoration(
                labelText: 'Preço por kg (R\$)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
                prefixText: 'R\$ ',
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              double? peso = double.tryParse(pesoController.text);
              double? preco = double.tryParse(precoController.text);

              if (peso != null && preco != null && peso > 0 && preco > 0) {
                setState(() {
                  _pesos[animal.id] = peso;
                  _precos[animal.id] = preco;
                  if (!_animaisSelecionados.contains(animal.id)) {
                    if (!_modoSelecaoMultipla) {
                      _animaisSelecionados.clear();
                      _pesos.clear();
                      _precos.clear();
                      _pesos[animal.id] = peso;
                      _precos[animal.id] = preco;
                    }
                    _animaisSelecionados.add(animal.id);
                  }
                });
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Preencha os campos com valores válidos'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text('Salvar', style: TextStyle(color: Colors.white)),
          ),
        ],
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
                    Icon(Icons.filter_list, color: Colors.green, size: 24),
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
                          backgroundColor: Colors.green,
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
        color: cor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cor.withOpacity(0.2)),
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
      activeColor: Colors.green,
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

  void _finalizarVenda() {
    if (_animaisSelecionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Selecione pelo menos um animal para venda'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_compradorController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Preencha o nome do comprador'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Verificar se todos os animais têm peso e preço
    for (String animalId in _animaisSelecionados) {
      if (!_pesos.containsKey(animalId) || !_precos.containsKey(animalId)) {
        Animal? animal = widget.controller.getAnimalPorId(animalId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Configure peso e preço para ${animal?.identificacao ?? animalId}',
            ),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar Venda'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Comprador: ${_compradorController.text}'),
            SizedBox(height: 8),
            Text('Animais: ${_animaisSelecionados.length}'),
            SizedBox(height: 8),
            Text(
              'Valor Total: R\$ ${_valorTotal.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            if (_observacaoController.text.isNotEmpty) ...[
              SizedBox(height: 8),
              Text('Observação: ${_observacaoController.text}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              _processarVenda();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text(
              'Confirmar Venda',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _processarVenda() {
    List<AnimalVenda> animaisVenda = [];
    double pesoTotal = 0.0;

    for (String animalId in _animaisSelecionados) {
      Animal? animal = widget.controller.getAnimalPorId(animalId);
      if (animal != null) {
        double peso = _pesos[animalId]!;
        double preco = _precos[animalId]!;
        pesoTotal += peso;

        animaisVenda.add(
          AnimalVenda(
            animalId: animalId,
            identificacao: animal.identificacao,
            tipoAnimal: animal.tipoString,
            pesoKg: peso,
            precoPorKg: preco,
          ),
        );

        // Remove o animal do sistema após a venda
        widget.controller.removerAnimal(animalId);
      }
    }

    // Adicionar ao histórico de vendas
    VendaCompleta vendaCompleta = VendaCompleta(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      comprador: _compradorController.text.trim(),
      vendedor: 'Usuário Atual', // Em uma aplicação real, pegar do contexto/auth
      dataVenda: DateTime.now(),
      animais: animaisVenda,
      valorTotal: _valorTotal,
      pesoTotal: pesoTotal,
      observacoes: _observacaoController.text.trim(),
    );

    setState(() {
      _historicoVendas.insert(0, vendaCompleta); // Mais recentes primeiro
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Venda realizada com sucesso! R\$ ${_valorTotal.toStringAsFixed(2)}',
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );

    _limparFormulario();
  }

  void _limparFormulario() {
    setState(() {
      _animaisSelecionados.clear();
      _pesos.clear();
      _precos.clear();
    });
    _compradorController.clear();
    _observacaoController.clear();
  }

  void _mostrarDetalhesVenda(VendaCompleta venda) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detalhes da Venda'),
        content: Container(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetalheRow('Data:', _formatarData(venda.dataVenda)),
              _buildDetalheRow('Comprador:', venda.comprador),
              _buildDetalheRow('Vendedor:', venda.vendedor),
              _buildDetalheRow('Animais:', '${venda.animais.length}'),
              _buildDetalheRow('Peso Total:', '${venda.pesoTotal.toStringAsFixed(1)} kg'),
              _buildDetalheRow(
                'Valor Total:', 
                'R\$ ${venda.valorTotal.toStringAsFixed(2)}',
                isHighlight: true,
              ),
              if (venda.observacoes != null && venda.observacoes!.isNotEmpty)
                _buildDetalheRow('Observações:', venda.observacoes!),
              
              SizedBox(height: 16),
              Text(
                'Animais Vendidos:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Container(
                height: 150,
                child: ListView.builder(
                  itemCount: venda.animais.length,
                  itemBuilder: (context, index) {
                    AnimalVenda animal = venda.animais[index];
                    double valorAnimal = animal.pesoKg * animal.precoPorKg;
                    
                    return Card(
                      margin: EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  animal.identificacao,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  animal.tipoAnimal,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Text(
                              '${animal.pesoKg.toStringAsFixed(1)}kg × R\$ ${animal.precoPorKg.toStringAsFixed(2)} = R\$ ${valorAnimal.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetalheRow(String label, String valor, {bool isHighlight = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: TextStyle(
                fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
                color: isHighlight ? Colors.green[700] : Colors.grey[800],
                fontSize: isHighlight ? 16 : 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year} ${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildHistoricoTab() {
    if (_historicoVendas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'Nenhuma venda realizada ainda',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'As vendas aparecerão aqui após serem finalizadas',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Resumo do histórico
        Container(
          padding: EdgeInsets.all(16),
          color: Colors.green.withOpacity(0.1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text(
                    '${_historicoVendas.length}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  Text('Vendas'),
                ],
              ),
              Column(
                children: [
                  Text(
                    '${_historicoVendas.fold<int>(0, (sum, venda) => sum + venda.animais.length)}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  Text('Animais'),
                ],
              ),
              Column(
                children: [
                  Text(
                    'R\$ ${_historicoVendas.fold<double>(0, (sum, venda) => sum + venda.valorTotal).toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  Text('Total'),
                ],
              ),
            ],
          ),
        ),
        
        // Lista do histórico
        Expanded(
          child: ListView.builder(
            itemCount: _historicoVendas.length,
            itemBuilder: (context, index) {
              VendaCompleta venda = _historicoVendas[index];
              
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: InkWell(
                  onTap: () => _mostrarDetalhesVenda(venda),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              venda.comprador,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'R\$ ${venda.valorTotal.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            SizedBox(width: 4),
                            Text(
                              _formatarData(venda.dataVenda),
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(width: 16),
                            Icon(
                              Icons.pets,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            SizedBox(width: 4),
                            Text(
                              '${venda.animais.length} animais',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(width: 16),
                            Icon(
                              Icons.scale,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            SizedBox(width: 4),
                            Text(
                              '${venda.pesoTotal.toStringAsFixed(1)}kg',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.person,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Vendido por: ${venda.vendedor}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                        if (venda.observacoes != null && venda.observacoes!.isNotEmpty) ...[
                          SizedBox(height: 8),
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.note,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                                SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    venda.observacoes!,
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 12,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'Toque para ver detalhes',
                              style: TextStyle(
                                color: Colors.green[600],
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 12,
                              color: Colors.green[600],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVendasTab() {
    List<Animal> todosAnimais = widget.controller.animais;
    List<Animal> animaisFiltrados = _aplicarFiltros(todosAnimais);

    return Column(
      children: [
        // Indicador de modo de seleção
        if (_modoSelecaoMultipla)
          Container(
            padding: EdgeInsets.all(12),
            color: Colors.green.withOpacity(0.1),
            child: Row(
              children: [
                Icon(Icons.info, color: Colors.green, size: 18),
                SizedBox(width: 8),
                Text(
                  'Modo seleção múltipla ativo - toque nos animais para selecionar',
                  style: TextStyle(
                    color: Colors.green[700],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

        // Painel de resumo
        if (_animaisSelecionados.isNotEmpty)
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.green.withOpacity(0.1),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          '${_animaisSelecionados.length}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        Text('Animais'),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          'R\$ ${_valorTotal.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        Text('Total'),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _compradorController,
                        decoration: InputDecoration(
                          labelText: 'Nome do Comprador',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                TextField(
                  controller: _observacaoController,
                  decoration: InputDecoration(
                    labelText: 'Observações (opcional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.note),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),

        // Lista de animais
        Expanded(
          child: animaisFiltrados.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _filtrosAtivos ? Icons.search_off : Icons.pets,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16),
                      Text(
                        _filtrosAtivos
                            ? 'Nenhum animal encontrado com os filtros'
                            : 'Nenhum animal disponível para venda',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
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
                    bool temDados =
                        _pesos.containsKey(animal.id) &&
                        _precos.containsKey(animal.id);

                    return Card(
                      margin: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      elevation: selecionado ? 4 : 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: selecionado
                            ? BorderSide(color: Colors.green, width: 2)
                            : BorderSide.none,
                      ),
                      child: InkWell(
                        onTap: () => _mostrarDialogVenda(animal),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: selecionado
                                ? Colors.green.withOpacity(0.05)
                                : null,
                          ),
                          child: Row(
                            children: [
                              // Checkbox
                              Checkbox(
                                value: selecionado,
                                onChanged: temDados
                                    ? (value) =>
                                          _toggleAnimalSelecionado(animal.id)
                                    : null,
                                activeColor: Colors.green,
                              ),

                              // Avatar
                              Container(
                                margin: EdgeInsets.only(right: 16),
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: selecionado
                                      ? Colors.green
                                      : Colors.grey[600],
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Center(
                                  child: Text(
                                    animal.identificacao.length >= 2
                                        ? animal.identificacao
                                              .substring(0, 2)
                                              .toUpperCase()
                                        : animal.identificacao.toUpperCase(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),

                              // Informações
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          animal.identificacao,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey[800],
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            animal.tipoString,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.cake,
                                          size: 16,
                                          color: Colors.grey[600],
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          animal.idadeFormatada,
                                          style: TextStyle(
                                            color: Colors.grey[700],
                                            fontSize: 14,
                                          ),
                                        ),
                                        SizedBox(width: 16),
                                        Icon(
                                          Icons.medical_services,
                                          size: 16,
                                          color: animal.corStatusVacina,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          animal.textoStatusVacina,
                                          style: TextStyle(
                                            color: animal.corStatusVacina,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (temDados) ...[
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.green.withOpacity(
                                                0.1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              '${_pesos[animal.id]!.toStringAsFixed(1)}kg × R\$ ${_precos[animal.id]!.toStringAsFixed(2)} = R\$ ${(_pesos[animal.id]! * _precos[animal.id]!).toStringAsFixed(2)}',
                                              style: TextStyle(
                                                color: Colors.green[700],
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),

                              // Ícone de configuração
                              Icon(
                                temDados ? Icons.edit : Icons.settings,
                                color: temDados ? Colors.green : Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vendas'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(
              icon: Icon(Icons.shopping_cart),
              text: 'Nova Venda',
            ),
            Tab(
              icon: Icon(Icons.history),
              text: 'Histórico',
            ),
          ],
        ),
        actions: _tabController.index == 0 ? [
          IconButton(
            icon: Icon(
              Icons.filter_list,
              color: _filtrosAtivos ? Colors.white : Colors.white70,
            ),
            onPressed: _mostrarFiltros,
            tooltip: 'Filtros',
          ),
          IconButton(
            icon: Icon(
              _modoSelecaoMultipla
                  ? Icons.check_box
                  : Icons.check_box_outline_blank,
              color: _modoSelecaoMultipla ? Colors.white : Colors.white70,
            ),
            onPressed: _toggleModoSelecaoMultipla,
            tooltip: _modoSelecaoMultipla
                ? 'Seleção múltipla ativa'
                : 'Ativar seleção múltipla',
          ),
          if (_animaisSelecionados.isNotEmpty)
            IconButton(
              icon: Icon(Icons.clear),
              onPressed: _limparFormulario,
              tooltip: 'Limpar seleção',
            ),
        ] : null,
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildVendasTab(),
          _buildHistoricoTab(),
        ],
      ),
      bottomNavigationBar: _tabController.index == 0 && _animaisSelecionados.isNotEmpty
          ? Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, -3),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _finalizarVenda,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'FINALIZAR VENDA - R\$ ${_valorTotal.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          : null,
    );
  }
}

// Modelo para representar uma venda completa
class VendaCompleta {
  final String id;
  final String comprador;
  final String vendedor;
  final DateTime dataVenda;
  final List<AnimalVenda> animais;
  final double valorTotal;
  final double pesoTotal;
  final String? observacoes;

  VendaCompleta({
    required this.id,
    required this.comprador,
    required this.vendedor,
    required this.dataVenda,
    required this.animais,
    required this.valorTotal,
    required this.pesoTotal,
    this.observacoes,
  });
}
