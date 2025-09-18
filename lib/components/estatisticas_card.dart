import 'package:flutter/material.dart';
import '../controllers/fazenda_controller.dart';
import '../models/animal.dart';

class EstatisticasCard extends StatefulWidget {
  final FazendaController controller;

  const EstatisticasCard({super.key, required this.controller});

  @override
  State<EstatisticasCard> createState() => _EstatisticasCardState();
}

class _EstatisticasCardState extends State<EstatisticasCard>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late List<AnimationController> _cardAnimationControllers;
  late List<Animation<double>> _cardAnimations;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    // Criar animações para os cards
    _cardAnimationControllers = List.generate(
      7, // Total de cards (1 principal + 5 tipos + 2 vacinas)
      (index) => AnimationController(
        duration: Duration(milliseconds: 600),
        vsync: this,
      ),
    );

    _cardAnimations = _cardAnimationControllers.map((controller) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.elasticOut));
    }).toList();

    // Iniciar animações com delay
    _startAnimations();
  }

  void _startAnimations() async {
    for (int i = 0; i < _cardAnimationControllers.length; i++) {
      await Future.delayed(Duration(milliseconds: i * 100));
      if (mounted) {
        _cardAnimationControllers[i].forward();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    for (var controller in _cardAnimationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Map<TipoAnimal, int> estatisticasTipo = widget.controller
        .getEstatisticasPorTipo();
    int totalAnimais = widget.controller.totalAnimais;
    int vacinasAtrasadas = widget.controller.getAnimaisComVacinasAtrasadas();
    int semVacinas = widget.controller.getAnimaisSemVacinas();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Color(0xFF4CAF50).withOpacity(0.02),
            Colors.white,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF4CAF50).withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header melhorado com glass effect
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF4CAF50).withOpacity(0.1),
                      Color(0xFF81C784).withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Color(0xFF4CAF50).withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF4CAF50).withOpacity(0.4),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.analytics_outlined,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mapão Pecuário',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B5E20),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Visão geral do rebanho',
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
              ),

              SizedBox(height: 24),

              // Card principal com total - Design hero
              AnimatedBuilder(
                animation: _cardAnimations[0],
                builder: (context, child) {
                  return Transform.scale(
                    scale: _cardAnimations[0].value,
                    child: Container(
                      padding: EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF2E7D32),
                            Color(0xFF4CAF50),
                            Color(0xFF66BB6A),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF4CAF50).withOpacity(0.3),
                            blurRadius: 20,
                            offset: Offset(0, 8),
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              Icons.pets,
                              color: Colors.white,
                              size: 36,
                            ),
                          ),
                          SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total do Rebanho',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white.withOpacity(0.9),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      totalAnimais.toString(),
                                      style: TextStyle(
                                        fontSize: 40,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        height: 1.0,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Padding(
                                      padding: EdgeInsets.only(bottom: 8),
                                      child: Text(
                                        'cabeças',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white.withOpacity(0.8),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.trending_up,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: 32),

              // Título da distribuição
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Color(0xFF4CAF50),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Distribuição por Categoria',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),

              // Grid de categorias melhorado
              Row(
                children: [
                  Expanded(
                    child: AnimatedBuilder(
                      animation: _cardAnimations[1],
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(
                            0,
                            20 * (1 - _cardAnimations[1].value),
                          ),
                          child: Opacity(
                            opacity: _cardAnimations[1].value,
                            child: _buildCategoriaCard(
                              'Bois',
                              estatisticasTipo[TipoAnimal.boi] ?? 0,
                              Icons.male,
                              Color(0xFF795548),
                              '🐂',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: AnimatedBuilder(
                      animation: _cardAnimations[2],
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(
                            0,
                            20 * (1 - _cardAnimations[2].value),
                          ),
                          child: Opacity(
                            opacity: _cardAnimations[2].value,
                            child: _buildCategoriaCard(
                              'Vacas',
                              estatisticasTipo[TipoAnimal.vaca] ?? 0,
                              Icons.female,
                              Color(0xFFE91E63),
                              '🐄',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: AnimatedBuilder(
                      animation: _cardAnimations[3],
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(
                            0,
                            20 * (1 - _cardAnimations[3].value),
                          ),
                          child: Opacity(
                            opacity: _cardAnimations[3].value,
                            child: _buildCategoriaCard(
                              'Bezerros',
                              estatisticasTipo[TipoAnimal.bezerro] ?? 0,
                              Icons.child_friendly,
                              Color(0xFFFF9800),
                              '🐃',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: AnimatedBuilder(
                      animation: _cardAnimations[4],
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(
                            0,
                            20 * (1 - _cardAnimations[4].value),
                          ),
                          child: Opacity(
                            opacity: _cardAnimations[4].value,
                            child: _buildCategoriaCard(
                              'Bezerras',
                              estatisticasTipo[TipoAnimal.bezerra] ?? 0,
                              Icons.child_care,
                              Color(0xFFFF5722),
                              '🐄',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16),

              AnimatedBuilder(
                animation: _cardAnimations[5],
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, 20 * (1 - _cardAnimations[5].value)),
                    child: Opacity(
                      opacity: _cardAnimations[5].value,
                      child: _buildCategoriaCard(
                        'Novilhas',
                        estatisticasTipo[TipoAnimal.novilha] ?? 0,
                        Icons.favorite,
                        Color(0xFF9C27B0),
                        '🐮',
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: 32),

              // Título das vacinas
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Color(0xFFFF9800),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Status de Vacinação',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),

              // Cards de vacina melhorados
              Row(
                children: [
                  Expanded(
                    child: AnimatedBuilder(
                      animation: _cardAnimations[6],
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(
                            0,
                            20 * (1 - _cardAnimations[6].value),
                          ),
                          child: Opacity(
                            opacity: _cardAnimations[6].value,
                            child: _buildVacinaCard(
                              'Vacinas Atrasadas',
                              vacinasAtrasadas,
                              Color(0xFFE53E3E),
                              Icons.warning_amber_rounded,
                              '⚠️',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: AnimatedBuilder(
                      animation: _cardAnimations[6],
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(
                            0,
                            20 * (1 - _cardAnimations[6].value),
                          ),
                          child: Opacity(
                            opacity: _cardAnimations[6].value,
                            child: _buildVacinaCard(
                              'Sem Vacinas',
                              semVacinas,
                              Color(0xFFFF9800),
                              Icons.shield_outlined,
                              '🛡️',
                            ),
                          ),
                        );
                      },
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

  Widget _buildCategoriaCard(
    String nome,
    int quantidade,
    IconData icone,
    Color cor,
    String emoji,
  ) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cor.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: cor.withOpacity(0.1),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(emoji, style: TextStyle(fontSize: 20)),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: cor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icone, color: cor, size: 16),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            quantidade.toString(),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: cor,
            ),
          ),
          SizedBox(height: 4),
          Text(
            nome,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVacinaCard(
    String titulo,
    int quantidade,
    Color cor,
    IconData icone,
    String emoji,
  ) {
    bool isAlerta = quantidade > 0;

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAlerta ? cor.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
          width: isAlerta ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isAlerta
                ? cor.withOpacity(0.15)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(emoji, style: TextStyle(fontSize: 20)),
              ),
              Spacer(),
              if (isAlerta)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: cor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            quantidade.toString(),
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: isAlerta ? cor : Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            titulo,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
