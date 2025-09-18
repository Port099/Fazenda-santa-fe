import 'package:flutter/material.dart';

enum TipoLote { lote1, lote2, lote3, lote4, curral }

class Lote {
  final TipoLote tipo;
  final String nome;
  final String descricao;
  final IconData icone;
  final Color cor;
  final Color corSecundaria;
  final int capacidadeMaxima;
  final int quantidadeAtual;

  const Lote({
    required this.tipo,
    required this.nome,
    required this.descricao,
    required this.icone,
    required this.cor,
    required this.corSecundaria,
    this.capacidadeMaxima = 100,
    this.quantidadeAtual = 0,
  });

  String get id => tipo.toString().split('.').last;

  double get percentualOcupacao => quantidadeAtual / capacidadeMaxima;

  String get statusOcupacao {
    if (percentualOcupacao >= 0.9) return 'Lotado';
    if (percentualOcupacao >= 0.7) return 'Ocupado';
    if (percentualOcupacao >= 0.3) return 'Moderado';
    return 'Disponível';
  }

  Color get corStatus {
    if (percentualOcupacao >= 0.9) return Colors.red;
    if (percentualOcupacao >= 0.7) return Colors.orange;
    if (percentualOcupacao >= 0.3) return Colors.yellow;
    return Colors.green;
  }

  static List<Lote> get todosOsLotes => [
    Lote(
      tipo: TipoLote.lote1,
      nome: 'Lote 1',
      descricao: 'Área de pastagem ',
      icone: Icons.grass,
      cor: Color(0xFF2E7D32),
      corSecundaria: Color(0xFF4CAF50),
      capacidadeMaxima: 80,
      quantidadeAtual: 65,
    ),
    Lote(
      tipo: TipoLote.lote2,
      nome: 'Lote 2',
      descricao: 'Pastagem para reprodução',
      icone: Icons.eco,
      cor: Color(0xFF388E3C),
      corSecundaria: Color(0xFF66BB6A),
      capacidadeMaxima: 60,
      quantidadeAtual: 42,
    ),
    Lote(
      tipo: TipoLote.lote3,
      nome: 'Lote 3',
      descricao: 'Área de engorda',
      icone: Icons.nature,
      cor: Color(0xFF43A047),
      corSecundaria: Color(0xFF81C784),
      capacidadeMaxima: 70,
      quantidadeAtual: 28,
    ),
    Lote(
      tipo: TipoLote.lote4,
      nome: 'Lote 4',
      descricao: 'Pastagem de reserva',
      icone: Icons.park,
      cor: Color(0xFF689F38),
      corSecundaria: Color(0xFF9CCC65),
      capacidadeMaxima: 50,
      quantidadeAtual: 15,
    ),
    Lote(
      tipo: TipoLote.curral,
      nome: 'Curral',
      descricao: 'Área de manejo e cuidados',
      icone: Icons.home_work,
      cor: Color(0xFF5D4037),
      corSecundaria: Color(0xFF8D6E63),
      capacidadeMaxima: 30,
      quantidadeAtual: 8,
    ),
  ];

  static Lote? getLotePorId(String id) {
    try {
      return todosOsLotes.firstWhere((lote) => lote.id == id);
    } catch (e) {
      return null;
    }
  }

  static Lote? getLotePorTipo(TipoLote tipo) {
    try {
      return todosOsLotes.firstWhere((lote) => lote.tipo == tipo);
    } catch (e) {
      return null;
    }
  }
}

class LotesDashboard extends StatefulWidget {
  @override
  _LotesDashboardState createState() => _LotesDashboardState();
}

