import 'package:flutter/material.dart';
import '../models/animal.dart';

class AnimalCard extends StatelessWidget {
  final Animal animal;
  final VoidCallback onTap;
  final bool modoSelecao;
  final bool selecionado;

  const AnimalCard({
    super.key,
    required this.animal,
    required this.onTap,
    this.modoSelecao = false,
    this.selecionado = false,
  });

  @override
  Widget build(BuildContext context) {
    Color corTipo = _getCorTipo(animal.tipo);

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: selecionado ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: selecionado
            ? BorderSide(color: Color(0xFF4CAF50), width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: selecionado ? Color(0xFF4CAF50).withOpacity(0.05) : null,
          ),
          child: Row(
            children: [
              // Checkbox ou avatar
              if (modoSelecao)
                Container(
                  margin: EdgeInsets.only(right: 16),
                  child: Checkbox(
                    value: selecionado,
                    onChanged: (_) => onTap,
                    activeColor: Color(0xFF4CAF50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                )
              else
                Container(
                  margin: EdgeInsets.only(right: 16),
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: corTipo,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Center(
                    child: Text(
                      animal.identificacao.length >= 2
                          ? animal.identificacao.substring(0, 2).toUpperCase()
                          : animal.identificacao.toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),

              // Informações principais
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            color: corTipo.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: corTipo.withOpacity(0.3)),
                          ),
                          child: Text(
                            animal.tipoString,
                            style: TextStyle(
                              color: corTipo,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 8),

                    // Primeira linha: Idade e Vacina
                    Row(
                      children: [
                        Icon(Icons.cake, size: 16, color: Colors.grey[600]),
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

                    // Segunda linha: Cio (apenas para fêmeas)
                    if (animal.podeTerCio) ...[
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.favorite,
                            size: 16,
                            color: animal.corStatusCio,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Cio: ${animal.statusCio}',
                            style: TextStyle(
                              color: animal.corStatusCio,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],

                    if (animal.observacao.isNotEmpty) ...[
                      SizedBox(height: 6),
                      Text(
                        animal.observacao,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // Seta indicadora
              if (!modoSelecao)
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
            ],
          ),
        ),
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
