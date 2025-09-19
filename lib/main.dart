import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Importar a HomeScreen real das suas outras telas
import 'screens/home_screen.dart'; // Ajuste o caminho conforme sua estrutura de pastas

void main() async {
  // Necessário para inicializar o Firebase
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Inicializa o Firebase
    await Firebase.initializeApp();
    runApp(FazendaApp());
  } catch (e) {
    print('Erro ao inicializar Firebase: $e');
    // Se der erro no Firebase, roda uma versão de erro
    runApp(FazendaAppError());
  }
}

class FazendaApp extends StatelessWidget {
  const FazendaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Fazenda Santa Fé",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Cores principais modernizadas
        primarySwatch: Colors.green,
        primaryColor: Color(0xFF1B5E20),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF4CAF50),
          brightness: Brightness.light,
        ).copyWith(
          primary: Color(0xFF1B5E20),
          primaryContainer: Color(0xFF4CAF50),
          secondary: Color(0xFF66BB6A),
          secondaryContainer: Color(0xFF81C784),
          tertiary: Color(0xFF2E7D32),
          surface: Colors.white,
          surfaceContainerHighest: Color(0xFFF1F8F4),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Color(0xFF1D1D1D),
          outline: Color(0xFFE0E0E0),
        ),

        // Background geral
        scaffoldBackgroundColor: Color(0xFFF8FBF9),

        // AppBar moderna
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF1B5E20),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
          ),
        ),

        // Cards modernos
        cardTheme: CardThemeData(
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.08),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.white,
          surfaceTintColor: Color(0xFF4CAF50).withOpacity(0.02),
        ),

        // Botões elevados
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF4CAF50),
            foregroundColor: Colors.white,
            shadowColor: Color(0xFF4CAF50).withOpacity(0.3),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),

        // Botões de texto
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Color(0xFF4CAF50),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),

        // Botões delineados
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Color(0xFF4CAF50),
            side: BorderSide(color: Color(0xFF4CAF50), width: 1.5),
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),

        // FAB melhorado
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF4CAF50),
          foregroundColor: Colors.white,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),

        // Campos de entrada modernos
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFFE0E0E0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFFE0E0E0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFF4CAF50), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red, width: 2),
          ),
          labelStyle: TextStyle(color: Color(0xFF616161), fontSize: 16),
          hintStyle: TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
        ),

        // Tipografia melhorada
        textTheme: TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B5E20),
            height: 1.2,
          ),
          displayMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B5E20),
            height: 1.2,
          ),
          headlineLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2E7D32),
            height: 1.3,
          ),
          headlineMedium: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2E7D32),
            height: 1.3,
          ),
          titleLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1D1D1D),
            height: 1.4,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1D1D1D),
            height: 1.4,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: Color(0xFF424242),
            height: 1.5,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: Color(0xFF616161),
            height: 1.5,
          ),
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1D1D1D),
          ),
        ),

        // Lista e tiles
        listTileTheme: ListTileThemeData(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          tileColor: Colors.transparent,
        ),

        // Divisores
        dividerTheme: DividerThemeData(
          color: Color(0xFFE0E0E0),
          thickness: 1,
          space: 1,
        ),

        // Chips
        chipTheme: ChipThemeData(
          backgroundColor: Color(0xFFF1F8F4),
          selectedColor: Color(0xFF4CAF50),
          secondarySelectedColor: Color(0xFF66BB6A),
          labelStyle: TextStyle(color: Color(0xFF2E7D32)),
          secondaryLabelStyle: TextStyle(color: Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 2,
        ),

        // Bottom navigation bar
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFF4CAF50),
          unselectedItemColor: Color(0xFF9E9E9E),
          elevation: 8,
          type: BottomNavigationBarType.fixed,
        ),

        // Configurações de densidade e usabilidade
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,

        // Animações
        pageTransitionsTheme: PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Carregando
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              backgroundColor: Color(0xFFF8FBF9),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF4CAF50)),
                    SizedBox(height: 20),
                    Text(
                      'Carregando Fazenda Santa Fé...',
                      style: TextStyle(
                        color: Color(0xFF2E7D32),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // Se tem usuário logado, vai para home real; senão vai para login
          if (snapshot.hasData) {
            return HomeScreen(); // Esta é a HomeScreen real com todas as funcionalidades
          } else {
            return LoginScreen();
          }
        },
      ),
    );
  }
}

// Widget para mostrar se der erro no Firebase
class FazendaAppError extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fazenda Santa Fé - Erro',
      home: Scaffold(
        backgroundColor: Color(0xFFF8FBF9),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 80,
                  color: Colors.red,
                ),
                SizedBox(height: 20),
                Text(
                  'Erro de Configuração',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Firebase não foi configurado corretamente.\nVerifique as configurações.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Tela de Login
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  String errorMessage = '';

  Future<void> login() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        switch (e.code) {
          case 'user-not-found':
            errorMessage = 'Usuário não encontrado';
            break;
          case 'wrong-password':
            errorMessage = 'Senha incorreta';
            break;
          case 'invalid-email':
            errorMessage = 'Email inválido';
            break;
          case 'user-disabled':
            errorMessage = 'Usuário desabilitado';
            break;
          case 'too-many-requests':
            errorMessage = 'Muitas tentativas. Tente novamente mais tarde';
            break;
          default:
            errorMessage = 'Erro de autenticação: ${e.message}';
        }
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Erro inesperado: ${e.toString()}';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FBF9),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo/Título
              Column(
                children: [
                  Icon(
                    Icons.agriculture,
                    size: 80,
                    color: Color(0xFF4CAF50),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Fazenda Santa Fé',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: Color(0xFF1B5E20),
                        ),
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
                ],
              ),

              SizedBox(height: 48),

              // Campo de Email
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                  hintText: 'usuario@fazenda.com',
                ),
              ),

              SizedBox(height: 20),

              // Campo de Senha
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  prefixIcon: Icon(Icons.lock_outline),
                  hintText: '••••••',
                ),
              ),

              SizedBox(height: 24),

              // Mensagem de erro
              if (errorMessage.isNotEmpty)
                Container(
                  padding: EdgeInsets.all(16),
                  margin: EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 20),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          errorMessage,
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Botão de Login
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : login,
                  child: isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text('ENTRAR'),
                ),
              ),

              SizedBox(height: 32),

              // Informações adicionais
              Text(
                'Entre com suas credenciais de funcionário para acessar o sistema da fazenda.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Color(0xFF9E9E9E),
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
