import 'package:flutter/material.dart';
import '../models/animal.dart';
import '../models/lote.dart';
import '../controllers/fazenda_controller.dart';
import '../components/vacina_card.dart';
import '../components/cio_card.dart';
import 'edit_animal_screen.dart';

class AnimalProfileScreen extends StatefulWidget {
  final Animal animal;
  final FazendaController controller;

  const AnimalProfileScreen({
    super.key,
    required this.animal,
    required this.controller,
  });

  @override
  _AnimalProfileScreenState createState() => _AnimalProfileScreenState();
}

class _AnimalProfileScreenState extends State<AnimalProfileScreen> {
  late Animal _animal;

  @override
  void initState() {
    super.initState();
    _animal = widget.animal;
    widget.controller.addListener(_onControllerChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChange);
    super.dispose();
  }

  void _onControllerChange() {
    // Atualiza o animal local com os dados mais recentes
    Animal? animalAtualizado = widget.controller.getAnimalPorId(_animal.id);
    if (animalAtualizado != null) {
      setState(() {
        _animal = animalAtualizado;
      });
    }
  }

  void _editarAnimal() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EditAnimalScreen(animal: _animal, controller: widget.controller),
      ),
    );
  }

  void _transferirAnimal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildTransferirBottomSheet(),
    );
  }

  void _adicionarVacina() {
    showDialog(
      context: context,
      builder: (context) => _buildAdicionarVacinaDialog(),
    );
  }

  void _adicionarCio() {
    if (!_animal.podeTerCio) return;

    showDialog(
      context: context,
      builder: (context) => _buildAdicionarCioDialog(),
    );
  }

  void _removerAnimal() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Confirmar Exclusão'),
          ],
        ),
        content: Text(
          'Tem certeza que deseja remover ${_animal.identificacao}?\n\nEsta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              widget.controller.removerAnimal(_animal.id);
              Navigator.pop(context); // Fecha dialog
              Navigator.pop(context); // Volta para tela anterior
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Animal ${_animal.identificacao} removido'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Remover'),
          ),
        ],
      ),
    );
  }

  Widget _buildTransferirBottomSheet() {
    return Container(
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
            'Transferir ${_animal.identificacao} para:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
          SizedBox(height: 20),
          ...Lote.todosOsLotes
              .where((lote) => lote.id != _animal.loteAtual)
              .map(
                (lote) => ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: lote.cor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(lote.icone, color: lote.cor),
                  ),
                  title: Text(lote.nome),
                  subtitle: Text(lote.descricao),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    widget.controller.transferirAnimal(_animal.id, lote.id);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${_animal.identificacao} transferido para ${lote.nome}',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                ),
              ),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildAdicionarVacinaDialog() {
    final nomeController = TextEditingController();
    final observacaoController = TextEditingController();
    DateTime dataAplicacao = DateTime.now();
    DateTime? proximaData;

    return StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: Text('Adicionar Vacina'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomeController,
                decoration: InputDecoration(
                  labelText: 'Nome da Vacina',
                  hintText: 'Ex: Aftosa, Brucelose',
                ),
              ),
              SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Data de Aplicação'),
                subtitle: Text(
                  '${dataAplicacao.day.toString().padLeft(2, '0')}/'
                  '${dataAplicacao.month.toString().padLeft(2, '0')}/'
                  '${dataAplicacao.year}',
                ),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  final data = await showDatePicker(
                    context: context,
                    initialDate: dataAplicacao,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (data != null) {
                    setDialogState(() {
                      dataAplicacao = data;
                    });
                  }
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Próxima Aplicação (Opcional)'),
                subtitle: Text(
                  proximaData != null
                      ? '${proximaData!.day.toString().padLeft(2, '0')}/'
                            '${proximaData!.month.toString().padLeft(2, '0')}/'
                            '${proximaData!.year}'
                      : 'Não definida',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (proximaData != null)
                      IconButton(
                        icon: Icon(Icons.clear, size: 20),
                        onPressed: () {
                          setDialogState(() {
                            proximaData = null;
                          });
                        },
                      ),
                    Icon(Icons.calendar_today),
                  ],
                ),
                onTap: () async {
                  final data = await showDatePicker(
                    context: context,
                    initialDate:
                        proximaData ?? DateTime.now().add(Duration(days: 180)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(Duration(days: 365 * 2)),
                  );
                  if (data != null) {
                    setDialogState(() {
                      proximaData = data;
                    });
                  }
                },
              ),
              SizedBox(height: 16),
              TextField(
                controller: observacaoController,
                decoration: InputDecoration(
                  labelText: 'Observação (Opcional)',
                  hintText: 'Dose, veterinário, etc.',
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nomeController.text.trim().isNotEmpty) {
                Vacina novaVacina = Vacina(
                  nome: nomeController.text.trim(),
                  dataAplicacao: dataAplicacao,
                  proximaData: proximaData,
                  observacao: observacaoController.text.trim().isNotEmpty
                      ? observacaoController.text.trim()
                      : null,
                );

                _animal.adicionarVacina(novaVacina);
                widget.controller.editarAnimal(_animal);

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Vacina adicionada com sucesso'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  Widget _buildAdicionarCioDialog() {
    final observacaoController = TextEditingController();
    DateTime dataCio = DateTime.now();
    DateTime? previsaoProximoCio;
    bool usarCicloAutomatico = true;

    return StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.favorite, color: Colors.pink[600]),
            SizedBox(width: 8),
            Text('Registrar Cio'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Animal: ${_animal.identificacao} (${_animal.tipoString})',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Data do Cio'),
                subtitle: Text(
                  '${dataCio.day.toString().padLeft(2, '0')}/'
                  '${dataCio.month.toString().padLeft(2, '0')}/'
                  '${dataCio.year}',
                ),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  final data = await showDatePicker(
                    context: context,
                    initialDate: dataCio,
                    firstDate: DateTime.now().subtract(Duration(days: 60)),
                    lastDate: DateTime.now(),
                  );
                  if (data != null) {
                    setDialogState(() {
                      dataCio = data;
                      // Atualiza a previsão automática quando a data muda
                      if (usarCicloAutomatico) {
                        previsaoProximoCio = dataCio.add(Duration(days: 21));
                      }
                    });
                  }
                },
              ),
              SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Calcular próximo cio automaticamente'),
                subtitle: Text('Usa ciclo padrão de 21 dias'),
                value: usarCicloAutomatico,
                onChanged: (value) {
                  setDialogState(() {
                    usarCicloAutomatico = value;
                    if (value) {
                      previsaoProximoCio = dataCio.add(Duration(days: 21));
                    } else {
                      previsaoProximoCio = null;
                    }
                  });
                },
              ),
              if (!usarCicloAutomatico) ...[
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Próximo Cio Previsto (Opcional)'),
                  subtitle: Text(
                    previsaoProximoCio != null
                        ? '${previsaoProximoCio!.day.toString().padLeft(2, '0')}/'
                              '${previsaoProximoCio!.month.toString().padLeft(2, '0')}/'
                              '${previsaoProximoCio!.year}'
                        : 'Não definida',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (previsaoProximoCio != null)
                        IconButton(
                          icon: Icon(Icons.clear, size: 20),
                          onPressed: () {
                            setDialogState(() {
                              previsaoProximoCio = null;
                            });
                          },
                        ),
                      Icon(Icons.calendar_today),
                    ],
                  ),
                  onTap: () async {
                    final data = await showDatePicker(
                      context: context,
                      initialDate:
                          previsaoProximoCio ?? dataCio.add(Duration(days: 21)),
                      firstDate: dataCio.add(Duration(days: 1)),
                      lastDate: DateTime.now().add(Duration(days: 60)),
                    );
                    if (data != null) {
                      setDialogState(() {
                        previsaoProximoCio = data;
                      });
                    }
                  },
                ),
              ] else ...[
                Container(
                  padding: EdgeInsets.all(12),
                  margin: EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Próximo cio previsto para: ${previsaoProximoCio != null ? "${previsaoProximoCio!.day.toString().padLeft(2, '0')}/${previsaoProximoCio!.month.toString().padLeft(2, '0')}/${previsaoProximoCio!.year}" : "Não calculado"}',
                          style: TextStyle(
                            color: Colors.blue[800],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              SizedBox(height: 16),
              TextField(
                controller: observacaoController,
                decoration: InputDecoration(
                  labelText: 'Observações (Opcional)',
                  hintText: 'Comportamento, intensidade, etc.',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              RegistroCio novoRegistro = RegistroCio(
                data: dataCio,
                observacao: observacaoController.text.trim().isNotEmpty
                    ? observacaoController.text.trim()
                    : null,
                previsaoProximoCio: previsaoProximoCio,
              );

              _animal.adicionarRegistroCio(novoRegistro);
              widget.controller.editarAnimal(_animal);

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Registro de cio adicionado com sucesso'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Lote? loteAtual = Lote.getLotePorId(_animal.loteAtual);
    Color corTipo = _getCorTipo(_animal.tipo);

    return Scaffold(
      appBar: AppBar(
        title: Text(_animal.identificacao),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: _editarAnimal,
            tooltip: 'Editar Animal',
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'transferir',
                child: Row(
                  children: [
                    Icon(Icons.transfer_within_a_station, size: 20),
                    SizedBox(width: 8),
                    Text('Transferir'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'remover',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text('Remover', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'transferir') {
                _transferirAnimal();
              } else if (value == 'remover') {
                _removerAnimal();
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card principal do animal
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      corTipo.withOpacity(0.1),
                      corTipo.withOpacity(0.05),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: corTipo,
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: Center(
                            child: Text(
                              _animal.identificacao.length >= 3
                                  ? _animal.identificacao
                                        .substring(0, 3)
                                        .toUpperCase()
                                  : _animal.identificacao.toUpperCase(),
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _animal.identificacao,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(vertical: 4),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: corTipo.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: corTipo.withOpacity(0.4),
                                  ),
                                ),
                                child: Text(
                                  _animal.tipoString,
                                  style: TextStyle(
                                    color: corTipo,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildInfoItem(
                          'Idade',
                          _animal.idadeFormatada,
                          Icons.cake,
                        ),
                        _buildInfoItem(
                          'Local',
                          loteAtual?.nome ?? 'Desconhecido',
                          Icons.location_on,
                        ),
                        _buildInfoItem(
                          'Vacinas',
                          _animal.textoStatusVacina,
                          Icons.medical_services,
                          cor: _animal.corStatusVacina,
                        ),
                        // Adiciona info de cio apenas para fêmeas
                        if (_animal.podeTerCio)
                          _buildInfoItem(
                            'Cio',
                            _animal.statusCio.length > 15
                                ? _animal.statusCio.substring(0, 15) + '...'
                                : _animal.statusCio,
                            Icons.favorite,
                            cor: _animal.corStatusCio,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            // Observações
            if (_animal.observacao.isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.note, color: Color(0xFF4CAF50)),
                          SizedBox(width: 8),
                          Text(
                            'Observações',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Text(
                        _animal.observacao,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
            ],

            // Controle de Cio (apenas para fêmeas)
            if (_animal.podeTerCio) ...[
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.favorite, color: Colors.pink[600]),
                              SizedBox(width: 8),
                              Text(
                                'Controle de Cio',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: Icon(Icons.add, color: Colors.pink[600]),
                            onPressed: _adicionarCio,
                            tooltip: 'Registrar Cio',
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      if (_animal.registrosCio.isEmpty)
                        Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.orange.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.orange),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Nenhum registro de cio encontrado',
                                  style: TextStyle(color: Colors.orange[800]),
                                ),
                              ),
                            ],
                          ),
                        )
                      else ...[
                        // Status atual do cio
                        Container(
                          padding: EdgeInsets.all(12),
                          margin: EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: _animal.corStatusCio.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _animal.corStatusCio.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.schedule,
                                color: _animal.corStatusCio,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Status: ${_animal.statusCio}',
                                style: TextStyle(
                                  color: _animal.corStatusCio,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Lista de registros
                        ...List.generate(_animal.registrosCio.length, (index) {
                          return CioCard(
                            registro: _animal.registrosCio[index],
                            onRemover: () {
                              _animal.removerRegistroCio(index);
                              widget.controller.editarAnimal(_animal);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Registro de cio removido'),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                            },
                          );
                        }),
                      ],
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
            ],

            // Histórico de vacinas
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.medical_services,
                              color: Color(0xFF4CAF50),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Controle de Vacinas',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: Icon(Icons.add, color: Color(0xFF4CAF50)),
                          onPressed: _adicionarVacina,
                          tooltip: 'Adicionar Vacina',
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    if (_animal.vacinas.isEmpty)
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.orange.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning_amber, color: Colors.orange),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Nenhuma vacina registrada',
                                style: TextStyle(color: Colors.orange[800]),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ...List.generate(_animal.vacinas.length, (index) {
                        return VacinaCard(
                          vacina: _animal.vacinas[index],
                          onRemover: () {
                            _animal.removerVacina(index);
                            widget.controller.editarAnimal(_animal);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Vacina removida'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          },
                        );
                      }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    String label,
    String valor,
    IconData icone, {
    Color? cor,
  }) {
    Color corFinal = cor ?? Color(0xFF4CAF50);
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: corFinal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icone, color: corFinal, size: 20),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 2),
          Text(
            valor,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Color _getCorTipo(TipoAnimal tipo) {
    switch (tipo) {
      case TipoAnimal.boi:
        return Colors.brown[600]!;
      case TipoAnimal.vaca:
        return Colors.pink[600]!;
      case TipoAnimal.bezerro:
        return Colors.orange[600]!;
      case TipoAnimal.bezerra:
        return Colors.deepOrange[600]!;
      case TipoAnimal.novilha:
        return Colors.purple[600]!;
    }
  }
}
