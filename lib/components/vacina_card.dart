import 'package:flutter/material.dart';
import '../models/animal.dart';

class VacinaCard extends StatelessWidget {
  final Vacina vacina;
  final VoidCallback onRemover;

  const VacinaCard({super.key, required this.vacina, required this.onRemover});

  String _formatarData(DateTime? data) {
    if (data == null) return '-';
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
  }

  @override
  Widget build(BuildContext context) {
    bool vencida =
        vacina.proximaData != null &&
        vacina.proximaData!.isBefore(DateTime.now());
    bool proximaVencer =
        vacina.proximaData != null &&
        vacina.proximaData!.isAfter(DateTime.now()) &&
        vacina.proximaData!.isBefore(DateTime.now().add(Duration(days: 30)));

    Color cor = vencida
        ? Colors.red
        : proximaVencer
        ? Colors.orange
        : Colors.green;

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: cor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(Icons.vaccines, color: cor, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vacina.nome,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Aplicada: ${_formatarData(vacina.dataAplicacao)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                if (vacina.proximaData != null) ...[
                  SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.schedule, size: 14, color: cor),
                      SizedBox(width: 4),
                      Text(
                        'Próxima: ${_formatarData(vacina.proximaData!)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: cor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (vencida) ...[
                        SizedBox(width: 8),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'VENCIDA',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red[400]),
            onPressed: onRemover,
          ),
        ],
      ),
    );
  }
}
