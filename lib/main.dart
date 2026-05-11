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
        // Fonte Cinzel definida como principal para o app todo
        textTheme: GoogleFonts.cinzelTextTheme(ThemeData.dark().textTheme),
      ),
      home: const InventarioPagina(),
    );
  }
}

class InventarioPagina extends StatefulWidget {
  const InventarioPagina({super.key});
  @override
  State<InventarioPagina> createState() => _InventarioPaginaState();
}

class _InventarioPaginaState extends State<InventarioPagina> {
  final _nomeController = TextEditingController();
  final _quantidadeController = TextEditingController();
  final _precoController = TextEditingController();
  XFile? _imagemSelecionada;
  bool _carregando = false;

  // Selecionar imagem do PC/Dispositivo
  Future<void> _selecionarImagem() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _imagemSelecionada = image);
  }

  // CREATE: Salvar no Banco
  Future<void> _salvar() async {
    if (_nomeController.text.isEmpty) {
      _mostrarMensagem("Dê um nome ao item!", erro: true);
      return;
    }
    setState(() => _carregando = true);

    try {
      String? imageUrl;
      if (_imagemSelecionada != null) {
        final fileBytes = await _imagemSelecionada!.readAsBytes();
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
        final path = 'public/$fileName';
        await supabase.storage.from('fotos_produtos').uploadBinary(path, fileBytes);
        imageUrl = supabase.storage.from('fotos_produtos').getPublicUrl(path);
      }

      await supabase.from('produtos').insert({
        'nome': _nomeController.text,
        'quantidade': int.tryParse(_quantidadeController.text) ?? 0,
        'preco': double.tryParse(_precoController.text) ?? 0.0,
        'imagem_url': imageUrl,
      });

      _limparCampos();
      _mostrarMensagem("Item registrado no arquivo.");
      setState(() {});
    } catch (e) {
      _mostrarMensagem("Erro ao salvar: $e", erro: true);
    } finally {
      setState(() => _carregando = false);
    }
  }

  // UPDATE: Incrementar quantidade (+1)
  Future<void> _incrementar(int id, int qtd) async {
    await supabase.from('produtos').update({'quantidade': qtd + 1}).eq('id', id);
    setState(() {});
  }

  // DELETE: Remover do banco
  Future<void> _deletar(int id) async {
    await supabase.from('produtos').delete().eq('id', id);
    _mostrarMensagem("Item removido.");
    setState(() {});
  }

  void _limparCampos() {
    _nomeController.clear();
    _quantidadeController.clear();
    _precoController.clear();
    _imagemSelecionada = null;
  }

  void _mostrarMensagem(String msg, {bool erro = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: erro ? Colors.red : Colors.grey[900]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Imagem de Fundo (Nítida)
          Positioned.fill(child: Image.asset('assets/images/fundo.png', fit: BoxFit.cover)),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Text("ARQUIVO MÁGICO", style: GoogleFonts.cinzel(fontSize: 28, letterSpacing: 8, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),

                // ÁREA DE INPUTS (Mais visível)
                _buildVidro(
                  margem: 20,
                  filho: Column(
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: _selecionarImagem,
                            child: Container(
                              width: 80, height: 80,
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: _imagemSelecionada == null 
                                ? const Icon(Icons.add_a_photo, color: Colors.white70)
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: kIsWeb 
                                      ? Image.network(_imagemSelecionada!.path, fit: BoxFit.cover)
                                      : Image.file(File(_imagemSelecionada!.path), fit: BoxFit.cover),
                                  ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(child: _buildCampo(_nomeController, "NOME DO ITEM")),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: _buildCampo(_quantidadeController, "ESTOQUE", num: true)),
                          const SizedBox(width: 10),
                          Expanded(child: _buildCampo(_precoController, "PREÇO (G)", num: true)),
                        ],
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))
                          ),
                          onPressed: _carregando ? null : _salvar, 
                          child: _carregando 
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                            : const Text("REGISTRAR NO ARQUIVO"),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // LISTA DE BLOCOS GRANDES
                Expanded(
                  child: FutureBuilder(
                    future: supabase.from('produtos').select().order('created_at', ascending: false),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Colors.white24));
                      final lista = snapshot.data as List;

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: lista.length,
                        itemBuilder: (context, index) {
                          final item = lista[index];
                          final preco = (item['preco'] as num).toDouble();
                          
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child: _buildBlocoItem(item, preco),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Ícone sobre a estrela no canto inferior direito
          Positioned(
            bottom: 25, right: 25,
            child: Icon(Icons.auto_awesome, color: Colors.white.withOpacity(0.3), size: 30),
          ),
        ],
      ),
    );
  }

  // Widget para os blocos grandes da lista
  Widget _buildBlocoItem(Map item, double preco) {
    return _buildVidro(
      margem: 0,
      filho: InkWell(
        onTap: () => _incrementar(item['id'], item['quantidade']),
        child: Row(
          children: [
            // Imagem Grande Lateral
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.black45,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: item['imagem_url'] != null 
                  ? Image.network(item['imagem_url'], fit: BoxFit.cover)
                  : const Icon(Icons.auto_fix_normal, color: Colors.white10, size: 40),
              ),
            ),
            const SizedBox(width: 15),
            // Informações
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['nome'].toString().toUpperCase(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  const SizedBox(height: 5),
                  Text("DISPONÍVEL: ${item['quantidade']}", style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  const SizedBox(height: 10),
                  Text("${preco.toStringAsFixed(2)} GALEÕES", 
                    style: TextStyle(
                      color: preco > 100 ? Colors.greenAccent.withOpacity(0.6) : Colors.redAccent.withOpacity(0.6),
                      fontSize: 14, fontWeight: FontWeight.bold
                    )),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.white38),
              onPressed: () => _deletar(item['id']),
            )
          ],
        ),
      ),
    );
  }

  // Auxiliar para criar o efeito de vidro
  Widget _buildVidro({required Widget filho, required double margem}) {
    return Container(
      margin: EdgeInsets.all(margem),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5), // Mais visível
              border: Border.all(color: Colors.white10),
              borderRadius: BorderRadius.circular(15),
            ),
            child: filho,
          ),
        ),
      ),
    );
  }

  // Auxiliar para os campos de texto
  Widget _buildCampo(TextEditingController controller, String label, {bool num = false}) {
    return TextField(
      controller: controller,
      keyboardType: num ? TextInputType.number : TextInputType.text,
      style: GoogleFonts.cinzel(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.cinzel(color: Colors.white54, fontSize: 12),
        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
      ),
    );
  }
}