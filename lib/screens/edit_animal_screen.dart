import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/animal.dart';
import '../models/lote.dart';
import '../controllers/fazenda_controller.dart';

class EditAnimalScreen extends StatefulWidget {
  final Animal animal;
  final FazendaController controller;

  const EditAnimalScreen({
    super.key,
    required this.animal,
    required this.controller,
  });

  @override
  _EditAnimalScreenState createState() => _EditAnimalScreenState();
}

class _EditAnimalScreenState extends State<EditAnimalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identificacaoController = TextEditingController();
  final _mesesController = TextEditingController();
  final _observacaoController = TextEditingController();

  late TipoAnimal _tipoSelecionado;
  late String _loteSelecionado;
  bool _carregando = false;
  bool _alteracoesPendentes = false;

  @override
  void initState() {
    super.initState();
    _inicializarDados();
  }

  void _inicializarDados() {
    _identificacaoController.text = widget.animal.identificacao;
    _mesesController.text = widget.animal.meses.toString();
    _observacaoController.text = widget.animal.observacao;
    _tipoSelecionado = widget.animal.tipo;
    _loteSelecionado = widget.animal.loteAtual;

    // Listeners para detectar mudanças
    _identificacaoController.addListener(_marcarAlteracoesPendentes);
    _mesesController.addListener(_marcarAlteracoesPendentes);
    _observacaoController.addListener(_marcarAlteracoesPendentes);
  }

  void _marcarAlteracoesPendentes() {
    if (!_alteracoesPendentes) {
      setState(() {
        _alteracoesPendentes = true;
      });
    }
  }

  @override
  void dispose() {
    _identificacaoController.dispose();
    _mesesController.dispose();
    _observacaoController.dispose();
    super.dispose();
  }

  Future<bool> _confirmarSaida() async {
    if (!_alteracoesPendentes) return true;

    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Alterações não salvas'),
            content: Text(
              'Você tem alterações não salvas. Deseja sair mesmo assim?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Sair', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _salvarAlteracoes() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _carregando = true;
      });

      try {
        // Simula um pequeno delay para UX
        await Future.delayed(Duration(milliseconds: 500));

        Animal animalEditado = widget.animal.copyWith(
          identificacao: _identificacaoController.text.trim(),
          tipo: _tipoSelecionado,
          meses: int.parse(_mesesController.text.trim()),
          loteAtual: _loteSelecionado,
          observacao: _observacaoController.text.trim(),
        );

        widget.controller.editarAnimal(animalEditado);

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Animal ${animalEditado.identificacao} editado com sucesso!',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erro: ${e.toString().replaceAll('Exception: ', '')}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _carregando = false;
        });
      }
    }
  }

  String? _validarIdentificacao(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor, insira uma identificação';
    }

    String identificacao = value.trim();

    if (identificacao.length < 2) {
      return 'Identificação deve ter pelo menos 2 caracteres';
    }

    if (identificacao.length > 10) {
      return 'Identificação deve ter no máximo 10 caracteres';
    }

    // Verifica se já existe (exceto o atual)
    if (identificacao != widget.animal.identificacao) {
      if (widget.controller
          .buscarAnimaisPorIdentificacao(identificacao)
          .any(
            (animal) =>
                animal.identificacao.toLowerCase() ==
                    identificacao.toLowerCase() &&
                animal.id != widget.animal.id,
          )) {
        return 'Esta identificação já existe';
      }
    }

    return null;
  }

  String? _validarMeses(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor, insira a idade em meses';
    }

    int? meses = int.tryParse(value.trim());
    if (meses == null) {
      return 'Por favor, insira um número válido';
    }

    if (meses < 0) {
      return 'A idade não pode ser negativa';
    }

    if (meses > 360) {
      return 'Idade muito alta (máximo 360 meses/30 anos)';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _confirmarSaida,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Editar ${widget.animal.identificacao}'),
          actions: [
            if (_carregando)
              Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Banner de alterações pendentes
                if (_alteracoesPendentes)
                  Container(
                    margin: EdgeInsets.only(bottom: 16),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: Colors.orange, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Você tem alterações não salvas',
                            style: TextStyle(
                              color: Colors.orange[800],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Identificação
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.tag, color: Color(0xFF4CAF50)),
                            SizedBox(width: 8),
                            Text(
                              'Identificação',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: _identificacaoController,
                          decoration: InputDecoration(
                            labelText: 'Código de Identificação',
                            hintText: 'Ex: B001, V002, N003',
                            prefixIcon: Icon(Icons.qr_code),
                          ),
                          textCapitalization: TextCapitalization.characters,
                          validator: _validarIdentificacao,
                          enabled: !_carregando,
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 16),

                // Tipo do Animal
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.pets, color: Color(0xFF4CAF50)),
                            SizedBox(width: 8),
                            Text(
                              'Tipo do Animal',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: TipoAnimal.values.map((tipo) {
                            bool selecionado = _tipoSelecionado == tipo;
                            Color cor = _getCorTipo(tipo);

                            return FilterChip(
                              selected: selecionado,
                              label: Text(
                                _getTipoString(tipo),
                                style: TextStyle(
                                  color: selecionado ? Colors.white : cor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              avatar: Icon(
                                _getIconeTipo(tipo),
                                color: selecionado ? Colors.white : cor,
                                size: 18,
                              ),
                              selectedColor: cor,
                              checkmarkColor: Colors.white,
                              onSelected: _carregando ? null : (selected) {},
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 16),

                // Idade e Lote
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.cake, color: Color(0xFF4CAF50)),
                                  SizedBox(width: 8),
                                  Text(
                                    'Idade',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2E7D32),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              TextFormField(
                                controller: _mesesController,
                                decoration: InputDecoration(
                                  labelText: 'Meses',
                                  hintText: '24',
                                  suffixText: 'meses',
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                validator: _validarMeses,
                                enabled: !_carregando,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    color: Color(0xFF4CAF50),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Lote',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2E7D32),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                value: _loteSelecionado,
                                decoration: InputDecoration(
                                  labelText: 'Selecionar Lote',
                                ),
                                items: Lote.todosOsLotes.map((lote) {
                                  return DropdownMenuItem(
                                    value: lote.id,
                                    child: Row(
                                      children: [
                                        Icon(
                                          lote.icone,
                                          color: lote.cor,
                                          size: 16,
                                        ),
                                        SizedBox(width: 8),
                                        Text(lote.nome),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: _carregando
                                    ? null
                                    : (value) {
                                        if (value != null &&
                                            value != _loteSelecionado) {
                                          setState(() {
                                            _loteSelecionado = value;
                                            _marcarAlteracoesPendentes();
                                          });
                                        }
                                      },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16),

                // Observações
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
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: _observacaoController,
                          decoration: InputDecoration(
                            labelText: 'Observações',
                            hintText: 'Ex: Animal saudável, boa reprodução...',
                            alignLabelWithHint: true,
                          ),
                          maxLines: 3,
                          enabled: !_carregando,
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 16),

                // Informações adicionais
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: Color(0xFF4CAF50)),
                            SizedBox(width: 8),
                            Text(
                              'Informações',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        _buildInfoRow('ID do Sistema', widget.animal.id),
                        _buildInfoRow(
                          'Data de Cadastro',
                          _formatarData(widget.animal.dataCadastro),
                        ),
                        if (widget.animal.dataUltimaTransferencia != null)
                          _buildInfoRow(
                            'Última Transferência',
                            _formatarData(
                              widget.animal.dataUltimaTransferencia!,
                            ),
                          ),
                        _buildInfoRow(
                          'Total de Vacinas',
                          widget.animal.vacinas.length.toString(),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 32),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 5,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _carregando
                      ? null
                      : () async {
                          if (await _confirmarSaida()) {
                            Navigator.pop(context);
                          }
                        },
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Cancelar'),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: (_carregando || !_alteracoesPendentes)
                      ? null
                      : _salvarAlteracoes,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: _carregando
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              Text('Salvando...'),
                            ],
                          )
                        : Text('Salvar Alterações'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String valor) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/'
        '${data.month.toString().padLeft(2, '0')}/'
        '${data.year}';
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

  IconData _getIconeTipo(TipoAnimal tipo) {
    switch (tipo) {
      case TipoAnimal.boi:
        return Icons.agriculture;
      case TipoAnimal.vaca:
        return Icons.pets;
      case TipoAnimal.bezerro:
        return Icons.child_care;
      case TipoAnimal.bezerra:
        return Icons.child_care;
      case TipoAnimal.novilha:
        return Icons.favorite;
    }
  }

  String _getTipoString(TipoAnimal tipo) {
    switch (tipo) {
      case TipoAnimal.boi:
        return 'Boi';
      case TipoAnimal.vaca:
        return 'Vaca';
      case TipoAnimal.bezerro:
        return 'Bezerro';
      case TipoAnimal.bezerra:
        return 'Bezerra';
      case TipoAnimal.novilha:
        return 'Novilha';
    }
  }
}
