import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

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
      // Persistência: Se já estiver logado, vai direto pro Inventário
      home: supabase.auth.currentSession != null ? const InventarioPagina() : const LoginPage(),
    );
  }
}

// --- TRATAMENTO DE ERROS AMIGÁVEL ---
void mostrarErro(BuildContext context, Object e) {
  String mensagem = "Ocorreu um erro místico. Tente novamente.";
  if (e is AuthException) {
    mensagem = e.message;
    if (e.message.contains("Invalid login credentials")) mensagem = "E-mail ou senha incorretos.";
  }
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(mensagem),
    backgroundColor: Colors.redAccent.withOpacity(0.8),
    behavior: SnackBarBehavior.floating,
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
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const InventarioPagina()));
    } catch (e) { mostrarErro(context, e); }
    finally { if (mounted) setState(() => _carregando = false); }
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
                  _buildGlassBlock(
                    width: 340,
                    child: Column(
                      children: [
                        const Text("IDENTIFICAÇÃO", style: TextStyle(fontSize: 10, letterSpacing: 4, color: Colors.white54)),
                        const SizedBox(height: 20),
                        _buildInput(_email, "CORREIO ELETRÔNICO"),
                        _buildInput(_senha, "CHAVE SECRETA", obscure: true),
                        const SizedBox(height: 30),
                        _buildBotao("ACESSAR CASTELO", _entrar, carregando: _carregando),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
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

// --- TELA DE CADASTRO ---
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Acesso solicitado! Faça seu login.")));
      Navigator.pop(context);
    } catch (e) { mostrarErro(context, e); }
    finally { if (mounted) setState(() => _carregando = false); }
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
                  _buildGlassBlock(
                    width: 340,
                    child: Column(
                      children: [
                        const Text("NOVO REGISTRO", style: TextStyle(fontSize: 10, letterSpacing: 4, color: Colors.white54)),
                        const SizedBox(height: 20),
                        _buildInput(_email, "E-MAIL"),
                        _buildInput(_senha, "SENHA", obscure: true),
                        const SizedBox(height: 30),
                        _buildBotao("SOLICITAR ENTRADA", _registrar, carregando: _carregando, secundario: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
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

// --- TELA DE INVENTÁRIO ---
class InventarioPagina extends StatefulWidget {
  const InventarioPagina({super.key});
  @override
  State<InventarioPagina> createState() => _InventarioPaginaState();
}

class _InventarioPaginaState extends State<InventarioPagina> {
  final _nomeC = TextEditingController();
  final _qtdC = TextEditingController();
  final _precoC = TextEditingController();
  XFile? _imagem;
  bool _carregando = false;

  Future<void> _pickImg() async {
    final img = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (img != null) setState(() => _imagem = img);
  }

  Future<void> _salvar() async {
    if (_nomeC.text.isEmpty) return;
    setState(() => _carregando = true);
    try {
      String? url;
      if (_imagem != null) {
        final bytes = await _imagem!.readAsBytes();
        final path = 'public/${DateTime.now().millisecondsSinceEpoch}.png';
        await supabase.storage.from('fotos_produtos').uploadBinary(path, bytes);
        url = supabase.storage.from('fotos_produtos').getPublicUrl(path);
      }
      await supabase.from('produtos').insert({
        'nome': _nomeC.text,
        'quantidade': int.tryParse(_qtdC.text) ?? 0,
        'preco': double.tryParse(_precoC.text) ?? 0.0,
        'imagem_url': url,
      });
      _nomeC.clear(); _qtdC.clear(); _precoC.clear();
      setState(() => _imagem = null);
    } finally { setState(() => _carregando = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text("ARQUIVO INTERNO", style: GoogleFonts.cinzel(fontSize: 14, letterSpacing: 4)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () async {
              await supabase.auth.signOut();
              if (!mounted) return;
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
            },
            icon: const Icon(Icons.logout, size: 18),
          )
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset('assets/images/fundo.png', fit: BoxFit.cover)),
          Container(color: Colors.black.withOpacity(0.5)),
          SafeArea(
            child: Column(
              children: [
                _buildGlassBlock(
                  margem: 20,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: _pickImg,
                            child: Container(
                              width: 70, height: 70,
                              decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(8)),
                              child: _imagem == null 
                                ? const Icon(Icons.add_a_photo_outlined, color: Colors.white24)
                                : ClipRRect(borderRadius: BorderRadius.circular(8), child: kIsWeb ? Image.network(_imagem!.path, fit: BoxFit.cover) : Image.file(File(_imagem!.path), fit: BoxFit.cover)),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(child: _buildInput(_nomeC, "NOME DO ITEM")),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(child: _buildInput(_qtdC, "QTD", obscure: false)),
                          const SizedBox(width: 10),
                          Expanded(child: _buildInput(_precoC, "PREÇO", obscure: false)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _buildBotao("ADICIONAR", _salvar, carregando: _carregando)
                    ],
                  ),
                ),
                Expanded(
                  child: FutureBuilder(
                    future: supabase.from('produtos').select().order('created_at', ascending: false),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const SizedBox();
                      final lista = snapshot.data as List;
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: lista.length,
                        itemBuilder: (context, index) {
                          final item = lista[index];
                          final double preco = (item['preco'] as num).toDouble();
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildGlassBlock(
                              padding: EdgeInsets.all(10),
                              child: ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: item['imagem_url'] != null ? Image.network(item['imagem_url'], width: 60, height: 60, fit: BoxFit.cover) : Container(width: 60, height: 60, color: Colors.white10),
                                ),
                                title: Text(item['nome'].toString().toUpperCase(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                subtitle: Text("ESTOQUE: ${item['quantidade']}", style: const TextStyle(fontSize: 11, color: Colors.white38)),
                                trailing: Text("${preco.toStringAsFixed(2)} G", style: TextStyle(color: preco > 100 ? Colors.greenAccent.withOpacity(0.5) : Colors.redAccent.withOpacity(0.5), fontWeight: FontWeight.bold)),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Positioned(bottom: 25, right: 25, child: Icon(Icons.auto_awesome, color: Colors.white.withOpacity(0.2), size: 30)),
        ],
      ),
    );
  }
}

// --- COMPONENTES ---

Widget _buildGlassBlock({required Widget child, double? width, EdgeInsets? padding, double margem = 0}) {
  return Container(
    margin: EdgeInsets.all(margem),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: width,
          padding: padding ?? const EdgeInsets.all(25),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.04), border: Border.all(color: Colors.white.withOpacity(0.08))),
          child: child,
        ),
      ),
    ),
  );
}

Widget _buildInput(TextEditingController controller, String label, {bool obscure = false}) {
  return TextField(
    controller: controller,
    obscureText: obscure,
    style: const TextStyle(fontSize: 13),
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
      style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white24), padding: const EdgeInsets.symmetric(vertical: 15)),
      child: carregando ? const SizedBox(height: 15, width: 15, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text(texto, style: const TextStyle(color: Colors.white, fontSize: 10, letterSpacing: 2)),
    ),
  );
}