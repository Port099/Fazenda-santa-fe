import 'package:flutter/material.dart';
import '../models/animal.dart';

class CioCard extends StatelessWidget {
  final RegistroCio registro;
  final VoidCallback? onRemover;

  const CioCard({super.key, required this.registro, this.onRemover});

  @override
  Widget build(BuildContext context) {
    DateTime agora = DateTime.now();
    bool isProximoCioAtrasado =
        registro.previsaoProximoCio != null &&
        registro.previsaoProximoCio!.isBefore(agora);
    bool isProximoCioProximo =
        registro.previsaoProximoCio != null &&
        !isProximoCioAtrasado &&
        registro.previsaoProximoCio!.difference(agora).inDays <= 3;

    Color corStatus = isProximoCioAtrasado
        ? Colors.red
        : isProximoCioProximo
        ? Colors.orange
        : Colors.blue;

    return Card(
      margin: EdgeInsets.symmetric(vertical: 4),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.pink.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.favorite,
                        color: Colors.pink[600],
                        size: 16,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      _formatarData(registro.data),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
                if (onRemover != null)
                  IconButton(
                    icon: Icon(Icons.delete_outline, size: 18),
                    color: Colors.grey[600],
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Confirmar Exclusão'),
                          content: Text('Deseja remover este registro de cio?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                onRemover!();
                              },
                              child: Text(
                                'Remover',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),

            if (registro.previsaoProximoCio != null) ...[
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.schedule, size: 14, color: corStatus),
                  SizedBox(width: 4),
                  Text(
                    'Próximo previsto: ${_formatarData(registro.previsaoProximoCio!)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: corStatus,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: corStatus.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _getStatusProximoCio(),
                      style: TextStyle(
                        fontSize: 10,
                        color: corStatus,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            if (registro.observacao != null &&
                registro.observacao!.isNotEmpty) ...[
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.note, size: 14, color: Colors.grey[600]),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        registro.observacao!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/'
        '${data.month.toString().padLeft(2, '0')}/'
        '${data.year}';
  }

  String _getStatusProximoCio() {
    if (registro.previsaoProximoCio == null) return '';

    DateTime agora = DateTime.now();
    int diasDiferenca = registro.previsaoProximoCio!.difference(agora).inDays;

    if (diasDiferenca < 0) {
      return '${diasDiferenca.abs()} dias atrasado';
    } else if (diasDiferenca == 0) {
      return 'Hoje';
    } else if (diasDiferenca <= 3) {
      return 'Em $diasDiferenca dias';
    } else {
      return 'Em $diasDiferenca dias';
    }
  }
}
