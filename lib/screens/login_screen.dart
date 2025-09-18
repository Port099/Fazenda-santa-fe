import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;

  // Lista dos usuários autorizados da fazenda
  final List<Map<String, String>> usuariosAutorizados = [
    {'email': 'ericklindo123lindo@gmail.com', 'nome': 'Erick Porto'},
  ];

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Fazer login no Firebase
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Verificar se o usuário está na lista autorizada
      String userEmail = userCredential.user?.email ?? '';
      bool isAuthorized =
          usuariosAutorizados.any((user) => user['email'] == userEmail);

      if (isAuthorized) {
        // Usuário autorizado - navegar para home
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        }
      } else {
        // Usuário não autorizado - fazer logout e mostrar erro
        await FirebaseAuth.instance.signOut();
        _showError('Usuário não autorizado para acessar este sistema.');
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Erro no login';

      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'Usuário não encontrado.';
          break;
        case 'wrong-password':
          errorMessage = 'Senha incorreta.';
          break;
        case 'invalid-email':
          errorMessage = 'Email inválido.';
          break;
        case 'too-many-requests':
          errorMessage = 'Muitas tentativas. Tente novamente mais tarde.';
          break;
        default:
          errorMessage = 'Erro: ${e.message}';
      }

      _showError(errorMessage);
    } catch (e) {
      _showError('Erro inesperado: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FBF9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            children: [
              SizedBox(height: 60),

              // Logo/Título
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Color(0xFF4CAF50),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.agriculture,
                  size: 60,
                  color: Colors.white,
                ),
              ),

              SizedBox(height: 24),

              Text(
                'Fazenda Santa Fé',
                style: Theme.of(context).textTheme.displayMedium,
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 8),

              Text(
                'Acesso restrito aos funcionários',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Color(0xFF616161),
                    ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 48),

              // Formulário de login
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Campo Email
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'Digite seu email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, digite seu email';
                        }
                        if (!value.contains('@')) {
                          return 'Digite um email válido';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 20),

                    // Campo Senha
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _login(),
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        hintText: 'Digite sua senha',
                        prefixIcon: Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, digite sua senha';
                        }
                        if (value.length < 6) {
                          return 'A senha deve ter pelo menos 6 caracteres';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 32),

                    // Botão de Login
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        child: _isLoading
                            ? SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                'ENTRAR',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 40),

              // Lista de usuários autorizados (para desenvolvimento)
              if (Theme.of(context).platform == TargetPlatform.android) ...[
                ExpansionTile(
                  title: Text(
                    'Usuários Autorizados',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF616161),
                    ),
                  ),
                  children: usuariosAutorizados.map((user) {
                    return ListTile(
                      title: Text(
                        user['nome']!,
                        style: TextStyle(fontSize: 14),
                      ),
                      subtitle: Text(
                        user['email']!,
                        style: TextStyle(fontSize: 12),
                      ),
                      onTap: () {
                        _emailController.text = user['email']!;
                      },
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
