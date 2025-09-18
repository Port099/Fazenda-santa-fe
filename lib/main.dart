import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart'; // Este arquivo será gerado automaticamente
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

void main() async {
  // Necessário para inicializar o Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(FazendaApp());
}

class FazendaApp extends StatelessWidget {
  const FazendaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Santa Fé",
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
                child: CircularProgressIndicator(
                  color: Color(0xFF4CAF50),
                ),
              ),
            );
          }

          // Se tem usuário logado, vai para home; senão vai para login
          if (snapshot.hasData) {
            return HomeScreen();
          } else {
            return LoginScreen();
          }
        },
      ),
    );
  }
}
