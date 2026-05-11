import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://hfgkvqrnqowxjdyfaksj.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhmZ2t2cXJucW93eGpkeWZha3NqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg0NjMxNzYsImV4cCI6MjA5NDAzOTE3Nn0.SDgxyimDkyJX89EusHDAHYCR06QeK2Y0hXm_sNRdMYo',
  );
  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        textTheme: GoogleFonts.cinzelTextTheme(ThemeData.dark().textTheme),
      ),
      home: supabase.auth.currentSession != null ? const InventarioPagina() : const LoginPage(),
    );
  }
}

// --- FUNÇÃO AUXILIAR DE ERROS ---
void mostrarErro(BuildContext context, Object e) {
  // Isso vai nos mostrar o erro REAL que o Supabase está enviando
  String mensagem = e.toString(); 
  
  if (e is AuthException) {
    mensagem = e.message; // Pega a mensagem técnica do Supabase
  }

  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text("DEBUG: $mensagem"), 
    backgroundColor: Colors.redAccent,
  ));
}

// --- TELA DE LOGIN ---
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController();
  final _senha = TextEditingController();
  bool _carregando = false;

  Future<void> _entrar() async {
    setState(() => _carregando = true);
    try {
      await supabase.auth.signInWithPassword(email: _email.text.trim(), password: _senha.text.trim());
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const InventarioPagina()));
    } catch (e) { mostrarErro(context, e); }
    finally { setState(() => _carregando = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset('assets/images/floresta.png', fit: BoxFit.cover)),
          Container(color: Colors.black.withOpacity(0.7)),
          
          Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text("THE ARCHIVE", style: GoogleFonts.cinzel(fontSize: 32, letterSpacing: 10, color: Colors.white70)),
                  const SizedBox(height: 40),

                  // CARD PRINCIPAL DE LOGIN
                  _buildGlassBlock(
                    width: 340,
                    child: Column(
                      children: [
                        Text("IDENTIFICAÇÃO", style: TextStyle(fontSize: 12, letterSpacing: 4, color: Colors.white54)),
                        const SizedBox(height: 20),
                        _buildInput(_email, "CORREIO ELETRÔNICO"),
                        _buildInput(_senha, "CHAVE SECRETA", obscure: true),
                        const SizedBox(height: 30),
                        _buildBotao("ACESSAR CASTELO", _entrar, carregando: _carregando),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  // MINI BLOCO SEPARADO (ESTILO QUE VOCÊ PEDIU)
                  _buildGlassBlock(
                    width: 340,
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Novo bruxo?", style: TextStyle(fontSize: 12, color: Colors.white38)),
                        TextButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterPage())),
                          child: const Text("CRIAR CONTA", style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- TELA DE CADASTRO (PÁGINA DIFERENTE) ---
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _email = TextEditingController();
  final _senha = TextEditingController();
  bool _carregando = false;

  Future<void> _registrar() async {
    setState(() => _carregando = true);
    try {
      await supabase.auth.signUp(email: _email.text.trim(), password: _senha.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Acesso solicitado! Faça seu login.")));
        Navigator.pop(context);
      }
    } catch (e) { mostrarErro(context, e); }
    finally { setState(() => _carregando = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset('assets/images/floresta.png', fit: BoxFit.cover)),
          Container(color: Colors.black.withOpacity(0.7)),
          
          Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // CARD PRINCIPAL DE CADASTRO
                  _buildGlassBlock(
                    width: 340,
                    child: Column(
                      children: [
                        Text("NOVO REGISTRO", style: TextStyle(fontSize: 12, letterSpacing: 4, color: Colors.white54)),
                        const SizedBox(height: 20),
                        _buildInput(_email, "E-MAIL"),
                        _buildInput(_senha, "SENHA", obscure: true),
                        const SizedBox(height: 30),
                        _buildBotao("SOLICITAR ENTRADA", _registrar, carregando: _carregando, secundario: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  // MINI BLOCO PARA VOLTAR
                  _buildGlassBlock(
                    width: 340,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("JÁ SOU MEMBRO. VOLTAR.", style: TextStyle(fontSize: 10, color: Colors.white38, letterSpacing: 2)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- TELA DE INVENTÁRIO (DENTRO DO CASTELO) ---
class InventarioPagina extends StatefulWidget {
  const InventarioPagina({super.key});
  @override
  State<InventarioPagina> createState() => _InventarioPaginaState();
}

class _InventarioPaginaState extends State<InventarioPagina> {
  // ... (Coloque aqui o seu código de produtos que já fizemos)
  // Certifique-se de usar a imagem 'assets/images/fundo.png' no fundo aqui.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ARQUIVO INTERNO", style: GoogleFonts.cinzel(fontSize: 14, letterSpacing: 4)),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: () async {
              await supabase.auth.signOut();
              if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
            },
            icon: const Icon(Icons.logout, size: 18),
          )
        ],
      ),
      body: Container() // Aqui entra seu código da lista de blocos grandes
    );
  }
}

// --- WIDGETS DE ESTILO COMPARTILHADO ---

Widget _buildGlassBlock({required Widget child, double? width, EdgeInsets? padding}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(15),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
      child: Container(
        width: width,
        padding: padding ?? const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: child,
      ),
    ),
  );
}

Widget _buildInput(TextEditingController controller, String label, {bool obscure = false}) {
  return TextField(
    controller: controller,
    obscureText: obscure,
    style: const TextStyle(fontSize: 13, color: Colors.white),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white24, fontSize: 10, letterSpacing: 2),
      enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
      focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
    ),
  );
}

Widget _buildBotao(String texto, VoidCallback acao, {bool carregando = false, bool secundario = false}) {
  return SizedBox(
    width: double.infinity,
    child: OutlinedButton(
      onPressed: carregando ? null : acao,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: secundario ? Colors.white12 : Colors.white24),
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
      child: carregando 
        ? const SizedBox(height: 15, width: 15, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
        : Text(texto, style: const TextStyle(color: Colors.white, fontSize: 11, letterSpacing: 3)),
    ),
  );
}