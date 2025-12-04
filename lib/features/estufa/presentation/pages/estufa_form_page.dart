import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/estufa.dart';
import '../providers/estufa_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class EstufaFormPage extends StatefulWidget {
  final Estufa? estufa;

  const EstufaFormPage({super.key, this.estufa});

  @override
  State<EstufaFormPage> createState() => _EstufaFormPageState();
}

class _EstufaFormPageState extends State<EstufaFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  late TextEditingController _localizacaoController;
  late TextEditingController _larguraController;
  late TextEditingController _alturaController;
  late TextEditingController _comprimentoController;
  late TextEditingController _volumeTotalController;
  late TextEditingController _firmwareVersaoController;
  String _status = 'ativa';

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.estufa?.nome ?? '');
    _localizacaoController =
        TextEditingController(text: widget.estufa?.localizacao ?? '');
    _larguraController =
        TextEditingController(text: widget.estufa?.largura.toString() ?? '');
    _alturaController =
        TextEditingController(text: widget.estufa?.altura.toString() ?? '');
    _comprimentoController = TextEditingController(
        text: widget.estufa?.comprimento.toString() ?? '');
    _volumeTotalController = TextEditingController(
        text: widget.estufa?.volumeTotal?.toString() ?? '');
    _firmwareVersaoController =
        TextEditingController(text: widget.estufa?.firmwareVersao ?? '');
    _status = widget.estufa?.status ?? 'ativa';

    // Add listeners to calculate volume automatically
    _larguraController.addListener(_calculateVolume);
    _alturaController.addListener(_calculateVolume);
    _comprimentoController.addListener(_calculateVolume);
  }

  void _calculateVolume() {
    final largura = double.tryParse(_larguraController.text);
    final altura = double.tryParse(_alturaController.text);
    final comprimento = double.tryParse(_comprimentoController.text);

    if (largura != null && altura != null && comprimento != null) {
      final volume = largura * altura * comprimento;
      _volumeTotalController.text = volume.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _localizacaoController.dispose();
    _larguraController.dispose();
    _alturaController.dispose();
    _comprimentoController.dispose();
    _volumeTotalController.dispose();
    _firmwareVersaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.estufa != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Estufa' : 'Nova Estufa'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _localizacaoController,
                decoration: const InputDecoration(labelText: 'Localização'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _larguraController,
                      decoration:
                          const InputDecoration(labelText: 'Largura (m)'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Obrigatório';
                        if (double.tryParse(value) == null) return 'Inválido';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _alturaController,
                      decoration:
                          const InputDecoration(labelText: 'Altura (m)'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Obrigatório';
                        if (double.tryParse(value) == null) return 'Inválido';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _comprimentoController,
                      decoration:
                          const InputDecoration(labelText: 'Comprimento (m)'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Obrigatório';
                        if (double.tryParse(value) == null) return 'Inválido';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _volumeTotalController,
                decoration: const InputDecoration(
                  labelText: 'Volume Total (m³)',
                  suffixIcon: Icon(Icons.calculate),
                ),
                keyboardType: TextInputType.number,
                readOnly: true,
                enabled: false,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: ['ativa', 'inativa', 'manutencao'].map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _status = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _firmwareVersaoController,
                decoration:
                    const InputDecoration(labelText: 'Versão do Firmware'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final data = {
                      'nome': _nomeController.text,
                      'localizacao': _localizacaoController.text,
                      'largura': double.parse(_larguraController.text),
                      'altura': double.parse(_alturaController.text),
                      'comprimento': double.parse(_comprimentoController.text),
                      'volume_total':
                          double.tryParse(_volumeTotalController.text),
                      'status': _status,
                      'firmware_versao': _firmwareVersaoController.text,
                    };

                    final provider = context.read<EstufaProvider>();
                    final token = context.read<AuthProvider>().token;
                    if (token == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Sessão expirada. Faça login novamente.')),
                      );
                      return;
                    }
                    bool success;
                    if (isEditing) {
                      success = await provider.updateEstufa(
                          widget.estufa!.id, data, token);
                    } else {
                      success = await provider.createEstufa(data, token);
                    }

                    if (success && mounted) {
                      Navigator.pop(context);
                    } else if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(provider.error ?? 'Erro ao salvar')),
                      );
                    }
                  }
                },
                child: Text(isEditing ? 'Salvar Alterações' : 'Criar Estufa'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
