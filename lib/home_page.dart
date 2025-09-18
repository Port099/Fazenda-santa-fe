import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Função para adicionar dados
  Future<void> adicionarMensagem(String texto) async {
    await _firestore.collection('mensagens').add({
      'texto': texto,
      'timestamp': FieldValue.serverTimestamp(),
      'usuario': 'Usuario${DateTime.now().millisecondsSinceEpoch % 100}',
    });
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController _controller = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text('Chat em Tempo Real'),
      ),
      body: Column(
        children: [
          // Lista de mensagens em tempo real
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('mensagens')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                final mensagens = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: mensagens.length,
                  itemBuilder: (context, index) {
                    final dados =
                        mensagens[index].data() as Map<String, dynamic>;

                    return ListTile(
                      title: Text(dados['texto'] ?? ''),
                      subtitle: Text('Por: ${dados['usuario'] ?? 'Anônimo'}'),
                      trailing: dados['timestamp'] != null
                          ? Text((dados['timestamp'] as Timestamp)
                              .toDate()
                              .toString()
                              .substring(11, 16))
                          : null,
                    );
                  },
                );
              },
            ),
          ),

          // Campo para enviar mensagem
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Digite sua mensagem...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (_controller.text.trim().isNotEmpty) {
                      adicionarMensagem(_controller.text.trim());
                      _controller.clear();
                    }
                  },
                  child: Text('Enviar'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
