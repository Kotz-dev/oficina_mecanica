import 'package:flutter/material.dart';

void main() => runApp(const OficinaApp());

/// Modelo do registro da oficina.
class Registro {
  String veiculo;
  String placa;
  String servico;

  Registro({required this.veiculo, required this.placa, required this.servico});
}

class OficinaApp extends StatelessWidget {
  const OficinaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Oficina Mecânica',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      home: const ListaPage(),
    );
  }
}

/// Tela de listagem (lista em memória).
class ListaPage extends StatefulWidget {
  const ListaPage({super.key});

  @override
  State<ListaPage> createState() => _ListaPageState();
}

class _ListaPageState extends State<ListaPage> {
  final List<Registro> _registros = [];

  Future<void> _abrirFormulario({Registro? registro}) async {
    final resultado = await Navigator.push<Registro>(
      context,
      MaterialPageRoute(builder: (_) => FormularioPage(registro: registro)),
    );
    if (resultado == null) return;

    setState(() {
      if (registro == null) {
        _registros.add(resultado); // novo cadastro
      } else {
        // edição: altera o mesmo objeto, sem criar duplicata
        registro.veiculo = resultado.veiculo;
        registro.placa = resultado.placa;
        registro.servico = resultado.servico;
      }
    });
  }

  void _excluir(Registro registro) {
    setState(() => _registros.remove(registro));
  }

  Future<void> _confirmarExclusao(Registro registro) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir registro'),
        content: Text('Deseja remover "${registro.veiculo}" da lista?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmar == true) _excluir(registro);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Oficina Mecânica'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _registros.isEmpty
          ? const Center(child: Text('Nenhum registro cadastrado.'))
          : ListView.builder(
              itemCount: _registros.length,
              itemBuilder: (context, index) {
                final r = _registros[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: const Icon(Icons.directions_car),
                    title: Text(
                      r.veiculo,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Placa: ${r.placa}\nServiço: ${r.servico}'),
                    isThreeLine: true,
                    onTap: () => _abrirFormulario(registro: r),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      tooltip: 'Excluir',
                      onPressed: () => _confirmarExclusao(r),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(),
        icon: const Icon(Icons.add),
        label: const Text('Novo registro'),
      ),
    );
  }
}

/// Tela de formulário (cadastro e edição).
class FormularioPage extends StatefulWidget {
  final Registro? registro;

  const FormularioPage({super.key, this.registro});

  @override
  State<FormularioPage> createState() => _FormularioPageState();
}

class _FormularioPageState extends State<FormularioPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _veiculoCtrl;
  late final TextEditingController _placaCtrl;
  late final TextEditingController _servicoCtrl;

  bool get _editando => widget.registro != null;

  @override
  void initState() {
    super.initState();
    _veiculoCtrl = TextEditingController(text: widget.registro?.veiculo ?? '');
    _placaCtrl = TextEditingController(text: widget.registro?.placa ?? '');
    _servicoCtrl = TextEditingController(text: widget.registro?.servico ?? '');
  }

  @override
  void dispose() {
    _veiculoCtrl.dispose();
    _placaCtrl.dispose();
    _servicoCtrl.dispose();
    super.dispose();
  }

  String? _validar(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Campo obrigatório';
    }
    return null;
  }

  void _salvar() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      Registro(
        veiculo: _veiculoCtrl.text.trim(),
        placa: _placaCtrl.text.trim(),
        servico: _servicoCtrl.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editando ? 'Editar registro' : 'Novo registro'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _veiculoCtrl,
                decoration: const InputDecoration(
                  labelText: 'Veículo',
                  border: OutlineInputBorder(),
                ),
                validator: _validar,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _placaCtrl,
                decoration: const InputDecoration(
                  labelText: 'Placa',
                  border: OutlineInputBorder(),
                ),
                validator: _validar,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _servicoCtrl,
                decoration: const InputDecoration(
                  labelText: 'Serviço',
                  border: OutlineInputBorder(),
                ),
                validator: _validar,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _salvar,
                icon: const Icon(Icons.save),
                label: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