class _LotesDashboardState extends State<LotesDashboard>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          'Sistema de Lotes',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              _animationController.reset();
              _animationController.forward();
            },
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildResumoGeral(),
            Expanded(child: _buildGridLotes()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Ação para adicionar novo lote ou animal
        },
        backgroundColor: Color(0xFF4CAF50),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildResumoGeral() {
    final totalAnimais = Lote.todosOsLotes.fold(
      0,
      (sum, lote) => sum + lote.quantidadeAtual,
    );
    final capacidadeTotal = Lote.todosOsLotes.fold(
      0,
      (sum, lote) => sum + lote.capacidadeMaxima,
    );

    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildResumoItem(
            'Total de Animais',
            totalAnimais.toString(),
            Icons.pets,
            Color(0xFF4CAF50),
          ),
          _buildDivider(),
          _buildResumoItem(
            'Capacidade Total',
            capacidadeTotal.toString(),
            Icons.warehouse,
            Color(0xFF2196F3),
          ),
          _buildDivider(),
          _buildResumoItem(
            'Taxa de Ocupação',
            '${((totalAnimais / capacidadeTotal) * 100).toStringAsFixed(1)}%',
            Icons.pie_chart,
            Color(0xFFFF9800),
          ),
        ],
      ),
    );
  }

  Widget _buildResumoItem(
    String titulo,
    String valor,
    IconData icone,
    Color cor,
  ) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: cor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icone, color: cor, size: 24),
        ),
        SizedBox(height: 8),
        Text(
          valor,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: cor,
          ),
        ),
        Text(
          titulo,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(height: 50, width: 1, color: Colors.grey[300]);
  }

  Widget _buildGridLotes() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        itemCount: Lote.todosOsLotes.length,
        itemBuilder: (context, index) {
          return _buildLoteCard(Lote.todosOsLotes[index], index);
        },
      ),
    );
  }

  Widget _buildLoteCard(Lote lote, int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 100)),
      curve: Curves.easeOutBack,
      child: GestureDetector(
        onTap: () => _mostrarDetalhesLote(lote),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: lote.cor.withOpacity(0.3),
                blurRadius: 15,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [lote.cor, lote.corSecundaria],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Center(
                  child: Icon(lote.icone, size: 40, color: Colors.white),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lote.nome,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        lote.descricao,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Spacer(),
                      _buildBarraProgresso(lote),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${lote.quantidadeAtual}/${lote.capacidadeMaxima}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: lote.corStatus.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              lote.statusOcupacao,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: lote.corStatus.withOpacity(0.8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBarraProgresso(Lote lote) {
    return Container(
      height: 6,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(3),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: lote.percentualOcupacao,
        child: Container(
          decoration: BoxDecoration(
            color: lote.cor,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }

  void _mostrarDetalhesLote(Lote lote) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildDetalhesLote(lote),
    );
  }

  Widget _buildDetalhesLote(Lote lote) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
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
          Container(
            height: 100,
            margin: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [lote.cor, lote.corSecundaria]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(lote.icone, size: 40, color: Colors.white),
                  SizedBox(height: 8),
                  Text(
                    lote.nome,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informações Detalhadas',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  _buildInfoItem('Descrição', lote.descricao),
                  _buildInfoItem('Animais Atuais', '${lote.quantidadeAtual}'),
                  _buildInfoItem(
                    'Capacidade Máxima',
                    '${lote.capacidadeMaxima}',
                  ),
                  _buildInfoItem(
                    'Taxa de Ocupação',
                    '${(lote.percentualOcupacao * 100).toStringAsFixed(1)}%',
                  ),
                  _buildInfoItem('Status', lote.statusOcupacao),
                  Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Ação para editar lote
                          },
                          icon: Icon(Icons.edit),
                          label: Text('Editar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: lote.cor,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.close),
                          label: Text('Fechar'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: lote.cor,
                            side: BorderSide(color: lote.cor),
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String titulo, String valor) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              titulo + ':',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: TextStyle(fontSize: 14, color: Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }
}

// Exemplo de uso
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistema de Lotes',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LotesDashboard(),
      debugShowCheckedModeBanner: false,
    );
  }
}
