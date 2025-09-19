import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Lista dos usuários autorizados da fazenda
  static const List<Map<String, String>> usuariosAutorizados = [
    {
      'email': 'ericklindo123lindo@gmail.com',
      'nome': 'Erick Porto',
      'funcao': 'Proprietário'
    },
  ];

  // Obter usuário atual
  User? get currentUser => _auth.currentUser;

  // Stream do estado de autenticação
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Verificar se usuário está logado
  bool get isLoggedIn => _auth.currentUser != null;

  // Login
  Future<UserCredential?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Verificar se usuário está autorizado
      if (!isUserAuthorized(email)) {
        await signOut(); // Deslogar se não autorizado
        throw FirebaseAuthException(
          code: 'unauthorized-user',
          message: 'Usuário não autorizado para acessar este sistema.',
        );
      }

      // Salvar dados do usuário no Firestore
      await _saveUserData(result.user!);

      return result;
    } catch (e) {
      rethrow;
    }
  }

  // Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Verificar se usuário está na lista autorizada
  bool isUserAuthorized(String email) {
    return usuariosAutorizados.any((user) => user['email'] == email.trim());
  }

  // Obter dados do usuário autorizado
  Map<String, String>? getUserData(String email) {
    return usuariosAutorizados.firstWhere(
      (user) => user['email'] == email.trim(),
      orElse: () => {},
    );
  }

  // Salvar dados do usuário no Firestore
  Future<void> _saveUserData(User user) async {
    final userData = getUserData(user.email!);
    if (userData != null && userData.isNotEmpty) {
      await _firestore.collection('usuarios').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'nome': userData['nome'],
        'funcao': userData['funcao'],
        'ultimo_acesso': FieldValue.serverTimestamp(),
        'ativo': true,
      }, SetOptions(merge: true));
    }
  }

  // Registrar log de acesso
  Future<void> logUserAccess(String action) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('logs_acesso').add({
        'usuario_id': user.uid,
        'email': user.email,
        'acao': action,
        'timestamp': FieldValue.serverTimestamp(),
        'dispositivo': 'mobile_app',
      });
    }
  }

  // Criar todos os usuários automaticamente (usar apenas uma vez)
  Future<void> createAllUsers() async {
    const String defaultPassword = 'fazenda2024'; // Senha padrão

    for (var userData in usuariosAutorizados) {
      try {
        // Criar usuário no Firebase Auth
        UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: userData['email']!,
          password: defaultPassword,
        );

        // Salvar dados no Firestore
        await _firestore.collection('usuarios').doc(result.user!.uid).set({
          'uid': result.user!.uid,
          'email': userData['email'],
          'nome': userData['nome'],
          'funcao': userData['funcao'],
          'criado_em': FieldValue.serverTimestamp(),
          'ativo': true,
        });

        print('Usuário criado: ${userData['email']}');
      } catch (e) {
        print('Erro ao criar usuário ${userData['email']}: $e');
      }
    }

    // Fazer logout após criar todos
    await signOut();
  }

  // Resetar senha de um usuário
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }

  // Obter informações do usuário atual
  Future<Map<String, dynamic>?> getCurrentUserInfo() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('usuarios').doc(user.uid).get();
      return doc.data();
    }
    return null;
  }
}
