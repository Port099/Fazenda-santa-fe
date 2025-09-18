import 'add_animal_screen.dart';
import 'package:flutter/material.dart';
import '../controllers/fazenda_controller.dart';
import '../models/lote.dart';
import '../components/estatisticas_card.dart';
import 'lote_screen.dart';
import 'vendas_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late FazendaController _controller;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = FazendaController();
    _controller.addListener(() {
      setState(() {});
    });

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
    _controller.dispose();
    super.dispose();
  }

  void _navegarParaLote(Lote lote) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            LoteScreen(lote: lote, controller: _controller),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var begin = Offset(1.0, 0.0);
          var end = Offset.zero;
          var curve = Curves.ease;
          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  void _navegarParaVendas() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            VendasScreen(controller: _controller),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var begin = Offset(1.0, 0.0);
          var end = Offset.zero;
          var curve = Curves.ease;
          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Map<String, int> estatisticasLote = _controller.getEstatisticasPorLote();

    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            // App Bar melhorado com gradiente e informações (sem botão de vendas)
            SliverAppBar(
              expandedHeight: 160,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF1B5E20),
                        Color(0xFF2E7D32),
                        Color(0xFF4CAF50),
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Padrão de fundo
                      Positioned.fill(
                        child: CustomPaint(painter: BackgroundPatternPainter()),
                      ),
                      // Conteúdo do header
                      Positioned(
                        bottom: 20,
                        left: 20,
                        right: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.agriculture,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Fazenda Santa Fé',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'Sistema de Gestão Pecuária',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.9),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Estatísticas aprimoradas
            SliverToBoxAdapter(
              child: Container(
                margin: EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resumo Geral',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    SizedBox(height: 12),
                    EstatisticasCard(controller: _controller),
                  ],
                ),
              ),
            ),

            // Seção de Ações Rápidas (sem vendas, com transferência no lugar de vacinas)
            SliverToBoxAdapter(
              child: Container(
                margin: EdgeInsets.fromLTRB(16, 24, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.flash_on,
                          color: Color(0xFF2E7D32),
                          size: 24,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Ações Rápidas',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildBotaoAcaoRapida(
                            icon: Icons.sell,
                            label: 'Vendas',
                            color: Colors.green,
                            onTap: _navegarParaVendas,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _buildBotaoAcaoRapida(
                            icon: Icons.pets,
                            label: 'Adicionar',
                            color: Colors.blue,
                            onTap: _mostrarDialogoAdicionar,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Título dos lotes com filtro
            SliverToBoxAdapter(
              child: Container(
                margin: EdgeInsets.fromLTRB(16, 24, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Color(0xFF2E7D32),
                          size: 24,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Lotes e Áreas',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Color(0xFF4CAF50).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${Lote.todosOsLotes.length} lotes',
                        style: TextStyle(
                          color: Color(0xFF2E7D32),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Grid de lotes melhorado
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.9,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  Lote lote = Lote.todosOsLotes[index];
                  int quantidadeAnimais = estatisticasLote[lote.id] ?? 0;

                  return AnimatedContainer(
                    duration: Duration(milliseconds: 300 + (index * 100)),
                    curve: Curves.easeOutBack,
                    child: _buildLoteCardEnhanced(
                      lote: lote,
                      quantidadeAnimais: quantidadeAnimais,
                      onTap: () => _navegarParaLote(lote),
                    ),
                  );
                }, childCount: Lote.todosOsLotes.length),
              ),
            ),

            // Espaçamento final
            SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarOpcoesRapidas,
        backgroundColor: Color(0xFF4CAF50),
        elevation: 8,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBotaoAcaoRapida({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 2,
      shadowColor: color.withOpacity(0.2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoteCardEnhanced({
    required Lote lote,
    required int quantidadeAnimais,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 4,
      shadowColor: Color(0xFF4CAF50).withOpacity(0.2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Color(0xFF4CAF50).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.grass,
                      color: Color(0xFF4CAF50),
                      size: 20,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: quantidadeAnimais > 0
                          ? Color(0xFF4CAF50).withOpacity(0.2)
                          : Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$quantidadeAnimais',
                      style: TextStyle(
                        color: quantidadeAnimais > 0
                            ? Color(0xFF2E7D32)
                            : Colors.grey[600],
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                lote.nome,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 4),
              Text(
                lote.descricao,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              Spacer(),
              Row(
                children: [
                  Icon(Icons.pets, size: 16, color: Color(0xFF4CAF50)),
                  SizedBox(width: 4),
                  Text(
                    quantidadeAnimais > 0
                        ? '$quantidadeAnimais animais'
                        : 'Vazio',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF2E7D32),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarOpcoesRapidas() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: EdgeInsets.all(24),
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
            SizedBox(height: 24),
            Text(
              'Ações Rápidas',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
            SizedBox(height: 24),
            _buildOpcaoRapidaEnhanced(
              icon: Icons.sell,
              titulo: 'Sistema de Vendas',
              subtitulo: 'Vender animais com cálculo automático',
              color: Colors.green,
              onTap: () {
                Navigator.pop(context);
                _navegarParaVendas();
              },
            ),
            _buildOpcaoRapidaEnhanced(
              icon: Icons.pets,
              titulo: 'Adicionar Animal',
              subtitulo: 'Cadastrar novo animal no sistema',
              color: Color(0xFF4CAF50),
              onTap: () {
                Navigator.pop(context);
                _mostrarDialogoAdicionar();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOpcaoRapidaEnhanced({
    required IconData icon,
    required String titulo,
    required String subtitulo,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        subtitulo,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _mostrarDialogoAdicionar() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            AddAnimalScreen(controller: _controller),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var begin = Offset(1.0, 0.0);
          var end = Offset.zero;
          var curve = Curves.ease;
          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }
}

// Custom Painter para o padrão de fundo do header
class BackgroundPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 20; i++) {
      for (int j = 0; j < 10; j++) {
        final x = (i * 40.0) - 20;
        final y = (j * 40.0) - 20;
        canvas.drawCircle(Offset(x, y), 2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
// Botão para criar usuários (remover depois)
// Removido ElevatedButton fora de função/classe para evitar erro de compilação.
