import 'package:flutter/material.dart';
import '../models/lote.dart';

class LoteCard extends StatelessWidget {
  final Lote lote;
  final int quantidadeAnimais;
  final VoidCallback onTap;

  const LoteCard({
    super.key,
    required this.lote,
    required this.quantidadeAnimais,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    double ocupacao = quantidadeAnimais / lote.capacidadeMaxima;
    Color corOcupacao = _getCorOcupacao(ocupacao);

    return Card(
      margin: EdgeInsets.all(0),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [lote.cor.withOpacity(0.1), lote.cor.withOpacity(0.05)],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header com ícone e status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: lote.cor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(lote.icone, color: Colors.white, size: 24),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: corOcupacao.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: corOcupacao, width: 1),
                    ),
                    child: Text(
                      '${(ocupacao * 100).toInt()}%',
                      style: TextStyle(
                        color: corOcupacao,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16),

              // Nome do lote
              Text(
                lote.nome,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),

              SizedBox(height: 4),

              // Descrição
              Text(
                lote.descricao,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              Spacer(),

              // Informações de ocupação
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.pets, size: 16, color: lote.cor),
                      SizedBox(width: 4),
                      Text(
                        '$quantidadeAnimais animais',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 8),

                  // Barra de progresso
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: ocupacao.clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: corOcupacao,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 4),

                  Text(
                    'Capacidade: ${lote.capacidadeMaxima}',
                    style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCorOcupacao(double ocupacao) {
    if (ocupacao >= 0.9) return Colors.red;
    if (ocupacao >= 0.7) return Colors.orange;
    if (ocupacao >= 0.4) return Colors.green;
    return Colors.blue;
  }
}
